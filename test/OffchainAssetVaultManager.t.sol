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

    function test_vault_update_success() public {
        // Create the vault with initial vault parameters.
        vm.expectEmit(true, true, true, false);
        emit IOffchainAssetVaultManager.VaultCreated(org1, 1, address(this), address(this), address(this));
        (address _vaultAddress, uint64 _vaultId) = manager.createVault(org1, address(this), address(this));
        assertEq(_vaultId, 1);
        assertEq(address(this), manager.getAuthoritySigner(org1, _vaultId));
        assertEq(address(this), manager.getOwner(org1, _vaultId));

        // Change the vault parameters.
        vm.expectEmit(true, true, true, true);
        emit IOffchainAssetVaultManager.VaultUpdated(org1, 1, _vaultAddress, address(leet), address(alice));
        manager.updateVault(org1, 1, address(leet), address(alice));

        // Ensure values have been changed.
        assertEq(_vaultAddress, manager.getVaultAddress(org1, 1));
        assertEq(address(leet), manager.getOwner(org1, 1));
        assertEq(address(alice), manager.getAuthoritySigner(org1, 1));
    }

    function test_vault_update_fail() public {
        // Create the vault with initial vault parameters.
        vm.expectEmit(true, true, true, false);
        emit IOffchainAssetVaultManager.VaultCreated(org1, 1, address(this), address(this), address(this));
        (address _vaultAddress, uint64 _vaultId) = manager.createVault(org1, address(this), address(this));
        assertEq(_vaultId, 1);
        assertEq(address(this), manager.getAuthoritySigner(org1, _vaultId));
        assertEq(address(this), manager.getOwner(org1, _vaultId));

        // Expect invalid permissions to fail.
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(OrganizationManagerStorage.NotOrganizationAdmin.selector, address(alice))
        );
        manager.updateVault(org1, 1, address(leet), address(alice));

        // Expect invalid vaultId to fail.
        vm.expectRevert("Cannot modify invalid vaultId.");
        manager.updateVault(org1, 0, address(leet), address(alice));
        vm.expectRevert("Cannot modify invalid vaultId.");
        manager.updateVault(org1, 2, address(leet), address(alice));

        // Expect invalid owner to fail.
        vm.expectRevert("Cannot set owner to null address.");
        manager.updateVault(org1, 1, address(0), address(alice));
        vm.expectRevert("Cannot set authoritySigner to null address.");
        manager.updateVault(org1, 1, address(leet), address(0));

        // Check vault info hasn't changed.
        assertEq(_vaultAddress, manager.getVaultAddress(org1, 1));
        assertEq(address(this), manager.getOwner(org1, 1));
        assertEq(address(this), manager.getAuthoritySigner(org1, 1));
    }
}
