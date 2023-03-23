//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ContextUpgradeable } from "@openzeppelin/contracts-diamond/utils/ContextUpgradeable.sol";

import { AccessControlFacet } from "src/access/AccessControlFacet.sol";
import { ERC1155Facet } from "src/token/ERC1155Facet.sol";
import { IGuildToken } from "src/interfaces/IGuildToken.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { LibUtilities } from "src/libraries/LibUtilities.sol";
import { MetaTxFacet, MetaTxFacetStorage } from "src/metatx/MetaTxFacet.sol";
import { LibGuildToken } from "src/libraries/LibGuildToken.sol";

/**
 * @title Guild Token Contract
 * @notice Token contract to manage all of the guilds within an organization. Each tokenId is a different guild
 * @dev This contract is not expected to me part of a diamond since it is an asset contract that is dynamically created
 *  by the GuildManager contract.
 */
abstract contract GuildTokenBase is IGuildToken, MetaTxFacet, AccessControlFacet, ERC1155Facet {
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

    modifier supportsMetaTxNoId() override {
        verifyAndConsumeSessionId(LibGuildToken.getOrganizationId());
        _;
    }
}
