//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/WorldStateStorage.sol";
import "./interfaces/IERC20Consumer.sol";
import "hardhat/console.sol";


enum TOKENTYPE {
    ERC20,
    ERC721,
    ERC1155,
    
}

struct FunctionalResult{
    address target;
    bytes4 signature;
    bytes callData;
}


struct Ingredient {
    address tokenAddress;
    TOKENTYPE tokenType;

    //One or both of these will be used depending on the tokentype.
    uint256 tokenId;
    uint256 tokenQuantity;
}

struct Result {
    FunctionalResult functionalResult;
}


struct CraftingRecipe{
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



    function createNewRecipe(CraftingRecipe memory _craftingRecipe) public {
        craftingRecipes[_currentRecipeId] = _craftingRecipe;
        _currentRecipeId++;
    }

    function getRecipe(uint256 _recipeId) public view returns(CraftingRecipe memory) {
        return craftingRecipes[_recipeId];
    }

}
