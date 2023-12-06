# PausableFacet
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/security/PausableFacet.sol)

**Inherits:**
[FacetInitializable](/src/utils/FacetInitializable.sol/abstract.FacetInitializable.md), [Modifiers](/src/Modifiers.sol/abstract.Modifiers.md)

Exposes the paused() function for the diamond

*Using this facet ensures that contracts that depend on pausability can reference the internal functions via Modifiers.sol*


## Functions
### paused

*Returns true if the contract is paused, and false otherwise.*


```solidity
function paused() public view virtual returns (bool);
```

### setPause


```solidity
function setPause(bool _shouldPause) external onlyRole(ADMIN_ROLE);
```

