# StakingStorage
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/libraries/StakingStorage.sol)


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("staking.diamond");
```


## Functions
### getState


```solidity
function getState() internal pure returns (State storage s);
```

### getERC721TokenStorageData


```solidity
function getERC721TokenStorageData(
    address _tokenAddress,
    uint256 _tokenId
) internal view returns (ERC721TokenStorageData memory);
```

### setERC721TokenStorageData


```solidity
function setERC721TokenStorageData(
    address _tokenAddress,
    uint256 _tokenId,
    ERC721TokenStorageData memory _tokenStorageData
) internal;
```

### getERC20TokensStored


```solidity
function getERC20TokensStored(address _tokenAddress, address _user) internal view returns (uint256);
```

### setERC20TokensStored


```solidity
function setERC20TokensStored(address _tokenAddress, address _user, uint256 _amount) internal;
```

### getERC1155TokensStored


```solidity
function getERC1155TokensStored(
    address _tokenAddress,
    uint256 _tokenId,
    address _user
) internal view returns (uint256);
```

### setERC1155TokensStored


```solidity
function setERC1155TokensStored(address _tokenAddress, uint256 _tokenId, address _user, uint256 _quantity) internal;
```

### getUsedNonce


```solidity
function getUsedNonce(uint256 _nonce) internal view returns (bool);
```

### setUsedNonce


```solidity
function setUsedNonce(uint256 _nonce, bool _set) internal;
```

### compareStrings


```solidity
function compareStrings(string memory a, string memory b) internal pure returns (bool);
```

## Structs
### State

```solidity
struct State {
    mapping(address => mapping(uint256 => ERC721TokenStorageData)) tokenAddressToTokenIdToERC721TokenStorageData;
    mapping(address => mapping(address => uint256)) tokenAddressToAddressToTokensStored;
    mapping(address => mapping(uint256 => mapping(address => uint256))) tokenAddressToTokenIdToUserToQuantityStored;
    mapping(uint256 => bool) usedNonces;
}
```

