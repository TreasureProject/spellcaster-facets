# ISystem_Delegate_Approver
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/metatx/MetaTxFacetStorage.sol)

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

