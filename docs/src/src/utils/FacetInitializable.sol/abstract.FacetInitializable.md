# FacetInitializable
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/utils/FacetInitializable.sol)

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

