//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct TokenStorageData {
    address owner;
    bool stored;
}



library WorldStateStorage {

    struct State {
        mapping(address => mapping(uint256 => TokenStorageData)) collectionAddressToTokenIdToTokenStorageData;
        mapping(uint256 => bool) usedNonces;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("world.storage.diamond");

    function getState() internal pure returns (State storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function getTokenStorageData(address _collectionAddress, uint256 _tokenId) internal view returns (TokenStorageData memory) {
        return getState().collectionAddressToTokenIdToTokenStorageData[_collectionAddress][_tokenId];
    }

    function setTokenStorageData(address _collectionAddress, uint256 _tokenId, TokenStorageData memory _tokenStorageData) internal {
        getState().collectionAddressToTokenIdToTokenStorageData[_collectionAddress][_tokenId] = _tokenStorageData;
    }

    function getUsedNonce(uint256 _nonce) internal view returns(bool){
        return getState().usedNonces[_nonce];
    }  

    function setUsedNonce(uint256 _nonce, bool _set) internal{
        getState().usedNonces[_nonce] = _set;
    }  

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}

    

    