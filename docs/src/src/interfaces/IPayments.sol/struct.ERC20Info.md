# ERC20Info
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IPayments.sol)

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

