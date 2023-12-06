# LibPayments
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibPayments.sol)


## Functions
### getERC20Info


```solidity
function getERC20Info(address _erc20Addr) internal view returns (ERC20Info storage info_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20Addr`|`address`|The address of the coin to retrieve info for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`info_`|`ERC20Info`|The return struct is storage. This means all state changes to the struct will save automatically, instead of using a memory copy overwrite|


### getGasTokenUSDPriceFeed


```solidity
function getGasTokenUSDPriceFeed() internal view returns (AggregatorV3Interface priceFeed_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`priceFeed_`|`AggregatorV3Interface`|The price feed for the gas token valued in USD|


### getGasTokenERC20PriceFeed


```solidity
function getGasTokenERC20PriceFeed(address _erc20Addr) internal view returns (AggregatorV3Interface priceFeed_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20Addr`|`address`|The address of the coin to retrieve the price feed for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`priceFeed_`|`AggregatorV3Interface`|The price feed for the gas token valued in the ERC20 token|


### getMagicAddress


```solidity
function getMagicAddress() internal view returns (address magicAddress_);
```

### setGasTokenUSDPriceFeed


```solidity
function setGasTokenUSDPriceFeed(address _priceFeedAddr) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_priceFeedAddr`|`address`|The address of the price feed to set|


### setGasTokenERC20PriceFeed


```solidity
function setGasTokenERC20PriceFeed(address _erc20Addr, address _priceFeedAddr) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20Addr`|`address`|The address of the ERC20 token to set the price feed for|
|`_priceFeedAddr`|`address`|The address of the price feed to set|


### setMagicAddress


```solidity
function setMagicAddress(address _magicAddress) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_magicAddress`|`address`|The address of the $MAGIC token|


