// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { IPayments, ERC20Info, PriceType } from "src/interfaces/IPayments.sol";

/**
 * @title PaymentsReceiverStorage library
 * @notice This library contains the storage layout and events/errors for the PaymentsReceiver contract.
 */
library PaymentsReceiverStorage {
    struct Layout {
        IPayments spellcasterPayments;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.payments.receiver");

    function layout() internal pure returns (Layout storage l_) {
        bytes32 _position = FACET_STORAGE_POSITION;
        assembly {
            l_.slot := _position
        }
    }

    /**
     * @dev Emitted when an incorrect payment amount is provided.
     * @param amount The provided payment amount
     * @param price The expected payment amount (price)
     */
    error IncorrectPaymentAmount(uint256 amount, uint256 price);

    /**
     * @dev Emitted when the sender is not a valid spellcaster payment address.
     * @param sender The address of the sender attempting the action
     */
    error SenderNotSpellcasterPayments(address sender);

    /**
     * @dev Emitted when a non-accepted payment type is provided.
     * @param paymentType The provided payment type
     */
    error PaymentTypeNotAccepted(string paymentType);
}
