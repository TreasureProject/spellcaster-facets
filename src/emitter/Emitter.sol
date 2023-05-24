//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { EmitterBase, LibEmitter, IEmitter } from "./EmitterBase.sol";
import { LibEmitterStorage } from "./LibEmitterStorage.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { LibUtilities } from "src/libraries/LibUtilities.sol";
import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { EmittingCollectionType, EmittingInfo, EmittingRateChangeBehavior } from "src/interfaces/IEmitter.sol";
import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

contract Emitter is EmitterBase {
    /**
     * @inheritdoc IEmitter
     */
    function Emitter_init() external facetInitializer(keccak256("Emitter_init")) {
        __EmitterBase_init();
    }

    function createEmittingInstance(
        bytes32 _organizationId,
        EmittingCollectionType _collectionType,
        address _collection,
        uint256 _emittingFrequencyInSeconds,
        uint256 _amountToEmitPerSecond,
        uint256 _startTime,
        uint256 _endTime,
        EmittingRateChangeBehavior _rateChangeBehavior,
        uint256 _tokenId,
        bytes4 _emitFunctionSelector
    ) external whenNotPaused {
        LibEmitter.createEmittingInstance(
            _organizationId,
            _collectionType,
            _collection,
            _emittingFrequencyInSeconds,
            _amountToEmitPerSecond,
            _startTime,
            _endTime,
            _rateChangeBehavior,
            _tokenId,
            _emitFunctionSelector
        );
    }

    function deactivateEmittingInstance(uint64 _emittingId) external whenNotPaused {
        LibEmitter.deactivateEmittingInstance(_emittingId);
    }

    function changeEmittingInstanceCreator(uint64 _emittingId, address _newOwner) external whenNotPaused {
        LibEmitter.changeEmittingInstanceCreator(_emittingId, _newOwner);
    }

    function changeEmittingInstanceFrequencyAndRate(
        uint64 _emittingId,
        uint256 _emittingFrequencyInSeconds,
        uint256 _amountToEmitPerSecond
    ) external whenNotPaused {
        LibEmitter.changeEmittingInstanceFrequencyAndRate(
            _emittingId, _emittingFrequencyInSeconds, _amountToEmitPerSecond
        );
    }

    function changeEmittingInstanceCanClaim(
        uint64 _emittingId,
        address _address,
        bool _canClaim
    ) external whenNotPaused {
        LibEmitter.changeEmittingInstanceCanClaim(_emittingId, _address, _canClaim);
    }

    function changeEmittingInstanceApproval(uint64 _emittingId, bool _isApproved) external whenNotPaused {
        LibEmitter.changeEmittingInstanceApproval(_emittingId, _isApproved);
    }

    function claim(uint64 _emittingId) external whenNotPaused {
        LibEmitter.claim(_emittingId);
    }

    function amountToClaim(uint64 _emittingId, bool _includePartialAmount) public view returns (uint256, uint256) {
        return LibEmitter.amountToClaim(_emittingId, _includePartialAmount);
    }
}
