# ERC721Consumer
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/mocks/ERC721Consumer.sol)

**Inherits:**
ERC721EnumerableUpgradeable, OwnableUpgradeable


## State Variables
### _counter

```solidity
uint256 internal _counter;
```


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
function mintFromWorld(address _user, uint256 _tokenId) public;
```

### mintArbitrary


```solidity
function mintArbitrary(address _user, uint256 _quantity) public;
```

### walletOfOwner


```solidity
function walletOfOwner(address _user) public view returns (uint256[] memory);
```

