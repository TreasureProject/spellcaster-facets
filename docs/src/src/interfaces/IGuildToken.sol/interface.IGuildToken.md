# IGuildToken
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IGuildToken.sol)


## Functions
### initialize

*Sets initial state of this facet. Must be called for contract to work properly*


```solidity
function initialize(bytes32 _organizationId, address _systemDelegateApprover) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organizationId`|`bytes32`|The id of the organization that owns this guild collection|
|`_systemDelegateApprover`|`address`|The contract that approves and records meta transaction delegates|


### adminMint

*Mints ERC1155 tokens to the given address. Only callable by a privileged address (i.e. GuildManager contract)*


```solidity
function adminMint(address _to, uint256 _id, uint256 _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Recipient of the minted token|
|`_id`|`uint256`|The tokenId of the token to mint|
|`_amount`|`uint256`|The number of tokens to mint|


### adminBurn

*Burns ERC1155 tokens from the given address. Only callable by a privileged address (i.e. GuildManager contract)*


```solidity
function adminBurn(address _from, uint256 _id, uint256 _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|The account to burn the tokens from|
|`_id`|`uint256`|The tokenId of the token to burn|
|`_amount`|`uint256`|The number of tokens to burn|


### guildManager

*Returns the manager address for this token contract*


```solidity
function guildManager() external view returns (address manager_);
```

### organizationId

*Returns the organization id for this token contract*


```solidity
function organizationId() external view returns (bytes32 organizationId_);
```

