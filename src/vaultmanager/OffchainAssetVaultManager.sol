//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    OffchainAssetVaultManagerBase,
    LibOffchainAssetVaultManager
} from "src/vaultmanager/OffchainAssetVaultManagerBase.sol";
import { LibOffchainAssetVaultManagerStorage } from "src/vaultmanager/LibOffchainAssetVaultManagerStorage.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { LibUtilities } from "src/libraries/LibUtilities.sol";
import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { IOffchainAssetVaultManager } from "src/interfaces/IOffchainAssetVaultManager.sol";

contract OffchainAssetVaultManager is OffchainAssetVaultManagerBase {
    /**
     * @inheritdoc IOffchainAssetVaultManager
     */
    function OffchainAssetVaultManager_init(address _vaultImpl)
        external
        facetInitializer(keccak256("OffchainAssetVaultManager_init"))
    {
        __OffchainAssetVaultManagerBase_init();
        LibOffchainAssetVaultManager.setVaultBeaconImpl(_vaultImpl);
    }

    /**
     * @inheritdoc IOffchainAssetVaultManager
     */
    function createVault(
        bytes32 _orgId,
        address _owner,
        address _authoritySigner
    ) external override returns (address vaultAddress_, uint64 vaultId_) {
        (vaultAddress_, vaultId_) = LibOffchainAssetVaultManager.createVault(_orgId, _owner, _authoritySigner);

        emit VaultCreated(_orgId, vaultId_, vaultAddress_, _owner, _authoritySigner);
    }

    /**
     * @inheritdoc IOffchainAssetVaultManager
     */
    function getVaultAddress(bytes32 _orgId, uint64 _vaultId) external view returns (address) {
        return LibOffchainAssetVaultManager.getVaultInfo(_orgId, _vaultId).assetVault;
    }

    /**
     * @inheritdoc IOffchainAssetVaultManager
     */
    function getOwner(bytes32 _orgId, uint64 _vaultId) external view returns (address) {
        return LibOffchainAssetVaultManager.getVaultInfo(_orgId, _vaultId).owner;
    }

    /**
     * @inheritdoc IOffchainAssetVaultManager
     */
    function getAuthoritySigner(bytes32 _orgId, uint64 _vaultId) external view returns (address) {
        return LibOffchainAssetVaultManager.getVaultInfo(_orgId, _vaultId).authoritySigner;
    }

    function getVaultBeaconAddress() external view returns (address beacon_) {
        beacon_ = address(LibOffchainAssetVaultManagerStorage.layout().assetVaultBeacon);
    }
}
