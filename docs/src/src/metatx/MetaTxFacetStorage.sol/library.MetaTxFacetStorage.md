# MetaTxFacetStorage
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/metatx/MetaTxFacetStorage.sol)


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.facet.metatx");
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage s);
```

## Errors
### InvalidDelegateApprover
*Emitted when an invalid delegate approver is provided or not allowed.*


```solidity
error InvalidDelegateApprover();
```

### CannotCallExecuteFromExecute
*Emitted when the `execute` function is called recursively, which is not allowed.*


```solidity
error CannotCallExecuteFromExecute();
```

### SessionOrganizationIdNotConsumed
*Emitted when the session organization ID is not consumed or processed as expected.*


```solidity
error SessionOrganizationIdNotConsumed();
```

### SessionOrganizationIdMismatch
*Emitted when there is a mismatch between the session organization ID and the function organization ID.*


```solidity
error SessionOrganizationIdMismatch(bytes32 sessionOrganizationId, bytes32 functionOrganizationId);
```

### NonceAlreadyUsedForSender
*Emitted when a nonce has already been used for a specific sender address.*


```solidity
error NonceAlreadyUsedForSender(address sender, uint256 nonce);
```

### UnauthorizedSignerForSender
*Emitted when the signer is not authorized to sign on behalf of the sender address.*


```solidity
error UnauthorizedSignerForSender(address signer, address sender);
```

## Structs
### Layout

```solidity
struct Layout {
    ISystem_Delegate_Approver systemDelegateApprover;
    mapping(address => mapping(uint256 => bool)) nonces;
    bytes32 sessionOrganizationId;
}
```

