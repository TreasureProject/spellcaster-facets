//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ADMIN_ROLE} from "../../libraries/LibAccessControlRoles.sol";
import {GuildManagerBase, GuildManagerStorage, IGuildManager} from "./GuildManagerBase.sol";

abstract contract GuildManagerContracts is GuildManagerBase {

    function __GuildManagerContracts_init() internal onlyFacetInitializing {
        GuildManagerBase.__GuildManagerBase_init();
    }

    function setContracts(
        address _guildTokenImplementationAddress)
    external onlyRole(ADMIN_ROLE)
    {
        GuildManagerStorage.setGuildTokenBeacon(_guildTokenImplementationAddress);
    }

    modifier contractsAreSet() {
        require(areContractsSet(), "GuildManager: Contracts aren't set");
        _;
    }

    function areContractsSet() public view returns(bool) {
        return address(GuildManagerStorage.getGuildTokenBeacon()) != address(0);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildTokenImplementation() external view returns(address) {
        // Beacon hasn't been setup yet.
        if(address(GuildManagerStorage.getGuildTokenBeacon()) == address(0)) {
            return address(0);
        }

        return GuildManagerStorage.getGuildTokenBeacon().implementation();
    }
}