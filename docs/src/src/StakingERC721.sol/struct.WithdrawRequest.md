# WithdrawRequest
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/StakingERC721.sol)


```solidity
struct WithdrawRequest {
    address tokenAddress;
    address reciever;
    uint256 tokenId;
    uint256 nonce;
    bool stored;
    Signature signature;
}
```

