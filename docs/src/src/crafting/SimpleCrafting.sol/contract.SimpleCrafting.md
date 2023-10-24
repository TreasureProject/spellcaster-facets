# SimpleCrafting
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/crafting/SimpleCrafting.sol)

**Inherits:**
ERC1155HolderUpgradeable, [AccessControlFacet](/src/access/AccessControlFacet.sol/contract.AccessControlFacet.md)

*Simple contract allows for the creation of a recipe with arbitrary inputs and outputs
by the GuildManager contract.*


## Functions
### SimpleCrafting_init


```solidity
function SimpleCrafting_init() external;
```

### setRecipeToAllowedAsAdmin

*As an allowed admin, set a recipe as allowed for your scope*


```solidity
function setRecipeToAllowedAsAdmin(address _collection, uint256 _recipeId) public;
```

### createNewCraftingRecipe

*Create a new recipe, anyone can call this.*


```solidity
function createNewCraftingRecipe(CraftingRecipe calldata _craftingRecipeInput) public;
```

### getCraftingRecipe

*Helper function to return a crafting recipe*


```solidity
function getCraftingRecipe(uint256 _recipeId) public view returns (CraftingRecipe memory);
```

### craft

*Craft a given recipeId, recipe must be fully allowed.*


```solidity
function craft(uint256 _recipeId) public;
```

### supportsInterface

*Honestly I do not know what this does, but forge was aggresively telling me to add it.*


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC1155ReceiverUpgradeable, AccessControlFacet)
    returns (bool);
```

## Events
### CraftingRecipeCreated

```solidity
event CraftingRecipeCreated(uint256 _craftingRecipeId);
```

### CraftingRecipeCrafted

```solidity
event CraftingRecipeCrafted(uint256 _craftingRecipeId, address _user);
```

## Errors
### UserNotPermitted

```solidity
error UserNotPermitted();
```

### RecipeNotAllowed

```solidity
error RecipeNotAllowed();
```
