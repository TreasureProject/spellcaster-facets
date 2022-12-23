//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20Consumer{
    function mintFromWorld(address, uint256) external;
    function isAdmin(address) external view returns(bool);
}