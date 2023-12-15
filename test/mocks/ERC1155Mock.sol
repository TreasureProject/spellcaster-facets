// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/// @title ERC1155Mock
/// @dev ONLY FOR TESTS
contract ERC1155Mock is ERC1155 {
    constructor() ERC1155("www.example.come") { }

    /**
     * @dev Mint _amount of the _tokenId to _to.
     * @param _to The address that will receive the mint
     * @param _tokenId The tokenId to be minted
     * @param _amount The amount to be minted
     */
    function mint(address _to, uint256 _tokenId, uint256 _amount) external {
        _mint(_to, _tokenId, _amount, "");
    }

    /**
     * @dev needed to reference function selector as ERC1155Mock.safeTransferFrom.selector
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public virtual override {
        super.safeTransferFrom(_from, _to, _id, _amount, _data);
    }

    /**
     * @dev needed to reference function selector as ERC1155Mock.safeBatchTransferFrom.selector
     */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) public override {
        super.safeBatchTransferFrom(_from, _to, _ids, _amounts, _data);
    }

    /**
     * @dev needed to reference function selector as ERC1155Mock.setApprovalForAll.selector
     */
    function setApprovalForAll(address _operator, bool _approved) public virtual override {
        super.setApprovalForAll(_operator, _approved);
    }
}
