//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FacetInitializable} from "../../utils/FacetInitializable.sol";

import {GuildManagerStorage} from "../../libraries/GuildManagerStorage.sol";
import {IGuildManager} from "./IGuildManager.sol";
import {Modifiers} from "../../Modifiers.sol";

abstract contract GuildManagerState is FacetInitializable, IGuildManager, Modifiers {

    function __GuildManagerState_init() internal onlyFacetInitializing {
        _pause();

        GuildManagerStorage.layout().organizationIdCur = 1;
    }
}