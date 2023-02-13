//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FacetInitializable} from "../../utils/FacetInitializable.sol";
import {UpgradeableBeacon} from '@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol';

import {IGuildManager} from "./IGuildManager.sol";
import {IGuildToken} from "../guildtoken/IGuildToken.sol";
// import {AccessControlFacet} from "../../access/AccessControlFacet.sol";
import {Modifiers} from "../../Modifiers.sol";

abstract contract GuildManagerState is FacetInitializable, IGuildManager, Modifiers {

    event OrganizationCreated(uint32 organizationId, address tokenAddress);
    event OrganizationInfoUpdated(uint32 organizationId, string name, string description);
    event OrganizationAdminUpdated(uint32 organizationId, address admin);
    event OrganizationTimeoutAfterLeavingGuild(uint32 organizationId, uint32 timeoutAfterLeavingGuild);
    event OrganizationMaxGuildsPerUserUpdated(uint32 organizationId, uint8 maxGuildsPerUser);
    event OrganizationMaxUsersPerGuildUpdated(uint32 organizationId, MaxUsersPerGuildRule rule, uint32 maxUsersPerGuildConstant);
    event OrganizationCreationRuleUpdated(uint32 organizationId, GuildCreationRule creationRule);
    event OrganizationConfigAddressUpdated(uint32 organizationId, address organizationConfigAddress);

    event GuildCreated(uint32 organizationId, uint32 guildId);
    event GuildInfoUpdated(uint32 organizationId, uint32 guildId, string name, string description);
    event GuildSymbolUpdated(uint32 organizationId, uint32 guildId, string symbolImageData, bool isSymbolOnChain);

    event GuildUserStatusChanged(uint32 organizationId, uint32 guildId, address user, GuildUserStatus status);

    UpgradeableBeacon public guildTokenBeacon;

    uint32 public organizationIdCur;
    mapping(uint32 => OrganizationInfo) public organizationIdToInfo;

    mapping(uint32 => mapping(uint32 => GuildInfo)) public organizationIdToGuildIdToInfo;

    mapping(uint32 => mapping(address => OrganizationUserInfo)) organizationIdToAddressToInfo;

    function __GuildManagerState_init() internal onlyFacetInitializing {
        _pause();

        organizationIdCur = 1;
    }
}