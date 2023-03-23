// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { TestUtilities } from "./TestUtilities.sol";
import { TestErrors } from "./TestErrors.sol";
import { TestLogging } from "./TestLogging.sol";
import { TestMeta } from "./TestMeta.sol";

abstract contract TestBase is Test, TestUtilities, TestMeta, TestErrors, TestLogging {
    address internal leet = address(0x1337);
    address internal alice = address(0xa11ce);
    address internal deployer = address(this);

    bytes32 constant _org1 = keccak256("1");
    bytes32 constant _org2 = keccak256("2");
    uint32 constant _guild1 = 1;
    uint32 constant _guild2 = 2;

    constructor() {
        vm.label(leet, "L33T");
        vm.label(alice, "Alice");
        vm.label(deployer, "Deployer");
    }
}
