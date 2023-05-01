// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

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
import { IGuildToken } from "src/interfaces/IGuildToken.sol";
import { ICustomGuildManager } from "src/interfaces/ICustomGuildManager.sol";

import { OrganizationManagerStorage } from "src/organizations/OrganizationManagerStorage.sol";

/**
 * @title GuildManagerStorage library
 * @notice This library contains the storage layout and events/errors for the GuildManagerFacet contract.
 */
library GuildManagerStorage {
    struct Layout {
        /**
         * @dev The implementation of the guild token contract to create new contracts from
         */
        UpgradeableBeacon guildTokenBeacon;
        /**
         * @dev The organizationId is the key for this mapping
         */
        mapping(bytes32 => GuildOrganizationInfo) guildOrganizationInfo;
        /**
         * @dev The organizationId is the key for the first mapping, the guildId is the key for the second mapping
         */
        mapping(bytes32 => mapping(uint32 => GuildInfo)) organizationIdToGuildIdToInfo;
        /**
         * @dev The organizationId is the key for the first mapping, the user is the key for the second mapping
         */
        mapping(bytes32 => mapping(address => GuildOrganizationUserInfo)) organizationIdToAddressToInfo;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.guildmanager");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

    // Guild Management Events

    /**
     * @dev Emitted when a guild organization is initialized.
     * @param organizationId The ID of the guild's organization
     * @param tokenAddress The token address associated with the guild organization
     */
    event GuildOrganizationInitialized(bytes32 organizationId, address tokenAddress);

    /**
     * @dev Emitted when the timeout period after leaving a guild is updated.
     * @param organizationId The ID of the guild's organization
     * @param timeoutAfterLeavingGuild The new timeout period (in seconds)
     */
    event TimeoutAfterLeavingGuild(bytes32 organizationId, uint32 timeoutAfterLeavingGuild);

    /**
     * @dev Emitted when the maximum number of guilds per user is updated.
     * @param organizationId The ID of the guild's organization
     * @param maxGuildsPerUser The new maximum number of guilds per user
     */
    event MaxGuildsPerUserUpdated(bytes32 organizationId, uint8 maxGuildsPerUser);

    /**
     * @dev Emitted when the maximum number of users per guild is updated.
     * @param organizationId The ID of the guild's organization
     * @param rule The rule for maximum users per guild
     * @param maxUsersPerGuildConstant The new maximum number of users per guild constant
     */
    event MaxUsersPerGuildUpdated(bytes32 organizationId, MaxUsersPerGuildRule rule, uint32 maxUsersPerGuildConstant);

    /**
     * @dev Emitted when the guild creation rule is updated.
     * @param organizationId The ID of the guild's organization
     * @param creationRule The new guild creation rule
     */
    event GuildCreationRuleUpdated(bytes32 organizationId, GuildCreationRule creationRule);

    /**
     * @dev Emitted when the custom guild manager address is updated.
     * @param organizationId The ID of the guild's organization
     * @param customGuildManagerAddress The new custom guild manager address
     */
    event CustomGuildManagerAddressUpdated(bytes32 organizationId, address customGuildManagerAddress);

    // Guild Events

    /**
     * @dev Emitted when a new guild is created.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the newly created guild
     */
    event GuildCreated(bytes32 organizationId, uint32 guildId);

    /**
     * @dev Emitted when a guild is terminated.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the terminated guild
     * @param terminator The address of the initiator of the termination
     * @param reason The reason for the termination
     */
    event GuildTerminated(bytes32 organizationId, uint32 guildId, address terminator, string reason);

    /**
     * @dev Emitted when a guild's information is updated.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the guild being updated
     * @param name The updated guild name
     * @param description The updated guild description
     */
    event GuildInfoUpdated(bytes32 organizationId, uint32 guildId, string name, string description);

    /**
     * @dev Emitted when a guild's symbol is updated.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the guild being updated
     * @param symbolImageData The updated guild symbol image data
     * @param isSymbolOnChain Whether the updated guild symbol is stored on-chain
     */
    event GuildSymbolUpdated(bytes32 organizationId, uint32 guildId, string symbolImageData, bool isSymbolOnChain);

    /**
     * @dev Emitted when a user's status in a guild is changed.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the guild
     * @param user The address of the user whose status is changed
     * @param status The updated status of the user
     */
    event GuildUserStatusChanged(bytes32 organizationId, uint32 guildId, address user, GuildUserStatus status);

    // Errors

    /**
     * @dev Emitted when a guild organization has already been initialized.
     * @param organizationId The ID of the guild's organization
     */
    error GuildOrganizationAlreadyInitialized(bytes32 organizationId);

    /**
     * @dev Emitted when a user is not allowed to create a guild.
     * @param organizationId The ID of the guild's organization
     * @param user The address of the user attempting to create a guild
     */
    error UserCannotCreateGuild(bytes32 organizationId, address user);

    /**
     * @dev Emitted when the sender is not the guild owner and tries to perform an owner-only action.
     * @param sender The address of the sender attempting the action
     * @param action A description of the attempted action
     */
    error NotGuildOwner(address sender, string action);

    /**
     * @dev Emitted when the sender is neither the guild owner nor an admin and tries to perform an owner or admin action.
     * @param sender The address of the sender attempting the action
     * @param action A description of the attempted action
     */
    error NotGuildOwnerOrAdmin(address sender, string action);

    /**
     * @dev Emitted when a guild is full and cannot accept new members.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the guild
     */
    error GuildFull(bytes32 organizationId, uint32 guildId);

    /**
     * @dev Emitted when a user is already a member of a guild.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the guild
     * @param user The address of the user attempting to join the guild
     */
    error UserAlreadyInGuild(bytes32 organizationId, uint32 guildId, address user);

    /**
     * @dev Emitted when a user is a member of too many guilds.
     * @param organizationId The ID of the guild's organization
     * @param user The address of the user attempting to join another guild
     */
    error UserInTooManyGuilds(bytes32 organizationId, address user);

    /**
     * @dev Emitted when a user is not a member of a guild.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the guild
     * @param user The address of the user attempting to perform a guild member action
     */
    error UserNotGuildMember(bytes32 organizationId, uint32 guildId, address user);

    /**
     * @dev Emitted when an invalid address is provided.
     * @param user The address that is invalid
     */
    error InvalidAddress(address user);

    /**
     * @dev Error when trying to interact with a terminated or inactive guild.
     * @param organizationId The ID of the guild's organization
     * @param guildId The ID of the guild
     */
    error GuildIsNotActive(bytes32 organizationId, uint32 guildId);
}
