// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";
import { InitializableStorage } from "@openzeppelin/contracts-diamond/proxy/utils/InitializableStorage.sol";
import { FacetInitializableStorage } from "./FacetInitializableStorage.sol";
import { LibUtilities } from "../libraries/LibUtilities.sol";

/**
 * @title Initializable using DiamondStorage pattern and supporting facet-specific initializers
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)
 */
abstract contract FacetInitializable {
    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     * Name changed to prevent collision with OZ contracts
     */
    modifier facetInitializer(bytes32 _facetId) {
        // Allow infinite constructor initializations to support multiple inheritance.
        // Otherwise, this contract/facet must not have been previously initialized.
        if (
            InitializableStorage.layout()._initializing
                ? !_isConstructor()
                : FacetInitializableStorage.getState()._initialized[_facetId]
        ) {
            revert FacetInitializableStorage.AlreadyInitialized(_facetId);
        }
        bool isTopLevelCall = !InitializableStorage.layout()._initializing;
        // Always set facet initialized regardless of if top level call or not.
        // This is so that we can run through facetReinitializable() if needed, and lower level functions can protect themselves
        FacetInitializableStorage.getState()._initialized[_facetId] = true;
        
        if (isTopLevelCall) {
            InitializableStorage.layout()._initializing = true;
        }

        _;

        if (isTopLevelCall) {
            InitializableStorage.layout()._initializing = false;
        }
    }

    /**
     * @dev Modifier to trick internal functions that use onlyInitializing / onlyFacetInitializing into thinking
     *  that the contract is being initialized.
     *  This should only be called via a diamond initialization script and makes a lot of assumptions.
     *  Handle with care.
     */
    modifier facetReinitializable() {
        InitializableStorage.layout()._initializing = true;
        _;
        InitializableStorage.layout()._initializing = false;
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyFacetInitializing() {
        require(InitializableStorage.layout()._initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}
