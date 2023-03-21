# PaymentsReceiverStorage
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/payments/PaymentsReceiverStorage.sol)

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

