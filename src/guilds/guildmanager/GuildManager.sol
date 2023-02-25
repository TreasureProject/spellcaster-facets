//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GuildManagerOrganization, GuildManagerStorage} from "./GuildManagerOrganization.sol";
import {ICustomGuildManager} from "src/interfaces/ICustomGuildManager.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";
import {GuildInfo, GuildUserStatus} from "src/interfaces/IGuildManager.sol";

contract GuildManager is GuildManagerOrganization {

    function GuildManager_init() external facetInitializer(keccak256("GuildManager")) {
        GuildManagerOrganization.__GuildManagerOrganization_init();
    }

    function createGuild(
        uint32 _organizationId)
    contractsAreSet
    whenNotPaused
    external
    {
        GuildManagerStorage.createGuild(_organizationId);
    }

    function updateGuildInfo(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _name,
        string calldata _description)
    contractsAreSet
    whenNotPaused
    external
    {
        GuildManagerStorage.updateGuildInfo(_organizationId, _guildId, _name, _description);
    }

    function updateGuildSymbol(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _symbolImageData,
        bool _isSymbolOnChain)
    contractsAreSet
    whenNotPaused
    external
    {
        GuildManagerStorage.updateGuildSymbol(_organizationId, _guildId, _symbolImageData, _isSymbolOnChain);
    }

    function inviteUsers(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users)
    external
    whenNotPaused
    {
        GuildManagerStorage.inviteUsers(_organizationId, _guildId, _users);
    }

    function acceptInvitation(
        uint32 _organizationId,
        uint32 _guildId)
    external
    whenNotPaused
    {
        GuildManagerStorage.acceptInvitation(_organizationId, _guildId);
    }

    function changeGuildAdmins(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users,
        bool[] calldata _isAdmins)
    external
    whenNotPaused
    {
        GuildManagerStorage.changeGuildAdmins(_organizationId, _guildId, _users, _isAdmins);
    }

    function changeGuildOwner(
        uint32 _organizationId,
        uint32 _guildId,
        address _newOwner)
    external
    whenNotPaused
    {
        GuildManagerStorage.changeGuildOwner(_organizationId, _guildId, _newOwner);
    }

    function leaveGuild(
        uint32 _organizationId,
        uint32 _guildId)
    external
    whenNotPaused
    {
        GuildManagerStorage.leaveGuild(_organizationId, _guildId);
    }

    function kickOrRemoveInvitations(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users)
    external
    whenNotPaused
    {
        GuildManagerStorage.kickOrRemoveInvitations(_organizationId, _guildId, _users);
    }

    function userCanCreateGuild(
        uint32 _organizationId,
        address _user)
    onlyValidOrganization(_organizationId)
    public
    view
    returns(bool)
    {
        return GuildManagerStorage.userCanCreateGuild(_organizationId, _user);
    }

    function maxUsersForGuild(
        uint32 _organizationId,
        uint32 _guildId)
    public
    view
    returns(uint32)
    {
        return GuildManagerStorage.maxUsersForGuild(_organizationId, _guildId);
    }

    function getGuildMemberStatus(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    public
    view
    returns(GuildUserStatus)
    {
        return GuildManagerStorage.getGuildMemberStatus(_organizationId, _guildId, _user);
    }

    function isValidGuild(uint32 _organizationId, uint32 _guildId) external view returns(bool) {
        return GuildManagerStorage.getOrganizationInfo(_organizationId).guildIdCur > _guildId && _guildId != 0;
    }

    function organizationToken(uint32 _organizationId) external view returns(address) {
        return GuildManagerStorage.getOrganizationInfo(_organizationId).tokenAddress;
    }

    /**
     * @dev Retrieves the current owner for a given guild within a organization.
     * @param _organizationId The organization to find the guild within
     * @param _guildId The guild to return the name of
     */
    function guildName(uint32 _organizationId, uint32 _guildId) external view returns(string memory) {
        return GuildManagerStorage.getGuildInfo(_organizationId, _guildId).name;
    }

    /**
     * @dev Retrieves the current owner for a given guild within a organization.
     * @param _organizationId The organization to find the guild within
     * @param _guildId The guild to return the description of
     */
    function guildDescription(uint32 _organizationId, uint32 _guildId) external view returns(string memory) {
        return GuildManagerStorage.getGuildInfo(_organizationId, _guildId).description;
    }

    /**
     * @dev Retrieves the current owner for a given guild within a organization.
     * @param _organizationId The organization to find the guild within
     * @param _guildId The guild to return the owner of
     */
    function guildOwner(uint32 _organizationId, uint32 _guildId) external view returns(address) {
        return GuildManagerStorage.getGuildInfo(_organizationId, _guildId).currentOwner;
    }

    /**
     * @dev Retrieves the current owner for a given guild within a organization.
     * @param _organizationId The organization to find the guild within
     * @param _guildId The guild to return the symbol data of
     */
    function guildSymbolInfo(uint32 _organizationId, uint32 _guildId) external view returns(string memory _symbolImageData, bool _isSymbolOnChain) {
        GuildInfo storage _guildInfo = GuildManagerStorage.getGuildInfo(_organizationId, _guildId);
        _symbolImageData = _guildInfo.symbolImageData;
        _isSymbolOnChain = _guildInfo.isSymbolOnChain;
    }
}
