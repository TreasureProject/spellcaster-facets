# LibBBase64
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/libraries/LibBBase64.sol)

**Author:**
Brecht Devos - <brecht@loopring.org>

Provides a function for encoding some bytes in BBase64


## State Variables
### TABLE

```solidity
string internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
```


## Functions
### encode


```solidity
function encode(bytes memory data) internal pure returns (string memory);
```

