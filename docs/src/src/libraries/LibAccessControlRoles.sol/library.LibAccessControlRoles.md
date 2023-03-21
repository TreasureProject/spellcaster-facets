# LibAccessControlRoles
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/libraries/LibAccessControlRoles.sol)


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

