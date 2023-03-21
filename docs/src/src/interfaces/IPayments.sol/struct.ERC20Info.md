# ERC20Info
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/interfaces/IPayments.sol)

*Used to track ERC20 payment feeds and decimals for conversions. Note that `decimals` equaling 0 means that the erc20
information is not initialized/supported.*


```solidity
struct ERC20Info {
    mapping(address => AggregatorV3Interface) priceFeeds;
    AggregatorV3Interface usdAggregator;
    AggregatorV3Interface pricedInGasTokenAggregator;
    AggregatorV3Interface gasTokenPricedInERC20Aggregator;
    uint8 decimals;
}
```

