// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGuildOrganizationConfig {
    // Indicates if the given user can create a guild.
    // ONLY called if creationRule is set to CUSTOM_RULE
    //
    function canCreateGuild(address _user, uint32 _organizationId) external view returns(bool);

    // Called after a guild is created by the given owner. Additional state changes
    // or checks can be put here. For example, if staking is required, transfers can occur.
    //
    // Called regardless of creationRule if a config is setup for the organization.
    //
    function onGuildCreation(address _owner, uint32 _organizationId, uint32 _createdGuildId) external;

    // When maxUsersPerGuildRule is set to CUSTOM_RULE, this returns how many users the guild can have.
    //
    function maxUsersForGuild(address _owner, uint32 _organizationId, uint32 _guildId) external view returns(uint32);
}