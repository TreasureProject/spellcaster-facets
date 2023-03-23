// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Modifiers } from "../Modifiers.sol";
import { FacetInitializable } from "../utils/FacetInitializable.sol";
import { LibUtilities } from "../libraries/LibUtilities.sol";
import { LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE } from "../libraries/LibAccessControlRoles.sol";
import { LibMeta } from "../libraries/LibMeta.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { SupportsMetaTx } from "src/metatx/SupportsMetaTx.sol";

import { IOrganizationManager, OrganizationInfo } from "src/interfaces/IOrganizationManager.sol";
import { OrganizationManagerStorage } from "./OrganizationManagerStorage.sol";

/**
 * @title Organization Management Facet contract.
 * @dev Use this facet to consume the ability to segment feature adoption by organization.
 */
contract OrganizationFacet is FacetInitializable, Modifiers, IOrganizationManager, SupportsMetaTx {
    /**
     * @dev Initialize the facet. Can be called externally or internally.
     * Ideally referenced in an initialization script facet
     */
    function OrganizationFacet_init() public facetInitializer(keccak256("OrganizationFacet")) { }

    // =============================================================
    //                        Public functions
    // =============================================================

    /**
     * @inheritdoc IOrganizationManager
     */
    function createOrganization(
        bytes32 _newOrganizationId,
        string calldata _name,
        string calldata _description
    ) public override onlyRole(ADMIN_ROLE) whenNotPaused supportsMetaTx(_newOrganizationId) {
        LibOrganizationManager.createOrganization(_newOrganizationId, _name, _description);
    }

    /**
     * @inheritdoc IOrganizationManager
     */
    function setOrganizationNameAndDescription(
        bytes32 _organizationId,
        string calldata _name,
        string calldata _description
    ) public override whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId) {
        LibOrganizationManager.setOrganizationNameAndDescription(_organizationId, _name, _description);
    }

    /**
     * @inheritdoc IOrganizationManager
     */
    function setOrganizationAdmin(
        bytes32 _organizationId,
        address _admin
    ) public override whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId) {
        LibOrganizationManager.setOrganizationAdmin(_organizationId, _admin);
    }

    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================

    /**
     * @inheritdoc IOrganizationManager
     */
    function getOrganizationInfo(bytes32 _organizationId) external view override returns (OrganizationInfo memory) {
        return LibOrganizationManager.getOrganizationInfo(_organizationId);
    }

    // =============================================================
    //                         MODIFIERS
    // =============================================================

    modifier onlyOrganizationAdmin(bytes32 _organizationId) {
        LibOrganizationManager.requireOrganizationAdmin(msg.sender, _organizationId);
        _;
    }

    modifier onlyValidOrganization(bytes32 _organizationId) {
        if (LibOrganizationManager.getOrganizationInfo(_organizationId).admin == address(0)) {
            revert OrganizationManagerStorage.NonexistantOrganization(_organizationId);
        }
        _;
    }
}
