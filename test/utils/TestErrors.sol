// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract TestErrors {
    
    function error(bytes4 selector) internal pure returns (bytes memory) {
        address arg1;
        bytes32 arg2;
        return abi.encodeWithSelector(selector, arg1, arg2);
    }
}