// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UpgradeableBeacon} from '@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol';
import {BeaconProxy} from '@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol';

import {
    IGuildManager,
    GuildInfo,
    GuildCreationRule,
    GuildUserInfo,
    GuildUserStatus,
    GuildOrganizationInfo,
    GuildOrganizationUserInfo,
    MaxUsersPerGuildRule
} from "src/interfaces/IGuildManager.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";
import {ICustomGuildManager} from "src/interfaces/ICustomGuildManager.sol";

import {OrganizationManagerStorage} from "src/organizations/OrganizationManagerStorage.sol";

/**
 * @title Guild Manager Storage Library
 * @dev This library is used to store and retrieve data from storage for the Guild Manager contracts
 */
library GuildManagerStorage {

    // Guild Management Events
    event GuildOrganizationInitialized(uint32 organizationId, address tokenAddress);
    event TimeoutAfterLeavingGuild(uint32 organizationId, uint32 timeoutAfterLeavingGuild);
    event MaxGuildsPerUserUpdated(uint32 organizationId, uint8 maxGuildsPerUser);
    event MaxUsersPerGuildUpdated(uint32 organizationId, MaxUsersPerGuildRule rule, uint32 maxUsersPerGuildConstant);
    event GuildCreationRuleUpdated(uint32 organizationId, GuildCreationRule creationRule);
    event CustomGuildManagerAddressUpdated(uint32 organizationId, address customGuildManagerAddress);

    // Guild Events
    event GuildCreated(uint32 organizationId, uint32 guildId);
    event GuildInfoUpdated(uint32 organizationId, uint32 guildId, string name, string description);
    event GuildSymbolUpdated(uint32 organizationId, uint32 guildId, string symbolImageData, bool isSymbolOnChain);
    event GuildUserStatusChanged(uint32 organizationId, uint32 guildId, address user, GuildUserStatus status);

    // Errors
    error GuildOrganizationAlreadyInitialized(uint32 organizationId);
    error UserCannotCreateGuild(uint32 organizationId, address user);
    error NotGuildOwner(address sender, string action);
    error NotGuildOwnerOrAdmin(address sender, string action);
    error GuildFull(uint32 organizationId, uint32 guildId);
    error UserAlreadyInGuild(uint32 organizationId, uint32 guildId, address user);
    error UserInTooManyGuilds(uint32 organizationId, address user);
    error UserNotGuildMember(uint32 organizationId, uint32 guildId, address user);
    error InvalidAddress(address user);

    struct Layout {
        /**
         * @dev The implementation of the guild token contract to create new contracts from
         */
        UpgradeableBeacon guildTokenBeacon;
        /**
         * @dev The organizationId is the key for this mapping
         */
        mapping(uint32 => GuildOrganizationInfo) guildOrganizationInfo;
        /**
         * @dev The organizationId is the key for the first mapping, the guildId is the key for the second mapping
         */
        mapping(uint32 => mapping(uint32 => GuildInfo)) organizationIdToGuildIdToInfo;
        /**
         * @dev The organizationId is the key for the first mapping, the user is the key for the second mapping
         */
        mapping(uint32 => mapping(address => GuildOrganizationUserInfo)) organizationIdToAddressToInfo;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.guildmanager");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

    // =============================================================
    //                    State Getters/Setters
    // =============================================================

    function setGuildTokenBeacon(address _beaconImplAddress) internal {
        Layout storage l = layout();

        if(address(l.guildTokenBeacon) == address(0)) {
            l.guildTokenBeacon = new UpgradeableBeacon(_beaconImplAddress);
        } else if(l.guildTokenBeacon.implementation() != _beaconImplAddress) {
            l.guildTokenBeacon.upgradeTo(_beaconImplAddress);
        }
    }

    function getGuildTokenBeacon() internal view returns (UpgradeableBeacon beacon_) {
        beacon_ = layout().guildTokenBeacon;
    }

    /**
     * @param _orgId The id of the org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getGuildOrganizationInfo(uint32 _orgId) internal view returns (GuildOrganizationInfo storage info_) {
        info_ = layout().guildOrganizationInfo[_orgId];
    }

    /**
     * @param _orgId The id of the org that contains the guild to retrieve info for
     * @param _guildId The id of the guild within the given org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getGuildInfo(uint32 _orgId, uint32 _guildId) internal view returns (GuildInfo storage info_) {
        info_ = layout().organizationIdToGuildIdToInfo[_orgId][_guildId];
    }

    /**
     * @param _orgId The id of the org that contains the user to retrieve info for
     * @param _user The id of the user within the given org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getUserInfo(uint32 _orgId, address _user) internal view returns (GuildOrganizationUserInfo storage info_) {
        info_ = layout().organizationIdToAddressToInfo[_orgId][_user];
    }

    /**
     * @param _orgId The id of the org that contains the user to retrieve info for
     * @param _guildId The id of the guild within the given org to retrieve user info for
     * @param _user The id of the user to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getGuildUserInfo(
        uint32 _orgId,
        uint32 _guildId,
        address _user)
    internal
    view
    returns (GuildUserInfo storage info_)
    {
        info_ = layout().organizationIdToGuildIdToInfo[_orgId][_guildId].addressToGuildUserInfo[_user];
    }

    // =============================================================
    //                  GuildOrganization Settings
    // =============================================================

    function setMaxGuildsPerUser(
        uint32 _organizationId,
        uint8 _maxGuildsPerUser)
    internal
    {
        require(_maxGuildsPerUser > 0, "maxGuildsPerUser must be greater than 0");

        getGuildOrganizationInfo(_organizationId).maxGuildsPerUser = _maxGuildsPerUser;
        emit MaxGuildsPerUserUpdated(_organizationId, _maxGuildsPerUser);
    }

    function setTimeoutAfterLeavingGuild(
        uint32 _organizationId,
        uint32 _timeoutAfterLeavingGuild)
    internal
    {
        getGuildOrganizationInfo(_organizationId).timeoutAfterLeavingGuild = _timeoutAfterLeavingGuild;
        emit TimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
    }

    function setGuildCreationRule(
        uint32 _organizationId,
        GuildCreationRule _guildCreationRule)
    internal
    {
        getGuildOrganizationInfo(_organizationId).creationRule = _guildCreationRule;
        emit GuildCreationRuleUpdated(_organizationId, _guildCreationRule);
    }

    function setMaxUsersPerGuild(
        uint32 _organizationId,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant)
    internal
    {
        getGuildOrganizationInfo(_organizationId).maxUsersPerGuildRule = _maxUsersPerGuildRule;
        getGuildOrganizationInfo(_organizationId).maxUsersPerGuildConstant = _maxUsersPerGuildConstant;
        emit MaxUsersPerGuildUpdated(_organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
    }

    function setCustomGuildManagerAddress(
        uint32 _organizationId,
        address _customGuildManagerAddress)
    internal
    {
        getGuildOrganizationInfo(_organizationId).customGuildManagerAddress = _customGuildManagerAddress;
        emit CustomGuildManagerAddressUpdated(_organizationId, _customGuildManagerAddress);
    }

    // =============================================================
    //                  Guild Settings
    // =============================================================

    /**
     * @dev Assumes permissions have already been checked (only guild owner)
     */
    function setGuildInfo(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _name,
        string calldata _description)
    internal
    {
        GuildInfo storage _guildInfo = getGuildInfo(_organizationId, _guildId);

        _guildInfo.name = _name;
        _guildInfo.description = _description;

        emit GuildInfoUpdated(_organizationId, _guildId, _name, _description);
    }

    /**
     * @dev Assumes permissions have already been checked (only guild owner)
     */
    function setGuildSymbol(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _symbolImageData,
        bool _isSymbolOnChain)
    internal
    {
        GuildInfo storage _guildInfo = getGuildInfo(_organizationId, _guildId);

        _guildInfo.symbolImageData = _symbolImageData;
        _guildInfo.isSymbolOnChain = _isSymbolOnChain;

        emit GuildSymbolUpdated(_organizationId, _guildId, _symbolImageData, _isSymbolOnChain);
    }

    function getMaxUsersForGuild(
        uint32 _organizationId,
        uint32 _guildId)
    internal
    view
    returns(uint32)
    {
        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();
        address _guildOwner = l.organizationIdToGuildIdToInfo[_organizationId][_guildId].currentOwner;
        require(_guildOwner != address(0), "Invalid guild");

        GuildOrganizationInfo storage _orgInfo = l.guildOrganizationInfo[_organizationId];
        if(_orgInfo.maxUsersPerGuildRule == MaxUsersPerGuildRule.CONSTANT) {
            return _orgInfo.maxUsersPerGuildConstant;
        } else {
            require(_orgInfo.customGuildManagerAddress != address(0), "CUSTOM_RULE with no config set");
            return ICustomGuildManager(_orgInfo.customGuildManagerAddress)
                .maxUsersForGuild(_organizationId, _guildId);
        }
    }

}
