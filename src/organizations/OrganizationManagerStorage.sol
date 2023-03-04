// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    OrganizationInfo
} from "src/interfaces/IOrganizationManager.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";
import {ICustomGuildManager} from "src/interfaces/ICustomGuildManager.sol";

/// @title Library for handling storage interfacing for Guild Manager contracts
library OrganizationManagerStorage {
    event OrganizationCreated(bytes32 organizationId);
    event OrganizationInfoUpdated(bytes32 organizationId, string name, string description);
    event OrganizationAdminUpdated(bytes32 organizationId, address admin);

    error NotOrganizationAdmin(address sender);
    error InvalidOrganizationAdmin(address admin);
    error NonexistantOrganization(bytes32 organizationId);
    error OrganizationAlreadyExists(bytes32 organizationId);

    struct Layout {
        mapping(bytes32 => OrganizationInfo) organizationIdToInfo;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.organization.manager");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

}
