//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    GuildManagerSettings, LibGuildManager, IGuildManager, LibOrganizationManager
} from "./GuildManagerSettings.sol";
import { ICustomGuildManager } from "src/interfaces/ICustomGuildManager.sol";
import { IGuildToken } from "src/interfaces/IGuildToken.sol";
import { GuildInfo, GuildUserInfo, GuildUserStatus, GuildStatus } from "src/interfaces/IGuildManager.sol";
import { LibUtilities } from "src/libraries/LibUtilities.sol";
import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";

contract GuildManager is GuildManagerSettings {
    /**
     * @inheritdoc IGuildManager
     */
    function GuildManager_init(address _guildTokenImplementationAddress)
        external
        facetInitializer(keccak256("GuildManager_init"))
    {
        __GuildManagerSettings_init();
        LibGuildManager.setGuildTokenBeacon(_guildTokenImplementationAddress);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function createGuild(bytes32 _organizationId)
        external
        contractsAreSet
        whenNotPaused
        supportsMetaTx(_organizationId)
    {
        LibGuildManager.createGuild(_organizationId);
    }

    function terminateGuild(
        bytes32 _organizationId,
        uint32 _guildId,
        string calldata _reason
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.terminateGuild(_organizationId, _guildId, _reason);
    }

    function grantGuildTerminator(
        address _account,
        bytes32 _organizationId,
        uint32 _guildId
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.requireGuildOwner(_organizationId, _guildId, "GRANT_TERMINATOR_ROLE");
        LibAccessControlRoles.grantGuildTerminator(_account, _organizationId, _guildId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function updateGuildInfo(
        bytes32 _organizationId,
        uint32 _guildId,
        string calldata _name,
        string calldata _description
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.requireGuildOwner(_organizationId, _guildId, "UPDATE_INFO");
        LibGuildManager.setGuildInfo(_organizationId, _guildId, _name, _description);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function updateGuildSymbol(
        bytes32 _organizationId,
        uint32 _guildId,
        string calldata _symbolImageData,
        bool _isSymbolOnChain
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.requireGuildOwner(_organizationId, _guildId, "UPDATE_SYMBOL");
        LibGuildManager.setGuildSymbol(_organizationId, _guildId, _symbolImageData, _isSymbolOnChain);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function adjustMemberLevel(
        bytes32 _organizationId,
        uint32 _guildId,
        address _user,
        uint8 _memberLevel
    ) external whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.adjustMemberLevel(_organizationId, _guildId, _user, _memberLevel);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function inviteUsers(
        bytes32 _organizationId,
        uint32 _guildId,
        address[] calldata _users
    ) external whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.inviteUsers(_organizationId, _guildId, _users);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function acceptInvitation(
        bytes32 _organizationId,
        uint32 _guildId
    ) external whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.acceptInvitation(_organizationId, _guildId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function changeGuildAdmins(
        bytes32 _organizationId,
        uint32 _guildId,
        address[] calldata _users,
        bool[] calldata _isAdmins
    ) external whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.changeGuildAdmins(_organizationId, _guildId, _users, _isAdmins);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function changeGuildOwner(
        bytes32 _organizationId,
        uint32 _guildId,
        address _newOwner
    ) external whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.changeGuildOwner(_organizationId, _guildId, _newOwner);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function leaveGuild(
        bytes32 _organizationId,
        uint32 _guildId
    ) external whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.leaveGuild(_organizationId, _guildId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function kickOrRemoveInvitations(
        bytes32 _organizationId,
        uint32 _guildId,
        address[] calldata _users
    ) external whenNotPaused supportsMetaTx(_organizationId) {
        LibGuildManager.kickOrRemoveInvitations(_organizationId, _guildId, _users);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function getGuildStatus(bytes32 _organizationId, uint32 _guildId) public view returns (GuildStatus) {
        return LibGuildManager.getGuildStatus(_organizationId, _guildId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function userCanCreateGuild(bytes32 _organizationId, address _user) public view returns (bool) {
        LibOrganizationManager.requireOrganizationValid(_organizationId);
        return LibGuildManager.userCanCreateGuild(_organizationId, _user);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function getGuildMemberStatus(
        bytes32 _organizationId,
        uint32 _guildId,
        address _user
    ) public view returns (GuildUserStatus) {
        return LibGuildManager.getGuildUserInfo(_organizationId, _guildId, _user).userStatus;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function getGuildMemberInfo(
        bytes32 _organizationId,
        uint32 _guildId,
        address _user
    ) public view returns (GuildUserInfo memory) {
        return LibGuildManager.getGuildUserInfo(_organizationId, _guildId, _user);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function isValidGuild(bytes32 _organizationId, uint32 _guildId) external view returns (bool) {
        return LibGuildManager.getGuildOrganizationInfo(_organizationId).guildIdCur > _guildId && _guildId != 0;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildTokenAddress(bytes32 _organizationId) external view returns (address) {
        return LibGuildManager.getGuildOrganizationInfo(_organizationId).tokenAddress;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildName(bytes32 _organizationId, uint32 _guildId) external view returns (string memory) {
        return LibGuildManager.getGuildInfo(_organizationId, _guildId).name;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildDescription(bytes32 _organizationId, uint32 _guildId) external view returns (string memory) {
        return LibGuildManager.getGuildInfo(_organizationId, _guildId).description;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildOwner(bytes32 _organizationId, uint32 _guildId) external view returns (address) {
        return LibGuildManager.getGuildInfo(_organizationId, _guildId).currentOwner;
    }

    /**
     * @inheritdoc IGuildManager
     */
    function maxUsersForGuild(bytes32 _organizationId, uint32 _guildId) public view returns (uint32) {
        return LibGuildManager.getMaxUsersForGuild(_organizationId, _guildId);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function guildSymbolInfo(
        bytes32 _organizationId,
        uint32 _guildId
    ) external view returns (string memory _symbolImageData, bool _isSymbolOnChain) {
        GuildInfo storage _guildInfo = LibGuildManager.getGuildInfo(_organizationId, _guildId);
        _symbolImageData = _guildInfo.symbolImageData;
        _isSymbolOnChain = _guildInfo.isSymbolOnChain;
    }
}
