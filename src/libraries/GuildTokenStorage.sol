//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibBBase64} from "./LibBBase64.sol";
import {IGuildManager} from "src/interfaces/IGuildManager.sol";

library GuildTokenStorage {

    error GuildOrganizationAlreadyInitialized(uint32 organizationId);

    struct Layout {
        /**
         * @notice The manager that created this guild collection.
        */
        IGuildManager guildManager;
        /**
         * @notice The organization this 1155 collection is associated to.
        */
        uint32 organizationId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.guildtoken");

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    // =============================================================
    //                      State Helpers
    // =============================================================

    function getGuildManager() internal view returns (IGuildManager manager_) {
        manager_ = layout().guildManager;
    }

    function getOrganizationId() internal view returns (uint32 orgId_) {
        orgId_ = layout().organizationId;
    }

    function setGuildManager(address _guildManagerAddress) internal {
        layout().guildManager = IGuildManager(_guildManagerAddress);
    }

    function setOrganizationId(uint32 _orgId) internal {
        layout().organizationId = _orgId;
    }
    
    function uri(uint256 _tokenId) internal view returns(string memory) {
        Layout storage l = layout();
        uint32 _castedtokenId = uint32(_tokenId);
        // For our purposes, token id and guild id are the same.
        //
        require(l.guildManager.isValidGuild(l.organizationId, _castedtokenId), "Not valid guild");

        (string memory _imageData, bool _isSymbolOnChain) = l.guildManager.guildSymbolInfo(l.organizationId, _castedtokenId);

        string memory _finalImageData;

        if(_isSymbolOnChain) {
            _finalImageData = string(abi.encodePacked(
                "data:image/svg+xml;base64,",
                LibBBase64.encode(bytes(_drawSVG(_imageData)))
            ));
        } else {
            // Probably a URL. Just return it raw.
            //
            _finalImageData = _imageData;
        }

        string memory metadata = string(abi.encodePacked(
            '{"name": "',
            l.guildManager.guildName(l.organizationId, _castedtokenId),
            '", "description": "',
            l.guildManager.guildDescription(l.organizationId, _castedtokenId),
            '", "image": "',
            _finalImageData,
            '", "attributes": []}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            LibBBase64.encode(bytes(metadata))
        ));
    }

    // =============================================================
    //                          Private
    // =============================================================

    function _drawImage(string memory _data) private pure returns (string memory) {
        return string(abi.encodePacked(
            '<image x="0" y="0" width="64" height="64" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
            _data,
            '"/>'
        ));
    }

    function _drawSVG(string memory _data) private pure returns (string memory) {
        string memory svgString = string(abi.encodePacked(
            _drawImage(_data)
        ));

        return string(abi.encodePacked(
            '<svg id="imageRender" width="100%" height="100%" version="1.1" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
            svgString,
            "</svg>"
        ));
    }
}

    

    