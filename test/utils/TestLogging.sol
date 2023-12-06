// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// solhint-disable no-console
import { console2 } from "forge-std/console2.sol";

abstract contract TestLogging {
    function debug(uint256 _p0) internal pure {
        console2.log(_p0);
    }

    function debug(bytes4 _p0) internal pure {
        console2.logBytes4(_p0);
    }

    function debug(string memory _p0) internal pure {
        console2.log(_p0);
    }

    function debug(bool _p0) internal pure {
        console2.log(_p0);
    }

    function debug(string memory _label, bool _p0) internal pure {
        console2.log(_label, _p0);
    }

    function debug(address _p0) internal pure {
        console2.log(_p0);
    }

    function debug(string memory _label, address _p0) internal pure {
        console2.log(_label, _p0);
    }

    function debug(int256 _p0) internal pure {
        console2.logInt(_p0);
    }

    function debugBytes(bytes memory _p0) internal pure {
        console2.logBytes(_p0);
    }

    function debugBytes32(bytes32 _p0) internal pure {
        console2.logBytes32(_p0);
    }
}
