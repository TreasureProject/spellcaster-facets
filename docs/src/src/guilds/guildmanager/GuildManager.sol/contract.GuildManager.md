# GuildManager
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/guilds/guildmanager/GuildManager.sol)

**Inherits:**
[GuildManagerSettings](/src/guilds/guildmanager/GuildManagerSettings.sol/abstract.GuildManagerSettings.md)


## Functions
### GuildManager_init

*Sets all necessary state and permissions for the contract*


```solidity
function GuildManager_init(
    address _guildTokenImplementationAddress,
    address _systemDelegateApprover
) external facetInitializer(keccak256("GuildManager"));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_guildTokenImplementationAddress`|`address`|The token implementation address for guild token contracts to proxy to|
|`_systemDelegateApprover`|`address`||


### createGuild

*Creates a new guild within the given organization. Must pass the guild creation requirements.*


```solidity
function createGuild(bytes32 _organizationId) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId);
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
) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId);
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
) external contractsAreSet whenNotPaused supportsMetaTx(_organizationId);
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
function inviteUsers(
    bytes32 _organizationId,
    uint32 _guildId,
    address[] calldata _users
) external whenNotPaused supportsMetaTx(_organizationId);
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
function acceptInvitation(
    bytes32 _organizationId,
    uint32 _guildId
) external whenNotPaused supportsMetaTx(_organizationId);
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
) external whenNotPaused supportsMetaTx(_organizationId);
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
function changeGuildOwner(
    bytes32 _organizationId,
    uint32 _guildId,
    address _newOwner
) external whenNotPaused supportsMetaTx(_organizationId);
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
function leaveGuild(bytes32 _organizationId, uint32 _guildId) external whenNotPaused supportsMetaTx(_organizationId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization the guild is within|
|`_guildId`|`uint32`|The guild to leave|


### kickOrRemoveInvitations

*Kicks or cancels any invites of the given users from the given guild.*


```solidity
function kickOrRemoveInvitations(
    bytes32 _organizationId,
    uint32 _guildId,
    address[] calldata _users
) external whenNotPaused supportsMetaTx(_organizationId);
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
function userCanCreateGuild(
    bytes32 _organizationId,
    address _user
) public view onlyValidOrganization(_organizationId) returns (bool);
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
) public view returns (GuildUserStatus);
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
function maxUsersForGuild(bytes32 _organizationId, uint32 _guildId) public view returns (uint32);
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


### guildSymbolInfo

*Get a given guild's symbol info*


```solidity
function guildSymbolInfo(
    bytes32 _organizationId,
    uint32 _guildId
) external view returns (string memory _symbolImageData, bool _isSymbolOnChain);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to find the given guild within|
|`_guildId`|`uint32`|The guild to retrieve the symbol info from|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_symbolImageData`|`string`|symbolImageData_ The symbol data of the given guild within the given organization|
|`_isSymbolOnChain`|`bool`|isSymbolOnChain_ Whether or not the returned data is a URL or on-chain|


