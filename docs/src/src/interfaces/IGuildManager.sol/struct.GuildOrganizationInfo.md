# GuildOrganizationInfo
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/interfaces/IGuildManager.sol)

*Info related to a specific organization. Think of organizations as systems/games. i.e. Bridgeworld, The Beacon, etc.*


```solidity
struct GuildOrganizationInfo {
    uint32 guildIdCur;
    GuildCreationRule creationRule;
    uint8 maxGuildsPerUser;
    uint32 timeoutAfterLeavingGuild;
    address tokenAddress;
    MaxUsersPerGuildRule maxUsersPerGuildRule;
    uint32 maxUsersPerGuildConstant;
    address customGuildManagerAddress;
}
```

