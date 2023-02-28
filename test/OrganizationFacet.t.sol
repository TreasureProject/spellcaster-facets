// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {TestBase} from "./utils/TestBase.sol";
import {DiamondManager, Diamond, IDiamondCut, FacetInfo} from "./utils/DiamondManager.sol";
import {DiamondUtils} from "./utils/DiamondUtils.sol";

import {OrganizationFacet} from "src/organizations/OrganizationFacet.sol";
import {OrganizationManagerStorage} from "src/organizations/OrganizationManagerStorage.sol";
import {
    IGuildManager,
    GuildCreationRule,
    MaxUsersPerGuildRule,
    GuildUserStatus
} from "src/interfaces/IGuildManager.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract OrganizationFacetTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    OrganizationFacet internal _orgs;

    uint32 constant _org1 = 1;

    function setUp() public {
        FacetInfo[] memory facetInfo = new FacetInfo[](1);
        Diamond.Initialization[] memory initializations = new Diamond.Initialization[](1);

        facetInfo[0] = FacetInfo(address(new OrganizationFacet()), "OrganizationFacet", IDiamondCut.FacetCutAction.Add);
        initializations[0] = Diamond.Initialization({
            initContract: facetInfo[0].addr,
            initData: abi.encodeWithSelector(OrganizationFacet.OrganizationFacet_init.selector, address(new OrganizationFacet()))
        });

        init(facetInfo, initializations);

        _orgs = OrganizationFacet(address(_diamond));
    }

    function testIsSetUp() public {
        vm.expectRevert(errAlreadyInitialized("OrganizationFacet"));
        _orgs.OrganizationFacet_init();
    }

    // =============================================================
    //                       Organizations
    // =============================================================

    function testAllowAdminCreateOrganization() public {
        assertEq("", _orgs.getOrganizationInfo(1).name);
        assertEq("", _orgs.getOrganizationInfo(1).description);
        
        _orgs.createOrganization(
            "My org",
            "My descr"
        );

        assertEq("My org", _orgs.getOrganizationInfo(1).name);
        assertEq("My descr", _orgs.getOrganizationInfo(1).description);
    }

    function testRevertNonAdminCreateOrganization() public {
        _diamond.revokeRole("ADMIN", deployer);
        vm.expectRevert(errMissingRole("ADMIN", deployer));
        _orgs.createOrganization(
            "My org",
            "My descr"
        );
    }

    function testAllowAdminEditOrganizationNameAndDesc() public {
        _orgs.createOrganization(
            "My org",
            "My descr"
        );
        
        assertEq("My org", _orgs.getOrganizationInfo(1).name);
        assertEq("My descr", _orgs.getOrganizationInfo(1).description);

        _orgs.setOrganizationNameAndDescription(1, "New name", "New descr");

        assertEq("New name", _orgs.getOrganizationInfo(1).name);
        assertEq("New descr", _orgs.getOrganizationInfo(1).description);

        vm.prank(leet);
        vm.expectRevert(err(OrganizationManagerStorage.NotOrganizationAdmin.selector, leet));
        _orgs.setOrganizationNameAndDescription(1, "New name2", "New descr2");
    }

    function testAllowAdminToBeChanged() public {
        _orgs.createOrganization(
            "My org",
            "My descr"
        );

        assertEq(deployer, _orgs.getOrganizationInfo(1).admin);

        _orgs.setOrganizationAdmin(1, leet);

        assertEq(leet, _orgs.getOrganizationInfo(1).admin);
    }

    function testRevertNonAdminChangeAdmin() public {
        _orgs.createOrganization(
            "My org",
            "My descr"
        );

        vm.prank(alice);
        vm.expectRevert(err(OrganizationManagerStorage.NotOrganizationAdmin.selector, alice));
        _orgs.setOrganizationAdmin(1, leet);
    }

}