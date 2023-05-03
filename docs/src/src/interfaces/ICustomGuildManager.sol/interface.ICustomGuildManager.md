# ICustomGuildManager
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/ICustomGuildManager.sol)


## Functions
### canCreateGuild

*Indicates if the given user can create a guild.
ONLY called if creationRule is set to CUSTOM_RULE*


```solidity
function canCreateGuild(address _user, bytes32 _organizationId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The user to check if they can create a guild.|
|`_organizationId`|`bytes32`|The organization to find the guild within.|


### onGuildCreation

*Called after a guild is created by the given owner. Additional state changes
or checks can be put here. For example, if staking is required, transfers can occur.*


```solidity
function onGuildCreation(address _owner, bytes32 _organizationId, uint32 _createdGuildId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The owner of the guild.|
|`_organizationId`|`bytes32`|The organization to find the guild within.|
|`_createdGuildId`|`uint32`|The guild that was created.|


### maxUsersForGuild

*Returns the maximum number of users that can be in a guild.
Only called if maxUsersPerGuildRule is set to CUSTOM_RULE.*


```solidity
function maxUsersForGuild(bytes32 _organizationId, uint32 _guildId) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to find the guild within.|
|`_guildId`|`uint32`|The guild to find the max users for.|


