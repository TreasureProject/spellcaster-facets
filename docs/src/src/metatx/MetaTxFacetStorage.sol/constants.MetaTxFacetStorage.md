# Constants
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/metatx/MetaTxFacetStorage.sol)

### FORWARD_REQ_TYPEHASH
*The typehash of the ForwardRequest struct used when signing the meta transaction
This must match the ForwardRequest struct, and must not have extra whitespace or it will invalidate the signature*


```solidity
bytes32 constant FORWARD_REQ_TYPEHASH =
    keccak256("ForwardRequest(address from,uint96 nonce,bytes32 organizationId,bytes data)");
```

