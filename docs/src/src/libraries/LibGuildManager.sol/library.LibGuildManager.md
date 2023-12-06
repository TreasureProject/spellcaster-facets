# LibGuildManager
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibGuildManager.sol)

*This library is used to implement features that use/update storage data for the Guild Manager contracts*


## Functions
### setGuildTokenBeacon


```solidity
function setGuildTokenBeacon(address _beaconImplAddress) internal;
```

### getGuildTokenBeacon


```solidity
function getGuildTokenBeacon() internal view returns (UpgradeableBeacon beacon_);
```

### getGuildOrganizationInfo


```solidity
function getGuildOrganizationInfo(bytes32 _organizationId)
    internal
    view
    returns (GuildOrganizationInfo storage info_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the org to retrieve info for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`info_`|`GuildOrganizationInfo`|The return struct is storage. This means all state changes to the struct will save automatically, instead of using a memory copy overwrite|


### getGuildInfo


```solidity
function getGuildInfo(bytes32 _organizationId, uint32 _guildId) internal view returns (GuildInfo storage info_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the org that contains the guild to retrieve info for|
|`_guildId`|`uint32`|The id of the guild within the given org to retrieve info for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`info_`|`GuildInfo`|The return struct is storage. This means all state changes to the struct will save automatically, instead of using a memory copy overwrite|


### getUserInfo


```solidity
function getUserInfo(
    bytes32 _organizationId,
    address _user
) internal view returns (GuildOrganizationUserInfo storage info_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the org that contains the user to retrieve info for|
|`_user`|`address`|The id of the user within the given org to retrieve info for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`info_`|`GuildOrganizationUserInfo`|The return struct is storage. This means all state changes to the struct will save automatically, instead of using a memory copy overwrite|


### getGuildUserInfo


```solidity
function getGuildUserInfo(
    bytes32 _organizationId,
    uint32 _guildId,
    address _user
) internal view returns (GuildUserInfo storage info_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the org that contains the user to retrieve info for|
|`_guildId`|`uint32`|The id of the guild within the given org to retrieve user info for|
|`_user`|`address`|The id of the user to retrieve info for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`info_`|`GuildUserInfo`|The return struct is storage. This means all state changes to the struct will save automatically, instead of using a memory copy overwrite|


### setMaxGuildsPerUser


```solidity
function setMaxGuildsPerUser(bytes32 _organizationId, uint8 _maxGuildsPerUser) internal;
```

### setTimeoutAfterLeavingGuild


```solidity
function setTimeoutAfterLeavingGuild(bytes32 _organizationId, uint32 _timeoutAfterLeavingGuild) internal;
```

### setGuildCreationRule


```solidity
function setGuildCreationRule(bytes32 _organizationId, GuildCreationRule _guildCreationRule) internal;
```

### setMaxUsersPerGuild


```solidity
function setMaxUsersPerGuild(
    bytes32 _organizationId,
    MaxUsersPerGuildRule _maxUsersPerGuildRule,
    uint32 _maxUsersPerGuildConstant
) internal;
```

### setCustomGuildManagerAddress


```solidity
function setCustomGuildManagerAddress(bytes32 _organizationId, address _customGuildManagerAddress) internal;
```

### setGuildInfo

*Assumes permissions have already been checked (only guild owner)*


```solidity
function setGuildInfo(
    bytes32 _organizationId,
    uint32 _guildId,
    string calldata _name,
    string calldata _description
) internal;
```

### setGuildSymbol

*Assumes permissions have already been checked (only guild owner)*


```solidity
function setGuildSymbol(
    bytes32 _organizationId,
    uint32 _guildId,
    string calldata _symbolImageData,
    bool _isSymbolOnChain
) internal;
```

### getMaxUsersForGuild


```solidity
function getMaxUsersForGuild(bytes32 _organizationId, uint32 _guildId) internal view returns (uint32);
```

### createForNewOrganization


```solidity
function createForNewOrganization(
    bytes32 _newOrganizationId,
    string calldata _name,
    string calldata _description
) internal;
```

### createForExistingOrganization

*Assumes that the organization already exists. This is used when creating a guild for an organization that
already exists, but has not initialized the guild feature yet.*


```solidity
function createForExistingOrganization(bytes32 _organizationId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization to create a guild for|


### createGuild


```solidity
function createGuild(bytes32 _organizationId) internal;
```

### inviteUsers


```solidity
function inviteUsers(
    bytes32 _organizationId,
    uint32 _guildId,
    address[] calldata _users
) internal onlyGuildOwnerOrAdmin(_organizationId, _guildId, "INVITE");
```

### acceptInvitation


```solidity
function acceptInvitation(bytes32 _organizationId, uint32 _guildId) internal;
```

### leaveGuild


```solidity
function leaveGuild(bytes32 _organizationId, uint32 _guildId) internal;
```

### kickOrRemoveInvitations


```solidity
function kickOrRemoveInvitations(bytes32 _organizationId, uint32 _guildId, address[] calldata _users) internal;
```

### changeGuildAdmins


```solidity
function changeGuildAdmins(
    bytes32 _organizationId,
    uint32 _guildId,
    address[] calldata _users,
    bool[] calldata _isAdmins
) internal onlyGuildOwner(_organizationId, _guildId, "CHANGE_ADMINS");
```

### changeGuildOwner


```solidity
function changeGuildOwner(
    bytes32 _organizationId,
    uint32 _guildId,
    address _newOwner
) internal onlyGuildOwner(_organizationId, _guildId, "TRANSFER_OWNER");
```

### userCanCreateGuild


```solidity
function userCanCreateGuild(bytes32 _organizationId, address _user) internal view returns (bool);
```

### isGuildOwner


```solidity
function isGuildOwner(bytes32 _organizationId, uint32 _guildId, address _user) internal view returns (bool);
```

### isGuildAdminOrOwner


```solidity
function isGuildAdminOrOwner(bytes32 _organizationId, uint32 _guildId, address _user) internal view returns (bool);
```

### requireGuildOwner


```solidity
function requireGuildOwner(bytes32 _organizationId, uint32 _guildId, string memory _action) internal view;
```

### requireGuildOwnerOrAdmin


```solidity
function requireGuildOwnerOrAdmin(bytes32 _organizationId, uint32 _guildId, string memory _action) internal view;
```

### _changeUserStatus


```solidity
function _changeUserStatus(
    bytes32 _organizationId,
    uint32 _guildId,
    address _user,
    GuildUserStatus _newStatus
) private;
```

### _onUserJoinedGuild


```solidity
function _onUserJoinedGuild(bytes32 _organizationId, uint32 _guildId, address _user) private;
```

### _onUserLeftGuild


```solidity
function _onUserLeftGuild(bytes32 _organizationId, uint32 _guildId, address _user) private;
```

### onlyGuildOwner


```solidity
modifier onlyGuildOwner(bytes32 _organizationId, uint32 _guildId, string memory _action);
```

### onlyGuildOwnerOrAdmin


```solidity
modifier onlyGuildOwnerOrAdmin(bytes32 _organizationId, uint32 _guildId, string memory _action);
```

