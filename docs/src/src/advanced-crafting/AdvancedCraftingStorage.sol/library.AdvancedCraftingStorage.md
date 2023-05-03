# AdvancedCraftingStorage
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/advanced-crafting/AdvancedCraftingStorage.sol)


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.crafting.advanced");
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Events
### RecipeCreated

```solidity
event RecipeCreated(
    uint64 indexed _recipeId, bytes32 indexed _organizationId, CreateRecipeArgs _recipeArgs, bool _isRandomRequired
);
```

### RecipeDeleted

```solidity
event RecipeDeleted(uint64 indexed _recipeId);
```

## Errors
### InvalidRecipeId

```solidity
error InvalidRecipeId();
```

### RecipeOwnerOnly

```solidity
error RecipeOwnerOnly();
```

### BadRecipeStartEndTime

```solidity
error BadRecipeStartEndTime();
```

### NoInputOptionsSupplied

```solidity
error NoInputOptionsSupplied();
```

### InvalidInputOption

```solidity
error InvalidInputOption();
```

### BadInputAmount

```solidity
error BadInputAmount();
```

### BadLootTable

```solidity
error BadLootTable();
```

## Structs
### Layout

```solidity
struct Layout {
    mapping(uint64 => RecipeInfo) recipeIdToInfo;
    mapping(address => mapping(uint64 => CraftingInfo)) userToCraftingIdToInfo;
    uint64 recipeIdCur;
    uint64 craftingIdCur;
}
```

