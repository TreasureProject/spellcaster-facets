# PaymentsStorage
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/payments/PaymentsStorage.sol)

This library contains the storage layout and events/errors for the PaymentsFacet contract.


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.payments");
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Errors
### NonexistantPriceFeed
*Emitted when a price feed is not found for a token or gas token*


```solidity
error NonexistantPriceFeed(address paymentToken, PriceType priceType, address pricedToken);
```

### InvalidPriceType
*Emitted when a type is given that hasn't been implemented*


```solidity
error InvalidPriceType();
```

### IncorrectPaymentAmount
*Emitted when a payment is made with an incorrect amount*


```solidity
error IncorrectPaymentAmount();
```

### NonPaymentsReceiverRecipient
*Emitted when a payment recipient doesn't implement the PaymentsReceiver interface*


```solidity
error NonPaymentsReceiverRecipient(address recipient);
```

### InvalidPriceFeedQuote
*Emitted when a price feed returns a zero value.*


```solidity
error InvalidPriceFeedQuote(address paymentToken, address pricedToken);
```

## Structs
### Layout

```solidity
struct Layout {
    mapping(address => ERC20Info) erc20ToInfo;
    AggregatorV3Interface gasTokenUSDPriceFeed;
    address magicAddress;
}
```

