// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibAccessControlRoles } from "./LibAccessControlRoles.sol";

import { SpellcasterGMStorage } from "../spellcaster/SpellcasterGMStorage.sol";

import { LibMeta } from "./LibMeta.sol";

library LibSpellcasterGM {
    /**
     * @dev Emitted when an account is not a trusted signer.
     * @param account The signer address
     */
    error AccountIsNotTrustedSigner(address account);

    /**
     * @dev Emitted when a nonce is already used.
     * @param account The signer address
     * @param nonce The nonce
     */
    error NonceUsed(address account, uint256 nonce);

    /**
     * @dev Emitted when the msg sender was not the contact owner.
     * @param account The msg sender
     */
    error MsgSenderIsNotContractOwner(address account);

    /**
     * @dev Sets a trusted signer to spellcaster
     * @param _account The address of the signer.
     * @param _isTrusted Whether they are trusted or not
     */
    function setTrustedSigner(address _account, bool _isTrusted) internal {
        if (LibMeta._msgSender() != LibAccessControlRoles.contractOwner()) {
            revert MsgSenderIsNotContractOwner(_account);
        }

        SpellcasterGMStorage.layout().trustedSigners[_account] = _isTrusted;
    }

    /**
     * @dev Returns whether a signer is trusted
     * @param _account The address of the signer.
     */
    function isTrustedSigner(address _account) public view returns (bool) {
        return SpellcasterGMStorage.layout().trustedSigners[_account];
    }

    /**
     * @dev Use a nonce, and revert if already used
     * @param _account The address of the signer.
     * @param _nonce The nonce.
     */
    function useNonce(address _account, uint96 _nonce) internal {
        if (SpellcasterGMStorage.layout().trustedSignersToNonceToUsed[_account][_nonce]) {
            revert NonceUsed(_account, _nonce);
        }

        SpellcasterGMStorage.layout().trustedSignersToNonceToUsed[_account][_nonce] = true;
    }

    /**
     * @dev Function that reverts if passed account is not a trusted signer
     * @param _account The address of the signer.
     */
    function requireTrustedSigner(address _account) external view {
        if (!isTrustedSigner(_account)) revert AccountIsNotTrustedSigner(_account);
    }
}
