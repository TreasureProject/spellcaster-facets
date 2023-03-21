# LibGuildToken
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/libraries/LibGuildToken.sol)

*This library is used to implement features that use/update storage data for the Guild Manager contracts*


## Functions
### getGuildManager


```solidity
function getGuildManager() internal view returns (IGuildManager manager_);
```

### getOrganizationId


```solidity
function getOrganizationId() internal view returns (bytes32 orgId_);
```

### setGuildManager


```solidity
function setGuildManager(address _guildManagerAddress) internal;
```

### setOrganizationId


```solidity
function setOrganizationId(bytes32 _orgId) internal;
```

### uri


```solidity
function uri(uint256 _tokenId) internal view returns (string memory);
```

### _drawImage


```solidity
function _drawImage(string memory _data) private pure returns (string memory);
```

### _drawSVG


```solidity
function _drawSVG(string memory _data) private pure returns (string memory);
```

