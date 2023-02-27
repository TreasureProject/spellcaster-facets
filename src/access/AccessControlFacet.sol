// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-diamond/access/AccessControlEnumerableUpgradeable.sol";
import {FacetInitializable} from "../utils/FacetInitializable.sol";
import {LibUtilities} from "../libraries/LibUtilities.sol";
import {LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE} from "../libraries/LibAccessControlRoles.sol";

/**
 * @title AccessControl facet wrapper for OZ's pausable contract.
 * @dev Use this facet to limit the spread of third-party dependency references and allow new functionality to be shared 
 */
contract AccessControlFacet is FacetInitializable, AccessControlEnumerableUpgradeable {

    function AccessControlFacet_init() external facetInitializer(keccak256("AccessControlFacet")) {
        __AccessControlEnumerable_init();

        _setRoleAdmin(ADMIN_ROLE, ADMIN_GRANTER_ROLE);
        _grantRole(ADMIN_GRANTER_ROLE, LibAccessControlRoles.contractOwner());

        // Give admin to the owner. May be revoked to prevent permanent administrative rights as owner
        _grantRole(ADMIN_ROLE, LibAccessControlRoles.contractOwner());
    }

    // =============================================================
    //                        External functions
    // =============================================================

    /// @notice Batch function for granting access to many addresses at once.
    /// @dev Checks for RoleAdmin permissions inside the grantRole function
    ///  per the OpenZeppelin AccessControl standard
    /// @param _roles Roles to be granted to the account in the same index of the _accounts array
    /// @param _accounts Addresses to grant the role in the same index of the _roles array
    function grantRoles(bytes32[] calldata _roles, address[] calldata _accounts) external {
        uint256 roleLength = _roles.length;
        if(roleLength != _accounts.length) {
            revert LibUtilities.ArrayLengthMismatch(roleLength, _accounts.length);
        }
        for (uint256 i = 0; i < roleLength; i++) {
            grantRole(_roles[i], _accounts[i]);   
        }
    }

    /**
     * @dev Helper for getting admin role from block explorers
     */
    function adminRole() external pure returns(bytes32 role_) {
        return ADMIN_ROLE;
    }

    /**
     * @dev Overrides to use custom error vs string building
     */
    function _checkRole(bytes32 role, address account) internal view override virtual {
        if (!hasRole(role, account)) {
            revert LibAccessControlRoles.MissingRole(account, role);
        }
    }

    /**
     * @dev Overrides AccessControlEnumerableUpgradeable and passes through to it.
     *  This is to have multiple inheritance overrides to be from this repo instead of OZ
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        virtual
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
