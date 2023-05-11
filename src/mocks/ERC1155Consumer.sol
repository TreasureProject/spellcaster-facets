//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC1155Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC1155/ERC1155Upgradeable.sol";
import { IERC1155Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-diamond/access/OwnableUpgradeable.sol";

contract ERC1155Consumer is ERC1155Upgradeable, OwnableUpgradeable {
    address public worldAddress;

    mapping(address => bool) public isAdmin;

    // constructor() ERC1155Upgradeable("uri") {}

    function initialize() public initializer {
        __ERC1155_init("uri");
        __Ownable_init();
    }

    function setAdmin(address _address, bool _isAdmin) public onlyOwner {
        isAdmin[_address] = _isAdmin;
    }

    function setWorldAddress(address _worldAddress) public onlyOwner {
        worldAddress = _worldAddress;
    }

    function mintFromWorld(address _user, uint256 _tokenId, uint256 _quantity) public {
        require(msg.sender == worldAddress, "Sender not world");
        _mint(_user, _tokenId, _quantity, "");
    }

    function mintArbitrary(address _user, uint256 _tokenId, uint256 _quantity) public {
        _mint(_user, _tokenId, _quantity, "");
    }
}
