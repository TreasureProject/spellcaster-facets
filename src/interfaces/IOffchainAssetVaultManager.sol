// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @param owner The owner of the Vault.
 * @param authoritySigner The signer used for withdrawing assets from the vault.
 * @param assetVault The address of the asset vault holding the assets.
 */
struct VaultInfo {
    address owner;
    address authoritySigner;
    address assetVault;
}

interface IOffchainAssetVaultManager {
    event VaultCreated(
        bytes32 indexed orgId, uint64 indexed vaultId, address vaultAddress, address owner, address authoritySigner
    );
    event VaultUpdated(
        bytes32 indexed orgId, uint64 indexed vaultId, address vaultAddress, address owner, address authoritySigner
    );

    function OffchainAssetVaultManager_init(address _vaultImpl) external;
    function createVault(
        bytes32 _orgId,
        address _owner,
        address _authoritySigner
    ) external returns (address vaultAddress_, uint64 vaultId_);
    function getVaultAddress(bytes32 _orgId, uint64 _vaultId) external view returns (address);
    function getOwner(bytes32 _orgId, uint64 _vaultId) external view returns (address);
    function getAuthoritySigner(bytes32 _orgId, uint64 _vaultId) external view returns (address);
}
