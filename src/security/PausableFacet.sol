// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-diamond/proxy/utils/Initializable.sol";
import {PausableStorage} from "@openzeppelin/contracts-diamond/security/PausableStorage.sol";
import {FacetInitializable} from "../utils/FacetInitializable.sol";

import {ADMIN_ROLE} from "../libraries/LibAccessControlRoles.sol";
import {Modifiers} from "../Modifiers.sol";

/**
 * @title Pausable facet wrapper for OZ's pausable contract.
 * @dev Using this facet ensures that contracts that depend on pausability can reference the internal functions via Modifiers.sol
 * @notice Exposes the paused() function for the diamond
 */
contract PausableFacet is FacetInitializable, Modifiers {

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return PausableStorage.layout()._paused;
    }

    function setPause(bool _shouldPause) external onlyRole(ADMIN_ROLE) {
        if(_shouldPause) {
            _pause();
        } else {
            _unpause();
        }
    }
}
