# LibMeta
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibMeta.sol)

The logic for getting msgSender and msgData are were copied from OpenZeppelin's
ERC2771ContextUpgradeable contract


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.metatx");
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

### isTrustedForwarder


```solidity
function isTrustedForwarder(address forwarder) internal view returns (bool isTrustedForwarder_);
```

### _msgSender

*The only valid forwarding contract is the one that is going to run the executing function*


```solidity
function _msgSender() internal view returns (address sender_);
```

### _msgData

*The only valid forwarding contract is the one that is going to run the executing function*


```solidity
function _msgData() internal view returns (bytes calldata data_);
```

### getMetaDelegateAddress


```solidity
function getMetaDelegateAddress() internal view returns (address delegateAddress_);
```

## Structs
### Layout

```solidity
struct Layout {
    address trustedForwarder;
}
```

