# SimpleCraftingStorage
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/crafting/SimpleCraftingStorage.sol)


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

