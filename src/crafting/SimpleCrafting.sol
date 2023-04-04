//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    ERC1155HolderUpgradeable,
    ERC1155ReceiverUpgradeable
} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import { IERC721Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import { IERC1155Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";

import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";
import { LibAccessControlRoles } from "../libraries/LibAccessControlRoles.sol";

import {
    SimpleCraftingStorage, CraftingRecipe, Ingredient, Result, TOKENTYPE
} from "../crafting/SimpleCraftingStorage.sol";
import { LibSimpleCraftingStorage } from "../libraries/LibSimpleCraftingStorage.sol";
import { IERC20Consumer } from "../interfaces/IERC20Consumer.sol";
import { AccessControlFacet } from "../access/AccessControlFacet.sol";
import { Modifiers } from "../Modifiers.sol";
import { LibMeta } from "../libraries/LibMeta.sol";

interface Ownable {
    function owner() external view returns (address);
}

/**
 * @title Simple Crafting Contract
 * @dev Simple contract allows for the creation of a recipe with arbitrary inputs and outputs
 *  by the GuildManager contract.
 */
contract SimpleCrafting is ERC1155HolderUpgradeable {
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

    function SimpleCrafting_init() external { }

    /**
     * @dev As an allowed admin, set a recipe as allowed for your scope
     * @param _collection The collection you are signing on behalf of.
     * @param _recipeId The recipeId to set.
     */
    function setRecipeToAllowedAsAdmin(address _collection, uint256 _recipeId) public {
        //Ensure they are an admin of this collection.
        if (
            LibMeta._msgSender() != Ownable(_collection).owner()
                && !LibAccessControlRoles.isCollectionAdmin(LibMeta._msgSender(), _collection)
        ) revert UserNotPermitted(LibMeta._msgSender());

        LibSimpleCraftingStorage.setCollectionToRecipeIdToAllowed(_collection, _recipeId, true);
    }

    /**
     * @dev Create a new recipe, anyone can call this.
     * @param _craftingRecipeInput The creation data for a crafting recipe.
     */
    function createNewCraftingRecipe(CraftingRecipe calldata _craftingRecipeInput) public {
        //Pull the current recipe Id
        uint256 _currentRecipeId = SimpleCraftingStorage.getState()._currentRecipeId;

        //Create a pointer to this recipeId (empty)
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage.getState().craftingRecipes[_currentRecipeId];

        //For each ingredient
        for (uint256 i = 0; i < _craftingRecipeInput.ingredients.length; i++) {
            //Push it into storage
            _craftingRecipe.ingredients.push(_craftingRecipeInput.ingredients[i]);
        }

        //For each result
        for (uint256 i = 0; i < _craftingRecipeInput.results.length; i++) {
            //Push it into storage
            _craftingRecipe.results.push(_craftingRecipeInput.results[i]);
        }

        emit CraftingRecipeCreated(_currentRecipeId);

        //Increment currentRecipeId
        _currentRecipeId++;
    }

    /**
     * @dev Helper function to return a crafting recipe
     * @param _recipeId The recipeId to return.
     */
    function getCraftingRecipe(uint256 _recipeId) public view returns (CraftingRecipe memory) {
        return SimpleCraftingStorage.getState().craftingRecipes[_recipeId];
    }

    /**
     * @dev Craft a given recipeId, recipe must be fully allowed.
     * @param _recipeId The recipeId to craft.
     */
    function craft(uint256 _recipeId) public {
        //Create a pointer to this recipe in storage.
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage.getState().craftingRecipes[_recipeId];

        for (uint256 i = 0; i < _craftingRecipe.ingredients.length; i++) {
            //Pull all the ingredients
            Ingredient storage _ingredient = _craftingRecipe.ingredients[i];

            if (_ingredient.tokenType == TOKENTYPE.ERC20) {
                //ERC20
                IERC20Upgradeable(_ingredient.tokenAddress).transferFrom(
                    LibMeta._msgSender(), address(this), _ingredient.tokenQuantity
                );
            }

            if (_ingredient.tokenType == TOKENTYPE.ERC721) {
                //ERC721
                IERC721Upgradeable(_ingredient.tokenAddress).transferFrom(
                    LibMeta._msgSender(), address(this), _ingredient.tokenId
                );
            }

            if (_ingredient.tokenType == TOKENTYPE.ERC1155) {
                //ERC1155
                IERC1155Upgradeable(_ingredient.tokenAddress).safeTransferFrom(
                    LibMeta._msgSender(), address(this), _ingredient.tokenId, _ingredient.tokenQuantity, ""
                );
            }
        }

        for (uint256 i = 0; i < _craftingRecipe.results.length; i++) {
            //Create a pointer to this result in storage.
            Result storage _result = _craftingRecipe.results[i];

            //Ensure this recipe result has been condoned by its' admin.
            if (!LibSimpleCraftingStorage.getCollectionToRecipeIdToAllowed(_result.target, _recipeId)) {
                revert RecipeNotAllowed(_recipeId);
            }

            AddressUpgradeable.functionCall(
                _result.target, abi.encodePacked(_result.selector, abi.encode(LibMeta._msgSender()), _result.params)
            );
        }

        emit CraftingRecipeCrafted(_recipeId, LibMeta._msgSender());
    }

    /**
     * @dev Honestly I do not know what this does, but forge was aggresively telling me to add it.
     * @param interfaceId The interface id.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155ReceiverUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
