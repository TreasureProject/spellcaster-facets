// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FacetInitializableStorage} from "../utils/FacetInitializableStorage.sol";

/**
 * @title Contract to check Facet initialization state 
 * @dev Only Facets using the FacetInitializable contract will be tracked here
 */
contract InitializedFacet {

    function isInitialized(bytes32 _facetId) public view returns (bool isInitialized_) {
        return FacetInitializableStorage.isInitialized(_facetId);
    }
}
