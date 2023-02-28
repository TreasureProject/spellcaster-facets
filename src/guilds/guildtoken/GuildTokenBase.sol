//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ContextUpgradeable} from "@openzeppelin/contracts-diamond/utils/ContextUpgradeable.sol";

import {AccessControlFacet} from "../../access/AccessControlFacet.sol";
import {ERC1155Facet} from "../../token/ERC1155Facet.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";
import {LibMeta} from "src/libraries/LibMeta.sol";
import {LibUtilities} from "src/libraries/LibUtilities.sol";

abstract contract GuildTokenBase is IGuildToken, AccessControlFacet, ERC1155Facet {

    function __GuildTokenState_init() internal onlyFacetInitializing {
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