//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibBBase64} from "src/libraries/LibBBase64.sol";
import {IGuildManager} from "src/interfaces/IGuildManager.sol";

library GuildTokenStorage {

    error GuildOrganizationAlreadyInitialized(uint32 organizationId);

    struct Layout {
        /**
         * @notice The manager that created this guild collection.
        */
        IGuildManager guildManager;
        /**
         * @notice The organization this 1155 collection is associated to.
        */
        uint32 organizationId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.guildtoken");

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}

    

    