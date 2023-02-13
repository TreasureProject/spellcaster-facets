//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ADMIN_ROLE} from "../../libraries/LibAccessControlRoles.sol";
import {BeaconProxy} from '@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol';

import {GuildManagerContracts} from "./GuildManagerContracts.sol";
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
        uint32 _newOrganizationId = organizationIdCur;
        organizationIdCur++;

        // Create new 1155 token to represent this organization.
        //
        bytes memory _guildTokenData = abi.encodeCall(IGuildToken.initialize, (_newOrganizationId));
        address _guildTokenAddress = address(new BeaconProxy(address(guildTokenBeacon), _guildTokenData));

        organizationIdToInfo[_newOrganizationId].tokenAddress = _guildTokenAddress;

        // The first guild created will be ID 1.
        //
        organizationIdToInfo[_newOrganizationId].guildIdCur = 1;

        emit OrganizationCreated(_newOrganizationId, _guildTokenAddress);

        _setOrganizationNameAndDescription(_newOrganizationId, _name, _description);
        _setOrganizationAdmin(_newOrganizationId, msg.sender);
        _setOrganizationMaxGuildsPerUser(_newOrganizationId, _maxGuildsPerUser);
        _setOrganizationTimeoutAfterLeavingGuild(_newOrganizationId, _timeoutAfterLeavingGuild);
        _setOrganizationCreationRule(_newOrganizationId, _guildCreationRule);
        _setOrganizationMaxUsersPerGuild(_newOrganizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
        _setOrganizationConfigAddress(_newOrganizationId, _organizationConfigAddress);
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
        _setOrganizationNameAndDescription(_organizationId, _name, _description);
    }

    function _setOrganizationNameAndDescription(
        uint32 _organizationId,
        string calldata _name,
        string calldata _description)
    private
    {
        organizationIdToInfo[_organizationId].name = _name;
        organizationIdToInfo[_organizationId].description = _description;
        emit OrganizationInfoUpdated(_organizationId, _name, _description);
    }

    function setOrganizationAdmin(
        uint32 _organizationId,
        address _admin)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        require(_admin != address(0) && _admin != organizationIdToInfo[_organizationId].admin);
        _setOrganizationAdmin(_organizationId, _admin);
    }

    function _setOrganizationAdmin(
        uint32 _organizationId,
        address _admin)
    private
    {
        organizationIdToInfo[_organizationId].admin = _admin;
        emit OrganizationAdminUpdated(_organizationId, _admin);
    }

    function setOrganizationMaxGuildsPerUser(
        uint32 _organizationId,
        uint8 _maxGuildsPerUser)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        _setOrganizationMaxGuildsPerUser(_organizationId, _maxGuildsPerUser);
    }

    /**
     * @dev Retrieves the stored info for a given organization. Used to wrap the tuple from
     *  calling the mapping directly from external contracts
     * @param _organizationId The organization to return info for
     */
    function getOrganizationInfo(uint32 _organizationId) external view returns(OrganizationInfo memory) {
        return organizationIdToInfo[_organizationId];
    }

    /**
     * @dev Retrieves the current owner for a given guild within a organization.
     * @param _organizationId The organization to find the guild within
     * @param _guildId The guild to return the owner of
     */
    function getGuildOwner(uint32 _organizationId, uint32 _guildId) external view returns(address) {
        return organizationIdToGuildIdToInfo[_organizationId][_guildId].currentOwner;
    }

    function _setOrganizationMaxGuildsPerUser(
        uint32 _organizationId,
        uint8 _maxGuildsPerUser)
    private
    {
        require(_maxGuildsPerUser > 0, "maxGuildsPerUser must be greater than 0");

        organizationIdToInfo[_organizationId].maxGuildsPerUser = _maxGuildsPerUser;
        emit OrganizationMaxGuildsPerUserUpdated(_organizationId, _maxGuildsPerUser);
    }

    function setOrganizationTimeoutAfterLeavingGuild(
        uint32 _organizationId,
        uint32 _timeoutAfterLeavingGuild)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        _setOrganizationTimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
    }

    function _setOrganizationTimeoutAfterLeavingGuild(
        uint32 _organizationId,
        uint32 _timeoutAfterLeavingGuild)
    private
    {
        organizationIdToInfo[_organizationId].timeoutAfterLeavingGuild = _timeoutAfterLeavingGuild;
        emit OrganizationTimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
    }

    function setOrganizationCreationRule(
        uint32 _organizationId,
        GuildCreationRule _guildCreationRule)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        _setOrganizationCreationRule(_organizationId, _guildCreationRule);
    }

    function _setOrganizationCreationRule(
        uint32 _organizationId,
        GuildCreationRule _guildCreationRule)
    private
    {
        organizationIdToInfo[_organizationId].creationRule = _guildCreationRule;
        emit OrganizationCreationRuleUpdated(_organizationId, _guildCreationRule);
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
        _setOrganizationMaxUsersPerGuild(_organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
    }

    function _setOrganizationMaxUsersPerGuild(
        uint32 _organizationId,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant)
    private
    {
        organizationIdToInfo[_organizationId].maxUsersPerGuildRule = _maxUsersPerGuildRule;
        organizationIdToInfo[_organizationId].maxUsersPerGuildConstant = _maxUsersPerGuildConstant;
        emit OrganizationMaxUsersPerGuildUpdated(_organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
    }

    function setOrganizationConfigAddress(
        uint32 _organizationId,
        address _organizationConfigAddress)
    external
    contractsAreSet
    whenNotPaused
    onlyOrganizationAdmin(_organizationId)
    {
        _setOrganizationConfigAddress(_organizationId, _organizationConfigAddress);
    }

    function _setOrganizationConfigAddress(
        uint32 _organizationId,
        address _organizationConfigAddress)
    private
    {
        organizationIdToInfo[_organizationId].organizationConfigAddress = _organizationConfigAddress;
        emit OrganizationConfigAddressUpdated(_organizationId, _organizationConfigAddress);
    }

    modifier onlyOrganizationAdmin(uint32 _organizationId) {
        require(msg.sender == organizationIdToInfo[_organizationId].admin, "Not organization admin");

        _;
    }

    modifier onlyValidOrganization(uint32 _organizationId) {
        require(address(0) != organizationIdToInfo[_organizationId].admin, "Not a valid organization");

        _;
    }
}