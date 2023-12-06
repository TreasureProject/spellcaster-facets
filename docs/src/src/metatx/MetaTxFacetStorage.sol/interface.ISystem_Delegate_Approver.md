# ISystem_Delegate_Approver
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/metatx/MetaTxFacetStorage.sol)

The contract that handles validating meta transaction delegate approvals

*References to 'System' are synonymous with 'Organization'*


## Functions
### isDelegateApprovedForSystem


```solidity
function isDelegateApprovedForSystem(
    address account,
    bytes32 systemId,
    address delegate
) external view returns (bool);
```

### setDelegateApprovalForSystem


```solidity
function setDelegateApprovalForSystem(bytes32 systemId, address delegate, bool approved) external;
```

### setDelegateApprovalForSystemBySignature


```solidity
function setDelegateApprovalForSystemBySignature(
    bytes32 systemId,
    address delegate,
    bool approved,
    address signer,
    uint256 nonce,
    bytes calldata signature
) external;
```

