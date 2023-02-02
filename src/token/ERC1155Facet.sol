// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1155Upgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/ERC1155Upgradeable.sol";

contract ERC1155Facet is ERC1155Upgradeable {

    function __ERC1155Facet_init(string memory uri_) public initializer {
        ERC1155Upgradeable.__ERC1155_init(uri_);
    }

    // =============================================================
    //                        Override functions
    // =============================================================

    /**
     * @dev Overrides ERC1155Ugradeable and passes through to it.
     *  This is to have multiple inheritance overrides to be from this repo instead of OZ
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
