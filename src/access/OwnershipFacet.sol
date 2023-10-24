// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../diamond/LibDiamond.sol";
import { IERC5313Upgradeable } from "@openzeppelin/contracts-diamond/interfaces/IERC5313Upgradeable.sol";

contract OwnershipFacet is IERC5313Upgradeable {
    function transferOwnership(address _newOwner) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.setContractOwner(_newOwner);
    }

    function owner() external view override returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }
}
