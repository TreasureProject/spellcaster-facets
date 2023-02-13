//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-diamond/proxy/utils/Initializable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-diamond/utils/ContextUpgradeable.sol";

import {AccessControlFacet} from "../../access/AccessControlFacet.sol";
import {ERC1155Facet} from "../../token/ERC1155Facet.sol";
import {IGuildManager} from "../guildmanager/IGuildManager.sol";
import {IGuildToken} from "./IGuildToken.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";
import {LibUtilities} from "../../libraries/LibUtilities.sol";
import {Modifiers} from "../../Modifiers.sol";

abstract contract GuildTokenState is IGuildToken, AccessControlFacet, ERC1155Facet {

    IGuildManager public guildManager;

    /**
     * @notice The organization this 1155 collection is associated to.
    */
    uint32 public organizationId;

    function __GuildTokenState_init() internal initializer {
        __ERC1155Facet_init("");
    }
    
    /**
     * @dev Overrides and passes through to ERC1155
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlFacet, ERC1155Facet)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    modifier whenNotPaused() {
        LibUtilities.requireNotPaused();
        _;
    }
}