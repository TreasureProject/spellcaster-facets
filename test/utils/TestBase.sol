// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ECDSAUpgradeable} from "@openzeppelin/contracts-diamond/utils/cryptography/ECDSAUpgradeable.sol";
import {Test} from "forge-std/Test.sol";
import {TestUtilities} from "./TestUtilities.sol";
import {TestErrors} from "./TestErrors.sol";
import {TestLogging} from "./TestLogging.sol";

abstract contract TestBase is Test, TestUtilities, TestErrors, TestLogging {
    address internal leet = address(0x1337);
    address internal alice = address(0xa11ce);
    address internal deployer = address(this);

    constructor() {
        vm.label(leet, "L33T");
        vm.label(alice, "Alice");
        vm.label(deployer, "Deployer");
    }

    function signHash(uint256 privateKey, bytes32 digest) internal pure returns(bytes memory bytes_) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        // convert curve to sig bytes for using with ECDSA vs ecrecover
        bytes_ = abi.encodePacked(r, s, v);
    }

    function signHashVRS(uint256 privateKey, bytes32 digest) internal pure returns(uint8 v, bytes32 r, bytes32 s) {
        (v, r, s) = vm.sign(privateKey, digest);
    }

    function signHashEth(uint256 privateKey, bytes32 digest) internal pure returns(bytes memory bytes_) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, ECDSAUpgradeable.toEthSignedMessageHash(digest));
        // convert curve to sig bytes for using with ECDSA vs ecrecover
        bytes_ = abi.encodePacked(r, s, v);
    }

    function signHashEthVRS(uint256 privateKey, bytes32 digest) internal pure returns(uint8 v, bytes32 r, bytes32 s) {
        (v, r, s) = vm.sign(privateKey, ECDSAUpgradeable.toEthSignedMessageHash(digest));
    }
}