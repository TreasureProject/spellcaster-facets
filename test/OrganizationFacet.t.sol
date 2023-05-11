// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import { TestBase } from "./utils/TestBase.sol";
import { DiamondManager, Diamond, IDiamondCut, FacetInfo } from "./utils/DiamondManager.sol";
import { DiamondUtils } from "./utils/DiamondUtils.sol";

import { OrganizationFacet } from "src/organizations/OrganizationFacet.sol";
import { OrganizationManagerStorage } from "src/organizations/OrganizationManagerStorage.sol";
import {
    IGuildManager, GuildCreationRule, MaxUsersPerGuildRule, GuildUserStatus
} from "src/interfaces/IGuildManager.sol";

import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract OrganizationFacetTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    OrganizationFacet internal orgs;

    function setUp() public {
        FacetInfo[] memory _facetInfo = new FacetInfo[](1);
        Diamond.Initialization[] memory _initializations = new Diamond.Initialization[](1);

        _facetInfo[0] = FacetInfo(address(new OrganizationFacet()), "OrganizationFacet", IDiamondCut.FacetCutAction.Add);
        _initializations[0] = Diamond.Initialization({
            initContract: _facetInfo[0].addr,
            initData: abi.encodeWithSelector(
                OrganizationFacet.OrganizationFacet_init.selector, address(new OrganizationFacet())
                )
        });

        init(_facetInfo, _initializations);

        orgs = OrganizationFacet(address(diamond));
    }

    function testIsSetUp() public {
        vm.expectRevert(errAlreadyInitialized("OrganizationFacet_init"));
        orgs.OrganizationFacet_init();
    }

    // =============================================================
    //                       Organizations
    // =============================================================

    function testAllowAdminCreateOrganization() public {
        assertEq("", orgs.getOrganizationInfo(org1).name);
        assertEq("", orgs.getOrganizationInfo(org1).description);

        orgs.createOrganization(org1, "My org", "My descr");

        assertEq("My org", orgs.getOrganizationInfo(org1).name);
        assertEq("My descr", orgs.getOrganizationInfo(org1).description);
    }

    function testRevertNonAdminCreateOrganization() public {
        diamond.revokeRole("ADMIN", deployer);
        vm.expectRevert(errMissingRole("ADMIN", deployer));
        orgs.createOrganization(org1, "My org", "My descr");
    }

    function testAllowAdminEditOrganizationNameAndDesc() public {
        orgs.createOrganization(org1, "My org", "My descr");

        assertEq("My org", orgs.getOrganizationInfo(org1).name);
        assertEq("My descr", orgs.getOrganizationInfo(org1).description);

        orgs.setOrganizationNameAndDescription(org1, "New name", "New descr");

        assertEq("New name", orgs.getOrganizationInfo(org1).name);
        assertEq("New descr", orgs.getOrganizationInfo(org1).description);

        vm.prank(leet);
        vm.expectRevert(err(OrganizationManagerStorage.NotOrganizationAdmin.selector, leet));
        orgs.setOrganizationNameAndDescription(org1, "New name2", "New descr2");
    }

    function testAllowAdminToBeChanged() public {
        orgs.createOrganization(org1, "My org", "My descr");

        assertEq(deployer, orgs.getOrganizationInfo(org1).admin);

        orgs.setOrganizationAdmin(org1, leet);

        assertEq(leet, orgs.getOrganizationInfo(org1).admin);
    }

    function testRevertNonAdminChangeAdmin() public {
        orgs.createOrganization(org1, "My org", "My descr");

        vm.prank(alice);
        vm.expectRevert(err(OrganizationManagerStorage.NotOrganizationAdmin.selector, alice));
        orgs.setOrganizationAdmin(org1, leet);
    }
}
