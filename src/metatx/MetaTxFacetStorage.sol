//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibBBase64} from "src/libraries/LibBBase64.sol";
import {IGuildManager} from "src/interfaces/IGuildManager.sol";

/**
 * @notice The contract that handles validating meta transaction delegate approvals
 * @dev References to 'System' are synonymous with 'Organization'
 */
interface ISystem_Delegate_Approver {
  function isDelegateApprovedForSystem(address account, bytes32 systemId, address delegate) external view returns (bool);
  function setDelegateApprovalForSystem(bytes32 systemId, address delegate, bool approved) external;
  function setDelegateApprovalForSystemBySignature(bytes32 systemId, address delegate, bool approved, address signer, uint256 nonce, bytes calldata signature) external;
}

/** 
 * @notice The struct used for signing and validating meta transactions
 * @dev from+nonce is packed to a single storage slot to save calldata gas on rollups
 * @param from The address that is being called on behalf of
 * @param nonce The nonce of the transaction. Used to prevent replay attacks
 * @param organizationId The id of the invoking organization
 * @param data The calldata of the function to be called 
 */
struct ForwardRequest {
    address from;
    uint96 nonce;
    bytes32 organizationId;
    bytes data;
}

/** 
 * @dev The typehash of the ForwardRequest struct used when signing the meta transaction
 *  This must match the ForwardRequest struct, and must not have extra whitespace or it will invalidate the signature 
 */
bytes32 constant FORWARD_REQ_TYPEHASH = keccak256("ForwardRequest(address from,uint96 nonce,bytes32 organizationId,bytes data)");

library MetaTxFacetStorage {

    error InvalidDelegateApprover();
    error CannotCallExecuteFromExecute();
    error SessionOrganizationIdNotConsumed();
    error SessionOrganizationIdMismatch(bytes32 sessionOrganizationId, bytes32 functionOrganizationId);
    error NonceAlreadyUsedForSender(address sender, uint256 nonce);
    error UnauthorizedSignerForSender(address signer, address sender);

    struct Layout {
        /**
         * @notice The delegate approver that tracks which wallet can run txs on behalf of the real sending account
         * @dev References to 'System' are synonymous with 'Organization'
        */
        ISystem_Delegate_Approver systemDelegateApprover;
        /**
         * @notice Tracks which nonces have been used by the from address. Prevents replay attacks.
         * @dev Key1: from address, Key2: nonce, Value: used or not
        */
        mapping(address => mapping(uint256 => bool)) nonces;
        /**
         * @dev The organization id of the session. Set before invoking a meta transaction and requires the function to clear it
         *  to ensure the session organization matches the function organizationId
         */
        bytes32 sessionOrganizationId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.facet.metatx");

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}

    

    