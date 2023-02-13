// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {TestBase} from "./utils/TestBase.sol";
import {DiamondManager, Diamond, IDiamondCut, FacetInfo} from "./utils/DiamondManager.sol";
import {DiamondUtils} from "./utils/DiamondUtils.sol";

import {GuildToken} from "../src/guilds/guildtoken/GuildToken.sol";
import {GuildManager} from "../src/guilds/guildmanager/GuildManager.sol";
import {IGuildManager} from "../src/guilds/guildmanager/IGuildManager.sol";

contract GuildManagerTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;

    GuildManager internal _manager;

    uint32 constant _org1 = 1;
    uint32 constant _guild1 = 1;

    function setUp() public {
        FacetInfo[] memory facetInfo = new FacetInfo[](1);
        Diamond.Initialization[] memory initializations = new Diamond.Initialization[](1);

        facetInfo[0] = FacetInfo(address(new GuildManager()), "GuildManager", IDiamondCut.FacetCutAction.Add);
        initializations[0] = Diamond.Initialization({
            initContract: facetInfo[0].addr,
            initData: abi.encodeWithSelector(GuildManager.GuildManager_init.selector)
        });

        init(facetInfo, initializations);

        _manager = GuildManager(address(_diamond));
        _diamond.grantRole("ADMIN", address(this));

        // Give the manager a reference impl for creating guild token beacons from
        _manager.setContracts(address(new GuildToken()));
    }

    function createDefaultOrgAndGuild() internal {
        _manager.createOrganization(
            "My org",
            "My descr",
            1, // Max users per guild 
            0, // Timeout to join another
            IGuildManager.GuildCreationRule.ADMIN_ONLY,
            IGuildManager.MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0) // optional contract for customizable guild rules
        );

        _manager.createGuild(_org1);
    }

    function testIsSetUp() public {
        vm.expectRevert(errorAlreadyInitialized("GuildManager"));
        _manager.GuildManager_init();

        assertEq(true, _diamond.paused());
    }

    function testCanCreateOrganization() public {
        _diamond.setPause(false);
        
        assertEq(0, _manager.getOrganizationInfo(1).guildIdCur);
        assertEq(address(0), _manager.getOrganizationInfo(1).admin);
        
        _manager.createOrganization(
            "My org",
            "My descr",
            1, // Max users per guild 
            0, // Timeout to join another
            IGuildManager.GuildCreationRule.ADMIN_ONLY,
            IGuildManager.MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0) // optional contract for customizable guild rules
        );

        assertEq(1, _manager.getOrganizationInfo(1).guildIdCur);
        assertEq(address(this), _manager.getOrganizationInfo(1).admin);
    }

    function testCanCreateGuild() public {
        _diamond.setPause(false);
        _diamond.grantRole("ADMIN", address(this));

        assertEq(address(0), _manager.getGuildOwner(_org1, _guild1));
        
        createDefaultOrgAndGuild();

        assertEq(address(this), _manager.getGuildOwner(_org1, _guild1));
    }

    function test() public {
    }

}