# IOrganizationManager
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IOrganizationManager.sol)


## Functions
### createOrganization

*Creates a new organization. For now, this can only be done by admins on the GuildManager contract.*


```solidity
function createOrganization(bytes32 _newOrganizationId, string calldata _name, string calldata _description) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOrganizationId`|`bytes32`|The id of the organization being created.|
|`_name`|`string`|The name of the organization.|
|`_description`|`string`|The description of the organization.|


### setOrganizationNameAndDescription

*Sets the name and description for an organization.*


```solidity
function setOrganizationNameAndDescription(
    bytes32 _organizationId,
    string calldata _name,
    string calldata _description
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to set the name and description for.|
|`_name`|`string`|The new name of the organization.|
|`_description`|`string`|The new description of the organization.|


### setOrganizationAdmin

*Sets the admin for an organization.*


```solidity
function setOrganizationAdmin(bytes32 _organizationId, address _admin) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to set the admin for.|
|`_admin`|`address`|The new admin of the organization.|


### getOrganizationInfo

*Retrieves the stored info for a given organization. Used to wrap the tuple from
calling the mapping directly from external contracts*


```solidity
function getOrganizationInfo(bytes32 _organizationId) external view returns (OrganizationInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to return info for|


