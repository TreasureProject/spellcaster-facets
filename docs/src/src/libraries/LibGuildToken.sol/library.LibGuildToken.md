# LibGuildToken
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibGuildToken.sol)

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

