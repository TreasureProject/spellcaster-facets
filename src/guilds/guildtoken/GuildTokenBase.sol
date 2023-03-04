//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ContextUpgradeable} from "@openzeppelin/contracts-diamond/utils/ContextUpgradeable.sol";

import {AccessControlFacet} from "src/access/AccessControlFacet.sol";
import {ERC1155Facet} from "src/token/ERC1155Facet.sol";
import {IGuildToken} from "src/interfaces/IGuildToken.sol";
import {LibMeta} from "src/libraries/LibMeta.sol";
import {LibUtilities} from "src/libraries/LibUtilities.sol";

abstract contract GuildTokenBase is IGuildToken, AccessControlFacet, ERC1155Facet {

    function __GuildTokenBase_init() internal onlyFacetInitializing {
        __ERC1155Facet_init("");
        __AccessControlEnumerable_init();
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

    /**
     * @dev Overrides the _msgSender function for all dependent contracts that implement it.
     *  This must be done outside of the OZ-wrapped facets to avoid conflicting overrides needing explicit declaration
     */
    function _msgSender() internal view override returns (address) {
        return LibMeta._msgSender();
    }

    modifier whenNotPaused() {
        LibUtilities.requireNotPaused();
        _;
    }
}