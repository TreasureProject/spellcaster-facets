//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ADMIN_ROLE } from "src/libraries/LibAccessControlRoles.sol";

import { GuildCreationRule, MaxUsersPerGuildRule, GuildOrganizationInfo } from "src/interfaces/IGuildManager.sol";
import { IGuildToken } from "src/interfaces/IGuildToken.sol";
import { GuildManagerContracts, LibGuildManager, IGuildManager } from "./GuildManagerContracts.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";

abstract contract GuildManagerSettings is GuildManagerContracts {
    function __GuildManagerSettings_init() internal onlyFacetInitializing {
        GuildManagerContracts.__GuildManagerContracts_init();
    }

    /**
     * @inheritdoc IGuildManager
     */
    function createForNewOrganization(
        bytes32 _newOrganizationId,
        string calldata _name,
        string calldata _description,
        uint8 _maxGuildsPerUser,
        uint32 _timeoutAfterLeavingGuild,
        GuildCreationRule _guildCreationRule,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant,
        address _customGuildManagerAddress
    ) external onlyRole(ADMIN_ROLE) contractsAreSet whenNotPaused supportsMetaTx(_newOrganizationId) {
        LibGuildManager.createForNewOrganization(_newOrganizationId, _name, _description);

        LibGuildManager.setMaxGuildsPerUser(_newOrganizationId, _maxGuildsPerUser);
        LibGuildManager.setTimeoutAfterLeavingGuild(_newOrganizationId, _timeoutAfterLeavingGuild);
        LibGuildManager.setGuildCreationRule(_newOrganizationId, _guildCreationRule);
        LibGuildManager.setMaxUsersPerGuild(_newOrganizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
        LibGuildManager.setCustomGuildManagerAddress(_newOrganizationId, _customGuildManagerAddress);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function createForExistingOrganization(
        bytes32 _organizationId,
        uint8 _maxGuildsPerUser,
        uint32 _timeoutAfterLeavingGuild,
        GuildCreationRule _guildCreationRule,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant,
        address _customGuildManagerAddress
    )
        external
        onlyRole(ADMIN_ROLE)
        contractsAreSet
        whenNotPaused
        supportsMetaTx(_organizationId)
    {
        LibOrganizationManager.requireOrganizationValid(_organizationId);
        LibGuildManager.createForExistingOrganization(_organizationId);

        LibGuildManager.setMaxGuildsPerUser(_organizationId, _maxGuildsPerUser);
        LibGuildManager.setTimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
        LibGuildManager.setGuildCreationRule(_organizationId, _guildCreationRule);
        LibGuildManager.setMaxUsersPerGuild(_organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
        LibGuildManager.setCustomGuildManagerAddress(_organizationId, _customGuildManagerAddress);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function setMaxGuildsPerUser(
        bytes32 _organizationId,
        uint8 _maxGuildsPerUser
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibOrganizationManager.requireOrganizationValid(_organizationId);
        LibGuildManager.setMaxGuildsPerUser(_organizationId, _maxGuildsPerUser);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function setTimeoutAfterLeavingGuild(
        bytes32 _organizationId,
        uint32 _timeoutAfterLeavingGuild
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibOrganizationManager.requireOrganizationValid(_organizationId);
        LibGuildManager.setTimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function setGuildCreationRule(
        bytes32 _organizationId,
        GuildCreationRule _guildCreationRule
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibOrganizationManager.requireOrganizationValid(_organizationId);
        LibGuildManager.setGuildCreationRule(_organizationId, _guildCreationRule);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function setMaxUsersPerGuild(
        bytes32 _organizationId,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibOrganizationManager.requireOrganizationValid(_organizationId);
        LibGuildManager.setMaxUsersPerGuild(_organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
    }

    /**
     * @inheritdoc IGuildManager
     */
    function setCustomGuildManagerAddress(
        bytes32 _organizationId,
        address _customGuildManagerAddress
    ) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId) {
        LibOrganizationManager.requireOrganizationValid(_organizationId);
        LibGuildManager.setCustomGuildManagerAddress(_organizationId, _customGuildManagerAddress);
    }

    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================

    /**
     * @inheritdoc IGuildManager
     */
    function getGuildOrganizationInfo(bytes32 _organizationId) external view returns (GuildOrganizationInfo memory) {
        return LibGuildManager.getGuildOrganizationInfo(_organizationId);
    }
}
