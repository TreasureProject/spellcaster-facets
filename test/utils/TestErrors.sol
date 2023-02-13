// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {FacetInitializableStorage} from "../../src/utils/FacetInitializableStorage.sol";

abstract contract TestErrors {
    
    function error(bytes4 selector) internal pure returns (bytes memory) {
        address arg1;
        bytes32 arg2;
        return abi.encodeWithSelector(selector, arg1, arg2);
    }
    
    function errorAlreadyInitialized(string memory _facetName) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(FacetInitializableStorage.AlreadyInitialized.selector, keccak256(abi.encodePacked(_facetName)));
    }
}