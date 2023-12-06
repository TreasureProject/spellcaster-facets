// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { PriceType } from "src/interfaces/IPayments.sol";

interface IPaymentsV2 {
    /**
     * @dev Make a payment in ERC20 to the recipient
     * @param _recipient The address of the recipient of the payment
     * @param _paymentERC20 The address of the ERC20 to take
     * @param _price The amount of the ERC20 to take
     * @param _data The data passed from the payments module to the receiver
     */
    function makeStaticERC20Payment(
        address _recipient,
        address _paymentERC20,
        uint256 _price,
        bytes calldata _data
    ) external;

    /**
     * @dev Make a payment in gas token to the recipient.
     *      All this does is verify that the price matches the tx value
     * @param _recipient The address of the recipient of the payment
     * @param _price The amount of the gas token to take
     * @param _data The data passed from the payments module to the receiver
     */
    function makeStaticGasTokenPayment(address _recipient, uint256 _price, bytes calldata _data) external payable;

    /**
     * @dev Make a payment in ERC20 to the recipient priced in another token (Gas Token/USD/other ERC20)
     * @param _recipient The address of the payor to take the payment from
     * @param _paymentERC20 The address of the ERC20 to take
     * @param _paymentAmountInPricedToken The desired payment amount, priced in another token, depending on what `priceType` is
     * @param _priceType The type of currency that the payment amount is priced in
     * @param _pricedERC20 The address of the ERC20 that the payment amount is priced in. Only used if `_priceType` is PRICED_IN_ERC20
     * @param _data The data passed from the payments module to the receiver
     */
    function makeERC20PaymentByPriceType(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes calldata _data
    ) external;

    /**
     * @dev Make a payment in a USD-backed token (USDC, USDT, etc.) to the recipient priced in another erc20 token
     * (MAGIC, ARB, etc)
     * @param _recipient The address of the payor to take the payment from
     * @param _usdToken The address of the USD-backed token to take
     * @param _paymentAmountInPricedToken The desired payment amount, priced in another erc20 token
     * @param _pricedERC20 The address of the ERC20 that the payment amount is priced in
     * @param _data The data passed from the payments module to the receiver
     */
    function makeUsdPaymentByPricedToken(
        address _recipient,
        address _usdToken,
        uint256 _paymentAmountInPricedToken,
        address _pricedERC20,
        bytes calldata _data
    ) external;

    /**
     * @dev Take payment in gas tokens (ETH, MATIC, etc.) priced in another token (USD/ERC20)
     * @param _recipient The address to send the payment to
     * @param _paymentAmountInPricedToken The desired payment amount, priced in another token, depending on what `_priceType` is
     * @param _priceType The type of currency that the payment amount is priced in
     * @param _pricedERC20 The address of the ERC20 that the payment amount is priced in. Only used if `_priceType` is PRICED_IN_ERC20
     * @param _data The data passed from the payments module to the receiver
     */
    function makeGasTokenPaymentByPriceType(
        address _recipient,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes calldata _data
    ) external payable;
}
