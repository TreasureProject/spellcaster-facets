// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Library for handling meta transactions with the EIP2771 standard
/// @notice The logic for getting msgSender and msgData are were copied from OpenZeppelin's 
///  ERC2771ContextUpgradeable contract
library LibMeta {

    struct Layout {
        address trustedForwarder;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.metatx");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

    // =============================================================
    //                      State Helpers
    // =============================================================

    function isTrustedForwarder(address forwarder) internal view returns (bool isTrustedForwarder_) {
        isTrustedForwarder_ = layout().trustedForwarder == forwarder;
    }

    // =============================================================
    //                      Meta Tx Helpers
    // =============================================================

    function _msgSender() internal view returns (address sender_) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /// @solidity memory-safe-assembly
            assembly {
                sender_ := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            sender_ = msg.sender;
        }
    }

    function _msgData() internal view returns (bytes calldata data_) {
        if (isTrustedForwarder(msg.sender)) {
            data_ = msg.data[:msg.data.length - 20];
        } else {
            data_ = msg.data;
        }
    }
}
