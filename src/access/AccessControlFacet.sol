// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-diamond/access/AccessControlEnumerableUpgradeable.sol"; 
import {LibUtilities} from "../libraries/LibUtilities.sol";
import {ADMIN_ROLE} from "../libraries/LibAccessControlRoles.sol";

contract AccessControlFacet is AccessControlEnumerableUpgradeable {

    function __AccessControlFacet_init() external initializer {
        __AccessControlEnumerable_init();
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
    function adminRole() public pure returns(bytes32 role_) {
        return ADMIN_ROLE;
    }

    /**
     * @dev Overrides AccessControlEnumerableUpgradeable and passes through to it.
     *  This is to have multiple inheritance overrides to be from this repo instead of OZ
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
