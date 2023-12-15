// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import { IOffchainAssetVaultManager, VaultInfo } from "src/interfaces/IOffchainAssetVaultManager.sol";

/**
 * @title LibOffchainAssetVaultManagerStorage library
 * @notice This library contains the storage layout and events/errors for the OffchainAssetVaultManager contract.
 */
library LibOffchainAssetVaultManagerStorage {
    struct Layout {
        /**
         * @dev The implementation of the vault contract to create new contracts from
         */
        UpgradeableBeacon assetVaultBeacon;
        /**
         * @dev Tracks the current vault id for a given organization
         */
        mapping(bytes32 _orgId => uint64 _currentId) vaultIds;
        /**
         * @dev Tracks the vault info for a given organization and vault id
         */
        mapping(bytes32 _orgId => mapping(uint64 _vaultId => VaultInfo _info)) vaultInfo;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.vault.offchainassetvaultmanager");

    function layout() internal pure returns (Layout storage l_) {
        bytes32 _position = FACET_STORAGE_POSITION;
        assembly {
            l_.slot := _position
        }
    }
}
