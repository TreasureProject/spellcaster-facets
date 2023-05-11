// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import { TestBase } from "./utils/TestBase.sol";
import { SupportMetaTxImpl } from "./utils/TestMeta.sol";
import { DiamondManager, Diamond, IDiamondCut, FacetInfo } from "./utils/DiamondManager.sol";
import { DiamondUtils } from "./utils/DiamondUtils.sol";

import { OrganizationFacet } from "src/organizations/OrganizationFacet.sol";
import { GuildToken } from "src/guilds/guildtoken/GuildToken.sol";
import { GuildManager } from "src/guilds/guildmanager/GuildManager.sol";
import { GuildManagerStorage } from "src/guilds/guildmanager/GuildManagerStorage.sol";
import { LibGuildManager } from "src/libraries/LibGuildManager.sol";
import { OrganizationManagerStorage } from "src/organizations/OrganizationManagerStorage.sol";
import {
    IGuildManager, GuildCreationRule, MaxUsersPerGuildRule, GuildUserStatus
} from "src/interfaces/IGuildManager.sol";
import { MetaTxFacet } from "src/metatx/MetaTxFacet.sol";
import {
    MetaTxFacetStorage,
    ISystemDelegateApprover,
    ForwardRequest,
    FORWARD_REQ_TYPEHASH
} from "src/metatx/MetaTxFacetStorage.sol";

