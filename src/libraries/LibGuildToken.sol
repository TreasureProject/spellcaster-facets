// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibBBase64 } from "./LibBBase64.sol";
import { GuildTokenStorage } from "src/guilds/guildtoken/GuildTokenStorage.sol";
import { IGuildManager } from "src/interfaces/IGuildManager.sol";

/**
 * @title Guild Manager Library
 * @dev This library is used to implement features that use/update storage data for the Guild Manager contracts
 */
library LibGuildToken {
    // =============================================================
    //                      State Helpers
    // =============================================================

    function getGuildManager() internal view returns (IGuildManager manager_) {
        manager_ = GuildTokenStorage.layout().guildManager;
    }

    function getOrganizationId() internal view returns (bytes32 orgId_) {
        orgId_ = GuildTokenStorage.layout().organizationId;
    }

    function setGuildManager(address _guildManagerAddress) internal {
        GuildTokenStorage.layout().guildManager = IGuildManager(_guildManagerAddress);
    }

    function setOrganizationId(bytes32 _orgId) internal {
        GuildTokenStorage.layout().organizationId = _orgId;
    }

    function uri(uint256 _tokenId) internal view returns (string memory) {
        GuildTokenStorage.Layout storage _l = GuildTokenStorage.layout();
        uint32 _castedtokenId = uint32(_tokenId);
        // For our purposes, token id and guild id are the same.
        //
        require(_l.guildManager.isValidGuild(_l.organizationId, _castedtokenId), "Not valid guild");

        (string memory _imageData, bool _isSymbolOnChain) =
            _l.guildManager.guildSymbolInfo(_l.organizationId, _castedtokenId);

        string memory _finalImageData;

        if (_isSymbolOnChain) {
            _finalImageData =
                string(abi.encodePacked("data:image/svg+xml;base64,", LibBBase64.encode(bytes(_drawSVG(_imageData)))));
        } else {
            // Probably a URL. Just return it raw.
            //
            _finalImageData = _imageData;
        }
        // solhint-disable quotes
        string memory _metadata = string(
            abi.encodePacked(
                '{"name": "',
                _l.guildManager.guildName(_l.organizationId, _castedtokenId),
                '", "description": "',
                _l.guildManager.guildDescription(_l.organizationId, _castedtokenId),
                '", "image": "',
                _finalImageData,
                '", "attributes": []}'
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", LibBBase64.encode(bytes(_metadata))));
    }

    // =============================================================
    //                          Private
    // =============================================================

    function _drawImage(string memory _data) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<image x="0" y="0" width="64" height="64" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                _data,
                '"/>'
            )
        );
    }

    function _drawSVG(string memory _data) private pure returns (string memory) {
        string memory _svgString = string(abi.encodePacked(_drawImage(_data)));

        return string(
            abi.encodePacked(
                '<svg id="imageRender" width="100%" height="100%" version="1.1" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                _svgString,
                "</svg>"
            )
        );
    }
}
