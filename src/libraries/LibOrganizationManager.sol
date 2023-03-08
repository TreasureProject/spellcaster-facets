// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    OrganizationInfo
} from "src/interfaces/IOrganizationManager.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";
import {ICustomGuildManager} from "src/interfaces/ICustomGuildManager.sol";
import {OrganizationManagerStorage} from "src/organizations/OrganizationManagerStorage.sol";
import {LibMeta} from "src/libraries/LibMeta.sol";

/// @title Library for handling storage interfacing for Guild Manager contracts
library LibOrganizationManager {
    // =============================================================
    //                      Getters/Setters
    // =============================================================

    /**
     * @param _orgId The id of the org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getOrganizationInfo(bytes32 _orgId) internal view returns (OrganizationInfo storage info_) {
        info_ = OrganizationManagerStorage.layout().organizationIdToInfo[_orgId];
    }

    /**
     * @dev Assumes that sender permissions have already been checked
     */
    function setOrganizationNameAndDescription(
        bytes32 _organizationId,
        string calldata _name,
        string calldata _description)
    internal
    {
        OrganizationInfo storage _info = getOrganizationInfo(_organizationId);
        _info.name = _name;
        _info.description = _description;
        emit OrganizationManagerStorage.OrganizationInfoUpdated(_organizationId, _name, _description);
    }

    /**
     * @dev Assumes that sender permissions have already been checked
     */
    function setOrganizationAdmin(
        bytes32 _organizationId,
        address _admin)
    internal
    {
        if(_admin == address(0) || _admin == getOrganizationInfo(_organizationId).admin) {
            revert OrganizationManagerStorage.InvalidOrganizationAdmin(_admin);
        }
        getOrganizationInfo(_organizationId).admin = _admin;
        emit OrganizationManagerStorage.OrganizationAdminUpdated(_organizationId, _admin);
    }

    // =============================================================
    //                        Create Functions
    // =============================================================

    function createOrganization(
        bytes32 _newOrganizationId,
        string calldata _name,
        string calldata _description)
    internal
    {
        if(getOrganizationInfo(_newOrganizationId).admin != address(0)) {
            revert OrganizationManagerStorage.OrganizationAlreadyExists(_newOrganizationId);
        }
        setOrganizationNameAndDescription(_newOrganizationId, _name, _description);
        setOrganizationAdmin(_newOrganizationId, LibMeta._msgSender());

        emit OrganizationManagerStorage.OrganizationCreated(_newOrganizationId);
    }

    // =============================================================
    //                       Helper Functionr
    // =============================================================

    function requireOrganizationAdmin(address _sender, bytes32 _organizationId) internal view {
        if(_sender != getOrganizationInfo(_organizationId).admin) {
            revert OrganizationManagerStorage.NotOrganizationAdmin(LibMeta._msgSender());
        }
    }

    // =============================================================
    //                         Modifiers
    // =============================================================

    modifier onlyOrganizationAdmin(bytes32 _organizationId) {
        requireOrganizationAdmin(LibMeta._msgSender(), _organizationId);
        _;
    }

}
