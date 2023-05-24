// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {TestBase} from "./utils/TestBase.sol";
import {DiamondManager, Diamond, IDiamondCut, FacetInfo} from "./utils/DiamondManager.sol";
import {DiamondUtils} from "./utils/DiamondUtils.sol";

import {ERC721Consumer} from "src/mocks/ERC721Consumer.sol";

import {LibAccessControlRoles} from "src/libraries/LibAccessControlRoles.sol";

import {GuildToken} from "src/guilds/guildtoken/GuildToken.sol";
import {Emitter} from "src/emitter/Emitter.sol";
import {GuildManagerStorage} from "src/guilds/guildmanager/GuildManagerStorage.sol";
import {LibGuildManager} from "src/libraries/LibGuildManager.sol";
import {OrganizationManagerStorage} from "src/organizations/OrganizationManagerStorage.sol";
import {OrganizationFacet, OrganizationManagerStorage} from "src/organizations/OrganizationFacet.sol";
import {IGuildManager, GuildCreationRule, MaxUsersPerGuildRule, GuildUserStatus, GuildStatus} from "src/interfaces/IGuildManager.sol";
import {EmittingCollectionType, EmittingRateChangeBehavior} from "src/interfaces/IEmitter.sol";
import {LibEmitterStorage} from "src/emitter/LibEmitterStorage.sol";
import {CollectionAccessControlFacet} from "src/access/CollectionAccessControlFacet.sol";
import {ERC1155Consumer} from "src/mocks/ERC1155Consumer.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract EmitterTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    Emitter internal emitter;
    OrganizationFacet internal organizationFacet;
    CollectionAccessControlFacet internal collectionAccessControl;
    ERC1155Consumer internal erc1155Consumer;

    function setUp() public {
        FacetInfo[] memory facetInfo = new FacetInfo[](3);
        Diamond.Initialization[]
            memory initializations = new Diamond.Initialization[](1);

        facetInfo[0] = FacetInfo(
            address(new Emitter()),
            "Emitter",
            IDiamondCut.FacetCutAction.Add
        );
        facetInfo[1] = FacetInfo(
            address(new OrganizationFacet()),
            "OrganizationFacet",
            IDiamondCut.FacetCutAction.Add
        );
        facetInfo[2] = FacetInfo(
            address(new CollectionAccessControlFacet()),
            "CollectionAccessControlFacet",
            IDiamondCut.FacetCutAction.Add
        );
        initializations[0] = Diamond.Initialization({
            initContract: facetInfo[0].addr,
            initData: abi.encodeWithSelector(Emitter.Emitter_init.selector)
        });

        init(facetInfo, initializations);

        emitter = Emitter(address(_diamond));
        organizationFacet = OrganizationFacet(address(_diamond));
        collectionAccessControl = CollectionAccessControlFacet(
            address(_diamond)
        );
        erc1155Consumer = new ERC1155Consumer();
        erc1155Consumer.initialize();

        _diamond.grantRole("ADMIN", deployer);

        createDefaultOrg();
    }

    function createDefaultOrg() internal {
        organizationFacet.createOrganization(_org1, "My org", "My descr");
    }

    function test_createEmittingInstance_invalidOrg() public {
        bytes32 _organizationId = "abc";
        vm.prank(leet);
        vm.expectRevert(
            err(
                OrganizationManagerStorage.NonexistantOrganization.selector,
                _organizationId
            )
        );

        emitter.createEmittingInstance(
            _organizationId,
            EmittingCollectionType.ERC1155,
            leet, // Random address for the collection
            1,
            1,
            1,
            0,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );
    }

    function test_createEmittingInstance_invalidStartTime() public {
        vm.prank(leet);
        vm.expectRevert(err(LibEmitterStorage.InvalidStartTime.selector));

        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            leet,
            1,
            1,
            0, // Bad start time
            0,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );
    }

    function test_createEmittingInstance_invalidFrequencyOrAmount() public {
        vm.prank(leet);
        vm.expectRevert(err(LibEmitterStorage.BadEmittingRate.selector));

        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            leet,
            1,
            0, // Bad rate
            1,
            0,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );

        vm.expectRevert(err(LibEmitterStorage.BadEmittingRate.selector));

        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            leet,
            0, // Bad frequency
            1,
            1,
            0,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );
    }

    function test_createEmittingInstance_invalidEndTime() public {
        vm.prank(leet);
        vm.expectRevert(err(LibEmitterStorage.BadEndTime.selector));

        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            leet,
            1,
            1,
            2,
            1, // End time before start time
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );
    }

    function test_createEmittingInstance_success() public {
        vm.prank(leet);

        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            leet,
            1,
            1,
            2,
            4,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );
    }

    function test_claim_instanceDoesNotExist() public {
        vm.prank(leet);
        vm.expectRevert(err(LibEmitterStorage.InstanceDeactivated.selector));

        emitter.claim(100);
    }

    function test_claim_instanceWasDisabled() public {
        vm.prank(leet);
        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            leet,
            1,
            1,
            2,
            4,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );

        vm.prank(leet);
        emitter.deactivateEmittingInstance(1);

        vm.prank(leet);
        vm.expectRevert(err(LibEmitterStorage.InstanceDeactivated.selector));

        emitter.claim(1);
    }

    function test_claim_claimerNotApproved() public {
        vm.prank(leet);
        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            leet,
            1,
            1,
            2,
            4,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );

        vm.prank(alice);
        vm.expectRevert(err(LibEmitterStorage.ApprovedClaimerOnly.selector));

        emitter.claim(1);
    }

    function test_claim_collectionHasNotApproved() public {
        vm.prank(leet);
        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            leet,
            1,
            1,
            2,
            4,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ""
        );

        vm.prank(leet);
        vm.expectRevert(err(LibEmitterStorage.CollectionNotApproved.selector));

        emitter.claim(1);
    }

    function test_claim_successBasic() public {
        vm.prank(leet);
        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            address(erc1155Consumer),
            1,
            1 ether, // ERC1155 rate in terms of eth
            2,
            4,
            EmittingRateChangeBehavior.CLAIM_PARTIAL,
            1,
            ERC1155Consumer.mintArbitrary.selector
        );
        uint64 _emittingInstanceId = 1;

        collectionAccessControl.grantCollectionAdmin(
            leet,
            address(erc1155Consumer)
        );

        vm.prank(leet);
        emitter.changeEmittingInstanceApproval(_emittingInstanceId, true);

        // Skip into the future. Since the emitting instance is only active for 2 seconds,
        // we should be able to claim the whole amount.
        //
        skip(100);

        vm.prank(leet);
        emitter.claim(_emittingInstanceId);

        assertEq(erc1155Consumer.balanceOf(leet, 1), 2);
    }

    function test_claim_successCliff() public {
        uint64 _emittingInstanceId = _setupAndApproveEmitterInstance(
            10,
            1,
            0,
            1 ether
        );

        warp(10);

        assertEq(_amountToClaim(_emittingInstanceId), 0);

        warp(11);

        assertEq(_amountToClaim(_emittingInstanceId), 10);

        warp(21);

        vm.prank(leet);
        emitter.claim(_emittingInstanceId);

        assertEq(erc1155Consumer.balanceOf(leet, 1), 20);
    }

    function test_claim_accruedLessThan1() public {
        uint64 _emittingInstanceId = _setupAndApproveEmitterInstance(
            1,
            1,
            0,
            0.09 ether
        );

        warp(12);

        // Still 0 as 0.99 ether (11 * 0.09) is less than 1 whole item
        assertEq(_amountToClaim(_emittingInstanceId), 0);

        warp(13);

        assertEq(_amountToClaim(_emittingInstanceId), 1);
    }

    function test_claim_acrrueRightAfterClaim() public {
        uint64 _emittingInstanceId = _setupAndApproveEmitterInstance(
            10,
            1,
            0,
            1 ether
        );

        warp(20);

        vm.prank(leet);
        emitter.claim(_emittingInstanceId);
        assertEq(erc1155Consumer.balanceOf(leet, 1), 10);

        // Should get two more emitting clifs for timestamp 21 and 31
        warp(31);

        vm.prank(leet);
        emitter.claim(_emittingInstanceId);
        assertEq(erc1155Consumer.balanceOf(leet, 1), 30);
    }

    function test_claim_changeRate_claimPartial() public {
        uint64 _emittingInstanceId = _setupAndApproveEmitterInstance(
            10,
            1,
            0,
            1 ether,
            EmittingRateChangeBehavior.CLAIM_PARTIAL
        );

        warp(11);

        vm.prank(leet);
        emitter.claim(_emittingInstanceId);
        assertEq(erc1155Consumer.balanceOf(leet, 1), 10);

        warp(20);
        _changeFrequencyAndRate(_emittingInstanceId, 10, 0.5 ether);

        // Window should restart at the time of change. Claim partial should save the 9 items that hadn't been claimed because the window hadn't been reached.
        warp(30);

        vm.prank(leet);
        emitter.claim(_emittingInstanceId);
        assertEq(erc1155Consumer.balanceOf(leet, 1), 24);
    }

    function test_claim_changeRate_discardExtra() public {
        uint64 _emittingInstanceId = _setupAndApproveEmitterInstance(
            10,
            1,
            0,
            1 ether,
            EmittingRateChangeBehavior.DISCARD_PARTIAL
        );

        warp(11);

        vm.prank(leet);
        emitter.claim(_emittingInstanceId);
        assertEq(erc1155Consumer.balanceOf(leet, 1), 10);

        warp(20);
        _changeFrequencyAndRate(_emittingInstanceId, 10, 0.5 ether);

        // Window should restart at the time of change. Discard partial should have discarded the 9 almost accrued items.
        warp(30);

        vm.prank(leet);
        emitter.claim(_emittingInstanceId);
        assertEq(erc1155Consumer.balanceOf(leet, 1), 15);
    }

    function _changeFrequencyAndRate(
        uint64 _emittingInstance,
        uint256 _frequency,
        uint256 _amount
    ) private {
        vm.prank(leet);
        emitter.changeEmittingInstanceFrequencyAndRate(
            _emittingInstance,
            _frequency,
            _amount
        );
    }

    function _setupAndApproveEmitterInstance(
        uint256 _frequency,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate
    ) private returns (uint64) {
        return
            _setupAndApproveEmitterInstance(
                _frequency,
                _startTime,
                _endTime,
                _rate,
                EmittingRateChangeBehavior.CLAIM_PARTIAL
            );
    }

    function _setupAndApproveEmitterInstance(
        uint256 _frequency,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        EmittingRateChangeBehavior _changeBehavior
    ) private returns (uint64) {
        vm.prank(leet);
        // Emits 1 item per second, every 10 seconds.
        emitter.createEmittingInstance(
            _org1,
            EmittingCollectionType.ERC1155,
            address(erc1155Consumer),
            _frequency,
            _rate, // ERC1155 rate in terms of eth
            _startTime,
            _endTime,
            _changeBehavior,
            1,
            ERC1155Consumer.mintArbitrary.selector
        );

        collectionAccessControl.grantCollectionAdmin(
            leet,
            address(erc1155Consumer)
        );

        vm.prank(leet);
        emitter.changeEmittingInstanceApproval(1, true);

        return 1;
    }

    function _amountToClaim(
        uint64 _emittingInstanceId
    ) private view returns (uint256) {
        return _amountToClaim(_emittingInstanceId, false);
    }

    function _amountToClaim(
        uint64 _emittingInstanceId,
        bool _includePartial
    ) private view returns (uint256) {
        (uint256 _amount, ) = emitter.amountToClaim(
            _emittingInstanceId,
            _includePartial
        );
        return _amount;
    }
}