import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract GuildManagerMetaTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    GuildManager internal manager;

    uint96 internal nonce = 1;

    function setUp() public {
        //Timeouts will fail if you do not skip in the setup
        //This is because the leave time for each user defaults to 0
        //And if the current time is under 604800, they would have theoretically not met the cooldown time.
        skip(604800);

        FacetInfo[] memory _facetInfo = new FacetInfo[](2);
        Diamond.Initialization[] memory _initializations = new Diamond.Initialization[](2);

        _facetInfo[0] = FacetInfo(address(new GuildManager()), "GuildManager", IDiamondCut.FacetCutAction.Add);
        _facetInfo[1] = FacetInfo(address(new OrganizationFacet()), "OrganizationFacet", IDiamondCut.FacetCutAction.Add);
        _initializations[0] = Diamond.Initialization({
            initContract: _facetInfo[0].addr,
            initData: abi.encodeWithSelector(IGuildManager.GuildManager_init.selector, address(new GuildToken()))
        });
        _initializations[1] = Diamond.Initialization({
            initContract: address(supportMetaTx),
            initData: abi.encodeWithSelector(SupportMetaTxImpl.init.selector, address(delegateApprover))
        });

        init(_facetInfo, _initializations);

        manager = GuildManager(address(diamond));
        diamond.grantRole("ADMIN", deployer);
        diamond.grantRole("ADMIN", signingAuthority);
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

    // =============================================================
    //                           Guilds
    // =============================================================

    function testCanCreateGuildOrganization() public {
        diamond.setPause(false);

        vm.prank(signingAuthority);
        OrganizationFacet(address(manager)).createOrganization(org1, "My org", "My descr");
        OrganizationFacet(address(manager)).createOrganization(org2, "My org", "My descr");

        // Signer is sender
        signAndExecuteMetaTx(
            ForwardRequest({
                from: signingAuthority,
                nonce: 1,
                organizationId: org1,
                data: abi.encodeWithSelector(
                    IGuildManager.initializeForOrganization.selector,
                    org1,
                    1, // Max users per guild
                    604800, // Timeout to join another
                    GuildCreationRule.ADMIN_ONLY,
                    MaxUsersPerGuildRule.CONSTANT,
                    20, // Max users in a guild
                    address(0), // optional contract for customizable guild rules)
                    false
                    )
            }),
            address(manager)
        );

        assertEq(manager.getGuildOrganizationInfo(org1).guildIdCur, 1, "Guild organization is not 1");
        assertEq(
            OrganizationFacet(address(diamond)).getOrganizationInfo(org1).admin,
            signingAuthority,
            "Is not organization admin"
        );

        delegateApprover.setDelegateApprovalForSystem(org2, signingAuthority, true);

        // Signer is delegate
        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: 1,
                organizationId: org2,
                data: abi.encodeWithSelector(
                    IGuildManager.initializeForOrganization.selector,
                    org2,
                    1, // Max users per guild
                    604800, // Timeout to join another
                    GuildCreationRule.ADMIN_ONLY,
                    MaxUsersPerGuildRule.CONSTANT,
                    20, // Max users in a guild
                    address(0), // optional contract for customizable guild rules)
                    false
                    )
            }),
            address(manager)
        );
    }

    function testCanEditGuild() public {
        diamond.setPause(false);

        createDefaultOrgAndGuild();
        assertEq("", manager.guildName(org1, guild1));
        assertEq("", manager.guildDescription(org1, guild1));

        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);

        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: 1,
                organizationId: org1,
                data: abi.encodeWithSelector(IGuildManager.updateGuildInfo.selector, org1, guild1, "New name", "New descr")
            }),
            address(manager)
        );

        assertEq("New name", manager.guildName(org1, guild1));
        assertEq("New descr", manager.guildDescription(org1, guild1));
    }

    function testCanInvite() public {
        // Set delegate for deployer and leet
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);
        vm.prank(leet);
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);

        diamond.setPause(false);
        createDefaultOrgAndGuild();
        address[] memory _inviteLeet = new address[](1);
        _inviteLeet[0] = leet;
        GuildUserStatus _before = manager.getGuildMemberStatus(org1, guild1, leet);
        GuildUserStatus _invited;
        GuildUserStatus _member;

        // Invite and accept for leet
        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: 1,
                organizationId: org1,
                data: abi.encodeWithSelector(IGuildManager.inviteUsers.selector, org1, guild1, _inviteLeet)
            }),
            address(manager)
        );

        _invited = manager.getGuildMemberStatus(org1, guild1, leet);

        signAndExecuteMetaTx(
            ForwardRequest({
                from: leet,
                nonce: 1,
                organizationId: org1,
                data: abi.encodeWithSelector(IGuildManager.acceptInvitation.selector, org1, guild1)
            }),
            address(manager)
        );
        _member = manager.getGuildMemberStatus(org1, guild1, leet);

        assertEq(uint256(_before), uint256(GuildUserStatus.NOT_ASSOCIATED));
        assertEq(uint256(_invited), uint256(GuildUserStatus.INVITED));
        assertEq(uint256(_member), uint256(GuildUserStatus.MEMBER));
    }

    function testCanLeaveGuild(address _user) public {
        vm.prank(_user);
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);

        diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0) && _user != manager.guildOwner(org1, guild1) && !_user.isContract());
        inviteAndAcceptGuildInvite(org1, guild1, _user);
        GuildUserStatus _before = manager.getGuildMemberStatus(org1, guild1, _user);

        signAndExecuteMetaTx(
            ForwardRequest({
                from: _user,
                nonce: 1,
                organizationId: org1,
                data: abi.encodeWithSelector(IGuildManager.leaveGuild.selector, org1, guild1)
            }),
            address(manager)
        );

        GuildUserStatus _afterLeave = manager.getGuildMemberStatus(org1, guild1, _user);
        assertEq(uint256(_before), uint256(GuildUserStatus.MEMBER));
        assertEq(uint256(_afterLeave), uint256(GuildUserStatus.NOT_ASSOCIATED));
    }

    function testCanKickMembers(address _user) public {
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);
        vm.prank(_user);
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);
        vm.prank(leet);
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);
        vm.prank(alice);
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);

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

    function testCanDemoteAdmin(address _user) public {
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);

        diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0) && _user != manager.guildOwner(org1, guild1) && !_user.isContract());
        inviteAndAcceptGuildInvite(org1, guild1, _user);
        changeGuildMemberAdminStatus(_user, true);
        GuildUserStatus _before = manager.getGuildMemberStatus(org1, guild1, _user);
        changeGuildMemberAdminStatus(_user, false);
        GuildUserStatus _afterDemote = manager.getGuildMemberStatus(org1, guild1, _user);
        assertEq(uint256(_before), uint256(GuildUserStatus.ADMIN));
        assertEq(uint256(_afterDemote), uint256(GuildUserStatus.MEMBER));
    }

    function testCaninitializeForOrganization() public {
        delegateApprover.setDelegateApprovalForSystem(org1, signingAuthority, true);
        delegateApprover.setDelegateApprovalForSystem(org2, signingAuthority, true);

        diamond.setPause(false);
        createDefaultOrgAndGuild();

        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: nonce++,
                organizationId: org2,
                data: abi.encodeWithSelector(
                    OrganizationFacet.createOrganization.selector, org2, "Organization2", "Org description2"
                    )
            }),
            address(manager)
        );

        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: nonce++,
                organizationId: org2,
                data: abi.encodeWithSelector(
                    IGuildManager.initializeForOrganization.selector,
                    org2,
                    69, // Max users per guild
                    604800, // Timeout to join another
                    GuildCreationRule.ADMIN_ONLY,
                    MaxUsersPerGuildRule.CONSTANT,
                    100, // Max users in a guild
                    address(0), // optional contract for customizable guild rules
                    false
                    )
            }),
            address(manager)
        );

        assertEq("Organization2", OrganizationFacet(address(diamond)).getOrganizationInfo(org2).name);
        assertEq("Org description2", OrganizationFacet(address(diamond)).getOrganizationInfo(org2).description);
        assertEq(69, manager.getGuildOrganizationInfo(org2).maxGuildsPerUser);
        assertEq(100, manager.getGuildOrganizationInfo(org2).maxUsersPerGuildConstant);
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
        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: nonce++,
                organizationId: org1,
                data: abi.encodeWithSelector(IGuildManager.changeGuildAdmins.selector, org1, guild1, _invites, _admins)
            }),
            address(manager)
        );
    }

    function kickGuildMemberAsAdmin(address _user, address _admin) public {
        address[] memory _kicks = new address[](1);
        _kicks[0] = _user;
        signAndExecuteMetaTx(
            ForwardRequest({
                from: _admin,
                nonce: nonce++,
                organizationId: org1,
                data: abi.encodeWithSelector(IGuildManager.kickOrRemoveInvitations.selector, org1, guild1, _kicks)
            }),
            address(manager)
        );
    }
}
