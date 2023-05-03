# GuildInfo
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IGuildManager.sol)

*Information about a guild within a given organization.*


```solidity
struct GuildInfo {
    string name;
    string description;
    string symbolImageData;
    bool isSymbolOnChain;
    address currentOwner;
    uint32 usersInGuild;
    mapping(address => GuildUserInfo) addressToGuildUserInfo;
}
```

