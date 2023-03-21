# StakingERC20
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/StakingERC20.sol)

**Inherits:**
Initializable


## Functions
### initialize


```solidity
function initialize() external initializer;
```

### depositERC20


```solidity
function depositERC20(address _tokenAddress, address _reciever, uint256 _amount) public;
```

### verifyHash


```solidity
function verifyHash(bytes32 _hash, Signature calldata signature) internal pure returns (address);
```

### withdrawERC20


```solidity
function withdrawERC20(WithdrawRequest[] calldata _withdrawRequests) public;
```

## Events
### ERC20Deposited

```solidity
event ERC20Deposited(address _tokenAddress, address _depositor, address _reciever, uint256 _amount);
```

### ERC20Withdrawn

```solidity
event ERC20Withdrawn(address _tokenAddress, address _reciever, uint256 _amount);
```

