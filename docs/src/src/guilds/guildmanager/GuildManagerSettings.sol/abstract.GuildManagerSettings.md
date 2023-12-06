# GuildManagerSettings
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/guilds/guildmanager/GuildManagerSettings.sol)

**Inherits:**
[GuildManagerContracts](/src/guilds/guildmanager/GuildManagerContracts.sol/abstract.GuildManagerContracts.md)


## Functions
### __GuildManagerSettings_init


```solidity
function __GuildManagerSettings_init() internal onlyFacetInitializing;
```

### createForNewOrganization

*Creates a new organization and initializes the Guild feature for it.
This can only be done by admins on the GuildManager contract.*


```solidity
function createForNewOrganization(
    bytes32 _newOrganizationId,
    string calldata _name,
    string calldata _description,
    uint8 _maxGuildsPerUser,
    uint32 _timeoutAfterLeavingGuild,
    GuildCreationRule _guildCreationRule,
    MaxUsersPerGuildRule _maxUsersPerGuildRule,
    uint32 _maxUsersPerGuildConstant,
    address _customGuildManagerAddress
) external onlyRole(ADMIN_ROLE) contractsAreSet whenNotPaused supportsMetaTx(_newOrganizationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOrganizationId`|`bytes32`|The id of the organization being created|
|`_name`|`string`|The name of the new organization|
|`_description`|`string`|The description of the new organization|
|`_maxGuildsPerUser`|`uint8`|The maximum number of guilds a user can join within the organization.|
|`_timeoutAfterLeavingGuild`|`uint32`|The number of seconds a user has to wait before being able to rejoin a guild|
|`_guildCreationRule`|`GuildCreationRule`|The rule for creating new guilds|
|`_maxUsersPerGuildRule`|`MaxUsersPerGuildRule`|Indicates how the max number of users per guild is decided|
|`_maxUsersPerGuildConstant`|`uint32`|If maxUsersPerGuildRule is set to CONSTANT, this is the max|
|`_customGuildManagerAddress`|`address`|A contract address that handles custom guild creation requirements (i.e owning specific NFTs). This is used for guild creation if @param _guildCreationRule == CUSTOM_RULE|


### createForExistingOrganization

*Creates a new organization and initializes the Guild feature for it.
This can only be done by admins on the GuildManager contract.*


```solidity
function createForExistingOrganization(
    bytes32 _organizationId,
    uint8 _maxGuildsPerUser,
    uint32 _timeoutAfterLeavingGuild,
    GuildCreationRule _guildCreationRule,
    MaxUsersPerGuildRule _maxUsersPerGuildRule,
    uint32 _maxUsersPerGuildConstant,
    address _customGuildManagerAddress
)
    external
    onlyRole(ADMIN_ROLE)
    contractsAreSet
    whenNotPaused
    onlyValidOrganization(_organizationId)
    supportsMetaTx(_organizationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to initialize|
|`_maxGuildsPerUser`|`uint8`|The maximum number of guilds a user can join within the organization.|
|`_timeoutAfterLeavingGuild`|`uint32`|The number of seconds a user has to wait before being able to rejoin a guild|
|`_guildCreationRule`|`GuildCreationRule`|The rule for creating new guilds|
|`_maxUsersPerGuildRule`|`MaxUsersPerGuildRule`|Indicates how the max number of users per guild is decided|
|`_maxUsersPerGuildConstant`|`uint32`|If maxUsersPerGuildRule is set to CONSTANT, this is the max|
|`_customGuildManagerAddress`|`address`|A contract address that handles custom guild creation requirements (i.e owning specific NFTs). This is used for guild creation if @param _guildCreationRule == CUSTOM_RULE|


### setMaxGuildsPerUser

*Sets the max number of guilds a user can join within the organization.*


```solidity
function setMaxGuildsPerUser(
    bytes32 _organizationId,
    uint8 _maxGuildsPerUser
) external contractsAreSet whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to set the max guilds per user for.|
|`_maxGuildsPerUser`|`uint8`|The maximum number of guilds a user can join within the organization.|


### setTimeoutAfterLeavingGuild

*Sets the cooldown period a user has to wait before joining a new guild within the organization.*


```solidity
function setTimeoutAfterLeavingGuild(
    bytes32 _organizationId,
    uint32 _timeoutAfterLeavingGuild
) external contractsAreSet whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to set the guild joining timeout for.|
|`_timeoutAfterLeavingGuild`|`uint32`|The cooldown period a user has to wait before joining a new guild within the organization.|


### setGuildCreationRule

*Sets the rule for creating new guilds within the organization.*


```solidity
function setGuildCreationRule(
    bytes32 _organizationId,
    GuildCreationRule _guildCreationRule
) external contractsAreSet whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to set the guild creation rule for.|
|`_guildCreationRule`|`GuildCreationRule`|The rule that outlines how a user can create a new guild within the organization.|


### setMaxUsersPerGuild

*Sets the max number of users per guild within the organization.*


```solidity
function setMaxUsersPerGuild(
    bytes32 _organizationId,
    MaxUsersPerGuildRule _maxUsersPerGuildRule,
    uint32 _maxUsersPerGuildConstant
) external contractsAreSet whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to set the max number of users per guild for|
|`_maxUsersPerGuildRule`|`MaxUsersPerGuildRule`|Indicates how the max number of users per guild is decided within the organization.|
|`_maxUsersPerGuildConstant`|`uint32`|If maxUsersPerGuildRule is set to CONSTANT, this is the max.|


### setCustomGuildManagerAddress

*Sets the contract address that handles custom guild creation requirements (i.e owning specific NFTs).*


```solidity
function setCustomGuildManagerAddress(
    bytes32 _organizationId,
    address _customGuildManagerAddress
) external contractsAreSet whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to set the custom guild manager address for|
|`_customGuildManagerAddress`|`address`|The contract address that handles custom guild creation requirements (i.e owning specific NFTs). This is used for guild creation if the saved `guildCreationRule` == CUSTOM_RULE|


### getGuildOrganizationInfo

*Retrieves the stored info for a given organization. Used to wrap the tuple from
calling the mapping directly from external contracts*


```solidity
function getGuildOrganizationInfo(bytes32 _organizationId) external view returns (GuildOrganizationInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to return guild management info for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`GuildOrganizationInfo`|The stored guild settings for a given organization|


