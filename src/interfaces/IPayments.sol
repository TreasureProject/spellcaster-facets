// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @dev Used to track ERC20 payment feeds and decimals for conversions. Note that coinDecimals equaling 0 means that the erc20
 *      information is not initialized/supported.
 * @param priceFeeds A mapping of any price feed that supports the denominating ERC20 token for conversions.
 * @param decimals The number of decimals of this coin.
 *  Needed to ensure proper funds transferring when decimals in the pair differ
 */
struct ERC20Info {
    // Slot 1: 168 bits
    mapping(address => AggregatorV3Interface) priceFeeds;
    uint8 decimals;
    AggregatorV3Interface gasTokenAggregator;
    AggregatorV3Interface usdAggregator;
}

/**
 * @dev Used to determine how to calculate the payment amount when taking a payment.
 *      SAME_AS_INPUT: The payment amount is the same as the input amount with no conversion.
 *      ERC20: The payment amount is priced as the input type (ERC20/GasToken) valued to the denominating ERC20 token.
 *      USD: The payment amount is priced as the input type (ERC20/GasToken) valued to USD.
 *      GAS_TOKEN: The payment amount is priced as the input type (ERC20/GasToken) valued to GasToken.
 */
enum DenominatingType {
    SAME_AS_INPUT,
    ERC20,
    USD,
    GAS_TOKEN
}

interface IPayments {
    /**
     * @dev Take a payment in ERC20 from the payor
     * @param _payor The address of the payor
     * @param _erc20ToTake The address of the ERC20 to take
     * @param _price The amount of the ERC20 to take
     */
    function takePaymentERC20(address _payor, address _erc20ToTake, uint256 _price) external;
    
    /**
     * @dev Take a payment in gas token from the payor.
     *      All this does is verify that the price matches the tx value
     * @param _price The amount of the gas token to take
     */
    function takePaymentGasToken(uint256 _price) external payable;

    /**
     * @dev Take a payment in ERC20 from the payor and optionally pin the price to a denominating currency (GasToken/USD/other ERC20)
     * @param _payor The address of the payor to take the payment from
     * @param _erc20ToTake The address of the ERC20 to take
     * @param _priceInDenominator The amount of the ERC20 to take, denominated in the _denominatingType currency
     * @param _denominatingType The type of currency to denominate the price in
     * @param _denominatingAddress The address of the currency to denominate the price in. Only used if _denominatingType is ERC20
     */
    function takePaymentERC20FromDenominating(
        address _payor,
        address _erc20ToTake,
        uint256 _priceInDenominator,
        DenominatingType _denominatingType,
        address _denominatingAddress
    ) external;

    /**
     * @dev Take payment in gas tokens (ETH, MATIC, etc.) and optionally pin the price to a denominating currency (USD/ERC20)
     * @param _priceInDenominator The price in the denominating type
     * @param _denominatingType The type of the denominating currency
     * @param _denominatingAddress The address of the denominating currency. Only used if _denominatingType is ERC20
     */
    function takePaymentGasTokenFromDenominating(
        uint256 _priceInDenominator,
        DenominatingType _denominatingType,
        address _denominatingAddress
    ) external payable;

    /**
     * @dev Admin-only function that initializes the ERC20 info for a given ERC20.
     *      Currently there are no price feeds for ERC20s, so those parameters are a placeholder
     * @param _coin The ERC20 address
     * @param _decimals The number of decimals of this coin.
     * @param _gasTokenAggregator The aggregator for the gas coin (ETH, MATIC, etc.)
     * @param _usdAggregator The aggregator for USD
     * @param _denominatingERC20s The coins to use as the denominator for price feeds
     * @param _priceFeeds The price feeds for the given denominating coins
     */
    function initializeERC20(
        address _coin,
        uint8 _decimals,
        address _gasTokenAggregator,
        address _usdAggregator,
        address[] calldata _denominatingERC20s,
        address[] calldata _priceFeeds
    ) external;

    /**
     * @dev Admin-only function that sets the price feed for a given ERC20.
     *      Currently there are no price feeds for ERC20s, so this is a placeholder
     * @param _coin The ERC20 to set the price feed for
     * @param _denominatingERC20 The coin to use as the denominator for the price feed
     * @param _priceFeed The address of the price feed
     */
    function setPriceFeedForERC20(address _coin, address _denominatingERC20, address _priceFeed) external;

    /**
     * @dev Admin-only function that sets the price feed for the gas token for the given ERC20.
     * @param _denominatingERC20 The coin to use as the denominator for the price feed
     * @param _priceFeed The address of the price feed
     */
    function setPriceFeedForGasToken(address _denominatingERC20, address _priceFeed) external;
}