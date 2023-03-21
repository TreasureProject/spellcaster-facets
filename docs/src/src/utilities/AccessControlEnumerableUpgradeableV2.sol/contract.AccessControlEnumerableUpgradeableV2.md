# AccessControlEnumerableUpgradeableV2
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/utilities/AccessControlEnumerableUpgradeableV2.sol)

**Inherits:**
AccessControlEnumerableUpgradeable


## State Variables
### OWNER_ROLE

```solidity
bytes32 internal constant OWNER_ROLE = keccak256("OWNER");
```


### ADMIN_ROLE

```solidity
bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN");
```


### ROLE_GRANTER_ROLE

```solidity
bytes32 internal constant ROLE_GRANTER_ROLE = keccak256("ROLE_GRANTER");
```


## Functions
### constructor


```solidity
constructor();
```

### grantRole


```solidity
function grantRole(
    bytes32 _role,
    address _account
)
    public
    override(AccessControlUpgradeable, IAccessControlUpgradeable)
    requiresEitherRole(ROLE_GRANTER_ROLE, OWNER_ROLE);
```

### revokeRole


```solidity
function revokeRole(
    bytes32 _role,
    address _account
)
    public
    override(AccessControlUpgradeable, IAccessControlUpgradeable)
    requiresEitherRole(ROLE_GRANTER_ROLE, OWNER_ROLE);
```

### requiresRole


```solidity
modifier requiresRole(bytes32 _role);
```

### requiresEitherRole


```solidity
modifier requiresEitherRole(bytes32 _roleOption1, bytes32 _roleOption2);
```

