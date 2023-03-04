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
    event GuildOrganizationInitialized(bytes32 organizationId, address tokenAddress);
    event TimeoutAfterLeavingGuild(bytes32 organizationId, uint32 timeoutAfterLeavingGuild);
    event MaxGuildsPerUserUpdated(bytes32 organizationId, uint8 maxGuildsPerUser);
    event MaxUsersPerGuildUpdated(bytes32 organizationId, MaxUsersPerGuildRule rule, uint32 maxUsersPerGuildConstant);
    event GuildCreationRuleUpdated(bytes32 organizationId, GuildCreationRule creationRule);
    event CustomGuildManagerAddressUpdated(bytes32 organizationId, address customGuildManagerAddress);

    // Guild Events
    event GuildCreated(bytes32 organizationId, uint32 guildId);
    event GuildInfoUpdated(bytes32 organizationId, uint32 guildId, string name, string description);
    event GuildSymbolUpdated(bytes32 organizationId, uint32 guildId, string symbolImageData, bool isSymbolOnChain);
    event GuildUserStatusChanged(bytes32 organizationId, uint32 guildId, address user, GuildUserStatus status);

    // Errors
    error GuildOrganizationAlreadyInitialized(bytes32 organizationId);
    error UserCannotCreateGuild(bytes32 organizationId, address user);
    error NotGuildOwner(address sender, string action);
    error NotGuildOwnerOrAdmin(address sender, string action);
    error GuildFull(bytes32 organizationId, uint32 guildId);
    error UserAlreadyInGuild(bytes32 organizationId, uint32 guildId, address user);
    error UserInTooManyGuilds(bytes32 organizationId, address user);
    error UserNotGuildMember(bytes32 organizationId, uint32 guildId, address user);
    error InvalidAddress(address user);

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
}
