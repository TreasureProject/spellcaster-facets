# AdvancedCrafting
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/advanced-crafting/AdvancedCrafting.sol)

**Inherits:**
[AdvancedCraftingBase](/src/advanced-crafting/AdvancedCraftingBase.sol/abstract.AdvancedCraftingBase.md)


## Functions
### AdvancedCrafting_init


```solidity
function AdvancedCrafting_init(address _systemDelegateApprover) external facetInitializer(keccak256("GuildManager"));
```

### createRecipe


```solidity
function createRecipe(bytes32 _organizationId, CreateRecipeArgs calldata _recipeArgs) external;
```

### deleteRecipe


```solidity
function deleteRecipe(uint64 _recipeId) external;
```

