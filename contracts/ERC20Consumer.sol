//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Consumer is ERC20, Ownable {
    address public worldAddress;

    mapping(address => bool) public isAdmin;

    constructor() ERC20("ERC20Consumer", "ERC20C") {}

    function setAdmin(address _address, bool _isAdmin) public onlyOwner {
        isAdmin[_address] = _isAdmin;
    }

    function setWorldAddress(address _worldAddress) public onlyOwner {
        worldAddress = _worldAddress;
    }

    function mintFromWorld(address _user, uint256 _tokenId) public {
        require(msg.sender == worldAddress);
        _mint(_user, _tokenId);
    }

    function mintArbitrary(address _user, uint256 _quantity) public {
        _mint(_user, _quantity);
    }

}
