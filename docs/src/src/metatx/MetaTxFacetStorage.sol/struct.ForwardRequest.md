# ForwardRequest
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/metatx/MetaTxFacetStorage.sol)

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

