# LibBBase64
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/libraries/LibBBase64.sol)

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

