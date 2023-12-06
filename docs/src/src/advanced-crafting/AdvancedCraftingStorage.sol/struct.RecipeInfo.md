# RecipeInfo
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/advanced-crafting/AdvancedCraftingStorage.sol)

*Stores all data related to a recipe*


```solidity
struct RecipeInfo {
    string name;
    bytes32 organizationId;
    uint64 startTime;
    uint64 endTime;
    uint64 timeToComplete;
    uint32 maxCrafts;
    uint32 currentCrafts;
    address[] contractsThatNeedApproved;
    mapping(address => bool) contractToIsApproved;
    mapping(uint16 => RecipeInput) indexToInput;
    mapping(uint16 => RecipeLootTable) indexToLootTable;
    uint16 numberOfInputs;
    uint16 numberOfLootTables;
    bool isRandomRequired;
    bool isRecipeApproved;
    address recipeHandler;
    address owner;
}
```

