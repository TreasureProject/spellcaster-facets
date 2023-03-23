// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PausableStorage } from "@openzeppelin/contracts-diamond/security/PausableStorage.sol";
import { LibUtilities } from "./libraries/LibUtilities.sol";
import { LibMeta } from "./libraries/LibMeta.sol";
import { LibAccessControlRoles } from "./libraries/LibAccessControlRoles.sol";

// abstract contract to include shared utility modifiers for ease of use
// also includes modifiers imported from PausableUpgradeable
/// @title Abstract contract to include shared utility across all facets.
/// @dev Modifiers can't go in a library so this is where they should go, also includes meta-tx helpers
abstract contract Modifiers {
    // =============================================================
    //                         Modifiers
    // =============================================================

    /// @dev Pass-through to Openzeppelin's AccessControl onlyRole. Changed name to avoid name conflicts
    /// @param _role Role to be verified against the sender
    modifier onlyRole(bytes32 _role) {
        LibAccessControlRoles.requireRole(_role, LibMeta._msgSender());
        _;
    }

    /// @notice Returns whether or not the sender has at least one of the provided roles
    /// @param _roleOption1 Role to be verified against the sender
    /// @param _roleOption2 Role to be verified against the sender
    modifier requireEitherRole(bytes32 _roleOption1, bytes32 _roleOption2) {
        if (!_hasRole(_roleOption1, LibMeta._msgSender()) && !_hasRole(_roleOption2, LibMeta._msgSender())) {
            revert LibAccessControlRoles.MissingEitherRole(LibMeta._msgSender(), _roleOption1, _roleOption2);
        }
        _;
    }

    modifier whenNotPaused() {
        LibUtilities.requireNotPaused();
        _;
    }

    modifier whenPaused() {
        LibUtilities.requirePaused();
        _;
    }

    // =============================================================
    //                      Utility functions
    // =============================================================

    // Taken from AccessControlUpgradeable, and renamed to avoid conflicts with any contract importing AccessControlUpgradeable
    // Purposefully not importing the entire contract to avoid bloating this base contract.
    // If this changes in AccessControlUpgradeable, it would be a breaking change and contracts using this wouldn't be able to update anyway.
    function _hasRole(bytes32 _role, address _account) internal view returns (bool) {
        return LibAccessControlRoles.hasRole(_role, _account);
    }

    function _pause() internal whenNotPaused {
        PausableStorage.layout()._paused = true;
        emit LibUtilities.Paused(LibMeta._msgSender());
    }

    function _unpause() internal whenPaused {
        PausableStorage.layout()._paused = false;
        emit LibUtilities.Unpaused(LibMeta._msgSender());
    }
}
