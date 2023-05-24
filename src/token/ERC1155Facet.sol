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
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    /**
     * @dev Adding support for meta transactions
     */
    function setApprovalForAll(address _operator, bool _approved) public virtual override supportsMetaTxNoId {
        super.setApprovalForAll(_operator, _approved);
    }

    /**
     * @dev Adding support for meta transactions
     */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) public virtual override supportsMetaTxNoId {
        super.safeBatchTransferFrom(_from, _to, _ids, _amounts, _data);
    }

    /**
     * @dev Adding support for meta transactions
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public virtual override supportsMetaTxNoId {
        super.safeTransferFrom(_from, _to, _id, _amount, _data);
    }
}
