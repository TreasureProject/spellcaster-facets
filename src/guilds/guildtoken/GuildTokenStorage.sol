//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibBBase64 } from "src/libraries/LibBBase64.sol";
import { IGuildManager } from "src/interfaces/IGuildManager.sol";

/**
 * @title GuildTokenStorage library
 * @notice This library contains the storage layout and events/errors for the GuildTokenFacet contract.
 */
library GuildTokenStorage {
    struct Layout {
        /**
         * @notice The manager that created this guild collection.
         */
        IGuildManager guildManager;
        /**
         * @notice The organization this 1155 collection is associated to.
         */
        bytes32 organizationId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.guildtoken");

    function layout() internal pure returns (Layout storage l_) {
        bytes32 _position = FACET_STORAGE_POSITION;
        assembly {
            l_.slot := _position
        }
    }

    /**
     * @dev Emitted when a guild organization has already been initialized.
     * @param organizationId The ID of the guild organization
     */
    error GuildOrganizationAlreadyInitialized(bytes32 organizationId);
}
