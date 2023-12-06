# RecipeInput
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/advanced-crafting/AdvancedCraftingStorage.sol)

*This struct represents a single input requirement for a recipe. This may have multiple options that can satisfy the "input".*


```solidity
struct RecipeInput {
    mapping(uint16 => RecipeInputOption) indexToInputOption;
    uint16 numberOfInputOptions;
    uint8 amount;
    bool isRequired;
}
```

