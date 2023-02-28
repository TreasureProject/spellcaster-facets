// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    OrganizationInfo
} from "src/interfaces/IOrganizationManager.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";
import {ICustomGuildManager} from "src/interfaces/ICustomGuildManager.sol";
import {OrganizationManagerStorage} from "src/organizations/OrganizationManagerStorage.sol";

/// @title Library for handling storage interfacing for Guild Manager contracts
library LibOrganizationManager {
    // =============================================================
    //                      Getters/Setters
    // =============================================================

    function getOrganizationIdCur() internal view returns (uint32 orgIdCur_) {
        orgIdCur_ = OrganizationManagerStorage.layout().organizationIdCur;
    }

    /**
     * @param _orgId The id of the org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getOrganizationInfo(uint32 _orgId) internal view returns (OrganizationInfo storage info_) {
        info_ = OrganizationManagerStorage.layout().organizationIdToInfo[_orgId];
    }

    /**
     * @dev Assumes that sender permissions have already been checked
     */
    function setOrganizationNameAndDescription(
        uint32 _organizationId,
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
        uint32 _organizationId,
        address _admin)
    internal
    {
        if(_admin == address(0) || _admin == OrganizationManagerStorage.getOrganizationInfo(_organizationId).admin) {
            revert OrganizationManagerStorage.InvalidOrganizationAdmin(_admin);
        }
        getOrganizationInfo(_organizationId).admin = _admin;
        emit OrganizationManagerStorage.OrganizationAdminUpdated(_organizationId, _admin);
    }

    // =============================================================
    //                        Create Functions
    // =============================================================

    function createOrganization(
        string calldata _name,
        string calldata _description)
    internal
    returns(uint32 newOrganizationId_)
    {
        OrganizationManagerStorage.Layout storage l = OrganizationManagerStorage.layout();

        newOrganizationId_ = l.organizationIdCur;
        l.organizationIdCur++;

        setOrganizationNameAndDescription(newOrganizationId_, _name, _description);
        setOrganizationAdmin(newOrganizationId_, msg.sender);

        emit OrganizationManagerStorage.OrganizationCreated(newOrganizationId_);
    }

    // =============================================================
    //                       Helper Functionr
    // =============================================================

    function requireOrganizationAdmin(address _sender, uint32 _organizationId) internal view {
        if(_sender != getOrganizationInfo(_organizationId).admin) {
            revert OrganizationManagerStorage.NotOrganizationAdmin(msg.sender);
        }
    }

    // =============================================================
    //                         Modifiers
    // =============================================================

    modifier onlyOrganizationAdmin(uint32 _organizationId) {
        requireOrganizationAdmin(msg.sender, _organizationId);
        _;
    }

}
