//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import "./libraries/LibSimpleCraftingRecipeAllowlist.sol";
import "./libraries/LibSimpleCraftingStorage.sol";
import "./interfaces/IERC20Consumer.sol";
import "./utilities/AccessControlEnumerableUpgradeableV2.sol";
import "./Modifiers.sol";

import "forge-std/console.sol";

/*
events
Create new recipe
Craft


*/

interface Ownable {
    function owner() external view returns(address);
}

contract SimpleCrafting is ERC1155HolderUpgradeable, AccessControlEnumerableUpgradeableV2 {

    
    function setRecipeToAllowedAsAdmin(address _collection, uint256 _recipeId) public {
        //Ensure they are an admin of this collection.
        require(
            msg.sender == Ownable(_collection).owner() || 
            hasRole(
                keccak256(
                    abi.encodePacked(
                        "ADMIN_ROLE_SIMPLE_CRAFTING_V1_",
                        _collection
                        )
                    ), 
                msg.sender
            ), "User not permitted."
        );

        LibSimpleCraftingRecipeAllowlist.setCollectionToRecipeIdToAllowed(_collection, _recipeId, true);
    }

    function createNewCraftingRecipe(CraftingRecipe calldata _craftingRecipeInput)
        public
    {
        uint256 _currentRecipeId = SimpleCraftingStorage
            .getSimpleCraftingState()
            ._currentRecipeId;

        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage
            .getSimpleCraftingState()
            .craftingRecipes[_currentRecipeId];

        for(uint256 i = 0; i < _craftingRecipeInput.ingredients.length; i++){
            _craftingRecipe.ingredients.push(_craftingRecipeInput.ingredients[i]);
        }

        for(uint256 i = 0; i < _craftingRecipeInput.results.length; i++){
            _craftingRecipe.results.push(_craftingRecipeInput.results[i]);
        }

        _currentRecipeId++;
    }

    function getCraftingRecipe(uint256 _recipeId)
        public
        view
        returns (CraftingRecipe memory)
    {
        return SimpleCraftingStorage.getSimpleCraftingState().craftingRecipes[_recipeId];
    }

    function craft(uint256 _recipeId) public {
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage
            .getSimpleCraftingState()
            .craftingRecipes[_recipeId];

        for (uint256 i = 0; i < _craftingRecipe.ingredients.length; i++) {
            //Pull all the ingredients
            Ingredient storage _ingredient = _craftingRecipe.ingredients[i];

            if (_ingredient.tokenType == TOKENTYPE.ERC20) {
                //ERC20
                IERC20Upgradeable(_ingredient.tokenAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _ingredient.tokenQuantity
                );
            }

            if (_ingredient.tokenType == TOKENTYPE.ERC721) {
                //ERC721
                IERC721Upgradeable(_ingredient.tokenAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _ingredient.tokenId
                );
            }

            if (_ingredient.tokenType == TOKENTYPE.ERC1155) {
                //ERC1155
                IERC1155Upgradeable(_ingredient.tokenAddress).safeTransferFrom(
                    msg.sender,
                    address(this),
                    _ingredient.tokenId,
                    _ingredient.tokenQuantity,
                    ""
                );
            }
        }

        for (uint256 i = 0; i < _craftingRecipe.results.length; i++) {
            Result storage _result = _craftingRecipe.results[i];

            require(LibSimpleCraftingRecipeAllowlist.getCollectionToRecipeIdToAllowed(_result.target, _recipeId), "Recipe not allowed yet!");

            (bool success, bytes memory data) = address(_result.target).call{
                value: 0
            }(
                abi.encodePacked(
                    _result.selector,
                    abi.encode(msg.sender),
                    _result.params
                )
            );
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155ReceiverUpgradeable, AccessControlEnumerableUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
