//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ADMIN_ROLE } from "src/libraries/LibAccessControlRoles.sol";
import { GuildTokenBase, IGuildToken, LibGuildToken } from "./GuildTokenBase.sol";

abstract contract GuildTokenContracts is GuildTokenBase {
    function __GuildTokenContracts_init() internal onlyFacetInitializing {
        GuildTokenBase.__GuildTokenBase_init();
    }

    function setContracts(address _guildManagerAddress) external onlyRole(ADMIN_ROLE) {
        LibGuildToken.setGuildManager(_guildManagerAddress);
    }

    modifier contractsAreSet() {
        require(areContractsSet(), "GuildToken: Contracts aren't set");
        _;
    }

    function areContractsSet() public view returns (bool) {
        return address(LibGuildToken.getGuildManager()) != address(0);
    }
}
