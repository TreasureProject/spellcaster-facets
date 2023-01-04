//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Consumer is ERC1155, Ownable {
    address public worldAddress;

    mapping(address => bool) public isAdmin;

    constructor() ERC1155("uri") {}

    function setAdmin(address _address, bool _isAdmin) public onlyOwner {
        isAdmin[_address] = _isAdmin;
    }

    function setWorldAddress(address _worldAddress) public onlyOwner {
        worldAddress = _worldAddress;
    }

    function mintFromWorld(address _user, uint256 _tokenId, uint256 _quantity) public {
        require(msg.sender == worldAddress);
        _mint(_user, _tokenId, _quantity, "");
    }

    function mintArbitrary(address _user, uint256 _tokenId, uint256 _quantity) public {
        _mint(_user, _tokenId, _quantity, "");
    }
}
