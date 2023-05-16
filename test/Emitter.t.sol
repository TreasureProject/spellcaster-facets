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

import {AddressUpgradeable} from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract EmitterTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    Emitter internal emitter;
    OrganizationFacet internal organizationFacet;

    function setUp() public {
        FacetInfo[] memory facetInfo = new FacetInfo[](2);
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
        initializations[0] = Diamond.Initialization({
            initContract: facetInfo[0].addr,
            initData: abi.encodeWithSelector(Emitter.Emitter_init.selector)
        });

        init(facetInfo, initializations);

        emitter = Emitter(address(_diamond));
        organizationFacet = OrganizationFacet(address(_diamond));

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
}
