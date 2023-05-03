# LootTableOdds
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/advanced-crafting/AdvancedCraftingStorage.sol)

*This is a generic struct to represent the odds for anything related to loot tables.*


```solidity
struct LootTableOdds {
    uint32 baseOdds;
    uint16 numberOfBoostOdds;
    mapping(uint16 => LootTableBoostOdds) indexToBoostOdds;
}
```

