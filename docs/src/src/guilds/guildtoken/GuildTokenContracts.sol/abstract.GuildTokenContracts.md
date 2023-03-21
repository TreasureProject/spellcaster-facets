# GuildTokenContracts
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/guilds/guildtoken/GuildTokenContracts.sol)

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

