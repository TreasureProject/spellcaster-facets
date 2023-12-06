# Constants
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/metatx/MetaTxFacetStorage.sol)

### FORWARD_REQ_TYPEHASH
*The typehash of the ForwardRequest struct used when signing the meta transaction
This must match the ForwardRequest struct, and must not have extra whitespace or it will invalidate the signature*


```solidity
bytes32 constant FORWARD_REQ_TYPEHASH =
    keccak256("ForwardRequest(address from,uint96 nonce,bytes32 organizationId,bytes data)");
```

