# LibUtilities
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibUtilities.sol)


## Functions
### requireArrayLengthMatch


```solidity
function requireArrayLengthMatch(uint256 _length1, uint256 _length2) internal pure;
```

### asSingletonArray


```solidity
function asSingletonArray(uint256 _item) internal pure returns (uint256[] memory array_);
```

### asSingletonArray


```solidity
function asSingletonArray(string memory _item) internal pure returns (string[] memory array_);
```

### compareStrings


```solidity
function compareStrings(string memory a, string memory b) public pure returns (bool);
```

### setPause


```solidity
function setPause(bool _paused) internal;
```

### paused


```solidity
function paused() internal view returns (bool);
```

### requirePaused


```solidity
function requirePaused() internal view;
```

### requireNotPaused


```solidity
function requireNotPaused() internal view;
```

### toString


```solidity
function toString(uint256 _value) internal pure returns (string memory);
```

### convertBytesToBytes4

This function takes the first 4 MSB of the given bytes32 and converts them to a bytes4

*This function is useful for grabbing function selectors from calldata*


```solidity
function convertBytesToBytes4(bytes memory inBytes) internal pure returns (bytes4 outBytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`inBytes`|`bytes`|The bytes to convert to bytes4|


## Events
### Paused

```solidity
event Paused(address _account);
```

### Unpaused

```solidity
event Unpaused(address _account);
```

## Errors
### ArrayLengthMismatch

```solidity
error ArrayLengthMismatch(uint256 _len1, uint256 _len2);
```

### IsPaused

```solidity
error IsPaused();
```

### NotPaused

```solidity
error NotPaused();
```

