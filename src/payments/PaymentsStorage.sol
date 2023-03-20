// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IPayments, ERC20Info, DenominatingType} from "src/interfaces/IPayments.sol";

/**
 * @title PaymentsStorage library
 * @notice This library contains the storage layout and events/errors for the ERC20PaymentsFacet contract.
 */
library PaymentsStorage {

    struct Layout {
        /**
         * @dev Input address: An ERC20 token address
         *      Output: The ERC20 token information, including price feeds and decimals
         */
        mapping(address => ERC20Info) erc20ToInfo;
        /**
         * @dev Input address: An ERC20 token address
         *      Output: The gas token price feed for the ERC20 token
         */
        mapping(address => AggregatorV3Interface) gasTokenERC20PriceFeeds;
        /**
         * @dev The gas token price feed for USD
         */
        AggregatorV3Interface gasTokenUSDPriceFeed;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.payments.erc20");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

    /**
     * @dev Emitted when a new price feed is added for a coin.
     * @param _baseCoin The base coin address
     * @param _quoteCoin The coin address to get a quote for
     */
    error NoPriceFeedForQuoteCoin(address _baseCoin, address _quoteCoin);

    error NonexistantPriceFeed(address _baseERC20, DenominatingType _denominatingType, address _denominatingAddress);

    error InvalidDenominatingType();
    
    error IncorrectPaymentAmount();

    /**
     * @dev Emitted when a price feed returns a zero value.
     * @param _baseCoin The base coin address
     * @param _quoteCoin The coin address to get a quote for
     */
    error InvalidPriceFeedQuote(address _baseCoin, address _quoteCoin);
}
