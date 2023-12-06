# WithdrawRequest
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/StakingERC20.sol)


```solidity
struct WithdrawRequest {
    address tokenAddress;
    address reciever;
    uint256 amount;
    uint256 nonce;
    bool stored;
    Signature signature;
}
```

