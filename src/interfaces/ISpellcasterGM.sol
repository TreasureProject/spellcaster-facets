// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
