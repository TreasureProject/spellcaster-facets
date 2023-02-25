// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {TestBase} from "./utils/TestBase.sol";
import {DiamondManager, Diamond, IDiamondCut, FacetInfo} from "./utils/DiamondManager.sol";
import {DiamondUtils} from "./utils/DiamondUtils.sol";

import {GuildToken} from "../src/guilds/guildtoken/GuildToken.sol";
import {GuildManager} from "../src/guilds/guildmanager/GuildManager.sol";
import {GuildManagerStorage} from "../src/libraries/GuildManagerStorage.sol";
import {
    IGuildManager,
    GuildCreationRule,
    MaxUsersPerGuildRule,
    GuildUserStatus
} from "src/interfaces/IGuildManager.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract GuildManagerTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

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
        _manager.createForNewOrganization(
            "My org",
            "My descr",
            1, // Max users per guild 
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0) // optional contract for customizable guild rules
        );

        _manager.createGuild(_org1);
    }

    function testIsSetUp() public {
        vm.expectRevert(errAlreadyInitialized("GuildManager"));
        _manager.GuildManager_init();

        assertEq(true, _diamond.paused());
    }

    // =============================================================
    //                       Organizations
    // =============================================================

    function testAllowAdminCreateOrganization() public {
        _diamond.setPause(false);
        
        assertEq(0, _manager.getGuildOrganizationInfo(1).guildIdCur);
        assertEq(address(0), _manager.getOrganizationInfo(1).admin);
        
        _manager.createForNewOrganization(
            "My org",
            "My descr",
            1, // Max users per guild 
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0) // optional contract for customizable guild rules
        );

        assertEq(1, _manager.getGuildOrganizationInfo(1).guildIdCur);
        assertEq(address(this), _manager.getOrganizationInfo(1).admin);
    }

    function testRevertNonAdminCreateOrganization() public {
        _diamond.setPause(false);
        _diamond.revokeRole("ADMIN", address(this));
        vm.expectRevert(errMissingRole("ADMIN", address(this)));
        _manager.createForNewOrganization(
            "My org",
            "My descr",
            1, // Max users per guild 
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0) // optional contract for customizable guild rules
        );
    }

    function testAllowAdminEditOrganizationNameAndDesc() public {
        _diamond.setPause(false);
        
        _manager.createForNewOrganization(
            "My org",
            "My descr",
            1, // Max users per guild 
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0) // optional contract for customizable guild rules
        );
        
        assertEq("My org", _manager.getOrganizationInfo(1).name);
        assertEq("My descr", _manager.getOrganizationInfo(1).description);

        _manager.setOrganizationNameAndDescription(1, "New name", "New descr");

        assertEq("New name", _manager.getOrganizationInfo(1).name);
        assertEq("New descr", _manager.getOrganizationInfo(1).description);

        vm.prank(leet);
        vm.expectRevert(err(GuildManagerStorage.NotOrganizationAdmin.selector, leet));
        _manager.setOrganizationNameAndDescription(1, "New name2", "New descr2");
    }

    // =============================================================
    //                           Guilds
    // =============================================================

    function testAllowAdminCreateGuild() public {
        _diamond.setPause(false);

        assertEq(address(0), _manager.guildOwner(_org1, _guild1));
        
        createDefaultOrgAndGuild();

        assertEq(address(this), _manager.guildOwner(_org1, _guild1));
    }

    function testRevertNonAdminCreateGuild() public {
        _diamond.setPause(false);

        assertEq(address(0), _manager.guildOwner(_org1, _guild1));
        
        _manager.createForNewOrganization(
            "My org",
            "My descr",
            1, // Max users per guild 
            0, // Timeout to join another
            GuildCreationRule.ADMIN_ONLY,
            MaxUsersPerGuildRule.CONSTANT,
            20, // Max users in a guild
            address(0) // optional contract for customizable guild rules
        );

        // address(this) is the Organization's admin
        vm.prank(leet);
        vm.expectRevert(err(GuildManagerStorage.UserCannotCreateGuild.selector, 1, leet));
        _manager.createGuild(_org1);
    }

    function testAllowOwnerEditGuild() public {
        _diamond.setPause(false);
        
        createDefaultOrgAndGuild();
        assertEq("", _manager.guildName(_org1, _guild1));
        assertEq("", _manager.guildDescription(_org1, _guild1));

        _manager.updateGuildInfo(_org1, _guild1, "New name", "New descr");

        assertEq("New name", _manager.guildName(_org1, _guild1));
        assertEq("New descr", _manager.guildDescription(_org1, _guild1));
    }

    function testRevertNonOwnerEditGuildInfo() public {
        _diamond.setPause(false);
        
        createDefaultOrgAndGuild();
        
        vm.prank(leet);
        vm.expectRevert(err(GuildManagerStorage.NotGuildOwner.selector, leet, "UPDATE_INFO"));
        _manager.updateGuildInfo(_org1, _guild1, "New name", "New descr");
    }

    function testAllowGuildOwnerAndAdminInvite() public {
        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        address[] memory inviteLeet = new address[](1);
        address[] memory inviteAlice = new address[](1);
        bool[] memory admins = new bool[](1);
        inviteLeet[0] = leet;
        inviteAlice[0] = alice;
        admins[0] = true;
        GuildUserStatus before = _manager.getGuildMemberStatus(_org1, _guild1, leet);
        GuildUserStatus invited;
        GuildUserStatus member;

        // Invite and accept for leet
        _manager.inviteUsers(_org1, _guild1, inviteLeet);
        invited = _manager.getGuildMemberStatus(_org1, _guild1, leet);
        vm.prank(leet);
        _manager.acceptInvitation(_org1, _guild1);
        member = _manager.getGuildMemberStatus(_org1, _guild1, leet);
        
        // Make leet an admin
        _manager.changeGuildAdmins(_org1, _guild1, inviteLeet, admins);
        
        // Leet can now invite alice
        _manager.inviteUsers(_org1, _guild1, inviteAlice);
        
        assertEq(uint(before), uint(GuildUserStatus.NOT_ASSOCIATED));
        assertEq(uint(invited), uint(GuildUserStatus.INVITED));
        assertEq(uint(member), uint(GuildUserStatus.MEMBER));
        assertEq(uint(_manager.getGuildMemberStatus(_org1, _guild1, alice)), uint(GuildUserStatus.INVITED));
    }

    function testRevertAddingNonMemberAsAdmin() public {
        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        address[] memory inviteLeet = new address[](1);
        bool[] memory admins = new bool[](1);
        inviteLeet[0] = leet;
        admins[0] = true;

        _manager.inviteUsers(_org1, _guild1, inviteLeet);
        vm.expectRevert(err(GuildManagerStorage.UserNotGuildMember.selector, _org1, _guild1, leet));
        _manager.changeGuildAdmins(_org1, _guild1, inviteLeet, admins);
    }

    function testRevertNonGuildOwnerOrAdminInvite(address _user) public {
        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        address[] memory invites = new address[](1);
        invites[0] = _user;

        inviteAndAcceptGuildInvite(_org1, _guild1, leet);
        changeGuildMemberAdminStatus(leet, true);
        
        if(_user == address(this) || _user == leet) {
            vm.expectRevert(err(GuildManagerStorage.UserAlreadyInGuild.selector, _org1, _guild1, _user));
        } else {
            vm.prank(_user);
            vm.expectRevert(err(GuildManagerStorage.NotGuildOwnerOrAdmin.selector, _user, "INVITE"));
        }
        _manager.inviteUsers(_org1, _guild1, invites);
    }

    function testAllowNonOwnerUsersToLeaveGuild(address _user) public {
        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0)
            && _user != _manager.guildOwner(_org1, _guild1)
            && !_user.isContract()
        );
        inviteAndAcceptGuildInvite(_org1, _guild1, _user);
        GuildUserStatus before = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        vm.prank(_user);
        _manager.leaveGuild(_org1, _guild1);
        GuildUserStatus afterLeave = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        assertEq(uint(before), uint(GuildUserStatus.MEMBER));
        assertEq(uint(afterLeave), uint(GuildUserStatus.NOT_ASSOCIATED));
    }

    function testAllowGuildOwnerAndAdminKickMembers(address _user) public {
        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0)
            && _user != _manager.guildOwner(_org1, _guild1)
            && !_user.isContract()
        );
        inviteAndAcceptGuildInvite(_org1, _guild1, _user);
        if(_user != leet) {
            inviteAndAcceptGuildInvite(_org1, _guild1, leet);
        }
        if(_user != alice) {
            inviteAndAcceptGuildInvite(_org1, _guild1, alice);
        }
        changeGuildMemberAdminStatus(leet, true);
        GuildUserStatus before = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        if(_manager.getGuildMemberStatus(_org1, _guild1, _user) == GuildUserStatus.MEMBER) {
            // Ensure member cannot kick other member
            vm.expectRevert(err(GuildManagerStorage.NotGuildOwnerOrAdmin.selector, alice, "KICK"));
            kickGuildMemberAsAdmin(_user, alice);
            // Kick members as admin or owner
            kickGuildMemberAsAdmin(_user, uint160(leet) % 2 == 1 ? leet : address(this));
        } else {
            // Kick admins as owner
            kickGuildMemberAsAdmin(_user, address(this));
            // Ensure admin cannot kick admin
            vm.expectRevert(err(GuildManagerStorage.NotGuildOwner.selector, leet, "KICK"));
            kickGuildMemberAsAdmin(_user, leet);
        }
        GuildUserStatus afterKick = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        assertEq(uint(before), uint(GuildUserStatus.MEMBER));
        assertEq(uint(afterKick), uint(GuildUserStatus.NOT_ASSOCIATED));
    }

    function testAllowAdminToBeDemoted(address _user) public {
        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0)
            && _user != _manager.guildOwner(_org1, _guild1)
            && !_user.isContract()
        );
        inviteAndAcceptGuildInvite(_org1, _guild1, _user);
        changeGuildMemberAdminStatus(_user, true);
        GuildUserStatus before = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        changeGuildMemberAdminStatus(_user, false);
        GuildUserStatus afterDemote = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        assertEq(uint(before), uint(GuildUserStatus.ADMIN));
        assertEq(uint(afterDemote), uint(GuildUserStatus.MEMBER));
    }

    function test() public {
        // TODO: add the following tests
        // testCanCreateForExistingOrganization
        // testCannotCreateForAlreadyInitializedOrganization
        // testCannotCreateForNonExistingOrganization
        // testCannotAddMoreMembersThanMax
        // testUserCannotJoinMoreGuildsThanMax
        // add emit event assertions to tests
    }

    function inviteAndAcceptGuildInvite(uint32 _orgId, uint32 _guildId, address _user) public {
        address[] memory invites = new address[](1);
        invites[0] = _user;
        _manager.inviteUsers(_orgId, _guildId, invites);
        vm.prank(_user);
        _manager.acceptInvitation(_org1, _guild1);
    }

    function changeGuildMemberAdminStatus(address _user, bool _isAdmin) public {
        address[] memory invites = new address[](1);
        bool[] memory admins = new bool[](1);
        invites[0] = _user;
        admins[0] = _isAdmin;
        _manager.changeGuildAdmins(_org1, _guild1, invites, admins);
    }

    function kickGuildMemberAsAdmin(address _user, address _admin) public {
        address[] memory kicks = new address[](1);
        kicks[0] = _user;
        vm.prank(_admin);
        _manager.kickOrRemoveInvitations(_org1, _guild1, kicks);
    }

}