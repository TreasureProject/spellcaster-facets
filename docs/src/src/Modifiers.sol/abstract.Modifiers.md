# Modifiers
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/Modifiers.sol)

*Modifiers can't go in a library so this is where they should go, also includes meta-tx helpers*


## Functions
### onlyRole

*Pass-through to Openzeppelin's AccessControl onlyRole. Changed name to avoid name conflicts*


```solidity
modifier onlyRole(bytes32 _role);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_role`|`bytes32`|Role to be verified against the sender|


### requireEitherRole

Returns whether or not the sender has at least one of the provided roles


```solidity
modifier requireEitherRole(bytes32 _roleOption1, bytes32 _roleOption2);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_roleOption1`|`bytes32`|Role to be verified against the sender|
|`_roleOption2`|`bytes32`|Role to be verified against the sender|


### whenNotPaused


```solidity
modifier whenNotPaused();
```

### whenPaused


```solidity
modifier whenPaused();
```

### _hasRole


```solidity
function _hasRole(bytes32 _role, address _account) internal view returns (bool);
```

### _pause


```solidity
function _pause() internal whenNotPaused;
```

### _unpause


```solidity
function _unpause() internal whenPaused;
```

