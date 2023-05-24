//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/ERC20Upgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-diamond/access/OwnableUpgradeable.sol";

contract ERC20Consumer is ERC20Upgradeable, OwnableUpgradeable {
    address public worldAddress;

    mapping(address => bool) public isAdmin;

    // constructor() ERC20Upgradeable("ERC20Consumer", "ERC20C") {}
    function initialize() public initializer {
        __ERC20_init("name", "symbol");
        __Ownable_init();
    }

    function setAdmin(address _address, bool _isAdmin) public onlyOwner {
        isAdmin[_address] = _isAdmin;
    }

    function setWorldAddress(address _worldAddress) public onlyOwner {
        worldAddress = _worldAddress;
    }

    function mintFromWorld(address _user, uint256 _tokenId) public {
        require(msg.sender == worldAddress, "Sender not world");
        _mint(_user, _tokenId);
    }

    function mintArbitrary(address _user, uint256 _quantity) public {
        _mint(_user, _quantity);
    }
}
