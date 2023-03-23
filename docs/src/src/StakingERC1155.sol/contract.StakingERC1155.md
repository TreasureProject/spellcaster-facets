# StakingERC1155
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/StakingERC1155.sol)

**Inherits:**
ERC1155HolderUpgradeable


## Functions
### initialize


```solidity
function initialize() external initializer;
```

### depositERC1155


```solidity
function depositERC1155(
    address _tokenAddress,
    address _reciever,
    uint256[] memory _tokenIds,
    uint256[] memory _quantities
) public;
```

### verifyHash


```solidity
function verifyHash(bytes32 _hash, Signature calldata signature) internal pure returns (address);
```

### withdrawERC1155


```solidity
function withdrawERC1155(WithdrawRequest[] calldata _withdrawRequests) public;
```

## Events
### ERC1155Deposited

```solidity
event ERC1155Deposited(address _tokenAddress, address _depositor, address _reciever, uint256 _tokenId, uint256 _amount);
```

### ERC1155Withdrawn

```solidity
event ERC1155Withdrawn(address _tokenAddress, address _reciever, uint256 _tokenId, uint256 _amount);
```
