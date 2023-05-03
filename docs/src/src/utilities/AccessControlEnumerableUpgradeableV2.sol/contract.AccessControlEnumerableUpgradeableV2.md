# AccessControlEnumerableUpgradeableV2
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/utilities/AccessControlEnumerableUpgradeableV2.sol)

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

