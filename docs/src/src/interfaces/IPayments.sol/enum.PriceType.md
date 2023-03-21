# PriceType
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/interfaces/IPayments.sol)

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

