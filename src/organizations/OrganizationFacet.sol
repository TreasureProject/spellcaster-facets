// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-diamond/access/AccessControlEnumerableUpgradeable.sol";
import {FacetInitializable} from "../utils/FacetInitializable.sol";
import {LibUtilities} from "../libraries/LibUtilities.sol";
import {LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE} from "../libraries/LibAccessControlRoles.sol";
import {LibMeta} from "../libraries/LibMeta.sol";

/**
 * @title Organization Management Facet contract.
 * @dev Use this facet to consume the ability to segment feature adoption by organization. 
 */
contract OrganizationFacet is FacetInitializable {

    function OrganizationFacet_init() external facetInitializer(keccak256("OrganizationFacet")) {
        
    }

    // =============================================================
    //                        External functions
    // =============================================================
}
