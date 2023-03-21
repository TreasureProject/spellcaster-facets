# FacetInitializable
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/utils/FacetInitializable.sol)

*derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)*


## Functions
### facetInitializer

*Modifier to protect an initializer function from being invoked twice.
Name changed to prevent collision with OZ contracts*


```solidity
modifier facetInitializer(bytes32 _facetId);
```

### onlyFacetInitializing

*Modifier to protect an initialization function so that it can only be invoked by functions with the
{initializer} modifier, directly or indirectly.*


```solidity
modifier onlyFacetInitializing();
```

### _isConstructor


```solidity
function _isConstructor() private view returns (bool);
```

