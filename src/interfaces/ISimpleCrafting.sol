// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @dev Enum to define ERC type of a token.
 */
enum TokenType {
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
    TokenType tokenType;
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

interface ISimpleCrafting {
    /**
     * @dev Emitted when a crafting recipe is created
     * @param _craftingRecipeId The crafting recipe Id.
     */
    event CraftingRecipeCreated(uint256 _craftingRecipeId);

    /**
     * @dev Emitted when a crafting recipe is crafting
     * @param _craftingRecipeId The crafting recipe Id.
     * @param _user The crafter.
     */
    event CraftingRecipeCrafted(uint256 _craftingRecipeId, address _user);

    /**
     * @dev Emitted when a user is not permitted to set a recipe as allowed.
     * @param _account The user.
     */
    error UserNotPermitted(address _account);

    /**
     * @dev Emitted when a recipe is not yet fully allowed
     * @param _recipeId The recipeId.
     */
    error RecipeNotAllowed(uint256 _recipeId);
}
