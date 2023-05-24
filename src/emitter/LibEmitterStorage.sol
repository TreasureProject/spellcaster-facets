// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { EmittingCollectionType, EmittingInfo, EmittingRateChangeBehavior } from "src/interfaces/IEmitter.sol";

/**
 * @title LibEmitterStorage library
 * @notice This library contains the storage layout and events/errors for the Emitter contract.
 */
library LibEmitterStorage {
    struct Layout {
        /**
         * @dev Store all information about the emitting
         */
        mapping(uint64 => EmittingInfo) emittingIdToInfo;
        uint64 currentEmittingId;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.emitter");

    function layout() internal pure returns (Layout storage l_) {
        bytes32 _position = FACET_STORAGE_POSITION;
        assembly {
            l_.slot := _position
        }
    }

    event EmittingInstanceCreated(
        uint64 indexed emittingId,
        bytes32 organizationId,
        EmittingCollectionType collectionType,
        address collection,
        uint256 startTime,
        EmittingRateChangeBehavior rateChangeBehavior,
        uint256 tokenId,
        bytes4 emitFunctionSelector
    );

    event EmittingInstanceCreatorChanged(uint64 indexed emittingId, address oldCreator, address newCreator);

    event EmittingInstanceEndTimeChanged(uint64 indexed emittingId, uint256 endTime);

    event EmittingInstanceRateChanged(
        uint64 indexed emittingId, uint256 emittingFrequencyInSeconds, uint256 amountToEmitPerSecond
    );

    event EmittingInstanceCanClaimChanged(uint64 indexed emittingId, address user, bool canClaim);

    event EmittingInstanceCollectionApprovalChanged(uint64 indexed emittingId, address collection, bool isApproved);

    event EmittingInstanceClaimed(
        uint64 indexed emittingId, address claimedBy, uint256 amountClaimed, uint256 lastClaimWindowTime
    );

    event EmittingInstanceDeactivated(uint64 indexed emittingId);

    error InvalidStartTime();
    error BadEmittingRate();
    error BadEndTime();
    error BadCreator();
    error InstanceCreatorOnly();
    error ApprovedClaimerOnly();
    error CollectionNotApproved();
    error InstanceDeactivated();
}
