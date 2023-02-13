//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ADMIN_ROLE} from "../../libraries/LibAccessControlRoles.sol";
import {GuildManagerState, UpgradeableBeacon} from "./GuildManagerState.sol";

abstract contract GuildManagerContracts is GuildManagerState {

    function __GuildManagerContracts_init() internal onlyFacetInitializing {
        GuildManagerState.__GuildManagerState_init();
    }

    function setContracts(
        address _guildTokenImplementationAddress)
    external onlyRole(ADMIN_ROLE)
    {
        if(address(guildTokenBeacon) == address(0)) {
            guildTokenBeacon = new UpgradeableBeacon(_guildTokenImplementationAddress);
        } else if(guildTokenBeacon.implementation() != _guildTokenImplementationAddress) {
            guildTokenBeacon.upgradeTo(_guildTokenImplementationAddress);
        }
    }

    modifier contractsAreSet() {
        require(areContractsSet(), "GuildManager: Contracts aren't set");
        _;
    }

    function areContractsSet() public view returns(bool) {
        return address(guildTokenBeacon) != address(0);
    }

    function guildTokenImplementation() external view returns(address) {
        // Beacon hasn't been setup yet.
        //
        if(address(guildTokenBeacon) == address(0)) {
            return address(0);
        }

        return guildTokenBeacon.implementation();
    }
}