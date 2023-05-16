// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum EmittingCollectionType {
    ERC20,
    ERC1155
}

enum EmittingRateChangeBehavior {
    CLAIM_PARTIAL,
    DISCARD_PARTIAL
}

struct EmittingInfo {
    bytes32 organizationId;
    address creator;
    mapping(address => bool) addressToCanClaim;
    EmittingCollectionType collectionType;
    address collection;
    bool isApprovedByCollection;
    uint256 emittingFrequencyInSeconds;
    uint256 amountToEmitPerSecond;
    uint256 startTime;
    uint256 endTime;
    uint256 lastClaimWindowTime;
    uint256 additionalAmountToClaim;
    EmittingRateChangeBehavior rateChangeBehavior;
    uint256 tokenId;
    bytes4 emitFunctionSelector;
    bool isActive;
}

interface IEmitter {
    /**
     * @dev Sets all necessary state and permissions for the contract
     */
    function Emitter_init() external;
}
