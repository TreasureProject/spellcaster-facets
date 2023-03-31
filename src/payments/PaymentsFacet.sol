// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165Upgradeable } from "@openzeppelin/contracts-diamond/utils/introspection/IERC165Upgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/utils/SafeERC20Upgradeable.sol";
import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-diamond/security/ReentrancyGuardUpgradeable.sol";
import { UD60x18, ud, convert } from "@prb/math/UD60x18.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { FacetInitializable } from "src/utils/FacetInitializable.sol";
import { Modifiers } from "src/Modifiers.sol";

import { IPayments, ERC20Info, PriceType } from "src/interfaces/IPayments.sol";
import { IPaymentsReceiver } from "src/interfaces/IPaymentsReceiver.sol";

import { LibUtilities } from "src/libraries/LibUtilities.sol";
import { ADMIN_ROLE } from "src/libraries/LibAccessControlRoles.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { LibPayments } from "src/libraries/LibPayments.sol";
import { PaymentsStorage } from "src/payments/PaymentsStorage.sol";

/**
 * @title Payments Facet contract.
 * @dev This facet exposes functionality to easily allow users to accept payments in ERC20 tokens or gas tokens (ETH, MATIC, etc.)
 *      Users can also pay in a token amount priced in USD, other ERC20, or gas tokens.
 */
