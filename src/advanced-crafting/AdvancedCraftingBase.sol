//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FacetInitializable } from "src/utils/FacetInitializable.sol";

import { IAdvancedCrafting } from "src/interfaces/IAdvancedCrafting.sol";
import { Modifiers } from "src/Modifiers.sol";
import { SupportsMetaTx } from "src/metatx/SupportsMetaTx.sol";

abstract contract AdvancedCraftingBase is IAdvancedCrafting, FacetInitializable, Modifiers, SupportsMetaTx {
    function __AdvancedCraftingBase_init() internal onlyFacetInitializing {
        _pause();
    }
}
