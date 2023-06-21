//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FacetInitializable } from "src/utils/FacetInitializable.sol";

import { LibGuildManager } from "src/libraries/LibGuildManager.sol";
import { IGuildManager } from "src/interfaces/IGuildManager.sol";
import { Modifiers } from "src/Modifiers.sol";
import { SupportsMetaTx } from "src/metatx/SupportsMetaTx.sol";

abstract contract GuildManagerBase is FacetInitializable, IGuildManager, Modifiers, SupportsMetaTx {
    function __GuildManagerBase_init() internal onlyFacetInitializing {
        _pause();
    }
}