contract PaymentsFacet is ReentrancyGuardUpgradeable, FacetInitializable, Modifiers, IPayments {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using AddressUpgradeable for address payable;

    /**
     * @dev Initialize the facet. Can be called externally or internally.
     * Ideally referenced in an initialization script facet
     */
    function PaymentsFacet_init(
        address _gasTokenUSDPriceFeed,
        address _magicAddress
    ) public facetInitializer(keccak256("PaymentsFacet")) {
        LibPayments.setGasTokenUSDPriceFeed(_gasTokenUSDPriceFeed);
        LibPayments.setMagicAddress(_magicAddress);
    }

    /**
     * @inheritdoc IPayments
     */
    function makeStaticERC20Payment(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmount
    ) external nonReentrant onlyReceiver(_recipient) {
        _sendERC20(_recipient, _paymentERC20, _paymentAmount, _paymentAmount, PriceType.STATIC, address(0));
    }

    /**
     * @inheritdoc IPayments
     */
    function makeStaticGasTokenPayment(
        address _recipient,
        uint256 _paymentAmount
    ) external payable nonReentrant onlyReceiver(_recipient) {
        _sendGasToken(_recipient, _paymentAmount, _paymentAmount, PriceType.STATIC, address(0));
    }

    /**
     * @inheritdoc IPayments
     */
    function makeERC20PaymentByPriceType(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) external nonReentrant onlyReceiver(_recipient) {
        if (
            _priceType == PriceType.STATIC || (_priceType == PriceType.PRICED_IN_ERC20 && _pricedERC20 == _paymentERC20)
        ) {
            _sendERC20(
                _recipient,
                _paymentERC20,
                _paymentAmountInPricedToken,
                _paymentAmountInPricedToken,
                PriceType.STATIC,
                address(0)
            );
            return;
        }
        ERC20Info storage _baseInfo = LibPayments.getERC20Info(_paymentERC20);
        AggregatorV3Interface priceFeed;

        if (_priceType == PriceType.PRICED_IN_USD) {
            priceFeed = _baseInfo.usdAggregator;
        } else if (_priceType == PriceType.PRICED_IN_ERC20) {
            priceFeed = _baseInfo.priceFeeds[_pricedERC20];
        } else if (_priceType == PriceType.PRICED_IN_GAS_TOKEN) {
            priceFeed = _baseInfo.pricedInGasTokenAggregator;
        } else {
            revert PaymentsStorage.InvalidPriceType();
        }
        if (address(priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(_paymentERC20, _priceType, _pricedERC20);
        }

        uint256 price = _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, priceFeed, _baseInfo.decimals);

        _sendERC20(_recipient, _paymentERC20, price, _paymentAmountInPricedToken, _priceType, _pricedERC20);
    }

    /**
     * @inheritdoc IPayments
     */
    function makeGasTokenPaymentByPriceType(
        address _recipient,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) external payable nonReentrant onlyReceiver(_recipient) {
        if (_priceType == PriceType.STATIC || _priceType == PriceType.PRICED_IN_GAS_TOKEN) {
            if (msg.value != _paymentAmountInPricedToken) {
                revert PaymentsStorage.IncorrectPaymentAmount();
            }
            _sendGasToken(
                _recipient, _paymentAmountInPricedToken, _paymentAmountInPricedToken, PriceType.STATIC, address(0)
            );
            return;
        }
        AggregatorV3Interface priceFeed;

        if (_priceType == PriceType.PRICED_IN_USD) {
            priceFeed = LibPayments.getGasTokenUSDPriceFeed();
        } else if (_priceType == PriceType.PRICED_IN_ERC20) {
            priceFeed = LibPayments.getGasTokenERC20PriceFeed(_pricedERC20);
        } else {
            revert PaymentsStorage.InvalidPriceType();
        }
        if (address(priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(address(0), _priceType, _pricedERC20);
        }

        uint256 price = _pricedTokenToPaymentAmount(
            _paymentAmountInPricedToken,
            priceFeed,
            18 // GasToken assumed to have 18 decimals (ETH, MATIC, etc.)
        );

        _sendGasToken(_recipient, price, _paymentAmountInPricedToken, _priceType, _pricedERC20);
    }

    /**
     * @inheritdoc IPayments
     */
    function initializeERC20(
        address _erc20,
        uint8 _decimals,
        address _pricedInGasTokenAggregator,
        address _usdAggregator,
        address[] calldata _pricedERC20s,
        address[] calldata _priceFeeds
    ) external onlyRole(ADMIN_ROLE) {
        uint256 numQuotes = _pricedERC20s.length;
        LibUtilities.requireArrayLengthMatch(numQuotes, _priceFeeds.length);
        ERC20Info storage info = LibPayments.getERC20Info(_erc20);
        info.decimals = _decimals;
        info.pricedInGasTokenAggregator = AggregatorV3Interface(_pricedInGasTokenAggregator);
        info.usdAggregator = AggregatorV3Interface(_usdAggregator);
        for (uint256 i = 0; i < numQuotes; i++) {
            info.priceFeeds[_pricedERC20s[i]] = AggregatorV3Interface(_priceFeeds[i]);
        }
    }

    /**
     * @inheritdoc IPayments
     */
    function setERC20PriceFeedForERC20(
        address _erc20,
        address _pricedERC20,
        address _priceFeed
    ) external onlyRole(ADMIN_ROLE) {
        ERC20Info storage info = LibPayments.getERC20Info(_erc20);
        info.priceFeeds[_pricedERC20] = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @inheritdoc IPayments
     */
    function setERC20PriceFeedForGasToken(address _pricedERC20, address _priceFeed) external onlyRole(ADMIN_ROLE) {
        LibPayments.setGasTokenERC20PriceFeed(_pricedERC20, _priceFeed);
    }

    /**
     * @inheritdoc IPayments
     */
    function getMagicAddress() external view override returns (address magicAddress_) {
        magicAddress_ = LibPayments.getMagicAddress();
    }

    /**
     * @inheritdoc IPayments
     */
    function isValidPriceType(
        address _paymentToken,
        PriceType _priceType,
        address _pricedERC20
    ) external view override returns (bool supported_) {
        if (
            _priceType == PriceType.STATIC || (_priceType == PriceType.PRICED_IN_ERC20 && _pricedERC20 == _paymentToken)
                || (_priceType == PriceType.PRICED_IN_GAS_TOKEN && _paymentToken == address(0))
        ) {
            return true;
        }
        AggregatorV3Interface priceFeed = _getPriceFeed(_paymentToken, _pricedERC20, _priceType);
        return address(priceFeed) != address(0);
    }

    /**
     * @inheritdoc IPayments
     */
    function calculatePaymentAmountByPriceType(
        address _paymentToken,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedToken
    ) external view override returns (uint256 paymentAmount_) {
        if (
            _priceType == PriceType.STATIC || (_priceType == PriceType.PRICED_IN_ERC20 && _pricedToken == _paymentToken)
                || (_priceType == PriceType.PRICED_IN_GAS_TOKEN && _paymentToken == address(0))
        ) {
            return _paymentAmountInPricedToken;
        }
        AggregatorV3Interface priceFeed = _getPriceFeed(_paymentToken, _pricedToken, _priceType);
        if (address(priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(_paymentToken, _priceType, _pricedToken);
        }
        // GasToken conversion, assume 18 decimals
        if (_paymentToken == address(0)) {
            paymentAmount_ = _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, priceFeed, 18);
        } else {
            ERC20Info storage _baseInfo = LibPayments.getERC20Info(_paymentToken);
            paymentAmount_ = _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, priceFeed, _baseInfo.decimals);
        }
    }

    /**
     * @dev Sends payment and invokes the acceptance function on the recipient
     */
    function _sendERC20(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) internal {
        IERC20Upgradeable(_paymentERC20).safeTransferFrom(LibMeta._msgSender(), _recipient, _paymentAmount);
        IPaymentsReceiver(_recipient).acceptERC20(
            LibMeta._msgSender(), _paymentERC20, _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20
        );
        emit PaymentSent(LibMeta._msgSender(), _paymentERC20, _paymentAmount, _recipient);
    }

    /**
     * @dev Sends gas token payment and invokes the acceptance function on the recipient
     */
    function _sendGasToken(
        address _recipient,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) internal {
        if (msg.value < _paymentAmount) {
            revert PaymentsStorage.IncorrectPaymentAmount();
        }
        uint256 _overpayment;
        if (msg.value > _paymentAmount) {
            _overpayment = msg.value - _paymentAmount;
        }
        IPaymentsReceiver(_recipient).acceptGasToken{value: _paymentAmount}(
            LibMeta._msgSender(), _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20
        );
        // Send back overpayments
        if (_overpayment > 0) {
            payable(LibMeta._msgSender()).sendValue(_overpayment);
        }
        emit PaymentSent(LibMeta._msgSender(), address(0), _paymentAmount, _recipient);
    }

    function _getPriceFeed(
        address _paymentToken,
        address _pricedToken,
        PriceType _priceType
    ) internal view returns (AggregatorV3Interface priceFeed_) {
        bool _baseIsGasToken = _paymentToken == address(0);
        if (_priceType == PriceType.PRICED_IN_USD) {
            priceFeed_ = _baseIsGasToken
                ? LibPayments.getGasTokenUSDPriceFeed()
                : LibPayments.getERC20Info(_paymentToken).usdAggregator;
        } else if (_priceType == PriceType.PRICED_IN_ERC20) {
            priceFeed_ = _baseIsGasToken
                ? LibPayments.getGasTokenERC20PriceFeed(_pricedToken)
                : LibPayments.getERC20Info(_paymentToken).priceFeeds[_pricedToken];
        } else if (_priceType == PriceType.PRICED_IN_GAS_TOKEN) {
            priceFeed_ = LibPayments.getERC20Info(_paymentToken).pricedInGasTokenAggregator;
        } else {
            priceFeed_ = AggregatorV3Interface(address(0));
        }
    }

    /**
     * @dev returns the given price in the given decimal format after converting the price into the related value from the price feed
     * @param _paymentAmountInPricedToken The price to convert to the value from the given price feed
     * @param _priceFeed The price feed to use to convert the price
     * @param _paymentDecimals The number of decimals to format the price as
     * @return paymentAmount_ The price in the given decimal format
     */
    function _pricedTokenToPaymentAmount(
        uint256 _paymentAmountInPricedToken,
        AggregatorV3Interface _priceFeed,
        uint8 _paymentDecimals
    ) internal view returns (uint256 paymentAmount_) {
        //  Because fixed precision is e18, value will be 5494505494505494505 and needs to be converted to payment token decimal
        // NOTE: It is assumed that the  _paymentAmountInPricedToken and the price feed's price are in the same decimal unit
        UD60x18 _priceFP = ud(_paymentAmountInPricedToken).div(ud(uint256(_getQuotePrice(_priceFeed))));
        // Lastly, we must convert the price into the payment token's decimal amount
        if (_paymentDecimals > 18) {
            // Add digits equal to the difference of fp's 18 decimals and the payment token's decimals
            paymentAmount_ = _priceFP.unwrap() * 10 ** (_paymentDecimals - 18);
        } else {
            // Remove digits equal to the difference of fp's 18 decimals and the payment token's decimals
            paymentAmount_ = _priceFP.unwrap() / 10 ** (18 - _paymentDecimals);
        }
    }

    /**
     * @dev returns the current relative value of the given price feed
     * @param _priceFeed The price feed to get the price of
     * @return price_ The current relative price of the given price feed
     */
    function _getQuotePrice(AggregatorV3Interface _priceFeed) internal view returns (uint256 price_) {
        (, int256 _quotePrice,,,) = _priceFeed.latestRoundData();
        // Unfortunately no way to determine this ahead of time, and likely will never occur, but is a possibility of the oracle
        if (_quotePrice < 0) {
            revert PaymentsStorage.InvalidPriceFeedQuote(address(_priceFeed), address(0));
        }
        price_ = uint256(_quotePrice);
    }

    modifier onlyReceiver(address _recipient) {
        if (!_recipient.isContract()) {
            revert PaymentsStorage.NonPaymentsReceiverRecipient(_recipient);
        }
        try IERC165Upgradeable(_recipient).supportsInterface(type(IPaymentsReceiver).interfaceId) returns (
            bool isSupported_
        ) {
            if (!isSupported_) {
                revert PaymentsStorage.NonPaymentsReceiverRecipient(_recipient);
            }
        } catch (bytes memory) {
            revert PaymentsStorage.NonPaymentsReceiverRecipient(_recipient);
        }

        _;
    }
}
