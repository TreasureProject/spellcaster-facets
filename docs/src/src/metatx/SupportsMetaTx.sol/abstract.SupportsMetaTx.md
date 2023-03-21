# SupportsMetaTx
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/metatx/SupportsMetaTx.sol)

**Inherits:**
[FacetInitializable](/src/utils/FacetInitializable.sol/abstract.FacetInitializable.md), EIP712Upgradeable


## Functions
### __SupportsMetaTx_init

*Sets all necessary state and permissions for the contract*


```solidity
function __SupportsMetaTx_init(address _organizationDelegateApprover) internal onlyFacetInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationDelegateApprover`|`address`|The delegate approver address that tracks which wallet can run txs on behalf of the real sending account|


### verifyAndConsumeSessionId

*Verifies and consumes the session ID, ensuring it matches the provided organization ID.
If the call is from a meta transaction, the session ID is consumed and must match the organization ID.
Resets the session ID before the call to ensure that subsequent calls do not keep validating.*


```solidity
function verifyAndConsumeSessionId(bytes32 _organizationId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The organization ID to be verified against the session ID|


### getSessionOrganizationId

*Returns the session organization ID from the MetaTxFacetStorage layout.*


```solidity
function getSessionOrganizationId() internal view returns (bytes32 sessionId_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`sessionId_`|`bytes32`|The session organization ID|


### supportsMetaTx


```solidity
modifier supportsMetaTx(bytes32 _organizationId) virtual;
```

### supportsMetaTxNoId


```solidity
modifier supportsMetaTxNoId() virtual;
```

