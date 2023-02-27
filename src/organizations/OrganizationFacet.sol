// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Modifiers} from "../Modifiers.sol";
import {FacetInitializable} from "../utils/FacetInitializable.sol";
import {LibUtilities} from "../libraries/LibUtilities.sol";
import {LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE} from "../libraries/LibAccessControlRoles.sol";
import {LibMeta} from "../libraries/LibMeta.sol";

import {IOrganizationManager, OrganizationInfo} from "../interfaces/IOrganizationManager.sol";
import {OrganizationManagerStorage} from "../libraries/OrganizationManagerStorage.sol";

/**
 * @title Organization Management Facet contract.
 * @dev Use this facet to consume the ability to segment feature adoption by organization. 
 */
contract OrganizationFacet is FacetInitializable, Modifiers, IOrganizationManager {

    /**
     * @dev Initialize the facet. Can be called externally or internally.
     * Ideally referenced in an initialization script facet
     */
    function OrganizationFacet_init() public facetInitializer(keccak256("OrganizationFacet")) {
        OrganizationManagerStorage.layout().organizationIdCur = 1;
    }

    // =============================================================
    //                        Public functions
    // =============================================================

    /**
     * @inheritdoc IOrganizationManager
     */
    function createOrganization(
        string calldata _name,
        string calldata _description)
    public
    override
    onlyRole(ADMIN_ROLE)
    whenNotPaused
    returns(uint32 newOrganizationId_)
    {
        newOrganizationId_ = OrganizationManagerStorage.createOrganization(_name, _description);
    }

    /**
     * @inheritdoc IOrganizationManager
     */
    function setOrganizationNameAndDescription(
        uint32 _organizationId,
        string calldata _name,
        string calldata _description)
    public
    override
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        OrganizationManagerStorage.setOrganizationNameAndDescription(_organizationId, _name, _description);
    }

    /**
     * @inheritdoc IOrganizationManager
     */
    function setOrganizationAdmin(
        uint32 _organizationId,
        address _admin)
    public
    override
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        OrganizationManagerStorage.setOrganizationAdmin(_organizationId, _admin);
    }

    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================

    /**
     * @inheritdoc IOrganizationManager
     */
    function getOrganizationInfo(uint32 _organizationId) external override view returns(OrganizationInfo memory) {
        return OrganizationManagerStorage.getOrganizationInfo(_organizationId);
    }

    // =============================================================
    //                         MODIFIERS
    // =============================================================

    modifier onlyOrganizationAdmin(uint32 _organizationId) {
        OrganizationManagerStorage.requireOrganizationAdmin(msg.sender, _organizationId);
        _;
    }

    modifier onlyValidOrganization(uint32 _organizationId) {
        if(OrganizationManagerStorage.getOrganizationInfo(_organizationId).admin == address(0)) {
            revert OrganizationManagerStorage.NonexistantOrganization(_organizationId);
        }
        _;
    }
}
