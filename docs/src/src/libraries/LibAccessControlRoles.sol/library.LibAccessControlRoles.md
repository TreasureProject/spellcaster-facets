# LibAccessControlRoles
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibAccessControlRoles.sol)


## Functions
### hasRole


```solidity
function hasRole(bytes32 _role, address _account) internal view returns (bool);
```

### requireRole


```solidity
function requireRole(bytes32 _role, address _account) internal view;
```

### requireOwner


```solidity
function requireOwner(address _account) internal view;
```

### contractOwner


```solidity
function contractOwner() internal view returns (address contractOwner_);
```

### isCollectionAdmin


```solidity
function isCollectionAdmin(address _user, address _collection) internal view returns (bool);
```

## Errors
### MissingEitherRole

```solidity
error MissingEitherRole(address _account, bytes32 _roleOption1, bytes32 _roleOption2);
```

### MissingRoleAndNotOwner

```solidity
error MissingRoleAndNotOwner(address _account, bytes32 _role);
```

### MissingRole

```solidity
error MissingRole(address _account, bytes32 _role);
```

### IsNotContractOwner

```solidity
error IsNotContractOwner(address _account);
```

