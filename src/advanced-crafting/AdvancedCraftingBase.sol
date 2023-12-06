//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FacetInitializable } from "src/utils/FacetInitializable.sol";

import { IAdvancedCrafting } from "src/interfaces/IAdvancedCrafting.sol";
import { Modifiers } from "src/Modifiers.sol";
import { SupportsMetaTx } from "src/metatx/SupportsMetaTx.sol";
import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

abstract contract AdvancedCraftingBase is
    IAdvancedCrafting,
    FacetInitializable,
    Modifiers,
    SupportsMetaTx,
    ERC1155HolderUpgradeable
{
    function __AdvancedCraftingBase_init() internal onlyFacetInitializing {
        ERC1155HolderUpgradeable.__ERC1155Holder_init();
    }
}
