# CreateRecipeArgs
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IAdvancedCrafting.sol)


```solidity
struct CreateRecipeArgs {
    string name;
    uint64 startTime;
    uint64 endTime;
    uint64 timeToComplete;
    uint32 maxCrafts;
    address recipeHandler;
    RecipeInputArgs[] inputs;
    RecipeLootTableArgs[] lootTables;
}
```

