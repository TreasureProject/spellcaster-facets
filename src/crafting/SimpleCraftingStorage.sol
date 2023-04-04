//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Enum to define ERC type of a token.
 */
enum TOKENTYPE {
    ERC20,
    ERC721,
    ERC1155
}

/**
 * @dev Struct that defines an ingredient within a crafting recipe
 * @param tokenAddress the address of the token
 * @param tokenType whether this is ERC20/720 or 1155
 * @param tokenId the tokenId if it is erc720/1155
 * @param tokenQuantity the quantity of the token if it is erc20/1155
 */
struct Ingredient {
    address tokenAddress;
    TOKENTYPE tokenType;
    //One or both of these will be used depending on the tokentype.
    uint256 tokenId;
    uint256 tokenQuantity;
}

/**
 * @dev Struct that defines a result for a crafting recipe
 * @param target the address to call with selector/params
 * @param selector the function selector to call
 * @param params the params to call with
 */
struct Result {
    address target;
    bytes4 selector;
    bytes params;
}

/**
 * @dev Struct that defines a crafting recipe
 * @param ingredients List of ingredients
 * @param results List of results
 */
struct CraftingRecipe {
    //Store array of essential ingredients
    Ingredient[] ingredients;
    //Store array of outputs
    Result[] results;
}

library SimpleCraftingStorage {
    struct SimpleCraftingState {
        /**
         * @dev Store collection -> recipeId -> allowed, whether a collection has permitted a recipe
         */
        mapping(address => mapping(uint256 => bool)) collectionToRecipeIdToAllowed;
        /**
         * @dev Store all crafting recipes
         */
        mapping(uint256 => CraftingRecipe) craftingRecipes;
        uint256 _currentRecipeId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("simple.crafting.diamond");

    /**
     * @dev Returns the state struct at a given storage position.
     */
    function getState() internal pure returns (SimpleCraftingState storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}
