// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {FacetInitializableStorage} from "../../src/utils/FacetInitializableStorage.sol";
import {LibAccessControlRoles} from "../../src/libraries/LibAccessControlRoles.sol";

abstract contract TestErrors {
    
    function err(bytes4 selector) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(selector);
    }
    
    function err(bytes4 selector, address arg1) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, arg1);
    }
    
    function err(bytes4 selector, uint256 arg1) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, arg1);
    }
    
    function err(bytes4 selector, address arg1, bytes memory arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, arg1, arg2);
    }
    
    function err(bytes4 selector, uint256 arg1, address arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, arg1, arg2);
    }
    
    function err(bytes4 selector, bytes32 arg1, address arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, arg1, arg2);
    }
    
    function err(bytes4 selector, uint256 arg1, uint256 arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, arg1, arg2);
    }
    
    function err(bytes4 selector, uint256 arg1, uint256 arg2, address arg3) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, arg1, arg2, arg3);
    }
    
    function errAlreadyInitialized(string memory _facetName) internal pure returns (bytes memory) {
        bytes32 nameBytes = keccak256(abi.encodePacked(_facetName));
        return abi.encodeWithSelector(FacetInitializableStorage.AlreadyInitialized.selector, nameBytes);
    }
    
    function errMissingRole(string memory _roleName, address _sender) internal pure returns (bytes memory) {
        bytes32 roleBytes = keccak256(abi.encodePacked(_roleName));
        return abi.encodeWithSelector(LibAccessControlRoles.MissingRole.selector, _sender, roleBytes);
    }

}