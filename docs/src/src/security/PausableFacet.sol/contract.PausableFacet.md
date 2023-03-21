# PausableFacet
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/security/PausableFacet.sol)

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

