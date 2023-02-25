//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ADMIN_ROLE} from "../../libraries/LibAccessControlRoles.sol";

import {GuildManagerContracts, GuildManagerStorage} from "./GuildManagerContracts.sol";
import {GuildCreationRule, MaxUsersPerGuildRule, GuildOrganizationInfo} from "src/interfaces/IGuildManager.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";

abstract contract GuildManagerOrganization is GuildManagerContracts {

    function __GuildManagerOrganization_init() internal onlyFacetInitializing {
        GuildManagerContracts.__GuildManagerContracts_init();
    }

    /**
     * @dev Creates a new organization and initializes the Guild feature for it.
     *  This can only be done by admins on the GuildManager contract.
     * @param _name The name of the new organization
     * @param _description The description of the new organization
     * @param _maxGuildsPerUser The maximum number of guilds a user can join within the organization.
     * @param _timeoutAfterLeavingGuild The number of seconds a user has to wait before being able to rejoin a guild
     * @param _guildCreationRule The rule for creating new guilds
     * @param _maxUsersPerGuildRule Indicates how the max number of users per guild is decided
     * @param _maxUsersPerGuildConstant If maxUsersPerGuildRule is set to CONSTANT, this is the max
     * @param _customGuildManagerAddress A contract address that handles custom guild creation requirements (i.e owning specific NFTs).
     *  This is used for guild creation if @param _guildCreationRule == CUSTOM_RULE
     */
    function createForNewOrganization(
        string calldata _name,
        string calldata _description,
        uint8 _maxGuildsPerUser,
        uint32 _timeoutAfterLeavingGuild,
        GuildCreationRule _guildCreationRule,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant,
        address _customGuildManagerAddress)
    external
    onlyRole(ADMIN_ROLE)
    contractsAreSet
    whenNotPaused
    {
        uint32 _newOrganizationId = GuildManagerStorage.createForNewOrganization(_name, _description);

        GuildManagerStorage.setOrganizationMaxGuildsPerUser(_newOrganizationId, _maxGuildsPerUser);
        GuildManagerStorage.setOrganizationTimeoutAfterLeavingGuild(_newOrganizationId, _timeoutAfterLeavingGuild);
        GuildManagerStorage.setOrganizationCreationRule(_newOrganizationId, _guildCreationRule);
        GuildManagerStorage.setOrganizationMaxUsersPerGuild(_newOrganizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
        GuildManagerStorage.setCustomGuildManagerAddress(_newOrganizationId, _customGuildManagerAddress);
    }

    /**
     * @dev Creates a new organization and initializes the Guild feature for it.
     *  This can only be done by admins on the GuildManager contract.
     * @param _organizationId The id of the organization to initialize
     * @param _maxGuildsPerUser The maximum number of guilds a user can join within the organization.
     * @param _timeoutAfterLeavingGuild The number of seconds a user has to wait before being able to rejoin a guild
     * @param _guildCreationRule The rule for creating new guilds
     * @param _maxUsersPerGuildRule Indicates how the max number of users per guild is decided
     * @param _maxUsersPerGuildConstant If maxUsersPerGuildRule is set to CONSTANT, this is the max
     * @param _customGuildManagerAddress A contract address that handles custom guild creation requirements (i.e owning specific NFTs).
     *  This is used for guild creation if @param _guildCreationRule == CUSTOM_RULE
     */
    function createForExistingOrganization(
        uint32 _organizationId,
        uint8 _maxGuildsPerUser,
        uint32 _timeoutAfterLeavingGuild,
        GuildCreationRule _guildCreationRule,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant,
        address _customGuildManagerAddress)
    external
    onlyRole(ADMIN_ROLE)
    contractsAreSet
    whenNotPaused
    onlyValidOrganization(_organizationId)
    {
        GuildManagerStorage.createForExistingOrganization(_organizationId);

        GuildManagerStorage.setOrganizationMaxGuildsPerUser(_organizationId, _maxGuildsPerUser);
        GuildManagerStorage.setOrganizationTimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
        GuildManagerStorage.setOrganizationCreationRule(_organizationId, _guildCreationRule);
        GuildManagerStorage.setOrganizationMaxUsersPerGuild(_organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
        GuildManagerStorage.setCustomGuildManagerAddress(_organizationId, _customGuildManagerAddress);
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

    function setCustomGuildManagerAddress(
        uint32 _organizationId,
        address _customGuildManagerAddress)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        GuildManagerStorage.setCustomGuildManagerAddress(_organizationId, _customGuildManagerAddress);
    }

    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================

    /**
     * @dev Retrieves the stored info for a given organization. Used to wrap the tuple from
     *  calling the mapping directly from external contracts
     * @param _organizationId The organization to return guild management info for
     */
    function getGuildOrganizationInfo(uint32 _organizationId) external view returns(GuildOrganizationInfo memory) {
        return GuildManagerStorage.getGuildOrganizationInfo(_organizationId);
    }
}