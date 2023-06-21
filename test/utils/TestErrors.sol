// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { FacetInitializableStorage } from "../../src/utils/FacetInitializableStorage.sol";
import { LibAccessControlRoles } from "../../src/libraries/LibAccessControlRoles.sol";

abstract contract TestErrors {
    function err(bytes4 _selector) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector);
    }

    function err(bytes4 _selector, address _arg1) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1);
    }

    function err(bytes4 _selector, uint256 _arg1) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1);
    }

    function err(bytes4 _selector, bytes32 _arg1) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1);
    }

    function err(bytes4 _selector, address _arg1, address _arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2);
    }

    function err(bytes4 _selector, address _arg1, bytes memory _arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2);
    }

    function err(bytes4 _selector, address _arg1, uint256 _arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2);
    }

    function err(bytes4 _selector, uint256 _arg1, address _arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2);
    }

    function err(bytes4 _selector, bytes32 _arg1, address _arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2);
    }

    function err(bytes4 _selector, bytes32 _arg1, bytes32 _arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2);
    }

    function err(bytes4 _selector, uint256 _arg1, uint256 _arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2);
    }

    function err(bytes4 _selector, bytes32 _arg1, uint256 _arg2) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2);
    }

    function err(bytes4 _selector, uint256 _arg1, uint256 _arg2, address _arg3) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2, _arg3);
    }

    function err(bytes4 _selector, address _arg1, bytes32 _arg2, uint256 _arg3) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2, _arg3);
    }

    function err(bytes4 _selector, bytes32 _arg1, uint256 _arg2, address _arg3) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(_selector, _arg1, _arg2, _arg3);
    }

    function errAlreadyInitialized(string memory _facetName) internal pure returns (bytes memory) {
        bytes32 _nameBytes = keccak256(abi.encodePacked(_facetName));
        return abi.encodeWithSelector(FacetInitializableStorage.AlreadyInitialized.selector, _nameBytes);
    }

    function errMissingRole(string memory _roleName, address _sender) internal pure returns (bytes memory) {
        bytes32 _roleBytes = keccak256(abi.encodePacked(_roleName));
        return abi.encodeWithSelector(LibAccessControlRoles.MissingRole.selector, _sender, _roleBytes);
    }
}
