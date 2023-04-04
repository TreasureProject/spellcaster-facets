// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SpellcasterGMStorage {
    struct Layout {
        /**
         * @dev Mapping of addres to bool, whether the account is a trusted signer
         * @param trustedSigner Whether they are trusted or not
         */
        mapping(address => bool) trustedSigner;
        /**
         * @dev Mapping of address to uint to bool, whether an accounts nonce has been used.
         * @param trustedSignersToNonce Whether the nonce for this account has been used
         */
        mapping(address => mapping(uint256 => bool)) trustedSignersToNonce;
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

    /**
     * @dev Sets a trusted signer into storage.
     * @param _account The signer to set.
     * @param _isTrustedSigner Whether they are trusted.
     */
    function setTrustedSigner(address _account, bool _isTrustedSigner) internal {
        layout().trustedSigner[_account] = _isTrustedSigner;
    }

    /**
     * @dev Returns if a signer is trusted.
     * @param _account The signer
     * @return bool Whether this signer is trusted
     */
    function isTrustedSigner(address _account) internal view returns (bool) {
        return layout().trustedSigner[_account];
    }

    /**
     * @dev Set a nonce to used
     * @param _account The address of the signer.
     * @param _nonce The nonce.
     */
    function setNonceUsed(address _account, uint256 _nonce) internal {
        layout().trustedSignersToNonce[_account][_nonce] = true;
    }

    /**
     * @dev Returns a nonce
     * @param _account The address of the signer.
     * @param _nonce The nonce.
     */
    function isNonceUsed(address _account, uint256 _nonce) internal view returns (bool) {
        return layout().trustedSignersToNonce[_account][_nonce];
    }
}
