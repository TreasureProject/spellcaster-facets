// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {TestBase} from "./utils/TestBase.sol";
import {DiamondManager, Diamond, IDiamondCut, FacetInfo} from "./utils/DiamondManager.sol";
import {DiamondUtils} from "./utils/DiamondUtils.sol";

import {GuildToken} from "../src/guilds/guildtoken/GuildToken.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract GuildTokenTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    GuildToken internal _token;

    uint32 constant _org1 = 1;
    uint32 constant _guild1 = 1;

    function setUp() public {
        _token = new GuildToken();
        _token.initialize(2);
    }

    function testIsSetUp() public {
        vm.expectRevert(errAlreadyInitialized("GuildToken"));
        _token.initialize(2);

        // This address called initialize so it is the manager
        assertEq(_token.guildManager(), deployer);
        assertEq(_token.organizationId(), 2);
        assertTrue(_token.hasRole(roleBytes("ADMIN"), deployer));
        assertTrue(_token.hasRole(roleBytes("ADMIN_GRANTER"), deployer));
    }

    function testAllowAdminMintAndBurn() public {
        _token.grantRole(roleBytes("ADMIN"), alice);

        _token.adminMint(alice, 1, 1);
        assertEq(_token.balanceOf(alice, 1), 1);

        vm.prank(alice);
        _token.adminMint(leet, 1, 1);

        _token.adminBurn(alice, 1, 1);
        assertEq(_token.balanceOf(alice, 1), 0);

        vm.prank(alice);
        _token.adminBurn(leet, 1, 1);
        
        assertEq(_token.balanceOf(leet, 1), 0);
    }

    function testRevertNonAdminMintAndBurn() public {
        vm.prank(alice);
        vm.expectRevert(errMissingRole("ADMIN", alice));
        _token.adminMint(alice, 1, 1);

        vm.prank(alice);
        vm.expectRevert(errMissingRole("ADMIN", alice));
        _token.adminBurn(alice, 1, 1);
    }

}