# GuildManagerContracts
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/guilds/guildmanager/GuildManagerContracts.sol)

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


