//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {IERC1155Upgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import {IERC1155Consumer} from "./interfaces/IERC1155Consumer.sol";
import {StakingStorage, ERC721TokenStorageData} from "./libraries/StakingStorage.sol";

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct WithdrawRequest {
    address tokenAddress;
    address reciever;
    uint256 tokenId;
    uint256 amount;
    uint256 nonce;
    bool stored;
    Signature signature;
}

contract StakingERC1155 is ERC1155HolderUpgradeable {
    event ERC1155Deposited(address _tokenAddress, address _depositor, address _reciever, uint256 _tokenId, uint256 _amount);
    event ERC1155Withdrawn(address _tokenAddress, address _reciever, uint256 _tokenId, uint256 _amount);

    function initialize() external initializer {
    }

    function depositERC1155(address _tokenAddress, address _reciever, uint256[] memory _tokenIds, uint256[] memory _quantities)
        public
    {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            //Require dey own it.
            require(
                IERC1155Upgradeable(_tokenAddress).balanceOf(msg.sender, _tokenIds[i]) == _quantities[i],
                "You don't own these tokens"
            );

            //Yoink it.
            IERC1155Upgradeable(_tokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenIds[i],
                _quantities[i],
                ""
            );

            //Store it.
            StakingStorage.setERC1155TokensStored(_tokenAddress, _tokenIds[i], _reciever, _quantities[i] + StakingStorage.getERC1155TokensStored(_tokenAddress, _tokenIds[i], _reciever));

            emit ERC1155Deposited(_tokenAddress, msg.sender, _reciever, _tokenIds[i], _quantities[i]);
        }
    }

    function verifyHash(
        bytes32 _hash,
        Signature calldata signature
    ) internal pure returns (address) {
        bytes32 messageDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
        );


        return ecrecover(messageDigest, signature.v, signature.r, signature.s);
    }


    function withdrawERC1155(
        WithdrawRequest[] calldata _withdrawRequests
    ) public {
        for (uint256 i = 0; i < _withdrawRequests.length; i++) {
            WithdrawRequest calldata _withdrawRequest = _withdrawRequests[i];
            address _tokenAddress = _withdrawRequest.tokenAddress;

            uint256 _ERC1155Stored = StakingStorage.getERC1155TokensStored(_tokenAddress, _withdrawRequest.tokenId, msg.sender);

            if (_withdrawRequest.stored) {
                //It's stored in the contract
                //Permissioned by chain

                require(
                    _ERC1155Stored >= _withdrawRequest.amount,
                    "You don't have a high enough balance of this erc1155."
                );

                //Store it.
                StakingStorage.setERC721TokenStorageData(_tokenAddress, _withdrawRequest.tokenId, ERC721TokenStorageData(
                    address(0),
                    false
                ));

                StakingStorage.setERC1155TokensStored(_tokenAddress, _withdrawRequest.tokenId, msg.sender, _ERC1155Stored - _withdrawRequest.amount);

                //Send it back.
                IERC1155Upgradeable(_tokenAddress).safeTransferFrom(
                    address(this),
                    _withdrawRequest.reciever,
                    _withdrawRequest.tokenId,
                    _withdrawRequest.amount,
                    ""
                );
                
                emit ERC1155Withdrawn( _tokenAddress,  _withdrawRequest.reciever, _withdrawRequest.tokenId, _withdrawRequest.amount);
            } else {
                //Not stored
                //Permissioned by admin

                //Compute that sig is correct
                //verifyHash returns the signer of this message.
                //message is a hash of three pieces of data: nonce, tokenAddress, tokenId, and the user.
                address _signer = verifyHash(keccak256(abi.encodePacked(_withdrawRequest.nonce, _withdrawRequest.tokenAddress, _withdrawRequest.tokenId, _withdrawRequest.amount, _withdrawRequest.reciever)), _withdrawRequest.signature);

                //Require they are a valid signer.
                require(IERC1155Consumer(_tokenAddress).isAdmin(_signer), "Not a valid signed message.");

                //Make sure they aren't using sig twice.
                require(!StakingStorage.getUsedNonce(_withdrawRequest.nonce), "Nonce already used.");

                //Store nonce as used.
                StakingStorage.setUsedNonce(_withdrawRequest.nonce, true);

                //Mint the token
                IERC1155Consumer(_tokenAddress).mintFromWorld(_withdrawRequest.reciever, _withdrawRequest.tokenId, _withdrawRequest.amount);

                emit ERC1155Withdrawn( _tokenAddress,  _withdrawRequest.reciever,  _withdrawRequest.tokenId, _withdrawRequest.amount);
            }
        }
    }
}