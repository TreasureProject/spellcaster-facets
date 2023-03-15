//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibSimpleCraftingRecipeAllowlist {

    struct State {
        mapping(address => mapping(uint256 => bool)) collectionToRecipeIdToAllowed;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("simple.crafting.recipe.allowlist.diamond");

    function getState() internal pure returns (State storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function getCollectionToRecipeIdToAllowed(address _collection, uint256 _recipeId) internal view returns(bool){
        return getState().collectionToRecipeIdToAllowed[_collection][_recipeId];
    } 

    function setCollectionToRecipeIdToAllowed(address _collection, uint256 _recipeId, bool _allowed) internal{
        getState().collectionToRecipeIdToAllowed[_collection][_recipeId] = _allowed;
    }  
}

    

    