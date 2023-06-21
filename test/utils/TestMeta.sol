// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { Test } from "forge-std/Test.sol";

import { TestUtilities } from "test/utils/TestUtilities.sol";
import { SupportsMetaTx } from "src/metatx/MetaTxFacet.sol";
import { MetaTxFacet } from "src/metatx/MetaTxFacet.sol";
import {
    MetaTxFacetStorage,
    ISystemDelegateApprover,
    ForwardRequest,
    FORWARD_REQ_TYPEHASH
} from "src/metatx/MetaTxFacetStorage.sol";

contract SupportMetaTxImpl is SupportsMetaTx {
    function init(address _systemDelegateApprover) external facetInitializer(keccak256("SupportMetaTxImpl")) {
        __SupportsMetaTx_init(_systemDelegateApprover);
    }
}

contract DelegateApprover is ISystemDelegateApprover {
    mapping(address => mapping(bytes32 => mapping(address => bool))) public delegateApprovals;

    function isDelegateApprovedForSystem(
        address _account,
        bytes32 _systemId,
        address _delegate
    ) external view override returns (bool) {
        return delegateApprovals[_account][_systemId][_delegate];
    }

    function setDelegateApprovalForSystem(bytes32 _systemId, address _delegate, bool _approved) external {
        delegateApprovals[msg.sender][_systemId][_delegate] = _approved;
    }

    function setDelegateApprovalForSystemBySignature(
        bytes32 _systemId,
        address _delegate,
        bool _approved,
        address _signer,
        uint256 _nonce,
        bytes calldata _signature
    ) external { }
}

abstract contract TestMeta is Test, TestUtilities {
    uint256 internal signingPK = 1;
    address internal signingAuthority = vm.addr(signingPK);

    DelegateApprover internal delegateApprover;

    SupportMetaTxImpl internal supportMetaTx;

    constructor() {
        delegateApprover = new DelegateApprover();
        supportMetaTx = new SupportMetaTxImpl();
    }

    function signAndExecuteMetaTx(ForwardRequest memory _req, address _executingContract) internal {
        bytes memory _sig = signHash(signingPK, reqToHash(_req, _executingContract));
        executeMetaTx(MetaTxFacet(_executingContract), _req, _sig);
    }

    function reqToHash(ForwardRequest memory _req, address _signatureRecipientAddress) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(FORWARD_REQ_TYPEHASH, _req.from, _req.nonce, _req.organizationId, keccak256(_req.data))
            ),
            "Spellcaster",
            "1.0.0",
            _signatureRecipientAddress
        );
    }

    function executeMetaTx(MetaTxFacet _contractToCall, ForwardRequest memory _req, bytes memory _sig) internal {
        _contractToCall.execute(_req, _sig);
    }
}
