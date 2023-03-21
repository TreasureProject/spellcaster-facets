# ICustomGuildManager
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/interfaces/ICustomGuildManager.sol)


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


