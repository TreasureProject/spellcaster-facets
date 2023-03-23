// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC1155Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC1155/ERC1155Upgradeable.sol";
import { FacetInitializable } from "../utils/FacetInitializable.sol";
import { SupportsMetaTx } from "src/metatx/SupportsMetaTx.sol";

/**
 * @title ERC1155 facet wrapper for OZ's pausable contract.
 * @dev Use/inherit this facet to limit the spread of third-party dependency references and allow new functionality to be shared
 */
abstract contract ERC1155Facet is FacetInitializable, SupportsMetaTx, ERC1155Upgradeable {
    function __ERC1155Facet_init(string memory uri_) internal onlyFacetInitializing {
        ERC1155Upgradeable.__ERC1155_init(uri_);
    }

    // =============================================================
    //                        Override functions
    // =============================================================

    /**
     * @dev Overrides ERC1155Ugradeable and passes through to it.
     *  This is to have multiple inheritance overrides to be from this repo instead of OZ
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Adding support for meta transactions
     */
    function setApprovalForAll(address operator, bool approved) public virtual override supportsMetaTxNoId {
        super.setApprovalForAll(operator, approved);
    }

    /**
     * @dev Adding support for meta transactions
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override supportsMetaTxNoId {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Adding support for meta transactions
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override supportsMetaTxNoId {
        super.safeTransferFrom(from, to, id, amount, data);
    }
}
