//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ECDSAUpgradeable } from "@openzeppelin/contracts-diamond/utils/cryptography/ECDSAUpgradeable.sol";

import { OffchainAssetVaultBase } from "src/vault/OffchainAssetVaultBase.sol";
import { LibOffchainAssetVaultStorage } from "src/vault/LibOffchainAssetVaultStorage.sol";
import { LibOffchainAssetVault } from "src/vault/LibOffchainAssetVault.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { LibUtilities } from "src/libraries/LibUtilities.sol";
import { IOffchainAssetVault, WithdrawArgs } from "src/interfaces/IOffchainAssetVault.sol";

contract OffchainAssetVault is OffchainAssetVaultBase {
    using ECDSAUpgradeable for bytes32;

    /**
     * @inheritdoc IOffchainAssetVault
     */
    function OffchainAssetVault_init(
        bytes32 _orgId,
        uint64 _vaultId
    ) external facetInitializer(keccak256("OffchainAssetVault_init")) {
        __OffchainAssetVaultBase_init(_vaultId);
        // The vault manager is the one that creates the vault
        LibOffchainAssetVault.setVaultManager(LibMeta._msgSender());
        LibOffchainAssetVault.setOrganizationId(_orgId);
        LibOffchainAssetVault.setVaultId(_vaultId);
    }

    function withdraw(WithdrawArgs[] calldata _withdraws, bytes[] calldata _signatures) external {
        uint256 _length = _withdraws.length;
        if (_length != _signatures.length) {
            revert LibUtilities.ArrayLengthMismatch(_length, _signatures.length);
        }
        for (uint256 i = 0; i < _length; i++) {
            _requireValidSignature(_withdraws[i], _signatures[i]);
            // throws if nonce already used
            LibOffchainAssetVault.useNonce(_withdraws[i].nonce);
            LibOffchainAssetVault.withdraw(_withdraws[i]);
        }
    }

    function _requireValidSignature(WithdrawArgs calldata _withdraw, bytes calldata _signature) internal view {
        LibOffchainAssetVaultStorage.Layout storage _l = LibOffchainAssetVaultStorage.layout();
        address _signer = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    WITHDRAW_ARGS_TYPEHASH,
                    _withdraw.asset,
                    _withdraw.tokenId,
                    _withdraw.amount,
                    _withdraw.kind,
                    _withdraw.to,
                    _withdraw.nonce
                )
            )
        ).recover(_signature);
        if (_signer != _l.vaultManager.getAuthoritySigner(_l.orgId, _l.vaultId)) {
            revert IOffchainAssetVault.InvalidAuthoritySignature();
        }
    }
}
