// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import { TestBase } from "./utils/TestBase.sol";
import { DiamondManager, Diamond, IDiamondCut, FacetInfo } from "./utils/DiamondManager.sol";
import { DiamondUtils } from "./utils/DiamondUtils.sol";

import { GuildToken } from "../src/guilds/guildtoken/GuildToken.sol";

import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract GuildTokenTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    GuildToken internal token;

    function setUp() public {
        token = new GuildToken();
        token.initialize(org2);
    }

    function testIsSetUp() public {
        vm.expectRevert(errAlreadyInitialized("initialize"));
        token.initialize(org2);

        // This address called initialize so it is the manager
        assertEq(token.guildManager(), deployer);
        assertEq(token.organizationId(), org2);
        assertTrue(token.hasRole(_roleBytes("ADMIN"), deployer));
        assertTrue(token.hasRole(_roleBytes("ADMIN_GRANTER"), deployer));
    }

    function testAllowAdminMintAndBurn() public {
        token.grantRole(_roleBytes("ADMIN"), alice);

        token.adminMint(alice, 1, 1);
        assertEq(token.balanceOf(alice, 1), 1);

        vm.prank(alice);
        token.adminMint(leet, 1, 1);

        token.adminBurn(alice, 1, 1);
        assertEq(token.balanceOf(alice, 1), 0);

        vm.prank(alice);
        token.adminBurn(leet, 1, 1);

        assertEq(token.balanceOf(leet, 1), 0);
    }

    function testRevertNonAdminMintAndBurn() public {
        vm.prank(alice);
        vm.expectRevert(errMissingRole("ADMIN", alice));
        token.adminMint(alice, 1, 1);

        vm.prank(alice);
        vm.expectRevert(errMissingRole("ADMIN", alice));
        token.adminBurn(alice, 1, 1);
    }

    function testMetaTransaction() public { }
}
