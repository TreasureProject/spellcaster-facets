# GuildTokenContracts
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/guilds/guildtoken/GuildTokenContracts.sol)

**Inherits:**
[GuildTokenBase](/src/guilds/guildtoken/GuildTokenBase.sol/abstract.GuildTokenBase.md)


## Functions
### __GuildTokenContracts_init


```solidity
function __GuildTokenContracts_init() internal onlyFacetInitializing;
```

### setContracts


```solidity
function setContracts(address _guildManagerAddress) external onlyRole(ADMIN_ROLE);
```

### contractsAreSet


```solidity
modifier contractsAreSet();
```

### areContractsSet


```solidity
function areContractsSet() public view returns (bool);
```

