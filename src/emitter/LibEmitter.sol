// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { EmittingCollectionType, EmittingInfo, EmittingRateChangeBehavior } from "src/interfaces/IEmitter.sol";

import { LibEmitterStorage } from "src/emitter/LibEmitterStorage.sol";
import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

/**
 * @title Emitter Library
 * @dev This library is used to implement features that use/update storage data for the Emitter contracts
 */
library LibEmitter {
    function createEmittingInstance(
        bytes32 _organizationId,
        EmittingCollectionType _collectionType,
        address _collection,
        uint64 _emittingFrequencyInSeconds,
        uint256 _amountToEmitPerSecond,
        uint64 _startTime,
        uint64 _endTime,
        EmittingRateChangeBehavior _rateChangeBehavior,
        uint256 _tokenId,
        bytes4 _emitFunctionSelector
    ) internal {
        LibOrganizationManager.requireOrganizationValid(_organizationId);

        if (_startTime == 0) {
            revert LibEmitterStorage.InvalidStartTime();
        }

        uint64 _emittingId = LibEmitterStorage.layout().currentEmittingId;
        LibEmitterStorage.layout().currentEmittingId++;

        EmittingInfo storage _emittingInfo = LibEmitterStorage.layout().emittingIdToInfo[_emittingId];
        _emittingInfo.organizationId = _organizationId;
        _emittingInfo.collectionType = _collectionType;
        _emittingInfo.collection = _collection;
        _emittingInfo.startTime = _startTime;
        _emittingInfo.lastClaimWindowTime = _startTime;
        _emittingInfo.rateChangeBehavior = _rateChangeBehavior;
        _emittingInfo.tokenId = _tokenId;
        _emittingInfo.emitFunctionSelector = _emitFunctionSelector;
        _emittingInfo.isActive = true;

        emit LibEmitterStorage.EmittingInstanceCreated(
            _emittingId,
            _organizationId,
            _collectionType,
            _collection,
            _startTime,
            _rateChangeBehavior,
            _tokenId,
            _emitFunctionSelector
        );

        _setEmittingInstanceCreator(_emittingId, LibMeta._msgSender());
        _setEmittingInstanceCanClaim(_emittingId, LibMeta._msgSender(), true);
        _setEmittingInstanceFrequencyAndRate(_emittingId, _emittingFrequencyInSeconds, _amountToEmitPerSecond);
        _setEmittingInstanceEndTime(_emittingId, _endTime);
    }

    function deactivateEmittingInstance(uint64 _emittingId) internal {
        _requireEmittingInstanceCreator(_emittingId);
        _requireEmittingInstanceActive(_emittingId);

        EmittingInfo storage _emittingInfo = LibEmitterStorage.layout().emittingIdToInfo[_emittingId];

        _emittingInfo.isActive = false;

        emit LibEmitterStorage.EmittingInstanceDeactivated(_emittingId);
    }

    function changeEmittingInstanceCreator(uint64 _emittingId, address _newOwner) internal {
        _requireEmittingInstanceCreator(_emittingId);

        _setEmittingInstanceCreator(_emittingId, _newOwner);
    }

    function changeEmittingInstanceFrequencyAndRate(
        uint64 _emittingId,
        uint64 _emittingFrequencyInSeconds,
        uint256 _amountToEmitPerSecond
    ) internal {
        _requireEmittingInstanceCreator(_emittingId);

        _setEmittingInstanceFrequencyAndRate(_emittingId, _emittingFrequencyInSeconds, _amountToEmitPerSecond);

        EmittingInfo storage _emittingInfo = LibEmitterStorage.layout().emittingIdToInfo[_emittingId];
        _emittingInfo.isApprovedByCollection = false;

        emit LibEmitterStorage.EmittingInstanceCollectionApprovalChanged(_emittingId, _emittingInfo.collection, false);
    }

    function changeEmittingInstanceCanClaim(uint64 _emittingId, address _address, bool _canClaim) internal {
        _requireEmittingInstanceCreator(_emittingId);

        _setEmittingInstanceCanClaim(_emittingId, _address, _canClaim);
    }

    function changeEmittingInstanceApproval(uint64 _emittingId, bool _isApproved) internal {
        _requireEmittingInstanceActive(_emittingId);

        EmittingInfo storage _emittingInfo = LibEmitterStorage.layout().emittingIdToInfo[_emittingId];

        require(
            LibAccessControlRoles.isCollectionAdmin(LibMeta._msgSender(), _emittingInfo.collection),
            "Not collection admin"
        );

        _emittingInfo.isApprovedByCollection = _isApproved;

        emit LibEmitterStorage.EmittingInstanceCollectionApprovalChanged(
            _emittingId, _emittingInfo.collection, _isApproved
        );
    }

    function claim(uint64 _emittingId) internal {
        _requireEmittingInstanceActive(_emittingId);
        _requireEmittingInstanceCanClaim(_emittingId);
        _requireEmittingInstanceApproved(_emittingId);

        (uint256 _amountToClaim, uint64 _newLastClaimWindowTime) = amountToClaim(_emittingId, false);

        if (_amountToClaim == 0) {
            return;
        }

        bytes4 _functionSelector = LibEmitterStorage.layout().emittingIdToInfo[_emittingId].emitFunctionSelector;

        address _collection = LibEmitterStorage.layout().emittingIdToInfo[_emittingId].collection;

        EmittingCollectionType _collectionType = LibEmitterStorage.layout().emittingIdToInfo[_emittingId].collectionType;

        LibEmitterStorage.layout().emittingIdToInfo[_emittingId].lastClaimWindowTime = _newLastClaimWindowTime;

        delete LibEmitterStorage
            .layout()
            .emittingIdToInfo[_emittingId]
            .additionalAmountToClaim;

        if (_collectionType == EmittingCollectionType.ERC20) {
            AddressUpgradeable.functionCall(
                _collection, abi.encodePacked(_functionSelector, abi.encode(LibMeta._msgSender()), _amountToClaim)
            );
        } else {
            // 1155
            AddressUpgradeable.functionCall(
                _collection,
                abi.encodePacked(
                    _functionSelector,
                    abi.encode(LibMeta._msgSender()),
                    LibEmitterStorage.layout().emittingIdToInfo[_emittingId].tokenId,
                    _amountToClaim
                )
            );
        }
    }

    function amountToClaim(uint64 _emittingId, bool _includePartialAmount) internal view returns (uint256, uint64) {
        EmittingInfo storage _emittingInfo = LibEmitterStorage.layout().emittingIdToInfo[_emittingId];

        if (!_emittingInfo.isActive) {
            return (0, 0);
        }

        uint256 _currentTimeForCalculation = _emittingInfo.endTime != 0 && block.timestamp > _emittingInfo.endTime
            ? _emittingInfo.endTime
            : block.timestamp;
        uint256 _timeSinceLastClaimWindow = _currentTimeForCalculation < _emittingInfo.lastClaimWindowTime
            ? 0
            : _currentTimeForCalculation - _emittingInfo.lastClaimWindowTime;

        uint256 _numberOfWindowsToClaim = _timeSinceLastClaimWindow / _emittingInfo.emittingFrequencyInSeconds;
        uint256 _amountToClaim = (
            _numberOfWindowsToClaim * _emittingInfo.emittingFrequencyInSeconds * _emittingInfo.amountToEmitPerSecond
        ) + _emittingInfo.additionalAmountToClaim;

        if (_includePartialAmount) {
            _amountToClaim += (_timeSinceLastClaimWindow % _emittingInfo.emittingFrequencyInSeconds)
                * _emittingInfo.amountToEmitPerSecond;
        }

        if (_amountToClaim == 0) {
            return (0, 0);
        }

        if (!_includePartialAmount && _emittingInfo.collectionType == EmittingCollectionType.ERC1155) {
            _amountToClaim = _amountToClaim / 1 ether;
        }

        return (
            _amountToClaim,
            _includePartialAmount
                ? uint64(block.timestamp)
                : uint64(
                    _emittingInfo.lastClaimWindowTime + (_numberOfWindowsToClaim * _emittingInfo.emittingFrequencyInSeconds)
                )
        );
    }

    function _setEmittingInstanceFrequencyAndRate(
        uint64 _emittingId,
        uint64 _emittingFrequencyInSeconds,
        uint256 _amountToEmitPerSecond
    ) private {
        EmittingInfo storage _emittingInfo = LibEmitterStorage.layout().emittingIdToInfo[_emittingId];

        bool _isSettingInitially = _emittingInfo.emittingFrequencyInSeconds == 0;

        if (_emittingFrequencyInSeconds == 0 || _amountToEmitPerSecond == 0) {
            revert LibEmitterStorage.BadEmittingRate();
        }

        if (!_isSettingInitially) {
            (uint256 _amountToClaim,) =
                amountToClaim(_emittingId, _emittingInfo.rateChangeBehavior == EmittingRateChangeBehavior.CLAIM_PARTIAL);

            _emittingInfo.additionalAmountToClaim = _amountToClaim;
            _emittingInfo.lastClaimWindowTime = uint64(block.timestamp);
        }

        _emittingInfo.emittingFrequencyInSeconds = _emittingFrequencyInSeconds;
        _emittingInfo.amountToEmitPerSecond = _amountToEmitPerSecond;

        emit LibEmitterStorage.EmittingInstanceRateChanged(
            _emittingId, _emittingFrequencyInSeconds, _amountToEmitPerSecond
        );
    }

    function _setEmittingInstanceEndTime(uint64 _emittingId, uint64 _endTime) private {
        EmittingInfo storage _emittingInfo = LibEmitterStorage.layout().emittingIdToInfo[_emittingId];

        if (_endTime != 0) {
            if (_emittingInfo.startTime >= _endTime) {
                revert LibEmitterStorage.BadEndTime();
            }
        }

        _emittingInfo.endTime = _endTime;

        emit LibEmitterStorage.EmittingInstanceEndTimeChanged(_emittingId, _endTime);
    }

    function _requireEmittingInstanceCreator(uint64 _emittingId) internal view {
        if (LibMeta._msgSender() != LibEmitterStorage.layout().emittingIdToInfo[_emittingId].creator) {
            revert LibEmitterStorage.InstanceCreatorOnly();
        }
    }

    function _requireEmittingInstanceCanClaim(uint64 _emittingId) internal view {
        if (!LibEmitterStorage.layout().emittingIdToInfo[_emittingId].addressToCanClaim[LibMeta._msgSender()]) {
            revert LibEmitterStorage.ApprovedClaimerOnly();
        }
    }

    function _requireEmittingInstanceActive(uint64 _emittingId) internal view {
        if (!LibEmitterStorage.layout().emittingIdToInfo[_emittingId].isActive) {
            revert LibEmitterStorage.InstanceDeactivated();
        }
    }

    function _requireEmittingInstanceApproved(uint64 _emittingId) internal view {
        if (!LibEmitterStorage.layout().emittingIdToInfo[_emittingId].isApprovedByCollection) {
            revert LibEmitterStorage.CollectionNotApproved();
        }
    }

    function _setEmittingInstanceCreator(uint64 _emittingId, address _creator) private {
        if (_creator == address(0)) {
            revert LibEmitterStorage.BadCreator();
        }

        address _oldCreator = LibEmitterStorage.layout().emittingIdToInfo[_emittingId].creator;
        LibEmitterStorage.layout().emittingIdToInfo[_emittingId].creator = _creator;

        emit LibEmitterStorage.EmittingInstanceCreatorChanged(_emittingId, _oldCreator, _creator);
    }

    function _setEmittingInstanceCanClaim(uint64 _emittingId, address _address, bool _canClaim) private {
        LibEmitterStorage.layout().emittingIdToInfo[_emittingId].addressToCanClaim[_address] = _canClaim;

        emit LibEmitterStorage.EmittingInstanceCanClaimChanged(_emittingId, _address, _canClaim);
    }
}
