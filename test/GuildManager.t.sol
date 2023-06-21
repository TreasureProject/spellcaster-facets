// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import { TestBase } from "./utils/TestBase.sol";
import { DiamondManager, Diamond, IDiamondCut, FacetInfo } from "./utils/DiamondManager.sol";
import { DiamondUtils } from "./utils/DiamondUtils.sol";

import { ERC721Consumer } from "src/mocks/ERC721Consumer.sol";

import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";

import { GuildToken } from "src/guilds/guildtoken/GuildToken.sol";
import { GuildManager } from "src/guilds/guildmanager/GuildManager.sol";
import { GuildManagerStorage } from "src/guilds/guildmanager/GuildManagerStorage.sol";
import { LibGuildManager } from "src/libraries/LibGuildManager.sol";
import { OrganizationManagerStorage } from "src/organizations/OrganizationManagerStorage.sol";
import { OrganizationFacet, OrganizationManagerStorage } from "src/organizations/OrganizationFacet.sol";
import {
    IGuildManager,
    GuildCreationRule,
    MaxUsersPerGuildRule,
    GuildUserStatus,
    GuildStatus
} from "src/interfaces/IGuildManager.sol";

import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract GuildManagerTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    ERC721Consumer internal erc721Consumer;
    GuildManager internal manager;

    function setUp() public {
        FacetInfo[] memory _facetInfo = new FacetInfo[](2);
        Diamond.Initialization[] memory _initializations = new Diamond.Initialization[](1);

        _facetInfo[0] = FacetInfo(address(new GuildManager()), "GuildManager", IDiamondCut.FacetCutAction.Add);
        _facetInfo[1] = FacetInfo(address(new OrganizationFacet()), "OrganizationFacet", IDiamondCut.FacetCutAction.Add);
        _initializations[0] = Diamond.Initialization({
            initContract: _facetInfo[0].addr,
            initData: abi.encodeWithSelector(
                GuildManager.GuildManager_init.selector, address(new GuildToken()), address(0x1)
                )
        });

        init(_facetInfo, _initializations);

        manager = GuildManager(address(diamond));
        diamond.grantRole("ADMIN", deployer);

        erc721Consumer = new ERC721Consumer();
        erc721Consumer.initialize();

        manager.setTreasureTagNFTAddress(address(erc721Consumer));
    }

    function createDefaultOrgAndGuild() internal {
        OrganizationFacet(address(manager)).createOrganization(org1, "My org", "My descr");
        manager.initializeForOrganization(
            org1,
            1, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            false
        );

        manager.createGuild(org1);
    }

    function testIsSetUp() public {
        vm.expectRevert(errAlreadyInitialized("GuildManager_init"));
        manager.GuildManager_init(address(0));

        assertEq(true, diamond.paused());
    }

    // =============================================================
    //                       Organizations
    // =============================================================

    function testAllowAdminCreateGuildOrganization() public {
        diamond.setPause(false);

        assertEq(0, manager.getGuildOrganizationInfo(org1).guildIdCur);
        assertEq(address(0), OrganizationFacet(address(diamond)).getOrganizationInfo(org1).admin);

        OrganizationFacet(address(manager)).createOrganization(org1, "My org", "My descr");

        manager.initializeForOrganization(
            keccak256("1"),
            1, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            false
        );

        assertEq(1, manager.getGuildOrganizationInfo(org1).guildIdCur);
        assertEq(deployer, OrganizationFacet(address(diamond)).getOrganizationInfo(org1).admin);
    }

    function testRevertNonAdminCreateGuildOrganization() public {
        diamond.setPause(false);

        OrganizationFacet(address(manager)).createOrganization(org1, "My org", "My descr");

        vm.prank(leet);
        vm.expectRevert(err(OrganizationManagerStorage.NotOrganizationAdmin.selector, leet));
        manager.initializeForOrganization(
            keccak256("1"),
            1, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            false
        );
    }

    // =============================================================
    //                           Guilds
    // =============================================================

    function testAllowAdminCreateGuild() public {
        diamond.setPause(false);

        assertEq(address(0), manager.guildOwner(org1, guild1));

        createDefaultOrgAndGuild();

        assertEq(deployer, manager.guildOwner(org1, guild1));
    }

    function testRevertNonAdminCreateGuild() public {
        diamond.setPause(false);

        OrganizationFacet(address(manager)).createOrganization(org1, "My org", "My descr");

        assertEq(address(0), manager.guildOwner(org1, guild1));

        manager.initializeForOrganization(
            keccak256("1"),
            1, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            false
        );

        // deployer is the Organization's admin
        vm.prank(leet);
        vm.expectRevert(err(GuildManagerStorage.UserCannotCreateGuild.selector, org1, leet));
        manager.createGuild(org1);
    }

    function testAllowOwnerEditGuild() public {
        diamond.setPause(false);

        createDefaultOrgAndGuild();
        assertEq("", manager.guildName(org1, guild1));
        assertEq("", manager.guildDescription(org1, guild1));

        manager.updateGuildInfo(org1, guild1, "New name", "New descr");

        assertEq("New name", manager.guildName(org1, guild1));
        assertEq("New descr", manager.guildDescription(org1, guild1));
    }

    function testRevertNonOwnerEditGuildInfo() public {
        diamond.setPause(false);

        createDefaultOrgAndGuild();

        vm.prank(leet);
        vm.expectRevert(err(GuildManagerStorage.NotGuildOwner.selector, leet, "UPDATE_INFO"));
        manager.updateGuildInfo(org1, guild1, "New name", "New descr");
    }

    function testAllowGuildOwnerAndAdminInvite() public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        address[] memory _inviteLeet = new address[](1);
        address[] memory _inviteAlice = new address[](1);
        bool[] memory _admins = new bool[](1);
        _inviteLeet[0] = leet;
        _inviteAlice[0] = alice;
        _admins[0] = true;
        GuildUserStatus _before = manager.getGuildMemberStatus(org1, guild1, leet);
        GuildUserStatus _invited;
        GuildUserStatus _member;

        // Invite and accept for leet
        manager.inviteUsers(org1, guild1, _inviteLeet);
        _invited = manager.getGuildMemberStatus(org1, guild1, leet);
        vm.prank(leet);
        manager.acceptInvitation(org1, guild1);
        _member = manager.getGuildMemberStatus(org1, guild1, leet);

        // Make leet an admin
        manager.changeGuildAdmins(org1, guild1, _inviteLeet, _admins);

        // Leet can now invite alice
        manager.inviteUsers(org1, guild1, _inviteAlice);

        assertEq(uint256(_before), uint256(GuildUserStatus.NOT_ASSOCIATED));
        assertEq(uint256(_invited), uint256(GuildUserStatus.INVITED));
        assertEq(uint256(_member), uint256(GuildUserStatus.MEMBER));
        assertEq(uint256(manager.getGuildMemberStatus(org1, guild1, alice)), uint256(GuildUserStatus.INVITED));
    }

    function testRevertAddingNonMemberAsAdmin() public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        address[] memory _inviteLeet = new address[](1);
        bool[] memory _admins = new bool[](1);
        _inviteLeet[0] = leet;
        _admins[0] = true;

        // manager.inviteUsers(org1, guild1, _inviteLeet);
        // vm.expectRevert(err(GuildManagerStorage.UserNotGuildMember.selector, org1, guild1, leet));
        // manager.changeGuildAdmins(org1, guild1, _inviteLeet, _admins);
    }

    function testRevertNonGuildOwnerOrAdminInvite(address _user) public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        address[] memory _invites = new address[](1);
        _invites[0] = _user;

        inviteAndAcceptGuildInvite(org1, guild1, leet);
        changeGuildMemberAdminStatus(leet, true);

        if (_user == deployer || _user == leet) {
            vm.expectRevert(err(GuildManagerStorage.UserAlreadyInGuild.selector, org1, guild1, _user));
        } else {
            vm.prank(_user);
            vm.expectRevert(err(GuildManagerStorage.NotGuildOwnerOrAdmin.selector, _user, "INVITE"));
        }
        manager.inviteUsers(org1, guild1, _invites);
    }

    function testAllowNonOwnerUsersToLeaveGuild(address _user) public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0) && _user != manager.guildOwner(org1, guild1) && !_user.isContract());
        inviteAndAcceptGuildInvite(org1, guild1, _user);
        GuildUserStatus _before = manager.getGuildMemberStatus(org1, guild1, _user);
        vm.prank(_user);
        manager.leaveGuild(org1, guild1);
        GuildUserStatus _afterLeave = manager.getGuildMemberStatus(org1, guild1, _user);
        assertEq(uint256(_before), uint256(GuildUserStatus.MEMBER));
        assertEq(uint256(_afterLeave), uint256(GuildUserStatus.NOT_ASSOCIATED));
    }

    function testAllowGuildOwnerAndAdminKickMembers(address _user) public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0) && _user != manager.guildOwner(org1, guild1) && !_user.isContract());
        inviteAndAcceptGuildInvite(org1, guild1, _user);
        if (_user != leet) {
            inviteAndAcceptGuildInvite(org1, guild1, leet);
        }
        if (_user != alice) {
            inviteAndAcceptGuildInvite(org1, guild1, alice);
        }
        changeGuildMemberAdminStatus(leet, true);
        GuildUserStatus _before = manager.getGuildMemberStatus(org1, guild1, _user);
        if (manager.getGuildMemberStatus(org1, guild1, _user) == GuildUserStatus.MEMBER) {
            // Ensure member cannot kick other member
            vm.expectRevert(err(GuildManagerStorage.NotGuildOwnerOrAdmin.selector, alice, "KICK"));
            kickGuildMemberAsAdmin(_user, alice);
            // Kick members as admin or owner
            kickGuildMemberAsAdmin(_user, uint160(leet) % 2 == 1 ? leet : deployer);
        } else if (manager.getGuildMemberStatus(org1, guild1, _user) == GuildUserStatus.ADMIN) {
            // Kick admins as owner
            kickGuildMemberAsAdmin(_user, deployer);
            // Ensure admin cannot kick admin
            vm.expectRevert(err(GuildManagerStorage.NotGuildOwner.selector, leet, "KICK"));
            kickGuildMemberAsAdmin(_user, leet);
        }
        GuildUserStatus _afterKick = manager.getGuildMemberStatus(org1, guild1, _user);
        assertEq(uint256(_before), uint256(GuildUserStatus.MEMBER));
        assertEq(uint256(_afterKick), uint256(GuildUserStatus.NOT_ASSOCIATED));
    }

    function testAllowAdminToBeDemoted(address _user) public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0) && _user != manager.guildOwner(org1, guild1) && !_user.isContract());
        //Mint them a treasure tag
        erc721Consumer.mintArbitrary(_user, 1);
        inviteAndAcceptGuildInvite(org1, guild1, _user);
        changeGuildMemberAdminStatus(_user, true);
        GuildUserStatus _before = manager.getGuildMemberStatus(org1, guild1, _user);
        changeGuildMemberAdminStatus(_user, false);
        GuildUserStatus _afterDemote = manager.getGuildMemberStatus(org1, guild1, _user);
        assertEq(uint256(_before), uint256(GuildUserStatus.ADMIN));
        assertEq(uint256(_afterDemote), uint256(GuildUserStatus.MEMBER));
    }

    function testCaninitializeForOrganization() public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        OrganizationFacet(address(diamond)).createOrganization(org2, "Organization2", "Org description2");
        manager.initializeForOrganization(
            org2,
            69, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            420, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            false
        );

        assertEq("Organization2", OrganizationFacet(address(diamond)).getOrganizationInfo(org2).name);
        assertEq("Org description2", OrganizationFacet(address(diamond)).getOrganizationInfo(org2).description);
        assertEq(69, manager.getGuildOrganizationInfo(org2).maxGuildsPerUser);
        assertEq(420, manager.getGuildOrganizationInfo(org2).maxUsersPerGuildConstant);
    }

    function testCannotCreateForAlreadyInitializedOrganization() public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        OrganizationFacet(address(diamond)).createOrganization(org2, "Organization2", "Org description2");
        manager.initializeForOrganization(
            org2,
            69, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            420, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            false
        );

        vm.expectRevert(err(GuildManagerStorage.GuildOrganizationAlreadyInitialized.selector, org2));
        manager.initializeForOrganization(
            org2,
            69, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            420, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            false
        );
    }

    function testCannotCreateForNonExistingOrganization() public {
        diamond.setPause(false);
        vm.expectRevert(err(OrganizationManagerStorage.NonexistantOrganization.selector, keccak256("2")));
        manager.initializeForOrganization(
            keccak256("2"),
            69, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            420, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            false
        );
    }

    function testUserCannotJoinMoreGuildsThanMax() public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        // Have alice create another guild because deployer already made the first guild,
        // and you can only be in one guild per organization
        OrganizationFacet(address(diamond)).setOrganizationAdmin(org1, alice);
        vm.prank(alice);
        manager.createGuild(org1);

        inviteAndAcceptGuildInvite(org1, guild1, leet);

        address[] memory _invites = new address[](1);
        _invites[0] = leet;
        vm.prank(alice);
        manager.inviteUsers(org1, 2, _invites);
        vm.prank(leet);
        vm.expectRevert(err(GuildManagerStorage.UserInTooManyGuilds.selector, org1, leet));
        manager.acceptInvitation(org1, 2);
    }

    function testEnsureTreasureTagRequirement() public {
        diamond.setPause(false);

        //creating guild
        OrganizationFacet(address(manager)).createOrganization(org1, "My org", "My descr");
        manager.initializeForOrganization(
            org1,
            1, // Max users per guild
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0), // optional contract for customizable guild rules
            true //Require treasure tag
        );

        vm.expectRevert(err(GuildManagerStorage.UserDoesNotOwnTreasureTag.selector, deployer));
        manager.createGuild(org1);

        erc721Consumer.mintArbitrary(deployer, 1);

        manager.createGuild(org1);

        address[] memory _invites = new address[](1);
        _invites[0] = vm.addr(578236);
        manager.inviteUsers(org1, guild1, _invites);

        //Joining the guild should fail, as they do not have a treasure tag
        vm.expectRevert(err(GuildManagerStorage.UserDoesNotOwnTreasureTag.selector, _invites[0]));

        vm.prank(_invites[0]);
        manager.acceptInvitation(org1, guild1);

        //Mint them a treasure tag
        erc721Consumer.mintArbitrary(_invites[0], 1);

        vm.prank(_invites[0]);
        //Will succeed
        manager.acceptInvitation(org1, guild1);
    }

    function testCannotAddMoreMembersThanMax() public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();
        inviteAndAcceptGuildInvite(org1, guild1, leet);

        uint32 _maxMembers = manager.maxUsersForGuild(org1, guild1);

        for (uint256 i = 1; i <= _maxMembers; i++) {
            address _userCur = vm.addr(i);

            //Mint them a mock treasure tag
            erc721Consumer.mintArbitrary(_userCur, 1);

            address[] memory _invites = new address[](1);
            _invites[0] = _userCur;
            manager.inviteUsers(org1, guild1, _invites);
            vm.prank(_userCur);
            if (i >= _maxMembers - 1) {
                // Because the guild owner is a member, and we already invited and accepted leet,
                // we can only invite _maxMembers - 2 users
                vm.expectRevert(err(GuildManagerStorage.GuildFull.selector, org1, guild1));
            }
            manager.acceptInvitation(org1, guild1);
        }
    }

    function testGuildTermination() public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();

        //---
        //ALL CALLS BELOW SHOULD NOT REVERT
        //Updating guild info
        manager.updateGuildInfo(org1, guild1, "New name", "New descr");

        //Inviting users
        address[] memory _invites = new address[](1);
        _invites[0] = leet;
        manager.inviteUsers(org1, guild1, _invites);
        //---

        assertEq(uint256(manager.getGuildStatus(org1, guild1)), uint256(GuildStatus.ACTIVE));

        vm.prank(leet);
        vm.expectRevert(err(LibAccessControlRoles.IsNotGuildTerminator.selector, leet, org1, guild1));
        //Leet does not have terminator role, do not allow to terminate.
        manager.terminateGuild(org1, guild1, "No more of this guild! I don't want it anymore!");

        //Give leet guild terminator role
        manager.grantGuildTerminator(leet, org1, guild1);

        //Prank as leet and terminate guild
        vm.prank(leet);
        manager.terminateGuild(org1, guild1, "No more of this guild! I don't want it anymore!");

        //---
        //ALL CALLS BELOW SHOULD REVERT
        //Updating guild info
        vm.expectRevert(err(GuildManagerStorage.GuildIsNotActive.selector, org1, guild1));
        manager.updateGuildInfo(org1, guild1, "New name", "New descr");

        //Inviting users
        address[] memory _invites2 = new address[](1);
        _invites2[0] = leet;
        vm.expectRevert(err(GuildManagerStorage.GuildIsNotActive.selector, org1, guild1));
        manager.inviteUsers(org1, guild1, _invites2);
        //---

        assertEq(uint256(manager.getGuildStatus(org1, guild1)), uint256(GuildStatus.TERMINATED));
    }

    function testMemberLevelAdjustment() public {
        diamond.setPause(false);
        createDefaultOrgAndGuild();

        address[] memory _invites = new address[](1);
        _invites[0] = leet;
        manager.inviteUsers(org1, guild1, _invites);

        vm.prank(leet);
        manager.acceptInvitation(org1, guild1);

        assertEq(1, manager.getGuildMemberInfo(org1, guild1, leet).memberLevel);

        vm.prank(leet);
        vm.expectRevert(err(LibAccessControlRoles.IsNotGuildAdmin.selector, leet, org1, guild1));
        manager.adjustMemberLevel(org1, guild1, leet, 3);

        manager.grantGuildAdmin(leet, org1, guild1);

        vm.prank(leet);
        manager.adjustMemberLevel(org1, guild1, leet, 3);

        assertEq(3, manager.getGuildMemberInfo(org1, guild1, leet).memberLevel);

        vm.expectRevert("Not a valid member level.");
        manager.adjustMemberLevel(org1, guild1, leet, 6);

        vm.expectRevert("Not a valid member level.");
        manager.adjustMemberLevel(org1, guild1, leet, 0);
    }

    function test() public {
        // TODO: add emit event assertions to tests
    }

    function inviteAndAcceptGuildInvite(bytes32 _orgId, uint32 _guildId, address _user) public {
        address[] memory _invites = new address[](1);
        _invites[0] = _user;
        manager.inviteUsers(_orgId, _guildId, _invites);
        vm.prank(_user);
        manager.acceptInvitation(org1, guild1);
    }

    function changeGuildMemberAdminStatus(address _user, bool _isAdmin) public {
        address[] memory _invites = new address[](1);
        bool[] memory _admins = new bool[](1);
        _invites[0] = _user;
        _admins[0] = _isAdmin;
        manager.changeGuildAdmins(org1, guild1, _invites, _admins);
    }

    function kickGuildMemberAsAdmin(address _user, address _admin) public {
        address[] memory _kicks = new address[](1);
        _kicks[0] = _user;
        vm.prank(_admin);
        manager.kickOrRemoveInvitations(org1, guild1, _kicks);
    }
}
