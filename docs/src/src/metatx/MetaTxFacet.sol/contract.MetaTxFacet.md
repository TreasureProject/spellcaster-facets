# MetaTxFacet
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/metatx/MetaTxFacet.sol)

**Inherits:**
[SupportsMetaTx](/src/metatx/SupportsMetaTx.sol/abstract.SupportsMetaTx.md)


## Functions
### __MetaTxFacet_init

*Sets all necessary state and permissions for the contract*


```solidity
function __MetaTxFacet_init(address _organizationDelegateApprover) internal onlyFacetInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationDelegateApprover`|`address`|The delegate approver address that tracks which wallet can run txs on behalf of the real sending account|


### verify


```solidity
function verify(ForwardRequest calldata req, bytes calldata signature, bool shouldRevert) public view returns (bool);
```

### execute


```solidity
function execute(ForwardRequest calldata req, bytes calldata signature) public payable returns (bytes memory);
```

### setDelegateAddress

This function is used to set the delegate approver address

*This function is only callable by the owner of the contract*


```solidity
function setDelegateAddress(address _organizationDelegateApprover) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationDelegateApprover`|`address`|The delegate approver address that tracks which wallet can run txs on behalf of the real sending account|


## Events
### ExecutedMetaTx

```solidity
event ExecutedMetaTx(address userAddress, address payable relayerAddress, bytes functionSignature);
```

### DelegateApproverSet

```solidity
event DelegateApproverSet(address delegateApprover);
```

