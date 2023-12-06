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
import { IPaymentsReceiverV2 } from "src/interfaces/IPaymentsReceiverV2.sol";

import { LibUtilities } from "src/libraries/LibUtilities.sol";
import { ADMIN_ROLE } from "src/libraries/LibAccessControlRoles.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { LibPayments } from "src/libraries/LibPayments.sol";
import { PaymentsStorage } from "src/payments/PaymentsStorage.sol";

/**
 * @title Payments Facet Base contract.
 * @dev This facet exposes shared functionality to accept payments in ERC20 tokens or gas tokens (ETH, MATIC, etc.)
 */
abstract contract PaymentsBase is ReentrancyGuardUpgradeable, FacetInitializable, Modifiers, IPayments {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using AddressUpgradeable for address payable;

    /**
     * @dev Initialize the facet. Can be called externally or internally.
     * Ideally referenced in an initialization script facet
     */
    function __PaymentsBase_init(address _gasTokenUSDPriceFeed, address _magicAddress) internal onlyFacetInitializing {
        LibPayments.setGasTokenUSDPriceFeed(_gasTokenUSDPriceFeed);
        LibPayments.setMagicAddress(_magicAddress);
    }

    // abstract function hooks for derived contracts

    function _acceptERC20WithData(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes memory _data
    ) internal virtual;

    function _acceptERC20(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) internal virtual;

    function _acceptGasTokenWithData(
        address _recipient,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes memory _data
    ) internal virtual;

    function _acceptGasToken(
        address _recipient,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) internal virtual;

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
        uint256 _numQuotes = _pricedERC20s.length;
        LibUtilities.requireArrayLengthMatch(_numQuotes, _priceFeeds.length);
        ERC20Info storage _info = LibPayments.getERC20Info(_erc20);
        _info.decimals = _decimals;
        _info.pricedInGasTokenAggregator = AggregatorV3Interface(_pricedInGasTokenAggregator);
        _info.usdAggregator = AggregatorV3Interface(_usdAggregator);
        for (uint256 i = 0; i < _numQuotes; i++) {
            _info.priceFeeds[_pricedERC20s[i]] = AggregatorV3Interface(_priceFeeds[i]);
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
        ERC20Info storage _info = LibPayments.getERC20Info(_erc20);
        _info.priceFeeds[_pricedERC20] = AggregatorV3Interface(_priceFeed);
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
        AggregatorV3Interface _priceFeed = _getPriceFeed(_paymentToken, _pricedERC20, _priceType);
        return address(_priceFeed) != address(0);
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
        AggregatorV3Interface _priceFeed = _getPriceFeed(_paymentToken, _pricedToken, _priceType);
        if (address(_priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(_paymentToken, _priceType, _pricedToken);
        }
        // GasToken conversion, assume 18 decimals
        if (_paymentToken == address(0)) {
            paymentAmount_ = _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, _priceFeed, 18);
        } else {
            ERC20Info storage _baseInfo = LibPayments.getERC20Info(_paymentToken);
            paymentAmount_ = _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, _priceFeed, _baseInfo.decimals);
        }
    }

    /**
     * @inheritdoc IPayments
     */
    function calculateUsdPaymentAmountByPricedToken(
        address _usdToken,
        uint256 _paymentAmountInPricedToken,
        address _pricedERC20
    ) external view override returns (uint256 paymentAmount_) {
        if (_usdToken != LibPayments.getUsdcAddress() && _usdToken != LibPayments.getUsdtAddress()) {
            revert PaymentsStorage.InvalidUsdToken(_usdToken);
        }
        ERC20Info storage _quoteInfo = LibPayments.getERC20Info(_pricedERC20);
        AggregatorV3Interface _priceFeed = _quoteInfo.usdAggregator;
        if (address(_priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(_pricedERC20, PriceType.PRICED_IN_USD, address(0));
        }
        paymentAmount_ =
            _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, _priceFeed, _quoteInfo.decimals, false);
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
        address _pricedERC20,
        bytes memory _data
    ) internal {
        IERC20Upgradeable(_paymentERC20).safeTransferFrom(LibMeta._msgSender(), _recipient, _paymentAmount);
        if (_data.length > 0) {
            _acceptERC20WithData(
                _recipient, _paymentERC20, _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data
            );
        } else {
            _acceptERC20(
                _recipient, _paymentERC20, _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20
            );
        }
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
        address _pricedERC20,
        bytes memory _data
    ) internal {
        if (msg.value < _paymentAmount) {
            revert PaymentsStorage.IncorrectPaymentAmount();
        }
        uint256 _overpayment;
        if (msg.value > _paymentAmount) {
            _overpayment = msg.value - _paymentAmount;
        }
        if (_data.length > 0) {
            _acceptGasTokenWithData(
                _recipient, _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data
            );
        } else {
            _acceptGasToken(_recipient, _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20);
        }
        // Send back overpayments
        if (_overpayment > 0) {
            payable(LibMeta._msgSender()).sendValue(_overpayment);
        }
        emit PaymentSent(LibMeta._msgSender(), address(0), _paymentAmount, _recipient);
    }

    function _makeERC20PaymentByPriceType(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes memory _data
    ) internal {
        if (
            _priceType == PriceType.STATIC || (_priceType == PriceType.PRICED_IN_ERC20 && _pricedERC20 == _paymentERC20)
        ) {
            _sendERC20(
                _recipient,
                _paymentERC20,
                _paymentAmountInPricedToken,
                _paymentAmountInPricedToken,
                PriceType.STATIC,
                address(0),
                _data
            );
            return;
        }
        ERC20Info storage _baseInfo = LibPayments.getERC20Info(_paymentERC20);
        AggregatorV3Interface _priceFeed;

        if (_priceType == PriceType.PRICED_IN_USD) {
            _priceFeed = _baseInfo.usdAggregator;
        } else if (_priceType == PriceType.PRICED_IN_ERC20) {
            _priceFeed = _baseInfo.priceFeeds[_pricedERC20];
        } else if (_priceType == PriceType.PRICED_IN_GAS_TOKEN) {
            _priceFeed = _baseInfo.pricedInGasTokenAggregator;
        } else {
            revert PaymentsStorage.InvalidPriceType();
        }
        if (address(_priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(_paymentERC20, _priceType, _pricedERC20);
        }

        uint256 _price = _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, _priceFeed, _baseInfo.decimals);

        _sendERC20(_recipient, _paymentERC20, _price, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data);
    }

    function _makeUsdPaymentByPricedToken(
        address _recipient,
        address _usdToken,
        uint256 _paymentAmountInPricedToken,
        address _pricedERC20,
        bytes memory _data
    ) internal {
        if (_usdToken != LibPayments.getUsdcAddress() && _usdToken != LibPayments.getUsdtAddress()) {
            revert PaymentsStorage.InvalidUsdToken(_usdToken);
        }
        ERC20Info storage _quoteInfo = LibPayments.getERC20Info(_pricedERC20);
        AggregatorV3Interface _priceFeed = _quoteInfo.usdAggregator;
        if (address(_priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(_pricedERC20, PriceType.PRICED_IN_USD, address(0));
        }
        uint256 _price =
            _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, _priceFeed, _quoteInfo.decimals, false);

        _sendERC20(
            _recipient, _usdToken, _price, _paymentAmountInPricedToken, PriceType.PRICED_IN_ERC20, _pricedERC20, _data
        );
    }

    function _makeGasTokenPaymentByPriceType(
        address _recipient,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes memory _data
    ) internal {
        if (_priceType == PriceType.STATIC || _priceType == PriceType.PRICED_IN_GAS_TOKEN) {
            if (msg.value != _paymentAmountInPricedToken) {
                revert PaymentsStorage.IncorrectPaymentAmount();
            }
            _sendGasToken(
                _recipient,
                _paymentAmountInPricedToken,
                _paymentAmountInPricedToken,
                PriceType.STATIC,
                address(0),
                _data
            );
            return;
        }
        AggregatorV3Interface _priceFeed;

        if (_priceType == PriceType.PRICED_IN_USD) {
            _priceFeed = LibPayments.getGasTokenUSDPriceFeed();
        } else if (_priceType == PriceType.PRICED_IN_ERC20) {
            _priceFeed = LibPayments.getGasTokenERC20PriceFeed(_pricedERC20);
        } else {
            revert PaymentsStorage.InvalidPriceType();
        }
        if (address(_priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(address(0), _priceType, _pricedERC20);
        }

        uint256 _price = _pricedTokenToPaymentAmount(
            _paymentAmountInPricedToken,
            _priceFeed,
            18 // GasToken assumed to have 18 decimals (ETH, MATIC, etc.)
        );

        _sendGasToken(_recipient, _price, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data);
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
     * @dev returns the given _price in the given decimal format after converting the _price into the related value from the _price feed.
     *  Assumes that the payment amount is in the base token
     */
    function _pricedTokenToPaymentAmount(
        uint256 _paymentAmountInPricedToken,
        AggregatorV3Interface _priceFeed,
        uint8 _paymentDecimals
    ) internal view returns (uint256 paymentAmount_) {
        paymentAmount_ = _pricedTokenToPaymentAmount(_paymentAmountInPricedToken, _priceFeed, _paymentDecimals, true);
    }

    /**
     * @dev returns the given _price in the given decimal format after converting the _price into the related value from the _price feed
     * @param _paymentAmountInPricedToken The _price to convert to the value from the given _price feed
     * @param _priceFeed The _price feed to use to convert the _price
     * @param _paymentDecimals The number of decimals to format the _price as
     * @param _isPriceInBaseToken Whether or not the _price is in the base token or the quote token from the price feed
     * @return paymentAmount_ The _price in the given decimal format
     */
    function _pricedTokenToPaymentAmount(
        uint256 _paymentAmountInPricedToken,
        AggregatorV3Interface _priceFeed,
        uint8 _paymentDecimals,
        bool _isPriceInBaseToken
    ) internal view returns (uint256 paymentAmount_) {
        //  Because fixed precision is e18, value needs to be converted to payment token decimal
        // NOTE: It is assumed that the  _paymentAmountInPricedToken and the _price feed's _price are in the same decimal unit
        UD60x18 _priceFP = _isPriceInBaseToken
            ? ud(_paymentAmountInPricedToken).div(ud(uint256(_getQuotePrice(_priceFeed))))
            : ud(_paymentAmountInPricedToken).mul(ud(uint256(_getQuotePrice(_priceFeed))));
        // Lastly, we must convert the _price into the payment token's decimal amount
        if (_paymentDecimals > 18) {
            // Add digits equal to the difference of fp's 18 decimals and the payment token's decimals
            paymentAmount_ = _priceFP.unwrap() * 10 ** (_paymentDecimals - 18);
        } else {
            // Remove digits equal to the difference of fp's 18 decimals and the payment token's decimals
            paymentAmount_ = _priceFP.unwrap() / 10 ** (18 - _paymentDecimals);
        }
    }

    /**
     * @dev returns the current relative value of the given _price feed
     * @param _priceFeed The _price feed to get the _price of
     * @return price_ The current relative _price of the given _price feed
     */
    function _getQuotePrice(AggregatorV3Interface _priceFeed) internal view returns (uint256 price_) {
        (, int256 _quotePrice,,,) = _priceFeed.latestRoundData();
        // Unfortunately no way to determine this ahead of time, and likely will never occur, but is a possibility of the oracle
        if (_quotePrice < 0) {
            revert PaymentsStorage.InvalidPriceFeedQuote(address(_priceFeed), address(0));
        }
        price_ = uint256(_quotePrice);
    }
}
