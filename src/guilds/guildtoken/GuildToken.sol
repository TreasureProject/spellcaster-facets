//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibBBase64} from "../../libraries/LibBBase64.sol";
import {LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE} from "../../libraries/LibAccessControlRoles.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";
import {LibUtilities} from "../../libraries/LibUtilities.sol";
import {GuildTokenContracts, IGuildManager} from "./GuildTokenContracts.sol";

contract GuildToken is GuildTokenContracts {

    /**
     * @dev Sets all necessary state and permissions for the contract
     * @param _organizationId The organization that this 1155 collection belongs to
     */
    function initialize(uint32 _organizationId) external facetInitializer(keccak256("GuildManager")) {
        GuildTokenContracts.__GuildTokenContracts_init();

        organizationId = _organizationId;
        // The guild manager is the one that creates the GuildToken.
        guildManager = IGuildManager(msg.sender);

        _setRoleAdmin(ADMIN_ROLE, ADMIN_GRANTER_ROLE);
        _grantRole(ADMIN_GRANTER_ROLE, LibMeta._msgSender());

        // Give admin to the owner. May be revoked to prevent permanent administrative rights as owner
        _grantRole(ADMIN_ROLE, LibMeta._msgSender());
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!LibUtilities.paused(), "GuildToken: Cannot transfer while paused");

        require(LibAccessControlRoles.hasRole(ADMIN_ROLE, msg.sender), "GuildToken: Only admin can transfer guild tokens");
    }

    function adminMint(
        address _to,
        uint256 _id,
        uint256 _amount)
    external
    onlyRole(ADMIN_ROLE)
    whenNotPaused
    {
        _mint(_to, _id, _amount, "");
    }

    function adminBurn(
        address _account,
        uint256 _id,
        uint256 _amount)
    external
    onlyRole(ADMIN_ROLE)
    whenNotPaused {
        _burn(_account, _id, _amount);
    }

    function uri(
        uint256 _tokenId)
    public
    view
    override
    returns(string memory)
    {
        uint32 _castedtokenId = uint32(_tokenId);
        // For our purposes, token id and guild id are the same.
        //
        require(guildManager.isValidGuild(organizationId, _castedtokenId), "Not valid guild");

        (string memory _imageData, bool _isSymbolOnChain) = guildManager.guildSymbolInfo(organizationId, _castedtokenId);

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
            guildManager.guildName(organizationId, _castedtokenId),
            '", "description": "',
            guildManager.guildDescription(organizationId, _castedtokenId),
            '", "image": "',
            _finalImageData,
            '", "attributes": []}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            LibBBase64.encode(bytes(metadata))
        ));
    }

     function _drawImage(string memory _data) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<image x="0" y="0" width="64" height="64" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
            _data,
            '"/>'
        ));
    }

    function _drawSVG(string memory _data) internal pure returns (string memory) {
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