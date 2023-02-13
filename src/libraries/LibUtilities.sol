// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PausableStorage} from "@openzeppelin/contracts-diamond/security/PausableStorage.sol";

library LibUtilities {
    event Paused(address _account);
    event Unpaused(address _account);
    
    error ArrayLengthMismatch(uint256 _len1, uint256 _len2);

    error IsPaused();
    error NotPaused();

    // =============================================================
    //                      Array Helpers
    // =============================================================

    function asSingletonArray(uint256 _item) internal pure returns (uint256[] memory array_) {
        array_ = new uint256[](1);
        array_[0] = _item;
    }

    function asSingletonArray(string memory _item) internal pure returns (string[] memory array_) {
        array_ = new string[](1);
        array_[0] = _item;
    }

    // =============================================================
    //                     Misc Functions
    // =============================================================

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function paused() internal view returns (bool) {
        return PausableStorage.layout()._paused;
    }

    function requirePaused() internal view {
        if(!paused()) {
            revert NotPaused();
        }
    }

    function requireNotPaused() internal view {
        if(paused()) {
            revert IsPaused();
        }
    }
}
