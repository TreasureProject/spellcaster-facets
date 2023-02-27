//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FacetInitializable} from "../../utils/FacetInitializable.sol";

import {GuildManagerStorage} from "../../libraries/GuildManagerStorage.sol";
import {IGuildManager} from "src/interfaces/IGuildManager.sol";
import {Modifiers} from "../../Modifiers.sol";
import {OrganizationFacet} from "../../organizations/OrganizationFacet.sol";

abstract contract GuildManagerBase is FacetInitializable, IGuildManager, Modifiers, OrganizationFacet {

    function __GuildManagerBase_init() internal onlyFacetInitializing {
        OrganizationFacet_init();
        _pause();
    }
}