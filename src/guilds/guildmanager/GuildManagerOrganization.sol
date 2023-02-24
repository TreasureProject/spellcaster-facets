//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ADMIN_ROLE} from "../../libraries/LibAccessControlRoles.sol";

import {GuildManagerContracts, GuildManagerStorage} from "./GuildManagerContracts.sol";
import {GuildCreationRule, MaxUsersPerGuildRule, OrganizationInfo} from "src/interfaces/IGuildManager.sol";
import {IGuildToken} from "../guildtoken/IGuildToken.sol";

abstract contract GuildManagerOrganization is GuildManagerContracts {

    function __GuildManagerOrganization_init() internal onlyFacetInitializing {
        GuildManagerContracts.__GuildManagerContracts_init();
    }

    // Creates a new organization. For now, this can only be done by admins on
    // the GuildManager contract.
    function createOrganization(
        string calldata _name,
        string calldata _description,
        uint8 _maxGuildsPerUser,
        uint32 _timeoutAfterLeavingGuild,
        GuildCreationRule _guildCreationRule,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant,
        address _organizationConfigAddress)
    external
    onlyRole(ADMIN_ROLE)
    contractsAreSet
    whenNotPaused
    {
        uint32 _newOrganizationId = GuildManagerStorage.createOrganization();

        GuildManagerStorage.setOrganizationNameAndDescription(_newOrganizationId, _name, _description);
        GuildManagerStorage.setOrganizationAdmin(_newOrganizationId, msg.sender);
        GuildManagerStorage.setOrganizationMaxGuildsPerUser(_newOrganizationId, _maxGuildsPerUser);
        GuildManagerStorage.setOrganizationTimeoutAfterLeavingGuild(_newOrganizationId, _timeoutAfterLeavingGuild);
        GuildManagerStorage.setOrganizationCreationRule(_newOrganizationId, _guildCreationRule);
        GuildManagerStorage.setOrganizationMaxUsersPerGuild(_newOrganizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
        GuildManagerStorage.setOrganizationConfigAddress(_newOrganizationId, _organizationConfigAddress);
    }

    function setOrganizationNameAndDescription(
        uint32 _organizationId,
        string calldata _name,
        string calldata _description)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        GuildManagerStorage.setOrganizationNameAndDescription(_organizationId, _name, _description);
    }

    function setOrganizationAdmin(
        uint32 _organizationId,
        address _admin)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        require(_admin != address(0) && _admin != GuildManagerStorage.getOrganizationInfo(_organizationId).admin);
        GuildManagerStorage.setOrganizationAdmin(_organizationId, _admin);
    }

    function setOrganizationMaxGuildsPerUser(
        uint32 _organizationId,
        uint8 _maxGuildsPerUser)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        GuildManagerStorage.setOrganizationMaxGuildsPerUser(_organizationId, _maxGuildsPerUser);
    }

    function setOrganizationTimeoutAfterLeavingGuild(
        uint32 _organizationId,
        uint32 _timeoutAfterLeavingGuild)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        GuildManagerStorage.setOrganizationTimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
    }

    function setOrganizationCreationRule(
        uint32 _organizationId,
        GuildCreationRule _guildCreationRule)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        GuildManagerStorage.setOrganizationCreationRule(_organizationId, _guildCreationRule);
    }

    function setOrganizationMaxUsersPerGuild(
        uint32 _organizationId,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        GuildManagerStorage.setOrganizationMaxUsersPerGuild(_organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
    }

    function setOrganizationConfigAddress(
        uint32 _organizationId,
        address _organizationConfigAddress)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        GuildManagerStorage.setOrganizationConfigAddress(_organizationId, _organizationConfigAddress);
    }

    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================

    /**
     * @dev Retrieves the stored info for a given organization. Used to wrap the tuple from
     *  calling the mapping directly from external contracts
     * @param _organizationId The organization to return info for
     */
    function getOrganizationInfo(uint32 _organizationId) external view returns(OrganizationInfo memory) {
        return GuildManagerStorage.getOrganizationInfo(_organizationId);
    }

    // =============================================================
    //                         MODIFIERS
    // =============================================================

    modifier onlyOrganizationAdmin(uint32 _organizationId) {
        if(msg.sender != GuildManagerStorage.getOrganizationInfo(_organizationId).admin) {
            revert GuildManagerStorage.NotOrganizationAdmin(msg.sender);
        }

        _;
    }

    modifier onlyValidOrganization(uint32 _organizationId) {
        if(address(0) == GuildManagerStorage.getOrganizationInfo(_organizationId).admin) {
            revert GuildManagerStorage.NonexistantOrganization(_organizationId);
        }

        _;
    }
}