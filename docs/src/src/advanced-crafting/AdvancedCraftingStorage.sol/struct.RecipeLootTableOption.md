# RecipeLootTableOption
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/advanced-crafting/AdvancedCraftingStorage.sol)

*Represents an individual loot table option for a given loot table.*


```solidity
struct RecipeLootTableOption {
    mapping(uint16 => LootTableResult) indexToResults;
    LootTableOdds optionOdds;
    uint16 numberOfResults;
}
```

