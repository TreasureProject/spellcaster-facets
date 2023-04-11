//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../crafting/SimpleCraftingStorage.sol";

library LibSimpleCrafting {
    /**
     * @dev Returns if a given recipeId for a collection is allowed
     * @param _collection The collection to check.
     * @param _recipeId The recipeId.
     */
    function getCollectionToRecipeIdToAllowed(address _collection, uint256 _recipeId) internal view returns (bool) {
        return SimpleCraftingStorage.getState().collectionToRecipeIdToAllowed[_collection][_recipeId];
    }

    /**
     * @dev sets a given recipeId for a collection to boolean
     * @param _collection The collection to set.
     * @param _recipeId The recipeId.
     * @param _allowed Whether this recipe is allowed.
     */
    function setCollectionToRecipeIdToAllowed(address _collection, uint256 _recipeId, bool _allowed) internal {
        SimpleCraftingStorage.getState().collectionToRecipeIdToAllowed[_collection][_recipeId] = _allowed;
    }
}
