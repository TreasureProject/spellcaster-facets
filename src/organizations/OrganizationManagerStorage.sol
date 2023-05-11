// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { OrganizationInfo } from "src/interfaces/IOrganizationManager.sol";
import { IGuildToken } from "src/interfaces/IGuildToken.sol";
import { ICustomGuildManager } from "src/interfaces/ICustomGuildManager.sol";

/**
 * @title OrganizationManagerStorage library
 * @notice This library contains the storage layout and events/errors for the OrganizationFacet contract.
 */
library OrganizationManagerStorage {
    struct Layout {
        mapping(bytes32 => OrganizationInfo) organizationIdToInfo;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.organization.manager");

    function layout() internal pure returns (Layout storage l_) {
        bytes32 _position = FACET_STORAGE_POSITION;
        assembly {
            l_.slot := _position
        }
    }

    /**
     * @dev Emitted when a new organization is created.
     * @param organizationId The ID of the newly created organization
     */
    event OrganizationCreated(bytes32 organizationId);

    /**
     * @dev Emitted when an organization's information is updated.
     * @param organizationId The ID of the organization being updated
     * @param name The updated organization name
     * @param description The updated organization description
     */
    event OrganizationInfoUpdated(bytes32 organizationId, string name, string description);

    /**
     * @dev Emitted when an organization's admin is updated.
     * @param organizationId The ID of the organization being updated
     * @param admin The updated organization admin address
     */
    event OrganizationAdminUpdated(bytes32 organizationId, address admin);

    /**
     * @dev Emitted when the sender is not an organization admin and tries to perform an admin-only action.
     * @param sender The address of the sender attempting the action
     */
    error NotOrganizationAdmin(address sender);

    /**
     * @dev Emitted when an invalid organization admin address is provided.
     * @param admin The invalid admin address
     */
    error InvalidOrganizationAdmin(address admin);

    /**
     * @dev Emitted when an organization does not exist.
     * @param organizationId The ID of the non-existent organization
     */
    error NonexistantOrganization(bytes32 organizationId);

    /**
     * @dev Emitted when an organization already exists.
     * @param organizationId The ID of the existing organization
     */
    error OrganizationAlreadyExists(bytes32 organizationId);
}
