# FacetInitializableStorage
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/utils/FacetInitializableStorage.sol)

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

