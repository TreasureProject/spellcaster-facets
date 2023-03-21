# AccessControlFacet
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/access/AccessControlFacet.sol)

**Inherits:**
[FacetInitializable](/src/utils/FacetInitializable.sol/abstract.FacetInitializable.md), [SupportsMetaTx](/src/metatx/SupportsMetaTx.sol/abstract.SupportsMetaTx.md), AccessControlEnumerableUpgradeable

*Use this facet to limit the spread of third-party dependency references and allow new functionality to be shared*


## Functions
### AccessControlFacet_init


```solidity
function AccessControlFacet_init() external facetInitializer(keccak256("AccessControlFacet"));
```

### grantRoles

Batch function for granting access to many addresses at once.

*Checks for RoleAdmin permissions inside the grantRole function
per the OpenZeppelin AccessControl standard*


```solidity
function grantRoles(bytes32[] calldata _roles, address[] calldata _accounts) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_roles`|`bytes32[]`|Roles to be granted to the account in the same index of the _accounts array|
|`_accounts`|`address[]`|Addresses to grant the role in the same index of the _roles array|


### adminRole

*Helper for getting admin role from block explorers*


```solidity
function adminRole() external pure returns (bytes32 role_);
```

### _checkRole

*Overrides to use custom error vs string building*


```solidity
function _checkRole(bytes32 role, address account) internal view virtual override;
```

### supportsInterface

*Overrides AccessControlEnumerableUpgradeable and passes through to it.
This is to have multiple inheritance overrides to be from this repo instead of OZ*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```

