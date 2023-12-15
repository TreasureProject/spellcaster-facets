// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IOffchainAssetVault } from "src/interfaces/IOffchainAssetVault.sol";
import { IOffchainAssetVaultManager } from "src/interfaces/IOffchainAssetVaultManager.sol";

/**
 * @title LibOffchainAssetVaultStorage library
 * @notice This library contains the storage layout and events/errors for the OffchainAssetVault contract.
 */
library LibOffchainAssetVaultStorage {
    struct Layout {
        /**
         * @dev The manager contract that created this vault. This is where permissions are managed
         */
        IOffchainAssetVaultManager vaultManager;
        /**
         * @dev The organization that owns this vault
         */
        bytes32 orgId;
        /**
         * @dev The id of this vault
         */
        uint64 vaultId;
        /**
         * @dev Tracks used nonces to avoid replay attacks
         */
        mapping(uint256 nonce => bool isUsed) usedNonces;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.vault.offchainassetvault");

    function layout() internal pure returns (Layout storage l_) {
        bytes32 _position = FACET_STORAGE_POSITION;
        assembly {
            l_.slot := _position
        }
    }
}
