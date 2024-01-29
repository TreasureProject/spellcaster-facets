// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/utils/SafeERC20Upgradeable.sol";
import { IERC721Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import { IERC1155Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";

import { IOffchainAssetVaultManager, VaultInfo } from "src/interfaces/IOffchainAssetVaultManager.sol";
import { IOffchainAssetVault, WithdrawArgs, AssetKind } from "src/interfaces/IOffchainAssetVault.sol";

import { LibOffchainAssetVaultStorage } from "src/vault/LibOffchainAssetVaultStorage.sol";

interface IAdminMintable {
    function adminMint(address _to, uint256 _tokenId) external;
    function adminMint(address _to, uint256 _tokenId, uint256 _amount) external;
    function adminMint(address _to, uint256 _tokenId, uint256 _amount, bytes calldata _data) external;
}

/**
 * @title OffchainAssetVault Library
 * @dev This library is used to implement features that use/update storage data for the OffchainAssetVault contracts
 */
library LibOffchainAssetVault {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // =============================================================
    //                    State Getters/Setters
    // =============================================================

    function getVaultManager() internal view returns (IOffchainAssetVaultManager manager_) {
        manager_ = LibOffchainAssetVaultStorage.layout().vaultManager;
    }

    function getOrganizationId() internal view returns (bytes32 orgId_) {
        orgId_ = LibOffchainAssetVaultStorage.layout().orgId;
    }

    function getVaultId() internal view returns (uint64 vaultId_) {
        vaultId_ = LibOffchainAssetVaultStorage.layout().vaultId;
    }

    function setVaultManager(address _vaultManagerAddress) internal {
        LibOffchainAssetVaultStorage.layout().vaultManager = IOffchainAssetVaultManager(_vaultManagerAddress);
    }

    function setOrganizationId(bytes32 _orgId) internal {
        LibOffchainAssetVaultStorage.layout().orgId = _orgId;
    }

    function setVaultId(uint64 _vaultId) internal {
        LibOffchainAssetVaultStorage.layout().vaultId = _vaultId;
    }

    // =============================================================
    //                           Settings
    // =============================================================

    // =============================================================
    //                       Create Functions
    // =============================================================

    /**
     * @dev Withdraws an asset from the vault to the specified address. Assumes permissions have been checked.
     *      Will revert if the asset is not in the vault
     * @param _withdraw The withdraw arguments
     */
    function withdraw(WithdrawArgs calldata _withdraw) internal {
        if (_withdraw.kind == AssetKind.ERC721) {
            IERC721Upgradeable(_withdraw.asset).safeTransferFrom(address(this), _withdraw.to, _withdraw.tokenId);
        } else if (_withdraw.kind == AssetKind.ERC1155) {
            IERC1155Upgradeable(_withdraw.asset).safeTransferFrom(
                address(this), _withdraw.to, _withdraw.tokenId, _withdraw.amount, ""
            );
        } else if (_withdraw.kind == AssetKind.ERC20) {
            IERC20Upgradeable(_withdraw.asset).safeTransfer(_withdraw.to, _withdraw.amount);
        } else {
            revert IOffchainAssetVault.InvalidAssetKind();
        }
    }

    /**
     * @dev Mints an asset to the specified address. Assumes permissions have been checked.
     *     Also assumes that this contract has been approved to mint the required assets through `adminMint`
     * @param _withdraw The withdraw arguments for minting an asset.
     */
    function mint(WithdrawArgs calldata _withdraw) internal {
        if (_withdraw.kind == AssetKind.ERC721) {
            IAdminMintable(_withdraw.asset).adminMint(_withdraw.to, _withdraw.tokenId);
        } else if (_withdraw.kind == AssetKind.ERC1155) {
            IAdminMintable(_withdraw.asset).adminMint(_withdraw.to, _withdraw.tokenId, _withdraw.amount, "");
        } else if (_withdraw.kind == AssetKind.ERC20) {
            IAdminMintable(_withdraw.asset).adminMint(_withdraw.to, _withdraw.amount);
        } else {
            revert IOffchainAssetVault.InvalidAssetKind();
        }
    }

    function useNonce(uint256 _nonce) internal {
        if (LibOffchainAssetVaultStorage.layout().usedNonces[_nonce]) {
            revert IOffchainAssetVault.NonceUsed(_nonce);
        }
        LibOffchainAssetVaultStorage.layout().usedNonces[_nonce] = true;
    }

    function isNonceUsed(uint256 _nonce) internal view returns (bool used_) {
        used_ = LibOffchainAssetVaultStorage.layout().usedNonces[_nonce];
    }

    function getAuthoritySigner() internal view returns (address signer_) {
        LibOffchainAssetVaultStorage.Layout storage _l = LibOffchainAssetVaultStorage.layout();
        signer_ = _l.vaultManager.getAuthoritySigner(_l.orgId, _l.vaultId);
    }
}
