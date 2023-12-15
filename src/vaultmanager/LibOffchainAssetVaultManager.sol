// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { IOffchainAssetVaultManager, VaultInfo } from "src/interfaces/IOffchainAssetVaultManager.sol";
import { IOffchainAssetVault } from "src/interfaces/IOffchainAssetVault.sol";

import { LibOffchainAssetVaultManagerStorage } from "src/vaultmanager/LibOffchainAssetVaultManagerStorage.sol";

/**
 * @title OffchainAssetVault Library
 * @dev This library is used to implement features that use/update storage data for the OffchainAssetVault contracts
 */
library LibOffchainAssetVaultManager {
    // =============================================================
    //                    State Getters/Setters
    // =============================================================

    function getVaultBeacon() internal view returns (UpgradeableBeacon beacon_) {
        beacon_ = LibOffchainAssetVaultManagerStorage.layout().assetVaultBeacon;
    }

    function setVaultBeaconImpl(address _beaconImplAddress) internal {
        LibOffchainAssetVaultManagerStorage.Layout storage _l = LibOffchainAssetVaultManagerStorage.layout();

        if (address(_l.assetVaultBeacon) == address(0)) {
            _l.assetVaultBeacon = new UpgradeableBeacon(_beaconImplAddress, address(this));
        } else if (_l.assetVaultBeacon.implementation() != _beaconImplAddress) {
            _l.assetVaultBeacon.upgradeTo(_beaconImplAddress);
        }
    }

    function getVaultInfo(bytes32 _orgId, uint64 vaultId_) internal view returns (VaultInfo storage info_) {
        info_ = LibOffchainAssetVaultManagerStorage.layout().vaultInfo[_orgId][vaultId_];
    }

    // =============================================================
    //                       Create Functions
    // =============================================================

    function createVault(
        bytes32 _orgId,
        address _owner,
        address _authoritySigner
    ) internal returns (address vaultAddress_, uint64 vaultId_) {
        LibOffchainAssetVaultManagerStorage.Layout storage _l = LibOffchainAssetVaultManagerStorage.layout();
        LibOrganizationManager.requireOrganizationAdmin(LibMeta._msgSender(), _orgId);

        vaultId_ = _l.vaultIds[_orgId];
        // start at 1 for the first vault.
        if (vaultId_ == 0) {
            vaultId_ = 1;
        }
        _l.vaultIds[_orgId] = vaultId_ + 1; // increment to a new available id

        VaultInfo storage _info = _l.vaultInfo[_orgId][vaultId_];
        _info.owner = _owner;
        _info.authoritySigner = _authoritySigner;

        bytes memory _offchainAssetVaultData =
            abi.encodeCall(IOffchainAssetVault.OffchainAssetVault_init, (_orgId, vaultId_));
        vaultAddress_ = address(new BeaconProxy(address(_l.assetVaultBeacon), _offchainAssetVaultData));
        _info.assetVault = vaultAddress_;
    }
}
