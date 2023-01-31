//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import "./libraries/WorldSimpleCraftingStorage.sol";
import "./interfaces/IERC20Consumer.sol";

contract WorldSimpleCrafting {
    
    function createNewRecipe(CraftingRecipe calldata _craftingRecipe) public {
        uint256 _currentRecipeId = getAndIncrementCurrentRecipeId();

        setCraftingRecipe(_currentRecipeId, _craftingRecipe);
    }

    function getCraftingRecipe(uint256 _recipeId)
        public
        view
        returns (CraftingRecipe memory)
    {
        return getCraftingRecipe(_recipeId);
    }

    function craft(uint256 _recipeId) public {
        CraftingRecipe memory _craftingRecipe = getCraftingRecipe(_recipeId);

        //10 minutes
        //TODO
        //Adjust anointment timelock method.
        require(block.timestamp >= _craftingRecipe.anointmentTime + 600);

        for (uint256 i = 0; i < _craftingRecipe.ingredients.length; i++) {
            //Pull all the ingredients
            Ingredient memory _ingredient = _craftingRecipe.ingredients[i];

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
            Result memory _result = _craftingRecipe.results[i];

            (bool success, bytes memory data) = address(_result.target).call{
                value: 0,
                gas: 150000
            }(abi.encodeWithSelector(_result.selector, _result.params));
        }
    }

    function anoint(uint256 _recipeId) public /*onlyAdmin(_recipeId)*/ {
        craftingRecipes[_recipeId].anointed = true;
        craftingRecipes[_recipeId].anointmentTime = block.timestamp;
    }

    function unanoint(uint256 _recipeId)  public /*onlyAdmin(_recipeId)*/ {
        craftingRecipes[_recipeId].anointed = false;
        craftingRecipes[_recipeId].anointmentTime = 0;
    }
}
