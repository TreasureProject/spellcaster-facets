//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum TOKENTYPE {
    ERC20,
    ERC721,
    ERC1155
}

struct Ingredient {
    address tokenAddress;
    TOKENTYPE tokenType;
    //One or both of these will be used depending on the tokentype.
    uint256 tokenId;
    uint256 tokenQuantity;
}

struct Result {
    address target;
    bytes4 selector;
    bytes params;
}

struct CraftingRecipe {
    //Store array of essential ingredients
    Ingredient[] ingredients;
    //Store array of outputs
    Result[] results;
    //Store whether this has been anointed. Defaults to false.
    bool anointed;
    //Store when this was anointed, must have been more than x time ago.
    uint256 anointmentTime;
}


library WorldSimpleCraftingStorage {

    struct State {
        mapping(uint256 => CraftingRecipe) craftingRecipes;
        uint256 _currentRecipeId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("world.simple.crafting.diamond");

    function getState() internal pure returns (State storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function getCraftingRecipe(uint256 _recipeId) internal view returns (CraftingRecipe storage) {
        return getState().craftingRecipes[_recipeId];
    }

    function setCraftingRecipe(uint256 _recipeId, CraftingRecipe memory _craftingRecipe) internal {
        getState().craftingRecipes[_recipeId] = _craftingRecipe;
    }

    function getCurrentRecipeId() internal view returns(uint256) {
        return getState()._currentRecipeId;
    }

    function getAndIncrementCurrentRecipeId() internal returns(uint256) {
        uint256 _currentRecipeId = getState()._currentRecipeId;
        getState()._currentRecipeId += 1;

        return _currentRecipeId;
    }
}
