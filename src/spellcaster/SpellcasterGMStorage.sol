// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SpellcasterGMStorage {
    struct Layout {
        mapping(address => bool) trustedSigner;
        mapping(address => mapping(uint256 => bool)) trustedSignersToNonce;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.gamemaster");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

    function setTrustedSigner(address _account, bool _isTrustedSigner) internal {
        layout().trustedSigner[_account] = _isTrustedSigner;
    }

    function isTrustedSigner(address _account) internal view returns (bool) {
        return layout().trustedSigner[_account];
    }

    function setNonceUsed(address _account, uint256 _nonce) internal {
        layout().trustedSignersToNonce[_account][_nonce] = true;
    }

    function isNonceUsed(address _account, uint256 _nonce) internal view returns (bool) {
        return layout().trustedSignersToNonce[_account][_nonce];
    }
}
