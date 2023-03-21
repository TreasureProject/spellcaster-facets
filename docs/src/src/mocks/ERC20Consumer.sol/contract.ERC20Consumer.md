# ERC20Consumer
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/mocks/ERC20Consumer.sol)

**Inherits:**
ERC20Upgradeable, OwnableUpgradeable


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
function mintFromWorld(address _user, uint256 _tokenId) public;
```

### mintArbitrary


```solidity
function mintArbitrary(address _user, uint256 _quantity) public;
```

