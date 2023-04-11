// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SpellcasterGMStorage {
    struct Layout {
        /**
         * @dev Mapping of addres to bool, whether the account is a trusted signer
         */
        mapping(address => bool) trustedSigners;
        /**
         * @dev Mapping of address to uint to bool, whether an accounts nonce has been used.
         */
        mapping(address => mapping(uint256 => bool)) trustedSignersToNonceToUsed;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.gamemaster");

    /**
     * @dev Returns the state struct at this storage slot
     */
    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }
}
