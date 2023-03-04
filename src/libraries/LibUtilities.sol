// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PausableStorage} from "@openzeppelin/contracts-diamond/security/PausableStorage.sol";
import {StringsUpgradeable} from "@openzeppelin/contracts-diamond/utils/StringsUpgradeable.sol";
import {LibMeta} from "./LibMeta.sol";

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

    function setPause(bool _paused) internal {
        PausableStorage.layout()._paused = _paused;
        if(_paused) {
            emit Paused(LibMeta._msgSender());
        } else {
            emit Unpaused(LibMeta._msgSender());
        }
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

    function toString(uint256 _value) internal pure returns (string memory) {
        return StringsUpgradeable.toString(_value);
    }

  /**
   * @notice This function takes the first 4 MSB of the given bytes32 and converts them to a bytes4
   * @dev This function is useful for grabbing function selectors from calldata
   * @param inBytes The bytes to convert to bytes4
   */
  function convertBytesToBytes4(bytes memory inBytes) internal pure returns (bytes4 outBytes4) {
    if (inBytes.length == 0) {
      return 0x0;
    }

    assembly {
      outBytes4 := mload(add(inBytes, 32))
    }
  }
}
