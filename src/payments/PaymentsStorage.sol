// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { IPayments, ERC20Info, PriceType } from "src/interfaces/IPayments.sol";

/**
 * @title PaymentsStorage library
 * @notice This library contains the storage layout and events/errors for the PaymentsFacet contract.
 */
library PaymentsStorage {
    struct Layout {
        /**
         * @dev Input address: An ERC20 token address
         *      Output: The ERC20 token information, including price feeds and decimals
         */
        mapping(address => ERC20Info) erc20ToInfo;
        /**
         * @dev The gas token price feed for USD
         */
        AggregatorV3Interface gasTokenUSDPriceFeed;
        /**
         * @dev The address of the $MAGIC contract
         */
        address magicAddress;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.payments");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

    /**
     * @dev Emitted when a price feed is not found for a token or gas token
     * @param paymentToken The payment ERC20 token or address(0) if gas token
     * @param priceType The type of the token or gas token pair
     * @param pricedToken The address of the token or gas token pair to the `paymentToken`
     */
    error NonexistantPriceFeed(address paymentToken, PriceType priceType, address pricedToken);

    /**
     * @dev Emitted when a type is given that hasn't been implemented
     */
    error InvalidPriceType();

    /**
     * @dev Emitted when a payment is made with an incorrect amount
     */
    error IncorrectPaymentAmount();

    /**
     * @dev Emitted when a payment recipient doesn't implement the PaymentsReceiver interface
     * @param recipient The address of the invalid recipient
     */
    error NonPaymentsReceiverRecipient(address recipient);

    /**
     * @dev Emitted when a price feed returns a zero value.
     * @param paymentToken The base token address
     * @param pricedToken The token address to get a quote for
     */
    error InvalidPriceFeedQuote(address paymentToken, address pricedToken);
}
