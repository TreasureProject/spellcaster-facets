# StakingERC721
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/StakingERC721.sol)

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

