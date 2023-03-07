//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts-diamond/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-diamond/utils/cryptography/EIP712Upgradeable.sol";

import {FacetInitializable} from "src/utils/FacetInitializable.sol";
import {LibAccessControlRoles} from "src/libraries/LibAccessControlRoles.sol";
import {LibUtilities} from "src/libraries/LibUtilities.sol";

import {MetaTxFacetStorage, ForwardRequest, ISystem_Delegate_Approver, FORWARD_REQ_TYPEHASH} from "./MetaTxFacetStorage.sol";

abstract contract SupportsMetaTx is FacetInitializable, EIP712Upgradeable {
  using ECDSAUpgradeable for bytes32;

  /**
   * @dev Sets all necessary state and permissions for the contract
   * @param _organizationDelegateApprover The delegate approver address that tracks which wallet can run txs on
   *  behalf of the real sending account
   */
  function __SupportsMetaTx_init(address _organizationDelegateApprover) internal onlyFacetInitializing {
    if(_organizationDelegateApprover == address(0)) {
      revert MetaTxFacetStorage.InvalidDelegateApprover();
    }
    __EIP712_init("Spellcaster", "1.0.0");

    MetaTxFacetStorage.layout().systemDelegateApprover = ISystem_Delegate_Approver(_organizationDelegateApprover);
  }

  function verifyAndConsumeSessionId(bytes32 _organizationId) internal {
    MetaTxFacetStorage.Layout storage l = MetaTxFacetStorage.layout();
    bytes32 sessionId = l.sessionOrganizationId;
    // If the call is from a meta tx, consume the session id and require it to match
    if(sessionId != "") {
      if(sessionId != _organizationId) {
        revert MetaTxFacetStorage.SessionOrganizationIdMismatch(sessionId, _organizationId);
      }
      // Reset the session id before the call to ensure that subsequent calls do not keep validating
      l.sessionOrganizationId = "";
    }
  }

  function getSessionOrganizationId() internal view returns(bytes32 sessionId_) {
    sessionId_ = MetaTxFacetStorage.layout().sessionOrganizationId;
  }

  modifier supportsMetaTx(bytes32 _organizationId) virtual {
    MetaTxFacetStorage.Layout storage l = MetaTxFacetStorage.layout();
    bytes32 sessionId = l.sessionOrganizationId;
    // If the call is from a meta tx, consume the session id and require it to match
    if(sessionId != "") {
      if(sessionId != _organizationId) {
        revert MetaTxFacetStorage.SessionOrganizationIdMismatch(sessionId, _organizationId);
      }
      // Reset the session id before the call to ensure that subsequent calls do not keep validating
      l.sessionOrganizationId = "";
    }
    _;
  }

  modifier supportsMetaTxNoId() virtual {
    _;

    MetaTxFacetStorage.Layout storage l = MetaTxFacetStorage.layout();
    // If the call is from a meta tx, consume the session id
    if(l.sessionOrganizationId != "") {
      // Reset the session id after the call to ensure that a subsequent call will validate the session id if applicable
      l.sessionOrganizationId = "";
    }
  }
}