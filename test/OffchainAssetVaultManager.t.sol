// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { TestBase } from "./utils/TestBase.sol";
import { DiamondManager, Diamond, IDiamondCut, FacetInfo } from "./utils/DiamondManager.sol";
import { DiamondUtils } from "./utils/DiamondUtils.sol";

import { OrganizationFacet, OrganizationManagerStorage } from "src/organizations/OrganizationFacet.sol";
import { OffchainAssetVaultManager } from "src/vaultmanager/OffchainAssetVaultManager.sol";
import { OffchainAssetVault } from "src/vault/OffchainAssetVault.sol";
import { IOffchainAssetVaultManager } from "src/interfaces/IOffchainAssetVaultManager.sol";

contract OffchainAssetVaultManagerTest is TestBase, DiamondManager {
    using DiamondUtils for Diamond;

    OffchainAssetVaultManager internal manager;

    function setUp() public {
        FacetInfo[] memory _facetInfo = new FacetInfo[](2);
        Diamond.Initialization[] memory _initializations = new Diamond.Initialization[](1);

        _facetInfo[0] = FacetInfo(
            address(new OffchainAssetVaultManager()), "OffchainAssetVaultManager", IDiamondCut.FacetCutAction.Add
        );
        _facetInfo[1] = FacetInfo(address(new OrganizationFacet()), "OrganizationFacet", IDiamondCut.FacetCutAction.Add);
        _initializations[0] = Diamond.Initialization({
            initContract: _facetInfo[0].addr,
            initData: abi.encodeWithSelector(
                OffchainAssetVaultManager.OffchainAssetVaultManager_init.selector, address(new OffchainAssetVault())
                )
        });

        init(_facetInfo, _initializations);

        manager = OffchainAssetVaultManager(address(diamond));
        OrganizationFacet(address(manager)).createOrganization(org1, "My org", "My descr");
    }

    function test_init_success() public {
        vm.expectRevert(errAlreadyInitialized("OffchainAssetVaultManager_init"));
        manager.OffchainAssetVaultManager_init(address(this));
    }

    function test_vault_create_success() public {
        // ensure the event is emitted but don't check the data because we do not know the address of the vault yet.
        vm.expectEmit(true, true, true, false);
        emit IOffchainAssetVaultManager.VaultCreated(org1, 1, address(this), address(this), address(this));
        (address _vaultAddress, uint64 _vaultId) = manager.createVault(org1, address(this), address(this));

        assertEq(_vaultId, 1);
        assertEq(address(this), manager.getAuthoritySigner(org1, _vaultId));
        assertEq(address(this), manager.getOwner(org1, _vaultId));

        (_vaultAddress, _vaultId) = manager.createVault(org1, address(leet), address(leet));

        assertEq(_vaultId, 2);
        assertEq(address(leet), manager.getAuthoritySigner(org1, _vaultId));
        assertEq(address(leet), manager.getOwner(org1, _vaultId));
    }
}
