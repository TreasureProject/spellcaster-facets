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
}
