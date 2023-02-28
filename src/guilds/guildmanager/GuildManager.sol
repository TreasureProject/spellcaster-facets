//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GuildManagerSettings, GuildManagerStorage, IGuildManager} from "./GuildManagerSettings.sol";
import {ICustomGuildManager} from "src/interfaces/ICustomGuildManager.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";
import {GuildInfo, GuildUserStatus} from "src/interfaces/IGuildManager.sol";
import {LibGuildManager} from "src/libraries/LibGuildManager.sol";

contract GuildManager is GuildManagerSettings {

    /**
     * @dev Sets all necessary state and permissions for the contract
     * @param _guildTokenImplementationAddress The token implementation address for guild token contracts to proxy to
     */
    function GuildManager_init(address _guildTokenImplementationAddress) external facetInitializer(keccak256("GuildManager")) {
        GuildManagerSettings.__GuildManagerSettings_init();
        GuildManagerStorage.setGuildTokenBeacon(_guildTokenImplementationAddress);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function createGuild(
        uint32 _organizationId)
    external
    contractsAreSet
    whenNotPaused
    {
        LibGuildManager.createGuild(_organizationId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function updateGuildInfo(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _name,
        string calldata _description)
    external
    contractsAreSet
    whenNotPaused
    {
        LibGuildManager.requireGuildOwner(_organizationId, _guildId, "UPDATE_INFO");
        GuildManagerStorage.setGuildInfo(_organizationId, _guildId, _name, _description);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function updateGuildSymbol(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _symbolImageData,
        bool _isSymbolOnChain)
    external
    contractsAreSet
    whenNotPaused
    {
        LibGuildManager.requireGuildOwner(_organizationId, _guildId, "UPDATE_SYMBOL");
        GuildManagerStorage.setGuildSymbol(_organizationId, _guildId, _symbolImageData, _isSymbolOnChain);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function inviteUsers(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users)
    external
    whenNotPaused
    {
        LibGuildManager.inviteUsers(_organizationId, _guildId, _users);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function acceptInvitation(
        uint32 _organizationId,
        uint32 _guildId)
    external
    whenNotPaused
    {
        LibGuildManager.acceptInvitation(_organizationId, _guildId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function changeGuildAdmins(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users,
        bool[] calldata _isAdmins)
    external
    whenNotPaused
    {
        LibGuildManager.changeGuildAdmins(_organizationId, _guildId, _users, _isAdmins);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function changeGuildOwner(
        uint32 _organizationId,
        uint32 _guildId,
        address _newOwner)
    external
    whenNotPaused
    {
        LibGuildManager.changeGuildOwner(_organizationId, _guildId, _newOwner);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function leaveGuild(
        uint32 _organizationId,
        uint32 _guildId)
    external
    whenNotPaused
    {
        LibGuildManager.leaveGuild(_organizationId, _guildId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function kickOrRemoveInvitations(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users)
    external
    whenNotPaused
    {
        LibGuildManager.kickOrRemoveInvitations(_organizationId, _guildId, _users);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function userCanCreateGuild(
        uint32 _organizationId,
        address _user)
    public
    view
    onlyValidOrganization(_organizationId)
    returns(bool)
    {
        return LibGuildManager.userCanCreateGuild(_organizationId, _user);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function getGuildMemberStatus(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    public
    view
    returns(GuildUserStatus)
    {
        return GuildManagerStorage.getGuildUserInfo(_organizationId, _guildId, _user).userStatus;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function isValidGuild(uint32 _organizationId, uint32 _guildId) external view returns(bool) {
        return GuildManagerStorage.getGuildOrganizationInfo(_organizationId).guildIdCur > _guildId && _guildId != 0;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildTokenAddress(uint32 _organizationId) external view returns(address) {
        return GuildManagerStorage.getGuildOrganizationInfo(_organizationId).tokenAddress;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildName(uint32 _organizationId, uint32 _guildId) external view returns(string memory) {
        return GuildManagerStorage.getGuildInfo(_organizationId, _guildId).name;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildDescription(uint32 _organizationId, uint32 _guildId) external view returns(string memory) {
        return GuildManagerStorage.getGuildInfo(_organizationId, _guildId).description;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildOwner(uint32 _organizationId, uint32 _guildId) external view returns(address) {
        return GuildManagerStorage.getGuildInfo(_organizationId, _guildId).currentOwner;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function maxUsersForGuild(
        uint32 _organizationId,
        uint32 _guildId)
    public
    view
    returns(uint32)
    {
        return GuildManagerStorage.getMaxUsersForGuild(_organizationId, _guildId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildSymbolInfo(uint32 _organizationId, uint32 _guildId) external view returns(string memory _symbolImageData, bool _isSymbolOnChain) {
        GuildInfo storage _guildInfo = GuildManagerStorage.getGuildInfo(_organizationId, _guildId);
        _symbolImageData = _guildInfo.symbolImageData;
        _isSymbolOnChain = _guildInfo.isSymbolOnChain;
    }
}
