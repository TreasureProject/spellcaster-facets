//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts-diamond/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-diamond/utils/cryptography/EIP712Upgradeable.sol";

import {FacetInitializable} from "src/utils/FacetInitializable.sol";
import {LibAccessControlRoles} from "src/libraries/LibAccessControlRoles.sol";
import {LibUtilities} from "src/libraries/LibUtilities.sol";

import {MetaTxFacetStorage, ForwardRequest, ISystem_Delegate_Approver, FORWARD_REQ_TYPEHASH} from "./MetaTxFacetStorage.sol";

import "forge-std/console.sol";

abstract contract MetaTxFacet is FacetInitializable, EIP712Upgradeable {
  using ECDSAUpgradeable for bytes32;

  event ExecutedMetaTx(address userAddress, address payable relayerAddress, bytes functionSignature);
  event DelegateApproverSet(address delegateApprover);

  /**
   * @dev Sets all necessary state and permissions for the contract
   * @param _organizationDelegateApprover The delegate approver address that tracks which wallet can run txs on
   *  behalf of the real sending account
   */
  function __MetaTxFacet_init(address _organizationDelegateApprover) internal onlyFacetInitializing {
    if(_organizationDelegateApprover == address(0)) {
      revert MetaTxFacetStorage.InvalidDelegateApprover();
    }
    __EIP712_init("Spellcaster", "1.0.0");

    MetaTxFacetStorage.layout().systemDelegateApprover = ISystem_Delegate_Approver(_organizationDelegateApprover);
  }

  function verify(ForwardRequest calldata req, bytes calldata signature, bool shouldRevert) public view returns (bool) {
    address signer = _hashTypedDataV4(
      keccak256(abi.encode(FORWARD_REQ_TYPEHASH, req.from, req.nonce, req.organizationId, keccak256(req.data)))
    ).recover(signature);
    console.log("signer: %s", signer);
    console.log("req.from: %s", req.from);
    if(MetaTxFacetStorage.layout().nonces[req.from][req.nonce])  {
      if(!shouldRevert) {
        return false;
      }
      revert MetaTxFacetStorage.NonceAlreadyUsedForSender(req.from, req.nonce);
    }
    if(signer != req.from && !MetaTxFacetStorage.layout().systemDelegateApprover.isDelegateApprovedForSystem(req.from, req.organizationId, signer)) {
      if(!shouldRevert) {
        return false;
      }
      revert MetaTxFacetStorage.UnauthorizedSignerForSender(signer, req.from);
    }
    return true;
  }

  function execute(ForwardRequest calldata req, bytes calldata signature) public payable returns (bool, bytes memory) {
    bytes4 functionSelector = LibUtilities.convertBytesToBytes4(req.data);
    if(functionSelector == msg.sig) {
      revert MetaTxFacetStorage.CannotCallExecuteFromExecute();
    }
    verify(req, signature, true);
    MetaTxFacetStorage.layout().nonces[req.from][req.nonce] = true;

    (bool success, bytes memory returnData) = address(this).call(abi.encodePacked(req.data, req.from));
    emit ExecutedMetaTx(req.from, payable(msg.sender), req.data);

    return (success, returnData);
  }

  /**
   * @notice This function is used to set the delegate approver address
   * @dev This function is only callable by the owner of the contract
   * @param _organizationDelegateApprover The delegate approver address that tracks which wallet can run txs on
   *  behalf of the real sending account
   */
  function setDelegateAddress(address _organizationDelegateApprover) external {
    if(_organizationDelegateApprover == address(0)) {
      revert MetaTxFacetStorage.InvalidDelegateApprover();
    }
    // Do not use _msgSender, as we want the owner themselves to change this.
    LibAccessControlRoles.requireOwner(msg.sender);
    MetaTxFacetStorage.layout().systemDelegateApprover = ISystem_Delegate_Approver(_organizationDelegateApprover);

    emit DelegateApproverSet(_organizationDelegateApprover);
  }
}