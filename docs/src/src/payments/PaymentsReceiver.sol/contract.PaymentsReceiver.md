# PaymentsReceiver
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/payments/PaymentsReceiver.sol)

**Inherits:**
[FacetInitializable](/src/utils/FacetInitializable.sol/abstract.FacetInitializable.md), [IPaymentsReceiver](/src/interfaces/IPaymentsReceiver.sol/interface.IPaymentsReceiver.md), IERC165Upgradeable

*This facet exposes functionality to easily allow developers to accept payments in ERC20 tokens or gas
tokens (ETH, MATIC, etc.). Developers can also accept payment in a token amount priced in USD, other ERC20, or gas tokens.*


## Functions
### PaymentsReceiver_init

*Initialize the facet. Must be called before any other functions.*


```solidity
function PaymentsReceiver_init(address _spellcasterPayments) public facetInitializer(keccak256("PaymentsReceiver"));
```

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
) external override onlySpellcasterPayments;
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
) external payable override onlySpellcasterPayments;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_payor`|`address`|The address of the payor for this payment|
|`_paymentAmount`|`uint256`|The amount of the gas token that was paid|
|`_paymentAmountInPricedToken`|`uint256`|The amount of the gas token that was paid in the given priced token For example, if the payment is the amount of ETH that equals $10 USD, then this value would be 10 * 10**8 (the number of decimals for USD)|
|`_priceType`|`PriceType`|The type of payment that was made. This can be static payment or priced in another currency|
|`_pricedERC20`|`address`|The address of the ERC20 token that was used to price the payment. Only used if `_priceType` is `PriceType.PRICED_IN_ERC20`|


### _acceptStaticMagicPayment


```solidity
function _acceptStaticMagicPayment(address _payor, uint256 _paymentAmount) internal virtual;
```

### _acceptMagicPaymentPricedInUSD


```solidity
function _acceptMagicPaymentPricedInUSD(address _payor, uint256 _paymentAmount, uint256 _priceInUSD) internal virtual;
```

### _acceptMagicPaymentPricedInGasToken


```solidity
function _acceptMagicPaymentPricedInGasToken(
    address _payor,
    uint256 _paymentAmount,
    uint256 _priceInGasToken
) internal virtual;
```

### _acceptMagicPaymentPricedInERC20


```solidity
function _acceptMagicPaymentPricedInERC20(
    address _payor,
    uint256 _paymentAmount,
    address _pricedERC20,
    uint256 _priceInERC20
) internal virtual;
```

### _acceptGasTokenPaymentPricedInMagic


```solidity
function _acceptGasTokenPaymentPricedInMagic(
    address _payor,
    uint256 _paymentAmount,
    uint256 _priceInMagic
) internal virtual;
```

### _acceptStaticERC20Payment


```solidity
function _acceptStaticERC20Payment(address _payor, address _paymentERC20, uint256 _paymentAmount) internal virtual;
```

### _acceptERC20PaymentPricedInERC20


```solidity
function _acceptERC20PaymentPricedInERC20(
    address _payor,
    address _paymentERC20,
    uint256 _paymentAmount,
    address _pricedERC20,
    uint256 _priceInERC20
) internal virtual;
```

### _acceptERC20PaymentPricedInUSD


```solidity
function _acceptERC20PaymentPricedInUSD(
    address _payor,
    address _paymentERC20,
    uint256 _paymentAmount,
    uint256 _priceInUSD
) internal virtual;
```

### _acceptERC20PaymentPricedInMagic


```solidity
function _acceptERC20PaymentPricedInMagic(
    address _payor,
    address _paymentERC20,
    uint256 _paymentAmount,
    uint256 _priceInMagic
) internal virtual;
```

### _acceptERC20PaymentPricedInGasToken


```solidity
function _acceptERC20PaymentPricedInGasToken(
    address _payor,
    address _paymentERC20,
    uint256 _paymentAmount,
    uint256 _priceInGasToken
) internal virtual;
```

### _acceptStaticGasTokenPayment


```solidity
function _acceptStaticGasTokenPayment(address _payor, uint256 _paymentAmount) internal virtual;
```

### _acceptGasTokenPaymentPricedInUSD


```solidity
function _acceptGasTokenPaymentPricedInUSD(
    address _payor,
    uint256 _paymentAmount,
    uint256 _priceInUSD
) internal virtual;
```

### _acceptGasTokenPaymentPricedInERC20


```solidity
function _acceptGasTokenPaymentPricedInERC20(
    address _payor,
    uint256 _paymentAmount,
    address _pricedERC20,
    uint256 _priceInERC20
) internal virtual;
```

### supportsInterface

*Enables external contracts to query if this contract implements the IPaymentsReceiver interface.
Needed for compliant implementation of Spellcaster Payments.*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```

### onlySpellcasterPayments

*Modifier to make a function callable only by the Spellcaster Payments contract.*


```solidity
modifier onlySpellcasterPayments();
```

