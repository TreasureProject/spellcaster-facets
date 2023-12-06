# IGuildManager
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IGuildManager.sol)


## Functions
### GuildManager_init

*Sets all necessary state and permissions for the contract*


```solidity
function GuildManager_init(address _guildTokenImplementationAddress, address _systemDelegateApprover) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_guildTokenImplementationAddress`|`address`|The token implementation address for guild token contracts to proxy to|
|`_systemDelegateApprover`|`address`||


### createGuild

*Creates a new guild within the given organization. Must pass the guild creation requirements.*


```solidity
function createGuild(bytes32 _organizationId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to create the guild within|


### updateGuildInfo

*Updates the guild info for the given guild.*


```solidity
function updateGuildInfo(
    bytes32 _organizationId,
    uint32 _guildId,
    string calldata _name,
    string calldata _description
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to update|
|`_name`|`string`|The new name of the guild|
|`_description`|`string`|The new description of the guild|


### updateGuildSymbol

*Updates the guild symbol for the given guild.*


```solidity
function updateGuildSymbol(
    bytes32 _organizationId,
    uint32 _guildId,
    string calldata _symbolImageData,
    bool _isSymbolOnChain
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to update|
|`_symbolImageData`|`string`|The new symbol for the guild|
|`_isSymbolOnChain`|`bool`|Indicates if symbolImageData is on chain or is a URL|


### inviteUsers

*Invites users to the given guild. Can only be done by admins or the guild owner.*


```solidity
function inviteUsers(bytes32 _organizationId, uint32 _guildId, address[] calldata _users) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to invite users to|
|`_users`|`address[]`|The users to invite|


### acceptInvitation

*Accepts an invitation to the given guild.*


```solidity
function acceptInvitation(bytes32 _organizationId, uint32 _guildId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to accept the invitation to|


### changeGuildAdmins

*Changes the admin status of the given users within the given guild.*


```solidity
function changeGuildAdmins(
    bytes32 _organizationId,
    uint32 _guildId,
    address[] calldata _users,
    bool[] calldata _isAdmins
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to change the admin status of users within|
|`_users`|`address[]`|The users to change the admin status of|
|`_isAdmins`|`bool[]`|Indicates if the users should be admins or not|


### changeGuildOwner

*Changes the owner of the given guild.*


```solidity
function changeGuildOwner(bytes32 _organizationId, uint32 _guildId, address _newOwner) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to change the owner of|
|`_newOwner`|`address`|The new owner of the guild|


### leaveGuild

*Leaves the given guild.*


```solidity
function leaveGuild(bytes32 _organizationId, uint32 _guildId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to leave|


### kickOrRemoveInvitations

*Kicks or cancels any invites of the given users from the given guild.*


```solidity
function kickOrRemoveInvitations(bytes32 _organizationId, uint32 _guildId, address[] calldata _users) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to kick users from|
|`_users`|`address[]`|The users to kick|


### userCanCreateGuild

*Returns whether or not the given user can create a guild within the given organization.*


```solidity
function userCanCreateGuild(bytes32 _organizationId, address _user) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to check|
|`_user`|`address`|The user to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether or not the user can create a guild within the given organization|


### getGuildMemberStatus

*Returns the membership status of the given user within the given guild.*


```solidity
function getGuildMemberStatus(
    bytes32 _organizationId,
    uint32 _guildId,
    address _user
) external view returns (GuildUserStatus);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to get the membership status of the user within|
|`_user`|`address`|The user to get the membership status of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`GuildUserStatus`|The membership status of the user within the guild|


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
) external;
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
) external;
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
function setMaxGuildsPerUser(bytes32 _organizationId, uint8 _maxGuildsPerUser) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to set the max guilds per user for.|
|`_maxGuildsPerUser`|`uint8`|The maximum number of guilds a user can join within the organization.|


### setTimeoutAfterLeavingGuild

*Sets the cooldown period a user has to wait before joining a new guild within the organization.*


```solidity
function setTimeoutAfterLeavingGuild(bytes32 _organizationId, uint32 _timeoutAfterLeavingGuild) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to set the guild joining timeout for.|
|`_timeoutAfterLeavingGuild`|`uint32`|The cooldown period a user has to wait before joining a new guild within the organization.|


### setGuildCreationRule

*Sets the rule for creating new guilds within the organization.*


```solidity
function setGuildCreationRule(bytes32 _organizationId, GuildCreationRule _guildCreationRule) external;
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
) external;
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
function setCustomGuildManagerAddress(bytes32 _organizationId, address _customGuildManagerAddress) external;
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


### guildTokenAddress

*Retrieves the token address for guilds within the given organization*


```solidity
function guildTokenAddress(bytes32 _organizationId) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to return the guild token address for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The token address for guilds within the given organization|


### guildTokenImplementation

*Retrieves the token implementation address for guild token contracts to proxy to*


```solidity
function guildTokenImplementation() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The beacon token implementation address|


### isValidGuild

*Determines if the given guild is valid for the given organization*


```solidity
function isValidGuild(bytes32 _organizationId, uint32 _guildId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to verify against|
|`_guildId`|`uint32`|The guild to verify|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|If the given guild is valid within the given organization|


### guildName

*Get a given guild's name*


```solidity
function guildName(bytes32 _organizationId, uint32 _guildId) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to find the given guild within|
|`_guildId`|`uint32`|The guild to retrieve the name from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The name of the given guild within the given organization|


### guildDescription

*Get a given guild's description*


```solidity
function guildDescription(bytes32 _organizationId, uint32 _guildId) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to find the given guild within|
|`_guildId`|`uint32`|The guild to retrieve the description from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The description of the given guild within the given organization|


### guildSymbolInfo

*Get a given guild's symbol info*


```solidity
function guildSymbolInfo(
    bytes32 _organizationId,
    uint32 _guildId
) external view returns (string memory symbolImageData_, bool isSymbolOnChain_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to find the given guild within|
|`_guildId`|`uint32`|The guild to retrieve the symbol info from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`symbolImageData_`|`string`|The symbol data of the given guild within the given organization|
|`isSymbolOnChain_`|`bool`|Whether or not the returned data is a URL or on-chain|


### guildOwner

*Retrieves the current owner for a given guild within a organization.*


```solidity
function guildOwner(bytes32 _organizationId, uint32 _guildId) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to find the guild within|
|`_guildId`|`uint32`|The guild to return the owner of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The current owner of the given guild within the given organization|


### maxUsersForGuild

*Retrieves the current owner for a given guild within a organization.*


```solidity
function maxUsersForGuild(bytes32 _organizationId, uint32 _guildId) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to find the guild within|
|`_guildId`|`uint32`|The guild to return the maxMembers of|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|The current maxMembers of the given guild within the given organization|


