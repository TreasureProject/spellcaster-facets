// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibAccessControlRoles } from "./LibAccessControlRoles.sol";

import { SpellcasterGMStorage } from "../spellcaster/SpellcasterGMStorage.sol";

import { LibMeta } from "./LibMeta.sol";

library LibSpellcasterGM {
    error AccountIsNotTrustedSigner(address _account);
    error NonceUsed(address _account, uint256 _nonce);
    error MsgSenderIsNotContractOwner(address _account);

    function setTrustedSigner(address _signer, bool _isTrusted) external {
        if (LibMeta._msgSender() != LibAccessControlRoles.contractOwner()) {
            revert MsgSenderIsNotContractOwner(_signer);
        }

        SpellcasterGMStorage.setTrustedSigner(_signer, _isTrusted);
    }

    function isTrustedSigner(address _account) public view returns (bool) {
        return SpellcasterGMStorage.isTrustedSigner(_account);
    }

    function useNonce(address _signer, uint96 _nonce) internal {
        if (SpellcasterGMStorage.isNonceUsed(_signer, _nonce)) {
            revert NonceUsed(_signer, _nonce);
        }

        SpellcasterGMStorage.setNonceUsed(_signer, _nonce);
    }

    function requireTrustedSigner(address _account) external view {
        if (!isTrustedSigner(_account)) revert AccountIsNotTrustedSigner(_account);
    }
}
