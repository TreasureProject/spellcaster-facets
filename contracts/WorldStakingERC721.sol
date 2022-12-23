//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./libraries/WorldStateStorage.sol";
import "./interfaces/IERC721Consumer.sol";
import "hardhat/console.sol";


struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct WithdrawRequest {
    address tokenAddress;
    address reciever;
    uint256 tokenId;
    uint256 nonce;
    bool stored;
    Signature signature;
}

contract WorldStakingERC721 {

    event ERC721Deposited(address _tokenAddress, address _depositor, address _reciever, uint256 _tokenId);
    event ERC721Withdrawn(address _tokenAddress, address _reciever, uint256 _tokenId);


    function depositERC721(address _tokenAddress, address _reciever, uint256[] memory _tokenIds)
        public
    {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            //Require dey own it.
            require(
                IERC721(_tokenAddress).ownerOf(_tokenIds[i]) == msg.sender,
                "You don't own these tokens"
            );

            //Yoink it.
            IERC721(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );

            //Store it.
            WorldStateStorage.setERC721TokenStorageData(_tokenAddress, _tokenIds[i], ERC721TokenStorageData(_reciever, true));

            emit ERC721Deposited(_tokenAddress, msg.sender, _reciever, _tokenIds[i]);
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


    function withdrawERC721(
        WithdrawRequest[] calldata _withdrawRequests
    ) public {
        for (uint256 i = 0; i < _withdrawRequests.length; i++) {
            WithdrawRequest calldata _withdrawRequest = _withdrawRequests[i];
            address _tokenAddress = _withdrawRequest.tokenAddress;

            ERC721TokenStorageData memory _ERC721TokenStorageData = WorldStateStorage.getERC721TokenStorageData(_tokenAddress, _withdrawRequest.tokenId);

            if (_withdrawRequest.stored) {
                //It's stored in the contract
                //Permissioned by chain

                require(
                    _ERC721TokenStorageData.owner == _withdrawRequest.reciever,
                    "You didn't store this ERC721."
                );

                //Store it.
                WorldStateStorage.setERC721TokenStorageData(_tokenAddress, _withdrawRequest.tokenId, ERC721TokenStorageData(
                    address(0),
                    false
                ));

                //Send it back.
                IERC721(_tokenAddress).transferFrom(
                    address(this),
                    _withdrawRequest.reciever,
                    _withdrawRequest.tokenId
                );
                
                emit ERC721Withdrawn( _tokenAddress,  _withdrawRequest.reciever,  _withdrawRequest.tokenId);
            } else {
                //Not stored
                //Permissioned by admin

                //Compute that sig is correct
                //verifyHash returns the signer of this message.
                //message is a hash of three pieces of data: nonce, tokenAddress, tokenId, and the user.
                address _signer = verifyHash(keccak256(abi.encodePacked(_withdrawRequest.nonce, _withdrawRequest.tokenAddress, _withdrawRequest.tokenId, _withdrawRequest.reciever)), _withdrawRequest.signature);

                //Require they are a valid signer.
                require(IERC721Consumer(_tokenAddress).isAdmin(_signer), "Not a valid signed message.");

                //Make sure they aren't using sig twice.
                require(!WorldStateStorage.getUsedNonce(_withdrawRequest.nonce), "Nonce already used.");

                //Store nonce as used.
                WorldStateStorage.setUsedNonce(_withdrawRequest.nonce, true);

                //Mint the token
                IERC721Consumer(_tokenAddress).mintFromWorld(_withdrawRequest.reciever, _withdrawRequest.tokenId);

                emit ERC721Withdrawn( _tokenAddress,  _withdrawRequest.reciever,  _withdrawRequest.tokenId);
            }
        }
    }
}