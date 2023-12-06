# PaymentsFacet
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/payments/PaymentsFacet.sol)

**Inherits:**
ReentrancyGuardUpgradeable, [FacetInitializable](/src/utils/FacetInitializable.sol/abstract.FacetInitializable.md), [Modifiers](/src/Modifiers.sol/abstract.Modifiers.md), [IPayments](/src/interfaces/IPayments.sol/interface.IPayments.md)

*This facet exposes functionality to easily allow users to accept payments in ERC20 tokens or gas tokens (ETH, MATIC, etc.)
Users can also pay in a token amount priced in USD, other ERC20, or gas tokens.*


## Functions
### PaymentsFacet_init

*Initialize the facet. Can be called externally or internally.
Ideally referenced in an initialization script facet*


```solidity
function PaymentsFacet_init(
    address _gasTokenUSDPriceFeed,
    address _magicAddress
) public facetInitializer(keccak256("PaymentsFacet"));
```

### makeStaticERC20Payment

*Make a payment in ERC20 to the recipient*


```solidity
function makeStaticERC20Payment(
    address _recipient,
    address _paymentERC20,
    uint256 _paymentAmount
) external nonReentrant onlyReceiver(_recipient);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address of the recipient of the payment|
|`_paymentERC20`|`address`|The address of the ERC20 to take|
|`_paymentAmount`|`uint256`||


### makeStaticGasTokenPayment

*Make a payment in gas token to the recipient.
All this does is verify that the price matches the tx value*


```solidity
function makeStaticGasTokenPayment(
    address _recipient,
    uint256 _paymentAmount
) external payable nonReentrant onlyReceiver(_recipient);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address of the recipient of the payment|
|`_paymentAmount`|`uint256`||


### makeERC20PaymentByPriceType

*Make a payment in ERC20 to the recipient priced in another token (Gas Token/USD/other ERC20)*


```solidity
function makeERC20PaymentByPriceType(
    address _recipient,
    address _paymentERC20,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
) external nonReentrant onlyReceiver(_recipient);
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
) external payable nonReentrant onlyReceiver(_recipient);
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
    address _erc20,
    uint8 _decimals,
    address _pricedInGasTokenAggregator,
    address _usdAggregator,
    address[] calldata _pricedERC20s,
    address[] calldata _priceFeeds
) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20`|`address`||
|`_decimals`|`uint8`|The number of decimals of this coin.|
|`_pricedInGasTokenAggregator`|`address`|The aggregator for the gas coin (ETH, MATIC, etc.)|
|`_usdAggregator`|`address`|The aggregator for USD|
|`_pricedERC20s`|`address[]`|The ERC20s that have supported price feeds for the given ERC20|
|`_priceFeeds`|`address[]`|The price feeds for the priced ERC20s|


### setERC20PriceFeedForERC20

*Admin-only function that sets the price feed for a given ERC20.
Currently there are no price feeds for ERC20s, so this is a placeholder*


```solidity
function setERC20PriceFeedForERC20(
    address _erc20,
    address _pricedERC20,
    address _priceFeed
) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20`|`address`||
|`_pricedERC20`|`address`|The ERC20 that is associated to the given price feed and `_paymentERC20`|
|`_priceFeed`|`address`|The address of the price feed|


### setERC20PriceFeedForGasToken

*Admin-only function that sets the price feed for the gas token for the given ERC20.*


```solidity
function setERC20PriceFeedForGasToken(address _pricedERC20, address _priceFeed) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pricedERC20`|`address`|The ERC20 that is associated to the given price feed and `_paymentERC20`|
|`_priceFeed`|`address`|The address of the price feed|


### getMagicAddress


```solidity
function getMagicAddress() external view override returns (address magicAddress_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`magicAddress_`|`address`|The address of the $MAGIC contract|


### isValidPriceType


```solidity
function isValidPriceType(
    address _paymentToken,
    PriceType _priceType,
    address _pricedERC20
) external view override returns (bool supported_);
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
    address _pricedToken
) external view override returns (uint256 paymentAmount_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_paymentToken`|`address`|The token to convert from. If address(0), then the input is in gas tokens|
|`_paymentAmountInPricedToken`|`uint256`|The desired payment amount, priced in either the `_pricedERC20`, gas token, or USD depending on `_priceType` used to calculate the output amount|
|`_priceType`|`PriceType`|The type of conversion to perform|
|`_pricedToken`|`address`||


### _sendERC20

*Sends payment and invokes the acceptance function on the recipient*


```solidity
function _sendERC20(
    address _recipient,
    address _paymentERC20,
    uint256 _paymentAmount,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
) internal;
```

### _sendGasToken

*Sends gas token payment and invokes the acceptance function on the recipient*


```solidity
function _sendGasToken(
    address _recipient,
    uint256 _paymentAmount,
    uint256 _paymentAmountInPricedToken,
    PriceType _priceType,
    address _pricedERC20
) internal;
```

### _getPriceFeed


```solidity
function _getPriceFeed(
    address _paymentToken,
    address _pricedToken,
    PriceType _priceType
) internal view returns (AggregatorV3Interface priceFeed_);
```

### _pricedTokenToPaymentAmount

*returns the given price in the given decimal format after converting the price into the related value from the price feed*


```solidity
function _pricedTokenToPaymentAmount(
    uint256 _paymentAmountInPricedToken,
    AggregatorV3Interface _priceFeed,
    uint8 _paymentDecimals
) internal view returns (uint256 paymentAmount_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_paymentAmountInPricedToken`|`uint256`|The price to convert to the value from the given price feed|
|`_priceFeed`|`AggregatorV3Interface`|The price feed to use to convert the price|
|`_paymentDecimals`|`uint8`|The number of decimals to format the price as|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`paymentAmount_`|`uint256`|The price in the given decimal format|


### _getQuotePrice

*returns the current relative value of the given price feed*


```solidity
function _getQuotePrice(AggregatorV3Interface _priceFeed) internal view returns (uint256 price_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_priceFeed`|`AggregatorV3Interface`|The price feed to get the price of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price_`|`uint256`|The current relative price of the given price feed|


### onlyReceiver


```solidity
modifier onlyReceiver(address _recipient);
```

