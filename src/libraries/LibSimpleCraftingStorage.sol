//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../crafting/SimpleCraftingStorage.sol";

library LibSimpleCraftingStorage {

    function getCollectionToRecipeIdToAllowed(address _collection, uint256 _recipeId) internal view returns(bool){
        return SimpleCraftingStorage.getState().collectionToRecipeIdToAllowed[_collection][_recipeId];
    } 

    function setCollectionToRecipeIdToAllowed(address _collection, uint256 _recipeId, bool _allowed) internal{
        SimpleCraftingStorage.getState().collectionToRecipeIdToAllowed[_collection][_recipeId] = _allowed;
    }  
}

    

    