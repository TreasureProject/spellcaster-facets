//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibAdvancedCrafting } from "src/libraries/LibAdvancedCrafting.sol";
import { AdvancedCraftingBase } from "./AdvancedCraftingBase.sol";
import { CreateRecipeArgs } from "src/interfaces/IAdvancedCrafting.sol";

contract AdvancedCrafting is AdvancedCraftingBase {
    function AdvancedCrafting_init(address _systemDelegateApprover)
        external
        facetInitializer(keccak256("GuildManager"))
    {
        __SupportsMetaTx_init(_systemDelegateApprover);
        __AdvancedCraftingBase_init();

        LibAdvancedCrafting.setRecipeIdCur(1);
        LibAdvancedCrafting.setCraftingIdCur(1);
    }

    function createRecipe(bytes32 _organizationId, CreateRecipeArgs calldata _recipeArgs) external {
        LibAdvancedCrafting.createRecipe(_organizationId, _recipeArgs);
    }

    function deleteRecipe(uint64 _recipeId) external {
        LibAdvancedCrafting.deleteRecipe(_recipeId);
    }
}
