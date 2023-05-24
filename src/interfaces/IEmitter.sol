// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev The type of collection that is being emitted. ERC721 is currently not supported.
 */
enum EmittingCollectionType {
    ERC20,
    ERC1155
}

/**
 * @dev The behavior of the emitter when the rate of the instance is changed.
 * If using CLAIM_PARTIAL, anything that has accrued before the emittingFrequnecy,
 * will be given to the user on the next claim.
 *
 * If using DISCARD_PARTIAL, anything that has been accrued before the emittingFrequnecy will be given up.
 *
 * In either case, resesting the rate or frequency will reset the time the emitting starts.
 */
enum EmittingRateChangeBehavior {
    CLAIM_PARTIAL,
    DISCARD_PARTIAL
}

/**
 * @dev Tracks all things related to emitting instance.
 * @param organizationId The ID of the organization this instance belongs to.
 * @param addressToCanClaim A mapping of addresses to whether they can claim the accrued 1155/20.
 * @param startTime The time this accruel should begin. Must be greater than 0.
 * @param endTime The time this accruel should end. If 0, the accruel is indefinite.
 * @param lastClaimWindowTime The last time the emitting instance was claimed. The timestamp will land on a window.
 * i.e. Claim 1 ERC1155 every 10 minutes. If claim at the 15 minute mark, this values will be the timestamp equivalent to the 10 minute mark.
 * @param collectionType The type of collection being accrued.
 * @param isApprovedByCollection Indicates if the owner or admin of the collection has approved this emitting instance.
 * @param isActive Indicates if this instance is active.
 * @param emitFunctionSelector The function selector on the collection to emit. For ERC1155 and ERC20, the parameters must be the common "mint" parameters.
 * @param rateChangeBehavior See EmittingRateChangeBehavior.
 * @param collection The address of the collection being accrued.
 * @param creator The creator of the instance. This person has control over the rate and ending the instance.
 * @param emittingFrequencyInSeconds The frequency, in seconds, that the user gets to claim.
 * i.e. Claim 1 ERC1155 every 10 minutes. At 10-19 minutes, 1 will have been accrued. At 20 minutes, 2 will have been accrued.
 * @param amountToEmitPerSecond The rate to accrue per second. ERC1155 is denoted where 1 ether = 1 full item. ERC20 should be in its decimal.
 * @param additionalAmountToClaim Used when the rate/frequency changes to carry over any unclaimed amount.
 * @param tokenId The tokenId to emit. Only useful for ERC1155.
 */
struct EmittingInfo {
    // Slot 1
    bytes32 organizationId;
    // Slot 2
    mapping(address => bool) addressToCanClaim;
    // Slot 3
    uint64 startTime;
    uint64 endTime;
    uint64 lastClaimWindowTime;
    EmittingCollectionType collectionType;
    bool isApprovedByCollection;
    bool isActive;
    bytes4 emitFunctionSelector;
    EmittingRateChangeBehavior rateChangeBehavior;
    // Slot 4 (160/256)
    address collection;
    // Slot 5 (224/256)
    address creator;
    uint64 emittingFrequencyInSeconds;
    // Slot 6
    uint256 amountToEmitPerSecond;
    // Slot 7
    uint256 additionalAmountToClaim;
    // Slot 8
    uint256 tokenId;
}

interface IEmitter {
    /**
     * @dev Sets all necessary state and permissions for the contract
     */
    function Emitter_init() external;

    /**
     * @dev Creates a new emitting instance. For more information about each parameter, see EmittingInfo.
     */
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
    ) external;

    /**
     * @dev Permanently deactivates the given emitting instance. Can only be called by the creator. All pending claims will be lost.
     * @param _emittingId the ID of the emitting instance to deactivate.
     */
    function deactivateEmittingInstance(uint64 _emittingId) external;

    /**
     * @notice Changes the creator of the emitting instance from the caller to the passed in address.
     * @param _emittingId The ID of the emitting instance
     * @param _newOwner The new owner. Cannot be the zero address.
     */
    function changeEmittingInstanceCreator(uint64 _emittingId, address _newOwner) external;

    /**
     * @notice Changes the frequency and rate of the emitting instance. See EmittingInfo for more information on frequency and rate
     * This will reset the collection approval status. The collection owner will need to reapproved the instance.
     */
    function changeEmittingInstanceFrequencyAndRate(
        uint64 _emittingId,
        uint64 _emittingFrequencyInSeconds,
        uint256 _amountToEmitPerSecond
    ) external;

    /**
     * @notice Adds or removes the ability for an address to claim an emitting instance. Only the creator can perform this action.
     * @param _emittingId the ID of the instance
     * @param _address the address to allow/disallow
     * @param _canClaim whether the given address should be able to be claimed or not.
     */
    function changeEmittingInstanceCanClaim(uint64 _emittingId, address _address, bool _canClaim) external;

    /**
     * @notice Called by the collection owner to approve or unapprove an instance
     * @param _emittingId the ID of the instance
     * @param _isApproved whether to approve or unapprove the instance.
     */
    function changeEmittingInstanceApproval(uint64 _emittingId, bool _isApproved) external;

    /**
     * @notice Claims any pending amount. If there is nothing to claim, this function will return.
     * @param _emittingId the ID of the instance
     */
    function claim(uint64 _emittingId) external;

    /**
     * @notice Returns the amount of ERC1155/ERC20 available to claim for the given instance.
     * @param _emittingId the ID of the instance
     */
    function amountToClaim(uint64 _emittingId) external view returns (uint256);
}
