# LibAdvancedCrafting
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibAdvancedCrafting.sol)

*This library is used to implement features that use/update storage data for the Advanced Crafting contracts*


## Functions
### getRecipeIdCur


```solidity
function getRecipeIdCur() public view returns (uint64);
```

### setRecipeIdCur


```solidity
function setRecipeIdCur(uint64 _recipeIdCur) public;
```

### getCraftingIdCur


```solidity
function getCraftingIdCur() public view returns (uint64);
```

### setCraftingIdCur


```solidity
function setCraftingIdCur(uint64 _craftingIdCur) public;
```

### getRecipeInfo


```solidity
function getRecipeInfo(uint64 _recipeId) internal view returns (RecipeInfo storage);
```

### requireValidRecipe


```solidity
function requireValidRecipe(uint64 _recipeId) internal view;
```

### requireRecipeOwner


```solidity
function requireRecipeOwner(uint64 _recipeId, address _user) internal view;
```

### createRecipe


```solidity
function createRecipe(bytes32 _organizationId, CreateRecipeArgs calldata _recipeArgs) public;
```

### deleteRecipe


```solidity
function deleteRecipe(uint64 _recipeId) public;
```

