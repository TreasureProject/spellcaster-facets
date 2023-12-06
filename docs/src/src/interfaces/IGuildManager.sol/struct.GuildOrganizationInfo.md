# GuildOrganizationInfo
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IGuildManager.sol)

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

