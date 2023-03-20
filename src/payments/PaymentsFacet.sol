// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20Upgradeable} from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-diamond/proxy/utils/Initializable.sol";
import {PausableStorage} from "@openzeppelin/contracts-diamond/security/PausableStorage.sol";
import {UD60x18, ud, convert} from "@prb/math/UD60x18.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {FacetInitializable} from "src/utils/FacetInitializable.sol";
import {Modifiers} from "src/Modifiers.sol";

import {IPayments, ERC20Info, DenominatingType} from "src/interfaces/IPayments.sol";

import {LibUtilities} from "src/libraries/LibUtilities.sol";
import {ADMIN_ROLE} from "src/libraries/LibAccessControlRoles.sol";
import {LibMeta} from "src/libraries/LibMeta.sol";
import {LibPayments} from "src/libraries/LibPayments.sol";
import {PaymentsStorage} from "src/payments/PaymentsStorage.sol";

/**
 * @title Payments Facet contract.
 * @dev This facet exposes functionality to easily allow users to accept payments in ERC20 tokens or gas tokens (ETH, MATIC, etc.)
 *      Users can also denominate a price in USD, ERC20, or gas tokens.
 */
contract PaymentsFacet is FacetInitializable, Modifiers, IPayments {

    /**
     * @dev Initialize the facet. Can be called externally or internally.
     * Ideally referenced in an initialization script facet
     */
    function ERC20PaymentsFacet_init(address _gasTokenUSDPriceFeed) public facetInitializer(keccak256("ERC20PaymentsFacet")) {
        LibPayments.setGasTokenUSDPriceFeed(_gasTokenUSDPriceFeed);
    }

    /**
     * @inheritdoc IPayments
     */
    function takePaymentERC20(address _payor, address _erc20ToTake, uint256 _price) external {
        IERC20Upgradeable(_erc20ToTake).transferFrom(_payor, LibMeta._msgSender(), _price);
    }

    /**
     * @inheritdoc IPayments
     */
    function takePaymentGasToken(uint256 _price) external payable {
        if(msg.value != _price) {
            revert PaymentsStorage.IncorrectPaymentAmount();
        }
    }

    /**
     * @inheritdoc IPayments
     */
    function takePaymentERC20FromDenominating(
        address _payor,
        address _erc20ToTake,
        uint256 _priceInDenominator,
        DenominatingType _denominatingType,
        address _denominatingAddress
    ) external
    {
        if(_denominatingType == DenominatingType.SAME_AS_INPUT) {
            IERC20Upgradeable(_erc20ToTake).transferFrom(_payor, LibMeta._msgSender(), _priceInDenominator);
            return;
        }
        ERC20Info storage _baseInfo = LibPayments.getERC20Info(_erc20ToTake);
        AggregatorV3Interface priceFeed;
        
        if(_denominatingType == DenominatingType.USD) {
            priceFeed = _baseInfo.usdAggregator;
        } else if(_denominatingType == DenominatingType.ERC20) {
            priceFeed = _baseInfo.priceFeeds[_denominatingAddress];
        } else if(_denominatingType == DenominatingType.GAS_TOKEN) {
            priceFeed = _baseInfo.gasTokenAggregator;
        } else {
            revert PaymentsStorage.InvalidDenominatingType();
        }
        if(address(priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(_erc20ToTake, _denominatingType, _denominatingAddress);
        }

        uint256 price = _denominatingPriceToPaymentPrice(
            _priceInDenominator,
            priceFeed,
            _baseInfo.decimals
        );

        IERC20Upgradeable(_erc20ToTake).transferFrom(_payor, LibMeta._msgSender(), price);
    }

    /**
     * @inheritdoc IPayments
     */
    function takePaymentGasTokenFromDenominating(
        uint256 _priceInDenominator,
        DenominatingType _denominatingType,
        address _denominatingAddress
    ) external payable
    {
        if(_denominatingType == DenominatingType.SAME_AS_INPUT || _denominatingType == DenominatingType.GAS_TOKEN) {
            if(msg.value != _priceInDenominator) {
                revert PaymentsStorage.IncorrectPaymentAmount();
            }
            return;
        }
        AggregatorV3Interface priceFeed;

        if(_denominatingType == DenominatingType.USD) {
            priceFeed = LibPayments.getGasTokenUSDPriceFeed();
        } else if(_denominatingType == DenominatingType.ERC20) {
            priceFeed = LibPayments.getGasTokenERC20PriceFeed(_denominatingAddress);
        } else {
            revert PaymentsStorage.InvalidDenominatingType();
        }
        if(address(priceFeed) == address(0)) {
            revert PaymentsStorage.NonexistantPriceFeed(address(0), _denominatingType, _denominatingAddress);
        }

        uint256 price = _denominatingPriceToPaymentPrice(
            _priceInDenominator,
            priceFeed,
            18 // GasToken assumed to have 18 decimals (ETH, MATIC, etc.)
        );

        if(msg.value != price) {
            revert PaymentsStorage.IncorrectPaymentAmount();
        }
    }

    /**
     * @inheritdoc IPayments
     */
    function initializeERC20(
        address _coin,
        uint8 _decimals,
        address _gasTokenAggregator,
        address _usdAggregator,
        address[] calldata _denominatingERC20s,
        address[] calldata _priceFeeds
    ) external onlyRole(ADMIN_ROLE)
    {
        uint256 numQuotes = _denominatingERC20s.length;
        LibUtilities.requireArrayLengthMatch(numQuotes, _priceFeeds.length);
        ERC20Info storage coinInfo = LibPayments.getERC20Info(_coin);
        coinInfo.decimals = _decimals;
        coinInfo.gasTokenAggregator = AggregatorV3Interface(_gasTokenAggregator);
        coinInfo.usdAggregator = AggregatorV3Interface(_usdAggregator);
        for(uint256 i = 0; i < numQuotes; i++) {
            coinInfo.priceFeeds[_denominatingERC20s[i]] = AggregatorV3Interface(_priceFeeds[i]);
        }
    }

    /**
     * @inheritdoc IPayments
     */
    function setPriceFeedForERC20(address _coin, address _denominatingERC20, address _priceFeed) external onlyRole(ADMIN_ROLE) {
        ERC20Info storage coinInfo = LibPayments.getERC20Info(_coin);
        coinInfo.priceFeeds[_denominatingERC20] = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @inheritdoc IPayments
     */
    function setPriceFeedForGasToken(address _denominatingERC20, address _priceFeed) external onlyRole(ADMIN_ROLE) {
        LibPayments.setGasTokenERC20PriceFeed(_denominatingERC20, _priceFeed);
    }

    /**
     * @dev returns the given price in the given decimal format after converting the price into the related value from the price feed
     * @param _priceInDenominator The price to convert to the value from the given price feed
     * @param _priceFeed The price feed to use to convert the price
     * @param _paymentDecimals The number of decimals to format the price as
     * @return price_ The price in the given decimal format
     */
    function _denominatingPriceToPaymentPrice(
        uint256 _priceInDenominator,
        AggregatorV3Interface _priceFeed,
        uint8 _paymentDecimals
    ) internal view returns(uint256 price_)
    {
        price_ = _convertFromDenominatorToPayment(
            _priceInDenominator,
            _getQuotePrice(_priceFeed),
            _paymentDecimals
        );
    }

    /**
     * @dev returns the given price in the given decimal format after converting the price into the related value from the price feed
     * @param _priceInDenominator The price to convert to the value from the given price feed
     * @param _paymentToDenominatorQuote The current value of the denominator coin relative to the payment coin
     * @param _paymentDecimals The number of decimals to format the price as
     * @return paymentAmount_ The price in the given decimal format
     */
    function _convertFromDenominatorToPayment(
        uint256 _priceInDenominator,
        uint256 _paymentToDenominatorQuote,
        uint256 _paymentDecimals
    ) internal pure returns(uint256 paymentAmount_)
    {
        // Rounding example: Quote price is 10 USD and denominating price for $MONEY is 1.82 USD, 10 / 1.82 = 5.494505494505495 $MONEY
        //  Because fixed precision is e18, value will be 5494505494505494505 and needs to be converted to payment coin decimal
        // NOTE: It is assumed that the _priceInDenominator and the price feed's price are in the same decimal unit
        UD60x18 priceFP = ud(_priceInDenominator).div(ud(uint256(_paymentToDenominatorQuote)));
        // Lastly, we must convert the price into the payment coin's decimal amount
        if(_paymentDecimals > 18) {
            // Add digits equal to the difference of fp's 18 decimals and the payment coin's decimals
            paymentAmount_ = priceFP.unwrap() * 10 ** (_paymentDecimals - 18);
        } else {
            // Remove digits equal to the difference of fp's 18 decimals and the payment coin's decimals
            paymentAmount_ = priceFP.unwrap() / 10 ** (18 - _paymentDecimals);
        }
    }

    /**
     * @dev returns the current relative value of the given price feed
     * @param _priceFeed The price feed to get the price of
     * @return price_ The current relative price of the given price feed
     */
    function _getQuotePrice(AggregatorV3Interface _priceFeed) internal view returns(uint256 price_) {
        (, int256 quotePrice,,,) = _priceFeed.latestRoundData();
        // Unfortunately no way to determine this ahead of time, and likely will never occur, but is a possibility of the oracle
        if(quotePrice < 0) {
            revert PaymentsStorage.InvalidPriceFeedQuote(address(_priceFeed), address(0));
        }
        price_ = uint256(quotePrice);
    }
}
