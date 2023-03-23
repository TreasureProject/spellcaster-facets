// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICustomGuildManager {

    /**
     * @dev Indicates if the given user can create a guild.
     *  ONLY called if creationRule is set to CUSTOM_RULE
     * @param _user The user to check if they can create a guild.
     * @param _organizationId The organization to find the guild within.
     */
    function canCreateGuild(address _user, bytes32 _organizationId) external view returns(bool);

    /**
     * @dev Called after a guild is created by the given owner. Additional state changes
     *  or checks can be put here. For example, if staking is required, transfers can occur.
     * @param _owner The owner of the guild.
     * @param _organizationId The organization to find the guild within.
     * @param _createdGuildId The guild that was created.
     */
    function onGuildCreation(address _owner, bytes32 _organizationId, uint32 _createdGuildId) external;

    /**
     * @dev Returns the maximum number of users that can be in a guild.
     *  Only called if maxUsersPerGuildRule is set to CUSTOM_RULE.
     * @param _organizationId The organization to find the guild within.
     * @param _guildId The guild to find the max users for.
     */
    function maxUsersForGuild(bytes32 _organizationId, uint32 _guildId) external view returns(uint32);
}