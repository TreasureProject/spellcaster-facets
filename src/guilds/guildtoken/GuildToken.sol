//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE} from "../../libraries/LibAccessControlRoles.sol";
import {LibMeta} from "../../libraries/LibMeta.sol";
import {LibUtilities} from "../../libraries/LibUtilities.sol";
import {GuildTokenContracts, GuildTokenStorage} from "./GuildTokenContracts.sol";

contract GuildToken is GuildTokenContracts {

    /**
     * @dev Sets all necessary state and permissions for the contract
     * @param _organizationId The organization that this 1155 collection belongs to
     */
    function initialize(uint32 _organizationId) external facetInitializer(keccak256("GuildManager")) {
        GuildTokenContracts.__GuildTokenContracts_init();
        GuildTokenStorage.setOrganizationId(_organizationId);
        // The guild manager is the one that creates the GuildToken.
        GuildTokenStorage.setGuildManager(msg.sender);

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

    /**
     * 
     * @param _to The wallet address that will receive this newly minted token
     * @param _id The token id to be minted
     * @param _amount The number of tokens of the given id to mint
     */
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

    /**
     * 
     * @param _account The wallet address that will burn the given token
     * @param _id The token id to be burned
     * @param _amount The number of tokens of the given id to burn
     */
    function adminBurn(
        address _account,
        uint256 _id,
        uint256 _amount)
    external
    onlyRole(ADMIN_ROLE)
    whenNotPaused {
        _burn(_account, _id, _amount);
    }

    function uri(uint256 _tokenId) public view override returns(string memory) {
        return GuildTokenStorage.uri(_tokenId);
    }

}