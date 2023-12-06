# PaymentsReceiverStorage
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/payments/PaymentsReceiverStorage.sol)

This library contains the storage layout and events/errors for the PaymentsReceiver contract.


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.payments.receiver");
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Errors
### IncorrectPaymentAmount
*Emitted when an incorrect payment amount is provided.*


```solidity
error IncorrectPaymentAmount(uint256 amount, uint256 price);
```

### SenderNotSpellcasterPayments
*Emitted when the sender is not a valid spellcaster payment address.*


```solidity
error SenderNotSpellcasterPayments(address sender);
```

### PaymentTypeNotAccepted
*Emitted when a non-accepted payment type is provided.*


```solidity
error PaymentTypeNotAccepted(string paymentType);
```

## Structs
### Layout

```solidity
struct Layout {
    IPayments spellcasterPayments;
}
```

