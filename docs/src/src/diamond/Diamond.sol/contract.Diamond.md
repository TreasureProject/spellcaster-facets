# Diamond
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/diamond/Diamond.sol)

\
Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
Implementation of a diamond.
/*****************************************************************************


## Functions
### constructor

This construct a diamond contract


```solidity
constructor(
    address _contractOwner,
    IDiamondCut.FacetCut[] memory _diamondCut,
    Initialization[] memory _initializations
) payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractOwner`|`address`|the owner of the contract. With default DiamondCutFacet, this is the sole address allowed to make further cuts.|
|`_diamondCut`|`FacetCut.IDiamondCut[]`|the list of facet to add|
|`_initializations`|`Initialization[]`|the list of initialization pair to execute. This allow to setup a contract with multiple level of independent initialization.|


### fallback


```solidity
fallback() external payable;
```

### receive


```solidity
receive() external payable;
```

## Structs
### Initialization

```solidity
struct Initialization {
    address initContract;
    bytes initData;
}
```

