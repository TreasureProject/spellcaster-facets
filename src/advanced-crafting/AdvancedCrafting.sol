//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { StartCraftingParams, LibAdvancedCrafting } from "./LibAdvancedCrafting.sol";
import { AdvancedCraftingBase } from "./AdvancedCraftingBase.sol";
import { CreateRecipeArgs } from "src/interfaces/IAdvancedCrafting.sol";

contract AdvancedCrafting is AdvancedCraftingBase {
    function AdvancedCrafting_init(address _systemDelegateApprover)
        external
        facetInitializer(keccak256("GuildManager"))
    {
        __SupportsMetaTx_init(_systemDelegateApprover);
        __AdvancedCraftingBase_init();

        LibAdvancedCrafting.AdvancedCrafting_init();
    }

    function createRecipe(bytes32 _organizationId, CreateRecipeArgs calldata _recipeArgs) external {
        LibAdvancedCrafting.createRecipe(_organizationId, _recipeArgs);
    }

    function startCraftingBatch(StartCraftingParams[] calldata _params) external {
        LibAdvancedCrafting.startCraftingBatch(_params);
    }

    function endCraftingBatch(uint64[] calldata _craftingIds) external {
        LibAdvancedCrafting.endCraftingBatch(_craftingIds);
    }

    function deleteRecipe(uint64 _recipeId) external {
        LibAdvancedCrafting.deleteRecipe(_recipeId);
    }
}