//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct ERC721TokenStorageData {
    address owner;
    bool stored;
}




library WorldStateStorage {

    struct State {
        mapping(address => mapping(uint256 => ERC721TokenStorageData)) tokenAddressToTokenIdToERC721TokenStorageData;
        mapping(address => mapping(address => uint256)) tokenAddressToAddressToTokensStored;
        mapping(address => mapping(uint256 => mapping(address => uint256))) tokenAddressToTokenIdToUserToQuantityStored;
        mapping(uint256 => bool) usedNonces;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("world.storage.diamond");

    function getState() internal pure returns (State storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function getERC721TokenStorageData(address _tokenAddress, uint256 _tokenId) internal view returns (ERC721TokenStorageData memory) {
        return getState().tokenAddressToTokenIdToERC721TokenStorageData[_tokenAddress][_tokenId];
    }

    function setERC721TokenStorageData(address _tokenAddress, uint256 _tokenId, ERC721TokenStorageData memory _tokenStorageData) internal {
        getState().tokenAddressToTokenIdToERC721TokenStorageData[_tokenAddress][_tokenId] = _tokenStorageData;
    }

    function getERC20TokensStored(address _tokenAddress, address _user) internal view returns (uint256) {
        return getState().tokenAddressToAddressToTokensStored[_tokenAddress][_user];
    }

    function setERC20TokensStored(address _tokenAddress, address _user, uint256 _amount) internal {
        getState().tokenAddressToAddressToTokensStored[_tokenAddress][_user] = _amount;
    }

    function getERC1155TokensStored(address _tokenAddress, uint256 _tokenId, address _user) internal view returns (uint256) {
        return getState().tokenAddressToTokenIdToUserToQuantityStored[_tokenAddress][_tokenId][_user];
    }

    function setERC1155TokensStored(address _tokenAddress, uint256 _tokenId, address _user, uint256 _quantity) internal {
        getState().tokenAddressToTokenIdToUserToQuantityStored[_tokenAddress][_tokenId][_user] = _quantity;
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

    

    