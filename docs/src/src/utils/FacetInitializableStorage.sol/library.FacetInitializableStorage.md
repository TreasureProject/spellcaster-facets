# FacetInitializableStorage
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/utils/FacetInitializableStorage.sol)

*Storage to track facets in a diamond that have been initialized.
Needed to prevent accidental re-initializations
Name changed to prevent collision with OZ contracts
OZ's Initializable storage handles all of the _initializing state, which isn't facet-specific*


## State Variables
### STORAGE_SLOT

```solidity
bytes32 internal constant STORAGE_SLOT = keccak256("diamond.dapp.utils.FacetInitializable");
```


## Functions
### getState


```solidity
function getState() internal pure returns (State storage s);
```

### isInitialized


```solidity
function isInitialized(bytes32 _facetId) internal view returns (bool isInitialized_);
```

## Errors
### AlreadyInitialized

```solidity
error AlreadyInitialized(bytes32 facetId);
```

## Structs
### State

```solidity
struct State {
    mapping(bytes32 => bool) _initialized;
}
```

