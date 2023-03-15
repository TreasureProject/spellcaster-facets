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
}


library SimpleCraftingStorage {

    struct SimpleCraftingState {
        mapping(uint256 => CraftingRecipe) craftingRecipes;
        uint256 _currentRecipeId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("simple.crafting.diamond");

    function getSimpleCraftingState() internal pure returns (SimpleCraftingState storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}
