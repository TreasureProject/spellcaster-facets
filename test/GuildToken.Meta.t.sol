// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {TestBase} from "./utils/TestBase.sol";
import {DiamondManager, Diamond, IDiamondCut, FacetInfo} from "./utils/DiamondManager.sol";
import {DiamondUtils} from "./utils/DiamondUtils.sol";

import {GuildToken} from "../src/guilds/guildtoken/GuildToken.sol";
import {MetaTxFacet} from "src/metatx/MetaTxFacet.sol";
import {MetaTxFacetStorage, ISystem_Delegate_Approver, ForwardRequest, FORWARD_REQ_TYPEHASH} from "src/metatx/MetaTxFacetStorage.sol";
import {LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE} from "src/libraries/LibAccessControlRoles.sol";
import {LibMeta} from "../src/libraries/LibMeta.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract GuildTokenMetaTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    GuildToken internal _token;

    function setUp() public {
        _token = new GuildToken();
        _token.initialize(_org2, address(_delegateApprover));
    }

    function testCanAdminMint() public {
        _token.grantRole(ADMIN_ROLE, signingAuthority);

        // Signer is sender
        signAndExecuteMetaTx(ForwardRequest({
                from: signingAuthority,
                nonce: 1,
                organizationId: _org2,
                data: abi.encodeWithSelector(GuildToken.adminMint.selector, signingAuthority, 1, 1)
        }), address(_token));

        assertEq(_token.balanceOf(signingAuthority, 1), 1);

        _delegateApprover.setDelegateApprovalForSystem(_org2, signingAuthority, true);

        signAndExecuteMetaTx(ForwardRequest({
                from: deployer,
                nonce: 2,
                organizationId: _org2,
                data: abi.encodeWithSelector(GuildToken.adminMint.selector, signingAuthority, 1, 1)
        }), address(_token));

        // Signer is delegate
        assertEq(_token.balanceOf(signingAuthority, 1), 2);
    }

    function testCanAdminBurn() public {
        _token.grantRole(ADMIN_ROLE, signingAuthority);

        // Signer is sender
        signAndExecuteMetaTx(ForwardRequest({
                from: signingAuthority,
                nonce: 1,
                organizationId: _org2,
                data: abi.encodeWithSelector(GuildToken.adminMint.selector, signingAuthority, 1, 2)
        }), address(_token));

        assertEq(_token.balanceOf(signingAuthority, 1), 2);

        _delegateApprover.setDelegateApprovalForSystem(_org2, signingAuthority, true);

        signAndExecuteMetaTx(ForwardRequest({
                from: signingAuthority,
                nonce: 2,
                organizationId: _org2,
                data: abi.encodeWithSelector(GuildToken.adminBurn.selector, signingAuthority, 1, 1)
        }), address(_token));

        assertEq(_token.balanceOf(signingAuthority, 1), 1);

        signAndExecuteMetaTx(ForwardRequest({
                from: deployer,
                nonce: 3,
                organizationId: _org2,
                data: abi.encodeWithSelector(GuildToken.adminBurn.selector, signingAuthority, 1, 1)
        }), address(_token));

        // Signer is delegate
        assertEq(_token.balanceOf(signingAuthority, 1), 0);
    }

}