// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGuildToken {
    /**
     * @dev Sets initial state of this facet. Must be called for contract to work properly
     * @param _organizationId The id of the organization that owns this guild collection
     * @param _systemDelegateApprover The contract that approves and records meta transaction delegates
     */
    function initialize(bytes32 _organizationId, address _systemDelegateApprover) external;

    /**
     * @dev Mints ERC1155 tokens to the given address. Only callable by a privileged address (i.e. GuildManager contract)
     * @param _to Recipient of the minted token
     * @param _id The tokenId of the token to mint
     * @param _amount The number of tokens to mint
     */
    function adminMint(address _to, uint256 _id, uint256 _amount) external;

    /**
     * @dev Burns ERC1155 tokens from the given address. Only callable by a privileged address (i.e. GuildManager contract)
     * @param _from The account to burn the tokens from
     * @param _id The tokenId of the token to burn
     * @param _amount The number of tokens to burn
     */
    function adminBurn(address _from, uint256 _id, uint256 _amount) external;

    /**
     * @dev Returns the manager address for this token contract
     */
    function guildManager() external view returns (address manager_);

    /**
     * @dev Returns the organization id for this token contract
     */
    function organizationId() external view returns (bytes32 organizationId_);
}
