//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FacetInitializable } from "src/utils/FacetInitializable.sol";

import { LibOffchainAssetVaultManager } from "src/vaultmanager/LibOffchainAssetVaultManager.sol";
import { LibOffchainAssetVaultManagerStorage } from "src/vaultmanager/LibOffchainAssetVaultManagerStorage.sol";
import { IOffchainAssetVaultManager } from "src/interfaces/IOffchainAssetVaultManager.sol";
import { Modifiers } from "src/Modifiers.sol";
import { SupportsMetaTx } from "src/metatx/SupportsMetaTx.sol";

abstract contract OffchainAssetVaultManagerBase is
    FacetInitializable,
    IOffchainAssetVaultManager,
    Modifiers,
    SupportsMetaTx
{
    function __OffchainAssetVaultManagerBase_init() internal onlyFacetInitializing { }
}
