//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

struct TokenStorageData {
    address owner;
    bool stored;
}

struct WithdrawRequest {
    bytes32 signature;
    uint256 tokenId;
    bool stored;
}

contract World {
    mapping(address => mapping(uint256 => TokenStorageData))
        public collectionAddressToTokenIdToTokenStorageData;

    function depositNFTs(address _collectionAddress, uint256[] memory _tokenIds)
        public
    {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            //Require dey own it.
            require(
                IERC721(_collectionAddress).ownerOf(_tokenIds[i]) == msg.sender,
                "You don't own these tokens"
            );

            //Yoink it.
            IERC721(_collectionAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );

            //Store it.
            collectionAddressToTokenIdToTokenStorageData[_collectionAddress][
                _tokenIds[i]
            ] = TokenStorageData(msg.sender, true);
        }
    }

    function withdrawNFTs(
        address _collectionAddress,
        WithdrawRequest[] calldata _withdrawRequests
    ) public {
        for (uint256 i = 0; i < _withdrawRequests.length; i++) {
            WithdrawRequest calldata _withdrawRequest = _withdrawRequests[i];

            if (_withdrawRequest.stored) {
                //It's stored in the contract

                require(
                    collectionAddressToTokenIdToTokenStorageData[
                        _collectionAddress
                    ][_withdrawRequest.tokenId].owner == msg.sender,
                    "You didn't store this NFT."
                );

                //Send it back.
                IERC721(_collectionAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    _withdrawRequest.tokenId
                );

                //Remove it.
                collectionAddressToTokenIdToTokenStorageData[
                    _collectionAddress
                ][_withdrawRequest.tokenId] = TokenStorageData(
                    address(0),
                    false
                );
            } else {
                //Compute that sig is correct
                //verifySig()
                //Store that the sig has been used
                //isUsed[sig] = true
                //Mint the token
                //IMinter(_collectionAddress).mint(_withdrawRequest.tokenId);
            }
        }
    }
}
