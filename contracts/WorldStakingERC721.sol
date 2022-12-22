//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/INFTConsumer.sol";
import "hardhat/console.sol";

struct TokenStorageData {
    address owner;
    bool stored;
}

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct WithdrawRequest {
    address collectionAddress;
    address reciever;
    uint256 tokenId;
    uint256 nonce;
    bool stored;
    Signature signature;
}

contract WorldStakingERC721 {
    mapping(address => mapping(uint256 => TokenStorageData))
        public collectionAddressToTokenIdToTokenStorageData;

    mapping(uint256 => bool) usedNonces;

    event NFTDeposited(address _collectionAddress, address _depositor,address _reciever, uint256 _tokenId);
    event NFTWithdrawn(address _collectionAddress, address _reciever, uint256 _tokenId);


    function depositNFTs(address _collectionAddress, address _reciever, uint256[] memory _tokenIds)
        public
    {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            //Require dey own it.
            require(
                IERC721(_collectionAddress).ownerOf(_tokenIds[i]) == msg.sender,
                "You don't own these tokens"
            );

            //Yoink it.
            IERC721(_collectionAddress).transferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );

            //Store it.
            collectionAddressToTokenIdToTokenStorageData[_collectionAddress][
                _tokenIds[i]
            ] = TokenStorageData(_reciever, true);

            emit NFTDeposited(_collectionAddress, msg.sender, _reciever, _tokenIds[i]);
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


    function withdrawNFTs(
        WithdrawRequest[] calldata _withdrawRequests
    ) public {
        for (uint256 i = 0; i < _withdrawRequests.length; i++) {
            WithdrawRequest calldata _withdrawRequest = _withdrawRequests[i];
            address _collectionAddress = _withdrawRequest.collectionAddress;

            if (_withdrawRequest.stored) {
                //It's stored in the contract
                //Permissioned by chain

                require(
                    collectionAddressToTokenIdToTokenStorageData[
                        _collectionAddress
                    ][_withdrawRequest.tokenId].owner == _withdrawRequest.reciever,
                    "You didn't store this NFT."
                );

                //Send it back.
                IERC721(_collectionAddress).transferFrom(
                    address(this),
                    _withdrawRequest.reciever,
                    _withdrawRequest.tokenId
                );

                //Remove it.
                collectionAddressToTokenIdToTokenStorageData[
                    _collectionAddress
                ][_withdrawRequest.tokenId] = TokenStorageData(
                    address(0),
                    false
                );
                
                emit NFTWithdrawn( _collectionAddress,  _withdrawRequest.reciever,  _withdrawRequest.tokenId);
            } else {
                //Not stored
                //Permissioned by admin

                //Compute that sig is correct
                //verifyHash returns the signer of this message.
                //message is a hash of three pieces of data: nonce, collectionAddress, tokenId, and the user.
                address _signer = verifyHash(keccak256(abi.encodePacked(_withdrawRequest.nonce, _withdrawRequest.collectionAddress, _withdrawRequest.tokenId, _withdrawRequest.reciever)), _withdrawRequest.signature);

                //Require they are a valid signer.
                require(INFTConsumer(_collectionAddress).isAdmin(_signer), "Not a valid signed message.");

                //Make sure they aren't using sig twice.
                require(!usedNonces[_withdrawRequest.nonce], "Nonce already used.");

                //Store nonce as used.
                usedNonces[_withdrawRequest.nonce] = true;

                //Mint the token
                INFTConsumer(_collectionAddress).mintFromWorld(_withdrawRequest.reciever, _withdrawRequest.tokenId);

                emit NFTWithdrawn( _collectionAddress,  _withdrawRequest.reciever,  _withdrawRequest.tokenId);
            }
        }
    }
}