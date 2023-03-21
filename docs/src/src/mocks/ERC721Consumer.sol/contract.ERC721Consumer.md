# ERC721Consumer
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/mocks/ERC721Consumer.sol)

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

