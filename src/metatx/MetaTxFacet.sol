//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { ECDSAUpgradeable } from "@openzeppelin/contracts-diamond/utils/cryptography/ECDSAUpgradeable.sol";
import { EIP712Upgradeable } from "@openzeppelin/contracts-diamond/utils/cryptography/EIP712Upgradeable.sol";

import { FacetInitializable } from "src/utils/FacetInitializable.sol";
import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";
import { LibUtilities } from "src/libraries/LibUtilities.sol";

import {
    MetaTxFacetStorage, ForwardRequest, ISystemDelegateApprover, FORWARD_REQ_TYPEHASH
} from "./MetaTxFacetStorage.sol";
import { SupportsMetaTx } from "./SupportsMetaTx.sol";

contract MetaTxFacet is SupportsMetaTx {
    using ECDSAUpgradeable for bytes32;

    event ExecutedMetaTx(address userAddress, address payable relayerAddress, bytes functionSignature);
    event DelegateApproverSet(address delegateApprover);

    /**
     * @dev Sets all necessary state and permissions for the contract
     *  behalf of the real sending account
     *  Assumes that the _systemDelegateApprover is already set
     */
    function __MetaTxFacet_init() internal onlyFacetInitializing { }

    function verify(
        ForwardRequest calldata _req,
        bytes calldata _signature,
        bool _shouldRevert
    ) public view returns (bool) {
        address _signer = _hashTypedDataV4(
            keccak256(
                abi.encode(FORWARD_REQ_TYPEHASH, _req.from, _req.nonce, _req.organizationId, keccak256(_req.data))
            )
        ).recover(_signature);
        if (MetaTxFacetStorage.layout().nonces[_req.from][_req.nonce]) {
            if (!_shouldRevert) {
                return false;
            }
            revert MetaTxFacetStorage.NonceAlreadyUsedForSender(_req.from, _req.nonce);
        }
        if (
            _signer != _req.from
                && !MetaTxFacetStorage.layout().systemDelegateApprover.isDelegateApprovedForSystem(
                    _req.from, _req.organizationId, _signer
                )
        ) {
            if (!_shouldRevert) {
                return false;
            }
            revert MetaTxFacetStorage.UnauthorizedSignerForSender(_signer, _req.from);
        }
        return true;
    }

    function execute(ForwardRequest calldata _req, bytes calldata _signature) public payable returns (bytes memory) {
        bytes4 _functionSelector = LibUtilities.convertBytesToBytes4(_req.data);
        if (_functionSelector == msg.sig) {
            revert MetaTxFacetStorage.CannotCallExecuteFromExecute();
        }
        verify(_req, _signature, true);

        MetaTxFacetStorage.Layout storage _l = MetaTxFacetStorage.layout();
        _l.nonces[_req.from][_req.nonce] = true;
        _l.sessionOrganizationId = _req.organizationId;

        (bool _success, bytes memory _returnData) = address(this).call(abi.encodePacked(_req.data, _req.from));

        if (!_success) {
            if (_returnData.length > 0) {
                // bubble up the error
                assembly {
                    revert(add(32, _returnData), mload(_returnData))
                }
            } else {
                revert("MetaTx: execute reverted");
            }
        }

        if (_l.sessionOrganizationId != "") {
            revert MetaTxFacetStorage.SessionOrganizationIdNotConsumed();
        }
        emit ExecutedMetaTx(_req.from, payable(msg.sender), _req.data);
        return _returnData;
    }

    /**
     * @notice This function is used to set the delegate approver address
     * @dev This function is only callable by the owner of the contract
     * @param _organizationDelegateApprover The delegate approver address that tracks which wallet can run txs on
     *  behalf of the real sending account
     */
    function setDelegateAddress(address _organizationDelegateApprover) external {
        if (_organizationDelegateApprover == address(0)) {
            revert MetaTxFacetStorage.InvalidDelegateApprover();
        }
        // Do not use _msgSender, as we want the owner themselves to change this.
        LibAccessControlRoles.requireOwner(msg.sender);
        MetaTxFacetStorage.layout().systemDelegateApprover = ISystemDelegateApprover(_organizationDelegateApprover);

        emit DelegateApproverSet(_organizationDelegateApprover);
    }
}
