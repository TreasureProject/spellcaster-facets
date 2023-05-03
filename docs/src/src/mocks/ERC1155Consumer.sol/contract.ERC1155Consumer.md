# ERC1155Consumer
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/mocks/ERC1155Consumer.sol)

**Inherits:**
ERC1155Upgradeable, OwnableUpgradeable


## State Variables
### worldAddress

```solidity
address public worldAddress;
```


### isAdmin

```solidity
mapping(address => bool) public isAdmin;
```


## Functions
### initialize


```solidity
function initialize() public initializer;
```

### setAdmin


```solidity
function setAdmin(address _address, bool _isAdmin) public onlyOwner;
```

### setWorldAddress


```solidity
function setWorldAddress(address _worldAddress) public onlyOwner;
```

### mintFromWorld


```solidity
function mintFromWorld(address _user, uint256 _tokenId, uint256 _quantity) public;
```

### mintArbitrary


```solidity
function mintArbitrary(address _user, uint256 _tokenId, uint256 _quantity) public;
```

