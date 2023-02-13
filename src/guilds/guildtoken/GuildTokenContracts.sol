//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ADMIN_ROLE} from "../../libraries/LibAccessControlRoles.sol";
import {GuildTokenState, IGuildManager} from "./GuildTokenState.sol";

abstract contract GuildTokenContracts is GuildTokenState {

    function __GuildTokenContracts_init() internal initializer {
        GuildTokenState.__GuildTokenState_init();
    }

    function setContracts(
        address _guildManagerAddress)
    external onlyRole(ADMIN_ROLE)
    {
        guildManager = IGuildManager(_guildManagerAddress);
    }

    modifier contractsAreSet() {
        require(areContractsSet(), "GuildToken: Contracts aren't set");
        _;
    }

    function areContractsSet() public view returns(bool) {
        return address(guildManager) != address(0);
    }
}