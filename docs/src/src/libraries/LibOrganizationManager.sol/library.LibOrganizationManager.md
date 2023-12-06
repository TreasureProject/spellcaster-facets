# LibOrganizationManager
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibOrganizationManager.sol)


## Functions
### getOrganizationInfo


```solidity
function getOrganizationInfo(bytes32 _orgId) internal view returns (OrganizationInfo storage info_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orgId`|`bytes32`|The id of the org to retrieve info for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`info_`|`OrganizationInfo`|The return struct is storage. This means all state changes to the struct will save automatically, instead of using a memory copy overwrite|


### setOrganizationNameAndDescription

*Assumes that sender permissions have already been checked*


```solidity
function setOrganizationNameAndDescription(
    bytes32 _organizationId,
    string calldata _name,
    string calldata _description
) internal;
```

### setOrganizationAdmin

*Assumes that sender permissions have already been checked*


```solidity
function setOrganizationAdmin(bytes32 _organizationId, address _admin) internal;
```

### createOrganization


```solidity
function createOrganization(bytes32 _newOrganizationId, string calldata _name, string calldata _description) internal;
```

### requireOrganizationAdmin


```solidity
function requireOrganizationAdmin(address _sender, bytes32 _organizationId) internal view;
```

### onlyOrganizationAdmin


```solidity
modifier onlyOrganizationAdmin(bytes32 _organizationId);
```

