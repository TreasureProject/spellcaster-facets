//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721HolderUpgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import { EIP712Upgradeable } from "@openzeppelin/contracts-diamond/utils/cryptography/EIP712Upgradeable.sol";
import { StringsUpgradeable } from "@openzeppelin/contracts-diamond/utils/StringsUpgradeable.sol";

import { FacetInitializable } from "src/utils/FacetInitializable.sol";

import { LibOffchainAssetVault } from "src/vault/LibOffchainAssetVault.sol";
import { LibOffchainAssetVaultStorage } from "src/vault/LibOffchainAssetVaultStorage.sol";
import { IOffchainAssetVault } from "src/interfaces/IOffchainAssetVault.sol";
import { Modifiers } from "src/Modifiers.sol";
import { SupportsMetaTx } from "src/metatx/SupportsMetaTx.sol";

abstract contract OffchainAssetVaultBase is
    FacetInitializable,
    EIP712Upgradeable,
    ERC721HolderUpgradeable,
    ERC1155HolderUpgradeable,
    IOffchainAssetVault,
    Modifiers,
    SupportsMetaTx
{
    /**
     * @dev The typehash of the ForwardRequest struct used when signing the meta transaction
     *  This must match the ForwardRequest struct, and must not have extra whitespace or it will invalidate the signature
     */
    bytes32 public constant WITHDRAW_ARGS_TYPEHASH = keccak256(
        "WithdrawArgs(address asset,uint96 tokenId,uint88 amount,uint8 kind,address to,uint248 nonce,bool isMint)"
    );

    function __OffchainAssetVaultBase_init(uint64 _vaultId) internal onlyFacetInitializing {
        __EIP712_init(string.concat("OffchainAssetVault-", StringsUpgradeable.toString(_vaultId)), "1.0.0");
    }
}
