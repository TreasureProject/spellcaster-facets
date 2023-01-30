//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import "./libraries/WorldStakingStorage.sol";
import "./interfaces/IERC20Consumer.sol";

enum TOKENTYPE {
    ERC20,
    ERC721,
    ERC1155
}

struct Ingredient {
    address tokenAddress;
    TOKENTYPE tokenType;
    //One or both of these will be used depending on the tokentype.
    uint256 tokenId;
    uint256 tokenQuantity;
}

struct Result {
    address target;
    bytes4 selector;
    bytes params;
}

struct CraftingRecipe {
    //Store array of essential ingredients
    Ingredient[] ingredients;
    //Store array of outputs
    Result[] results;
    //Store whether this has been anointed. Defaults to false.
    bool anointed;
    //Store when this was anointed, must have been more than x time ago.
    uint256 anointmentTime;
}

contract WorldSimpleCrafting {
    mapping(uint256 => CraftingRecipe) internal craftingRecipes;

    uint256 _currentRecipeId = 1;

    function createNewRecipe(CraftingRecipe calldata _craftingRecipe) public {
        craftingRecipes[_currentRecipeId] = _craftingRecipe;
        _currentRecipeId++;
    }

    function getRecipe(uint256 _recipeId)
        public
        view
        returns (CraftingRecipe memory)
    {
        return craftingRecipes[_recipeId];
    }

    function craft(uint256 _recipeId) public {
        CraftingRecipe memory _craftingRecipe = craftingRecipes[_recipeId];

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
