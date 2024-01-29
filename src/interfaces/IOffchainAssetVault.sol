// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @param asset The address of the asset to withdraw.
 * @param tokenId The token id of the asset to withdraw.
 * @param amount The amount of the asset to withdraw (for ERC20 and ERC1155s).
 * @param kind The kind of asset to withdraw. Used to avoid checking on-chain using supportsInterface.
 * @param to The address to send the asset to.
 * @param nonce The nonce of the withdrawal to prevent replay attacks.
 * @param isMint Whether or not the withdrawal is a mint vs a transfer.
 */
struct WithdrawArgs {
    // Slot 1 - address (uint160) + uint96
    address asset;
    uint96 tokenId;
    // Slot 2 - uint88 + enum (uint8) + address (uint160)
    uint88 amount;
    AssetKind kind;
    address to;
    // Slot 3
    uint248 nonce;
    bool isMint;
}

enum AssetKind {
    ERC20,
    ERC721,
    ERC1155
}

interface IOffchainAssetVault {
    error InvalidAuthoritySignature();
    error InvalidAssetKind();
    error NonceUsed(uint256 nonce);

    function OffchainAssetVault_init(bytes32 _orgId, uint64 _vaultId) external;
}
