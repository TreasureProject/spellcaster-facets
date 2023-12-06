# ForwardRequest
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/metatx/MetaTxFacetStorage.sol)

The struct used for signing and validating meta transactions

*from+nonce is packed to a single storage slot to save calldata gas on rollups*


```solidity
struct ForwardRequest {
    address from;
    uint96 nonce;
    bytes32 organizationId;
    bytes data;
}
```

