# GuildManagerContracts
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/guilds/guildmanager/GuildManagerContracts.sol)

**Inherits:**
[GuildManagerBase](/src/guilds/guildmanager/GuildManagerBase.sol/abstract.GuildManagerBase.md)


## Functions
### __GuildManagerContracts_init


```solidity
function __GuildManagerContracts_init() internal onlyFacetInitializing;
```

### setContracts


```solidity
function setContracts(address _guildTokenImplementationAddress) external onlyRole(ADMIN_ROLE);
```

### contractsAreSet


```solidity
modifier contractsAreSet();
```

### areContractsSet


```solidity
function areContractsSet() public view returns (bool);
```

### guildTokenImplementation

*Retrieves the token implementation address for guild token contracts to proxy to*


```solidity
function guildTokenImplementation() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The beacon token implementation address|


