// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PriceType} from "src/interfaces/IPayments.sol";

interface IPaymentsReceiver {
    /**
     * @dev Accepts a payment in ERC20 tokens
     * @param _payor The address of the payor for this payment
     * @param _paymentERC20 The address of the ERC20 token that was paid
     * @param _paymentAmount The amount of the ERC20 token that was paid
     * @param _paymentAmountInPricedToken The amount of the ERC20 token that was paid in the given priced token
     *      For example, if the payment is the amount of MAGIC that equals $10 USD,
     *      then this value would be 10 * 10**8 (the number of decimals for USD)
     * @param _priceType The type of payment that was made. This can be static payment or priced in another currency 
     * @param _pricedERC20 The address of the ERC20 token that was used to price the payment. Only used if `_priceType` is `PriceType.PRICED_IN_ERC20`
     */
    function acceptERC20(
        address _payor,
        address _paymentERC20,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) external;

    /**
     * @dev Accepts a payment in gas tokens
     * @param _payor The address of the payor for this payment
     * @param _paymentAmount The amount of the gas token that was paid
     * @param _paymentAmountInPricedToken The amount of the gas token that was paid in the given priced token
     *      For example, if the payment is the amount of ETH that equals $10 USD,
     *      then this value would be 10 * 10**8 (the number of decimals for USD)
     * @param _priceType The type of payment that was made. This can be static payment or priced in another currency 
     * @param _pricedERC20 The address of the ERC20 token that was used to price the payment. Only used if `_priceType` is `PriceType.PRICED_IN_ERC20`
     */
    function acceptGasToken(
        address _payor,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) external payable;
}