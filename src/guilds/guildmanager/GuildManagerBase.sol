//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FacetInitializable} from "src/utils/FacetInitializable.sol";

import {LibGuildManager} from "src/libraries/LibGuildManager.sol";
import {IGuildManager} from "src/interfaces/IGuildManager.sol";
import {Modifiers} from "src/Modifiers.sol";
import {OrganizationFacet} from "src/organizations/OrganizationFacet.sol";

abstract contract GuildManagerBase is FacetInitializable, IGuildManager, Modifiers, OrganizationFacet {

    function __GuildManagerBase_init() internal onlyFacetInitializing {
        OrganizationFacet_init();
        _pause();
    }
}