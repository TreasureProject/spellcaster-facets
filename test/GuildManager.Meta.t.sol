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
    ISystem_Delegate_Approver,
    ForwardRequest,
    FORWARD_REQ_TYPEHASH
} from "src/metatx/MetaTxFacetStorage.sol";

import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract GuildManagerMetaTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    GuildManager internal _manager;

    uint96 _nonce = 1;

    function setUp() public {
        FacetInfo[] memory facetInfo = new FacetInfo[](2);
        Diamond.Initialization[] memory initializations = new Diamond.Initialization[](2);

        facetInfo[0] = FacetInfo(address(new GuildManager()), "GuildManager", IDiamondCut.FacetCutAction.Add);
        facetInfo[1] = FacetInfo(address(new OrganizationFacet()), "OrganizationFacet", IDiamondCut.FacetCutAction.Add);
        initializations[0] = Diamond.Initialization({
            initContract: facetInfo[0].addr,
            initData: abi.encodeWithSelector(IGuildManager.GuildManager_init.selector, address(new GuildToken()))
        });
        initializations[1] = Diamond.Initialization({
            initContract: address(_supportMetaTx),
            initData: abi.encodeWithSelector(SupportMetaTxImpl.init.selector, address(_delegateApprover))
        });

        init(facetInfo, initializations);

        _manager = GuildManager(address(_diamond));
        _diamond.grantRole("ADMIN", deployer);
        _diamond.grantRole("ADMIN", signingAuthority);
    }

    function createDefaultOrgAndGuild() internal {
        _manager.createForNewOrganization(
            _org1,
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

    // =============================================================
    //                           Guilds
    // =============================================================

    function testCanCreateGuildOrganization() public {
        _diamond.setPause(false);

        // Signer is sender
        signAndExecuteMetaTx(
            ForwardRequest({
                from: signingAuthority,
                nonce: 1,
                organizationId: _org1,
                data: abi.encodeWithSelector(
                    IGuildManager.createForNewOrganization.selector,
                    _org1,
                    "My org",
                    "My descr",
                    1, // Max users per guild
                    0, // Timeout to join another
                    GuildCreationRule.ADMIN_ONLY,
                    MaxUsersPerGuildRule.CONSTANT,
                    20, // Max users in a guild
                    address(0) // optional contract for customizable guild rules)
                )
            }),
            address(_manager)
        );

        assertEq(_manager.getGuildOrganizationInfo(_org1).guildIdCur, 1, "Guild organization is not 1");
        assertEq(
            OrganizationFacet(address(_diamond)).getOrganizationInfo(_org1).admin,
            signingAuthority,
            "Is not organization admin"
        );

        _delegateApprover.setDelegateApprovalForSystem(_org2, signingAuthority, true);

        // Signer is delegate
        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: 1,
                organizationId: _org2,
                data: abi.encodeWithSelector(
                    IGuildManager.createForNewOrganization.selector,
                    _org2,
                    "My org",
                    "My descr",
                    1, // Max users per guild
                    0, // Timeout to join another
                    GuildCreationRule.ADMIN_ONLY,
                    MaxUsersPerGuildRule.CONSTANT,
                    20, // Max users in a guild
                    address(0) // optional contract for customizable guild rules)
                )
            }),
            address(_manager)
        );
    }

    function testCanEditGuild() public {
        _diamond.setPause(false);

        createDefaultOrgAndGuild();
        assertEq("", _manager.guildName(_org1, _guild1));
        assertEq("", _manager.guildDescription(_org1, _guild1));

        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);

        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: 1,
                organizationId: _org1,
                data: abi.encodeWithSelector(
                    IGuildManager.updateGuildInfo.selector, _org1, _guild1, "New name", "New descr"
                    )
            }),
            address(_manager)
        );

        assertEq("New name", _manager.guildName(_org1, _guild1));
        assertEq("New descr", _manager.guildDescription(_org1, _guild1));
    }

    function testCanInvite() public {
        // Set delegate for deployer and leet
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);
        vm.prank(leet);
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);

        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        address[] memory inviteLeet = new address[](1);
        inviteLeet[0] = leet;
        GuildUserStatus before = _manager.getGuildMemberStatus(_org1, _guild1, leet);
        GuildUserStatus invited;
        GuildUserStatus member;

        // Invite and accept for leet
        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: 1,
                organizationId: _org1,
                data: abi.encodeWithSelector(IGuildManager.inviteUsers.selector, _org1, _guild1, inviteLeet)
            }),
            address(_manager)
        );

        invited = _manager.getGuildMemberStatus(_org1, _guild1, leet);

        signAndExecuteMetaTx(
            ForwardRequest({
                from: leet,
                nonce: 1,
                organizationId: _org1,
                data: abi.encodeWithSelector(IGuildManager.acceptInvitation.selector, _org1, _guild1)
            }),
            address(_manager)
        );
        member = _manager.getGuildMemberStatus(_org1, _guild1, leet);

        assertEq(uint256(before), uint256(GuildUserStatus.NOT_ASSOCIATED));
        assertEq(uint256(invited), uint256(GuildUserStatus.INVITED));
        assertEq(uint256(member), uint256(GuildUserStatus.MEMBER));
    }

    function testCanLeaveGuild(address _user) public {
        vm.prank(_user);
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);

        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0) && _user != _manager.guildOwner(_org1, _guild1) && !_user.isContract());
        inviteAndAcceptGuildInvite(_org1, _guild1, _user);
        GuildUserStatus before = _manager.getGuildMemberStatus(_org1, _guild1, _user);

        signAndExecuteMetaTx(
            ForwardRequest({
                from: _user,
                nonce: 1,
                organizationId: _org1,
                data: abi.encodeWithSelector(IGuildManager.leaveGuild.selector, _org1, _guild1)
            }),
            address(_manager)
        );

        GuildUserStatus afterLeave = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        assertEq(uint256(before), uint256(GuildUserStatus.MEMBER));
        assertEq(uint256(afterLeave), uint256(GuildUserStatus.NOT_ASSOCIATED));
    }

    function testCanKickMembers(address _user) public {
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);
        vm.prank(_user);
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);
        vm.prank(leet);
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);
        vm.prank(alice);
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);

        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0) && _user != _manager.guildOwner(_org1, _guild1) && !_user.isContract());
        inviteAndAcceptGuildInvite(_org1, _guild1, _user);
        if (_user != leet) {
            inviteAndAcceptGuildInvite(_org1, _guild1, leet);
        }
        if (_user != alice) {
            inviteAndAcceptGuildInvite(_org1, _guild1, alice);
        }
        changeGuildMemberAdminStatus(leet, true);
        GuildUserStatus before = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        if (_manager.getGuildMemberStatus(_org1, _guild1, _user) == GuildUserStatus.MEMBER) {
            // Ensure member cannot kick other member
            vm.expectRevert(err(GuildManagerStorage.NotGuildOwnerOrAdmin.selector, alice, "KICK"));
            kickGuildMemberAsAdmin(_user, alice);
            // Kick members as admin or owner
            kickGuildMemberAsAdmin(_user, uint160(leet) % 2 == 1 ? leet : deployer);
        } else if (_manager.getGuildMemberStatus(_org1, _guild1, _user) == GuildUserStatus.ADMIN) {
            // Kick admins as owner
            kickGuildMemberAsAdmin(_user, deployer);
            // Ensure admin cannot kick admin
            vm.expectRevert(err(GuildManagerStorage.NotGuildOwner.selector, leet, "KICK"));
            kickGuildMemberAsAdmin(_user, leet);
        }
        GuildUserStatus afterKick = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        assertEq(uint256(before), uint256(GuildUserStatus.MEMBER));
        assertEq(uint256(afterKick), uint256(GuildUserStatus.NOT_ASSOCIATED));
    }

    function testCanDemoteAdmin(address _user) public {
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);

        _diamond.setPause(false);
        createDefaultOrgAndGuild();
        // User cannot be the owner or a contract
        vm.assume(_user != address(0) && _user != _manager.guildOwner(_org1, _guild1) && !_user.isContract());
        inviteAndAcceptGuildInvite(_org1, _guild1, _user);
        changeGuildMemberAdminStatus(_user, true);
        GuildUserStatus before = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        changeGuildMemberAdminStatus(_user, false);
        GuildUserStatus afterDemote = _manager.getGuildMemberStatus(_org1, _guild1, _user);
        assertEq(uint256(before), uint256(GuildUserStatus.ADMIN));
        assertEq(uint256(afterDemote), uint256(GuildUserStatus.MEMBER));
    }

    function testCanCreateForExistingOrganization() public {
        _delegateApprover.setDelegateApprovalForSystem(_org1, signingAuthority, true);
        _delegateApprover.setDelegateApprovalForSystem(_org2, signingAuthority, true);

        _diamond.setPause(false);
        createDefaultOrgAndGuild();

        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: _nonce++,
                organizationId: _org2,
                data: abi.encodeWithSelector(
                    OrganizationFacet.createOrganization.selector, _org2, "Organization2", "Org description2"
                    )
            }),
            address(_manager)
        );

        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: _nonce++,
                organizationId: _org2,
                data: abi.encodeWithSelector(
                    IGuildManager.createForExistingOrganization.selector,
                    _org2,
                    69, // Max users per guild
                    0, // Timeout to join another
                    GuildCreationRule.ADMIN_ONLY,
                    MaxUsersPerGuildRule.CONSTANT,
                    420, // Max users in a guild
                    address(0) // optional contract for customizable guild rules
                )
            }),
            address(_manager)
        );

        assertEq("Organization2", OrganizationFacet(address(_diamond)).getOrganizationInfo(_org2).name);
        assertEq("Org description2", OrganizationFacet(address(_diamond)).getOrganizationInfo(_org2).description);
        assertEq(69, _manager.getGuildOrganizationInfo(_org2).maxGuildsPerUser);
        assertEq(420, _manager.getGuildOrganizationInfo(_org2).maxUsersPerGuildConstant);
    }

    function inviteAndAcceptGuildInvite(bytes32 _orgId, uint32 _guildId, address _user) public {
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
        signAndExecuteMetaTx(
            ForwardRequest({
                from: deployer,
                nonce: _nonce++,
                organizationId: _org1,
                data: abi.encodeWithSelector(IGuildManager.changeGuildAdmins.selector, _org1, _guild1, invites, admins)
            }),
            address(_manager)
        );
    }

    function kickGuildMemberAsAdmin(address _user, address _admin) public {
        address[] memory kicks = new address[](1);
        kicks[0] = _user;
        signAndExecuteMetaTx(
            ForwardRequest({
                from: _admin,
                nonce: _nonce++,
                organizationId: _org1,
                data: abi.encodeWithSelector(IGuildManager.kickOrRemoveInvitations.selector, _org1, _guild1, kicks)
            }),
            address(_manager)
        );
    }
}
