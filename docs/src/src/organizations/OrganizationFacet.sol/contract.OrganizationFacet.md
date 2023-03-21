# OrganizationFacet
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/organizations/OrganizationFacet.sol)

**Inherits:**
[FacetInitializable](/src/utils/FacetInitializable.sol/abstract.FacetInitializable.md), [Modifiers](/src/Modifiers.sol/abstract.Modifiers.md), [IOrganizationManager](/src/interfaces/IOrganizationManager.sol/interface.IOrganizationManager.md), [SupportsMetaTx](/src/metatx/SupportsMetaTx.sol/abstract.SupportsMetaTx.md)

*Use this facet to consume the ability to segment feature adoption by organization.*


## Functions
### OrganizationFacet_init

*Initialize the facet. Can be called externally or internally.
Ideally referenced in an initialization script facet*


```solidity
function OrganizationFacet_init() public facetInitializer(keccak256("OrganizationFacet"));
```

### createOrganization

*Creates a new organization. For now, this can only be done by admins on the GuildManager contract.*


```solidity
function createOrganization(
    bytes32 _newOrganizationId,
    string calldata _name,
    string calldata _description
) public override onlyRole(ADMIN_ROLE) whenNotPaused supportsMetaTx(_newOrganizationId);
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
) public override whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId);
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
function setOrganizationAdmin(
    bytes32 _organizationId,
    address _admin
) public override whenNotPaused onlyOrganizationAdmin(_organizationId) supportsMetaTx(_organizationId);
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
function getOrganizationInfo(bytes32 _organizationId) external view override returns (OrganizationInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization to return info for|


### onlyOrganizationAdmin


```solidity
modifier onlyOrganizationAdmin(bytes32 _organizationId);
```

### onlyValidOrganization


```solidity
modifier onlyValidOrganization(bytes32 _organizationId);
```

