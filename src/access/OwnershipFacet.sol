// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../diamond/LibDiamond.sol";
import { IERC173Upgradeable } from "@openzeppelin/contracts-diamond/interfaces/IERC173Upgradeable.sol";

contract OwnershipFacet is IERC173Upgradeable {
    function transferOwnership(address _newOwner) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.setContractOwner(_newOwner);
    }

    function owner() external view override returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }
}
