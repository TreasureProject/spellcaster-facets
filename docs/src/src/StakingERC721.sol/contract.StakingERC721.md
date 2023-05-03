# StakingERC721
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/StakingERC721.sol)

**Inherits:**
Initializable


## Functions
### initialize


```solidity
function initialize() external initializer;
```

### depositERC721


```solidity
function depositERC721(address _tokenAddress, address _reciever, uint256[] memory _tokenIds) public;
```

### verifyHash


```solidity
function verifyHash(bytes32 _hash, Signature calldata signature) internal pure returns (address);
```

### withdrawERC721


```solidity
function withdrawERC721(WithdrawRequest[] calldata _withdrawRequests) public;
```

## Events
### ERC721Deposited

```solidity
event ERC721Deposited(address _tokenAddress, address _depositor, address _reciever, uint256 _tokenId);
```

### ERC721Withdrawn

```solidity
event ERC721Withdrawn(address _tokenAddress, address _reciever, uint256 _tokenId);
```

