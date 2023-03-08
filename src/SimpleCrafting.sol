//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import "./libraries/SimpleCraftingStorage.sol";
import "./interfaces/IERC20Consumer.sol";
import "./utilities/AccessControlEnumerableUpgradeableV2.sol";

import "forge-std/console.sol";

contract SimpleCrafting is ERC1155HolderUpgradeable, AccessControlEnumerableUpgradeableV2 {
    function createNewCraftingRecipe(CraftingRecipe calldata _craftingRecipeInput)
        public
    {
        uint256 _currentRecipeId = SimpleCraftingStorage
            .getState()
            ._currentRecipeId;

        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage
            .getState()
            .craftingRecipes[_currentRecipeId];

        _craftingRecipe.anointmentTime = 2**256 - 1;

        for(uint256 i = 0;i < _craftingRecipeInput.ingredients.length; i++){
            _craftingRecipe.ingredients.push(_craftingRecipeInput.ingredients[i]);
        }

        for(uint256 i = 0;i < _craftingRecipeInput.results.length; i++){
            _craftingRecipe.results.push(_craftingRecipeInput.results[i]);
        }

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
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage
            .getState()
            .craftingRecipes[_recipeId];

        //10 minutes
        //TODO
        //Adjust anointment timelock method.
        require(block.timestamp >= _craftingRecipe.anointmentTime, "Not past anointment time.");

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
            }(
                abi.encodePacked(
                    _result.selector,
                    abi.encode(msg.sender),
                    _result.params
                )
            );
        }
    }

    modifier onlyCollectionAdmin(uint256 _recipeId) {
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage
            .getState()
            .craftingRecipes[_recipeId];

            
        for (uint256 i = 0; i < _craftingRecipe.results.length; i++) {
            //Pull all the results
            Result storage _result = _craftingRecipe.results[i];
            require(hasRole(keccak256(abi.encodePacked("ADMIN_ROLE_",_result.target)), msg.sender), "Does not have role!");
        }

        _;
    }

    function anoint(
        uint256 _recipeId,
        uint256 _anointmentTime
    ) public onlyCollectionAdmin(_recipeId) {
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage
            .getState()
            .craftingRecipes[_recipeId];

        _craftingRecipe.anointmentTime = _anointmentTime;
    }

    function unanoint(
        uint256 _recipeId 
    ) public onlyCollectionAdmin(_recipeId) {
        CraftingRecipe storage _craftingRecipe = SimpleCraftingStorage
            .getState()
            .craftingRecipes[_recipeId];

        _craftingRecipe.anointmentTime = 2**256 - 1;
    }

    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155ReceiverUpgradeable, AccessControlEnumerableUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
