# RecipeLootTable
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/advanced-crafting/AdvancedCraftingStorage.sol)

*Represents an individual loot table for a recipe. This loot table may have multiple options within it.
It also may have a chance associated with it via the rollAmounts/rollOdds*


```solidity
struct RecipeLootTable {
    mapping(uint16 => RecipeLootTableOption) indexToOption;
    uint8[] rollAmounts;
    mapping(uint16 => LootTableOdds) rollIndexToOdds;
    uint16 numberOfOptions;
}
```

