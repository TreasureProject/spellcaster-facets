# IPaymentsReceiver
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IPaymentsReceiver.sol)


## Functions
### acceptERC20

*Accepts a payment in ERC20 tokens*


```solidity
function acceptERC20(
    address _payor,
    address _paymentERC20,
    uint256 _paymentAmount,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_payor`|`address`|The address of the payor for this payment|
|`_paymentERC20`|`address`|The address of the ERC20 token that was paid|
|`_paymentAmount`|`uint256`|The amount of the ERC20 token that was paid|
|`_paymentAmountInPricedToken`|`uint256`|The amount of the ERC20 token that was paid in the given priced token For example, if the payment is the amount of MAGIC that equals $10 USD, then this value would be 10 * 10**8 (the number of decimals for USD)|
|`_priceType`|`PriceType`|The type of payment that was made. This can be static payment or priced in another currency|
|`_pricedERC20`|`address`|The address of the ERC20 token that was used to price the payment. Only used if `_priceType` is `PriceType.PRICED_IN_ERC20`|


### acceptGasToken

*Accepts a payment in gas tokens*


```solidity
function acceptGasToken(
    address _payor,
    uint256 _paymentAmount,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_payor`|`address`|The address of the payor for this payment|
|`_paymentAmount`|`uint256`|The amount of the gas token that was paid|
|`_paymentAmountInPricedToken`|`uint256`|The amount of the gas token that was paid in the given priced token For example, if the payment is the amount of ETH that equals $10 USD, then this value would be 10 * 10**8 (the number of decimals for USD)|
|`_priceType`|`PriceType`|The type of payment that was made. This can be static payment or priced in another currency|
|`_pricedERC20`|`address`|The address of the ERC20 token that was used to price the payment. Only used if `_priceType` is `PriceType.PRICED_IN_ERC20`|


## Events
### PaymentReceived
*Emitted when a payment is made*


```solidity
event PaymentReceived(
    address _payor,
    address _paymentERC20,
    uint256 _paymentAmount,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
);
```

