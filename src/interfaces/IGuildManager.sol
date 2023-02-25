// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Info related to a specific organization. Think of organizations as systems/games. i.e. Bridgeworld, The Beacon, etc.
 * @param guildIdCur The next available guild id within this organization for newly created guilds
 * @param creationRule Describes who can create a guild within this organization
 * @param maxGuildsPerUser The number of guilds a user can join within the organization.
 * @param timeoutAfterLeavingGuild The timeout a user has before joining a new guild after being kicked or leaving another guild
 * @param tokenAddress The address of the 1155 token that represents this organization
 * @param maxUsersPerGuildRule Indicates how the max number of users per guild is decided
 * @param maxUsersPerGuildConstant If maxUsersPerGuildRule is set to CONSTANT, this is the max
 * @param customGuildManagerAddress A contract address that handles custom guild creation requirements (i.e owning specific NFTs).
 *  This is used for guild creation if @param creationRule == CUSTOM_RULE
 */
struct GuildOrganizationInfo {
    uint32 guildIdCur;
    GuildCreationRule creationRule;
    uint8 maxGuildsPerUser;
    uint32 timeoutAfterLeavingGuild;
    // Slot 4 (200/256)
    address tokenAddress;
    MaxUsersPerGuildRule maxUsersPerGuildRule;
    uint32 maxUsersPerGuildConstant;
    // Slot 5 (160/256) - customGuildManagerAddress
    address customGuildManagerAddress;
}

/**
 * @dev Contains information about a user at the organization user.
 * @param guildsIdsAMemberOf A list of guild ids they are currently a member/admin/owner of. Excludes invitations
 * @param timeUserLeftGuild The time this user last left or was kicked from a guild. Useful for guild joining timeouts
 */
struct GuildOrganizationUserInfo {
    // Slot 1
    uint32[] guildIdsAMemberOf;
    // Slot 2 (64/256)
    uint64 timeUserLeftGuild;
}

/**
 * @dev Information about a guild within a given organization.
 * @param name The name of this guild
 * @param description A description of this guild
 * @param symbolImageData A symbol that represents this guild
 * @param isSymbolOnChain Indicates if symbolImageData is on chain or is a URL
 * @param currentOwner The current owner of this guild
 * @param usersInGuild Keeps track of the number of users in the guild. This includes MEMBER, ADMIN, and OWNER
 */
struct GuildInfo {
    // Slot 1
    string name;
    // Slot 2
    string description;
    // Slot 3
    string symbolImageData;
    // Slot 4 (168/256)
    bool isSymbolOnChain;
    address currentOwner;
    uint32 usersInGuild;
    // Slot 5
    mapping(address => GuildUserInfo) addressToGuildUserInfo;
}

/**
 * @dev Provides information regarding a user in a specific guild 
 * @param userStatus Indicates the status of this user (i.e member, admin, invited)
 * @param timeUserJoined The time this user joined this guild
 */
struct GuildUserInfo {
    // Slot 1 (72/256)
    GuildUserStatus userStatus;
    uint64 timeUserJoined;
}

enum GuildUserStatus {
    NOT_ASSOCIATED,
    INVITED,
    MEMBER,
    ADMIN,
    OWNER
}

enum GuildCreationRule {
    ANYONE,
    ADMIN_ONLY,
    CUSTOM_RULE
}

enum MaxUsersPerGuildRule {
    CONSTANT,
    CUSTOM_RULE
}

interface IGuildManager {

    /**
     * @dev Determines if the given guild is valid for the given organization
     * @param _organizationId The organization to verify against
     * @param _guildId The guild to verify
     * @return If the given guild is valid within the given organization
     */
    function isValidGuild(uint32 _organizationId, uint32 _guildId) external view returns(bool);

    /** 
     * @dev Get a given guild's name
     * @param _organizationId The organization to find the given guild within
     * @param _guildId The guild to retrieve the name from
     * @return The name of the given guild within the given organization
     */
    function guildName(uint32 _organizationId, uint32 _guildId) external view returns(string memory);

    /**
     * @dev Get a given guild's description
     * @param _organizationId The organization to find the given guild within
     * @param _guildId The guild to retrieve the description from
     * @return The description of the given guild within the given organization
     */
    function guildDescription(uint32 _organizationId, uint32 _guildId) external view returns(string memory);

    /**
     * @dev Get a given guild's symbol info
     * @param _organizationId The organization to find the given guild within
     * @param _guildId The guild to retrieve the symbol info from
     * @return symbolImageData_ The symbol data of the given guild within the given organization
     * @return isSymbolOnChain_ Whether or not the returned data is a URL or on-chain
     */
    function guildSymbolInfo(uint32 _organizationId, uint32 _guildId) external view returns(string memory symbolImageData_, bool isSymbolOnChain_);
}