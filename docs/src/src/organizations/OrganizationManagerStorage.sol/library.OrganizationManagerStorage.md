# OrganizationManagerStorage
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/organizations/OrganizationManagerStorage.sol)

This library contains the storage layout and events/errors for the OrganizationFacet contract.


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.organization.manager");
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Events
### OrganizationCreated
*Emitted when a new organization is created.*


```solidity
event OrganizationCreated(bytes32 organizationId);
```

### OrganizationInfoUpdated
*Emitted when an organization's information is updated.*


```solidity
event OrganizationInfoUpdated(bytes32 organizationId, string name, string description);
```

### OrganizationAdminUpdated
*Emitted when an organization's admin is updated.*


```solidity
event OrganizationAdminUpdated(bytes32 organizationId, address admin);
```

## Errors
### NotOrganizationAdmin
*Emitted when the sender is not an organization admin and tries to perform an admin-only action.*


```solidity
error NotOrganizationAdmin(address sender);
```

### InvalidOrganizationAdmin
*Emitted when an invalid organization admin address is provided.*


```solidity
error InvalidOrganizationAdmin(address admin);
```

### NonexistantOrganization
*Emitted when an organization does not exist.*


```solidity
error NonexistantOrganization(bytes32 organizationId);
```

### OrganizationAlreadyExists
*Emitted when an organization already exists.*


```solidity
error OrganizationAlreadyExists(bytes32 organizationId);
```

## Structs
### Layout

```solidity
struct Layout {
    mapping(bytes32 => OrganizationInfo) organizationIdToInfo;
}
```

