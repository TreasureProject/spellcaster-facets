# PriceType
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/interfaces/IPayments.sol)

*Used to determine how to calculate the payment amount when taking a payment.
STATIC: The payment amount is the input token without conversion.
PRICED_IN_ERC20: The payment amount is priced in an ERC20 relative to the payment token.
PRICED_IN_USD: The payment amount is priced in USD relative to the payment token.
PRICED_IN_GAS_TOKEN: The payment amount is priced in the gas token relative to the payment token.*


```solidity
enum PriceType {
    STATIC,
    PRICED_IN_ERC20,
    PRICED_IN_USD,
    PRICED_IN_GAS_TOKEN
}
```

