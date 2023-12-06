// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibPayments } from "src/libraries/LibPayments.sol";
import { PaymentsV1 } from "src/payments/PaymentsV1.sol";
import { PaymentsV2 } from "src/payments/PaymentsV2.sol";

/**
 * @title Payments Facet contract.
 * @dev This facet exposes functionality to easily allow users to accept payments in ERC20 tokens or gas tokens (ETH, MATIC, etc.)
 *      Users can also pay in a token amount priced in USD, other ERC20, or gas tokens.
 */
contract PaymentsFacet is PaymentsV1, PaymentsV2 {
    /**
     * @dev Initialize the facet. Can be called externally or internally.
     * Ideally referenced in an initialization script facet
     */
    function PaymentsFacet_init(
        address _gasTokenUSDPriceFeed,
        address _magicAddress
    ) public facetInitializer(keccak256("PaymentsFacet_init")) {
        LibPayments.setGasTokenUSDPriceFeed(_gasTokenUSDPriceFeed);
        LibPayments.setMagicAddress(_magicAddress);
    }
}
