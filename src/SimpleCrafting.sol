//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import "./libraries/SimpleCraftingStorage.sol";
import "./interfaces/IERC20Consumer.sol";

import "forge-std/console.sol";

contract SimpleCrafting is ERC1155HolderUpgradeable {

    function createNewCraftingRecipe(CraftingRecipe calldata _craftingRecipe) public {
        uint256 _currentRecipeId = SimpleCraftingStorage.getState()._currentRecipeId;

        SimpleCraftingStorage.getState().craftingRecipes[_currentRecipeId] = _craftingRecipe;

        _currentRecipeId++;
    }

    function getCraftingRecipe(uint256 _recipeId)
        public
        view
        returns (CraftingRecipe memory)
    {
        return SimpleCraftingStorage.getState().craftingRecipes[_recipeId];
    }

    function craft(uint256 _recipeId) public {
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage.getState().craftingRecipes[_recipeId];

        //10 minutes
        //TODO
        //Adjust anointment timelock method.
        require(block.timestamp >= _craftingRecipe.anointmentTime);

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


            (bool success, bytes memory data) = address(_result.target).call{
                value: 0,
                gas: 150000
            }(abi.encodePacked(_result.selector, abi.encode(msg.sender), _result.params));
        }
    }

    function anoint(
        uint256 _recipeId /*onlyAdmin(_recipeId)*/
    ) public {
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage.getState().craftingRecipes[_recipeId];

        _craftingRecipe.anointed = true;
        _craftingRecipe.anointmentTime = block.timestamp;
    }

    function unanoint(
        uint256 _recipeId /*onlyAdmin(_recipeId)*/
    ) public {
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage.getState().craftingRecipes[_recipeId];

        _craftingRecipe.anointed = false;
        _craftingRecipe.anointmentTime = 0;
    }
}
