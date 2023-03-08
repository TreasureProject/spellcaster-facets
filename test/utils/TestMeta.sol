// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";

import {TestUtilities} from "test/utils/TestUtilities.sol";
import {MetaTxFacet} from "src/metatx/MetaTxFacet.sol";
import {MetaTxFacetStorage, ISystem_Delegate_Approver, ForwardRequest, FORWARD_REQ_TYPEHASH} from "src/metatx/MetaTxFacetStorage.sol";

contract DelegateApprover is ISystem_Delegate_Approver {
    mapping(address => mapping(bytes32 => mapping(address => bool))) public delegateApprovals;

    function isDelegateApprovedForSystem(address account, bytes32 systemId, address delegate) external view override returns (bool) {
        return delegateApprovals[account][systemId][delegate];
    }
    function setDelegateApprovalForSystem(bytes32 systemId, address delegate, bool approved) external {
        delegateApprovals[msg.sender][systemId][delegate] = approved;
    }
    function setDelegateApprovalForSystemBySignature(bytes32 systemId, address delegate, bool approved, address signer, uint256 nonce, bytes calldata signature) external {
    }
}

abstract contract TestMeta is Test, TestUtilities {
    uint256 internal signingPK = 1;
    address internal signingAuthority = vm.addr(signingPK);

    DelegateApprover internal _delegateApprover;
    
    constructor() {
        _delegateApprover = new DelegateApprover();
    }

    function signAndExecuteMetaTx(ForwardRequest memory req, address executingContract) internal {
        bytes memory sig = signHash(signingPK, reqToHash(req, executingContract));
        executeMetaTx(MetaTxFacet(executingContract), req, sig);
    }

    function reqToHash(ForwardRequest memory req, address _signatureRecipientAddress) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(FORWARD_REQ_TYPEHASH, req.from, req.nonce, req.organizationId, keccak256(req.data))),
            "Spellcaster",
            "1.0.0",
            _signatureRecipientAddress
        );
    }

    function executeMetaTx(MetaTxFacet contractToCall, ForwardRequest memory req, bytes memory sig) internal {
        contractToCall.execute(req, sig);
    }
}