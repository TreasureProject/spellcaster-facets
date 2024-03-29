//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721EnumerableUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import { IERC721Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-diamond/access/OwnableUpgradeable.sol";

contract ERC721Consumer is ERC721EnumerableUpgradeable, OwnableUpgradeable {
    uint256 internal counter;
    address public worldAddress;

    mapping(address => bool) public isAdmin;

    // constructor() ERC721Upgradeable("ERC721Consumer", "ERC721C") {}
    function initialize() public initializer {
        __ERC721_init("name", "symbol");
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
        for (uint256 i = counter; i < counter + _quantity; i++) {
            _mint(_user, counter + i);
        }
        counter += _quantity;
    }

    function walletOfOwner(address _user) public view returns (uint256[] memory) {
        uint256 _tokenCount = balanceOf(_user);
        uint256[] memory _tokens = new uint256[](_tokenCount);

        for (uint256 i = 0; i < _tokenCount; i++) {
            _tokens[i] = tokenOfOwnerByIndex(_user, i);
        }

        return _tokens;
    }
}
