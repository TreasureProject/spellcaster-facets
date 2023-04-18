//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE } from "src/libraries/LibAccessControlRoles.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { LibUtilities } from "src/libraries/LibUtilities.sol";
import { GuildTokenContracts, LibGuildToken, IGuildToken } from "./GuildTokenContracts.sol";

contract GuildToken is GuildTokenContracts {
    /**
     * @inheritdoc IGuildToken
     */
    function initialize(
        bytes32 _organizationId
    ) external facetInitializer(keccak256("initialize")) {
        GuildTokenContracts.__GuildTokenContracts_init();
        LibGuildToken.setOrganizationId(_organizationId);
        // The guild manager is the one that creates the GuildToken.
        LibGuildToken.setGuildManager(LibMeta._msgSender());

        _setRoleAdmin(ADMIN_ROLE, ADMIN_GRANTER_ROLE);
        _grantRole(ADMIN_GRANTER_ROLE, LibMeta._msgSender());

        // Give admin to the owner. May be revoked to prevent permanent administrative rights as owner
        _grantRole(ADMIN_ROLE, LibMeta._msgSender());
    }

    /**
     * @inheritdoc IGuildToken
     */
    function adminMint(
        address _to,
        uint256 _id,
        uint256 _amount
    ) external onlyRole(ADMIN_ROLE) whenNotPaused {
        _mint(_to, _id, _amount, "");
    }

    /**
     * @inheritdoc IGuildToken
     */
    function adminBurn(
        address _account,
        uint256 _id,
        uint256 _amount
    ) external onlyRole(ADMIN_ROLE) whenNotPaused {
        _burn(_account, _id, _amount);
    }

    /**
     * @inheritdoc IGuildToken
     */
    function guildManager() external view returns (address manager_) {
        manager_ = address(LibGuildToken.getGuildManager());
    }

    /**
     * @inheritdoc IGuildToken
     */
    function organizationId() external view returns (bytes32 organizationId_) {
        organizationId_ = LibGuildToken.getOrganizationId();
    }

    /**
     * @dev Returns the URI for a given token ID
     * @param _tokenId The id of the token to query
     * @return URI of the given token
     */
    function uri(uint256 _tokenId) public view override returns (string memory) {
        return LibGuildToken.uri(_tokenId);
    }

    /**
     * @dev Adds the following restrictions to transferring guild tokens:
     * - Only token admins can transfer guild tokens
     * - Guild tokens cannot be transferred while the contract is paused
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        LibUtilities.requireNotPaused();
        LibAccessControlRoles.requireRole(ADMIN_ROLE, LibMeta._msgSender());
    }
}
