# SimpleCraftingStorage
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/crafting/SimpleCraftingStorage.sol)


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("simple.crafting.diamond");
```


## Functions
### getState


```solidity
function getState() internal pure returns (SimpleCraftingState storage s);
```

## Structs
### SimpleCraftingState

```solidity
struct SimpleCraftingState {
    mapping(address => mapping(uint256 => bool)) collectionToRecipeIdToAllowed;
    mapping(uint256 => CraftingRecipe) craftingRecipes;
    uint256 _currentRecipeId;
}
```

