# GuildInfo
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/interfaces/IGuildManager.sol)

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

