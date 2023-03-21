# IPayments

## Enumerations
### PriceType
*Used to determine how to calculate the payment amount when taking a payment.
STATIC: The payment amount is the input token without conversion.
PRICED_IN_ERC20: The payment amount is priced in an ERC20 relative to the payment token.
PRICED_IN_USD: The payment amount is priced in USD relative to the payment token.
PRICED_IN_GAS_TOKEN: The payment amount is priced in the gas token relative to the payment token.*


```solidity
enum PriceType {
    STATIC,
    PRICED_IN_ERC20,
    PRICED_IN_USD,
    PRICED_IN_GAS_TOKEN
}
```

## Functions
### makeStaticERC20Payment

*Make a payment in ERC20 to the recipient*


```solidity
function makeStaticERC20Payment(address _recipient, address _paymentERC20, uint256 _price) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address of the recipient of the payment|
|`_paymentERC20`|`address`|The address of the ERC20 to take|
|`_price`|`uint256`|The amount of the ERC20 to take|


### makeStaticGasTokenPayment

*Make a payment in gas token to the recipient.
All this does is verify that the price matches the tx value*


```solidity
function makeStaticGasTokenPayment(address _recipient, uint256 _price) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address of the recipient of the payment|
|`_price`|`uint256`|The amount of the gas token to take|


### makeERC20PaymentByPriceType

*Make a payment in ERC20 to the recipient priced in another token (Gas Token/USD/other ERC20)*


```solidity
function makeERC20PaymentByPriceType(
    address _recipient,
    address _paymentERC20,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address of the payor to take the payment from|
|`_paymentERC20`|`address`|The address of the ERC20 to take|
|`_paymentAmountInPricedToken`|`uint256`|The desired payment amount, priced in another token, depending on what `priceType` is|
|`_priceType`|`PriceType`|The type of currency that the payment amount is priced in|
|`_pricedERC20`|`address`|The address of the ERC20 that the payment amount is priced in. Only used if `_priceType` is PRICED_IN_ERC20|


### makeGasTokenPaymentByPriceType

*Take payment in gas tokens (ETH, MATIC, etc.) priced in another token (USD/ERC20)*


```solidity
function makeGasTokenPaymentByPriceType(
    address _recipient,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address to send the payment to|
|`_paymentAmountInPricedToken`|`uint256`|The desired payment amount, priced in another token, depending on what `_priceType` is|
|`_priceType`|`PriceType`|The type of currency that the payment amount is priced in|
|`_pricedERC20`|`address`|The address of the ERC20 that the payment amount is priced in. Only used if `_priceType` is PRICED_IN_ERC20|


### initializeERC20

*Admin-only function that initializes the ERC20 info for a given ERC20.
Currently there are no price feeds for ERC20s, so those parameters are a placeholder*


```solidity
function initializeERC20(
    address _paymentERC20,
    uint8 _decimals,
    address _pricedInGasTokenAggregator,
    address _usdAggregator,
    address[] calldata _pricedERC20s,
    address[] calldata _priceFeeds
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_paymentERC20`|`address`|The ERC20 address|
|`_decimals`|`uint8`|The number of decimals of this coin.|
|`_pricedInGasTokenAggregator`|`address`|The aggregator for the gas coin (ETH, MATIC, etc.)|
|`_usdAggregator`|`address`|The aggregator for USD|
|`_pricedERC20s`|`address[]`|The ERC20s that have supported price feeds for the given ERC20|
|`_priceFeeds`|`address[]`|The price feeds for the priced ERC20s|


### setERC20PriceFeedForERC20

*Admin-only function that sets the price feed for a given ERC20.
Currently there are no price feeds for ERC20s, so this is a placeholder*


```solidity
function setERC20PriceFeedForERC20(address _paymentERC20, address _pricedERC20, address _priceFeed) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_paymentERC20`|`address`|The ERC20 to set the price feed for|
|`_pricedERC20`|`address`|The ERC20 that is associated to the given price feed and `_paymentERC20`|
|`_priceFeed`|`address`|The address of the price feed|


### setERC20PriceFeedForGasToken

*Admin-only function that sets the price feed for the gas token for the given ERC20.*


```solidity
function setERC20PriceFeedForGasToken(address _pricedERC20, address _priceFeed) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pricedERC20`|`address`|The ERC20 that is associated to the given price feed and `_paymentERC20`|
|`_priceFeed`|`address`|The address of the price feed|


### isValidPriceType


```solidity
function isValidPriceType(
    address _paymentToken,
    PriceType _priceType,
    address _pricedERC20
) external view returns (bool supported_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_paymentToken`|`address`|The token to convert from. If address(0), then the input is in gas tokens|
|`_priceType`|`PriceType`|The type of currency that the payment amount is priced in|
|`_pricedERC20`|`address`|The address of the ERC20 that the payment amount is priced in. Only used if `_priceType` is PRICED_IN_ERC20|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`supported_`|`bool`|Whether or not a price feed exists for the given payment token and price type|


### calculatePaymentAmountByPriceType

*Calculates the price of the input token relative to the output token*


```solidity
function calculatePaymentAmountByPriceType(
    address _paymentToken,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
) external view returns (uint256 paymentAmount_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_paymentToken`|`address`|The token to convert from. If address(0), then the input is in gas tokens|
|`_paymentAmountInPricedToken`|`uint256`|The desired payment amount, priced in either the `_pricedERC20`, gas token, or USD depending on `_priceType` used to calculate the output amount|
|`_priceType`|`PriceType`|The type of conversion to perform|
|`_pricedERC20`|`address`|The token to convert to. If address(0), then the output is in gas tokens or USD, depending on `_priceType`|


### getMagicAddress


```solidity
function getMagicAddress() external view returns (address magicAddress_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`magicAddress_`|`address`|The address of the $MAGIC contract|


## Events
### PaymentAccepted
*Emitted when a payment is made*


```solidity
event PaymentAccepted(address _recipient, address _token, uint256 _amount, address _paymentsReceiver);
```

