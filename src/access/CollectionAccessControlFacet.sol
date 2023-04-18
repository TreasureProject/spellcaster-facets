// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-diamond/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-diamond/utils/cryptography/EIP712Upgradeable.sol";

import { FacetInitializable } from "../utils/FacetInitializable.sol";
import { LibAccessControlRoles } from "../libraries/LibAccessControlRoles.sol";
import { LibSpellcasterGM } from "../libraries/LibSpellcasterGM.sol";
import { LibMeta } from "../libraries/LibMeta.sol";

import { CollectionRoleGrantRequest } from "../interfaces/ISpellcasterGM.sol";

import "forge-std/console.sol";

bytes32 constant COLLECTION_ROLE_GRANT_REQUEST_TYPEHASH =
    keccak256("CollectionRoleGrantRequest(address collection,uint96 nonce,address receiver,bytes32 role)");

contract CollectionAccessControlFacet is FacetInitializable, EIP712Upgradeable {
    function CollectionAccessControlFacet_init() external facetInitializer(keccak256("CollectionAccessControlFacet_init")) {
        __EIP712_init("Spellcaster", "1.0.0");
    }

    using ECDSAUpgradeable for bytes32;

    /**
     * @dev Error for when the signer is not a trusted signer.
     */
    error SignerIsNotTrustedSigner();

    /**
     * @dev Error for when the role request doesn't match the called function.
     */
    error InvalidRoleRequest();

    /**
     * @dev Verifies a given signature and a request and whether the signer is a trusted signer.
     * @param _collectionRoleGrantRequest The request to verify.
     * @param _signature The signature from a signer.
     */
    function verify(
        CollectionRoleGrantRequest calldata _collectionRoleGrantRequest,
        bytes calldata _signature
    ) internal returns (bool) {
        address signer = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    COLLECTION_ROLE_GRANT_REQUEST_TYPEHASH,
                    _collectionRoleGrantRequest.collection,
                    _collectionRoleGrantRequest.nonce,
                    _collectionRoleGrantRequest.receiver,
                    _collectionRoleGrantRequest.role
                )
            )
        ).recover(_signature);

        //Use the nonce, revert if used.
        LibSpellcasterGM.useNonce(signer, _collectionRoleGrantRequest.nonce);

        //Require signer is trusted.
        LibSpellcasterGM.requireTrustedSigner(signer);

        //Return bool of whether signer is trusted.
        return (LibSpellcasterGM.isTrustedSigner(signer));
    }

    /**
     * @dev Grants a collection role granter role given a valid request.
     * @param _collectionRoleGrantRequest The request to verify.
     * @param _signature The signature from a signer.
     */
    function grantCollectionRoleGranter(
        CollectionRoleGrantRequest calldata _collectionRoleGrantRequest,
        bytes calldata _signature
    ) external {
        if (LibMeta._msgSender() == LibAccessControlRoles.contractOwner()) {
            //Check that msg sender is collection owner
            //Do nothing
        } else {
            //This call reverts if they are not signed
            verify(_collectionRoleGrantRequest, _signature);
        }

        if (
            _collectionRoleGrantRequest.role
                != keccak256(
                    abi.encodePacked("COLLECTION_ROLE_GRANTER_ROLE_", address(_collectionRoleGrantRequest.collection))
                )
        ) revert InvalidRoleRequest();

        LibAccessControlRoles.grantCollectionRoleGranter(
            _collectionRoleGrantRequest.receiver, _collectionRoleGrantRequest.collection
        );
    }

    /**
     * @dev Grants a collection role admin role. Only callable by collection role granter.
     * @param _account The account to make an admin.
     * @param _collection The colletion to make them an admin of.
     */
    function grantCollectionAdmin(address _account, address _collection) external {
        LibAccessControlRoles.requireCollectionRoleGranter(LibMeta._msgSender(), _collection);
        LibAccessControlRoles.grantCollectionAdmin(_account, _collection);
    }
}
