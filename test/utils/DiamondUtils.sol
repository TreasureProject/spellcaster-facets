// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { IDiamondCut } from "src/diamond/IDiamondCut.sol";
import { Diamond } from "src/diamond/Diamond.sol";
import { DiamondCutFacet } from "src/diamond/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "src/diamond/DiamondLoupeFacet.sol";
import { AccessControlFacet } from "src/access/AccessControlFacet.sol";
import { OwnershipFacet } from "src/access/OwnershipFacet.sol";
import { PausableFacet } from "src/security/PausableFacet.sol";

library DiamondUtils {
    function grantRole(Diamond _diamond, string memory _roleName, address _addr) public {
        AccessControlFacet(address(_diamond)).grantRole(keccak256(abi.encodePacked(_roleName)), _addr);
    }

    function revokeRole(Diamond _diamond, string memory _roleName, address _addr) public {
        AccessControlFacet(address(_diamond)).revokeRole(keccak256(abi.encodePacked(_roleName)), _addr);
    }

    function hasRole(Diamond _diamond, string memory _roleName, address _addr) public view returns (bool) {
        return AccessControlFacet(address(_diamond)).hasRole(keccak256(abi.encodePacked(_roleName)), _addr);
    }

    function setPause(Diamond _diamond, bool _paused) internal {
        PausableFacet(address(_diamond)).setPause(_paused);
    }

    function paused(Diamond _diamond) internal view returns (bool) {
        return PausableFacet(address(_diamond)).paused();
    }
}
