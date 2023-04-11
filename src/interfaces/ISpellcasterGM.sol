// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @dev Struct that defines a collection role grant request
 * @param collection the address this role belongs to
 * @param nonce the nonce being used by this signer
 * @param receiver who the role is going to
 * @param role the role to add
 */
struct CollectionRoleGrantRequest {
    address collection;
    uint96 nonce;
    address receiver;
    bytes32 role;
}

interface ISpellcasterGM {
    /**
     * @dev Adds a trusted signer to spellcaster
     * @param _account The address of the signer.
     */
    function addTrustedSigner(address _account) external;
}
