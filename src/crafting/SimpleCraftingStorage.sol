//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { CraftingRecipe } from "../interfaces/ISimpleCrafting.sol";

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
        uint256 currentRecipeId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.simple.crafting");

    /**
     * @dev Returns the state struct at a given storage position.
     */
    function getState() internal pure returns (SimpleCraftingState storage l_) {
        bytes32 _position = FACET_STORAGE_POSITION;
        assembly {
            l_.slot := _position
        }
    }
}
