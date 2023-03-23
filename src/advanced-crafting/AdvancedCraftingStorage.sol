//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library AdvancedCraftingStorage {

    struct Layout {
        uint256 test;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.crafting.advanced");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }
}

/**
 * @dev Stores all data related to a recipe
 * @param name The name of the recipe. Only used for external tracking purposes
 * @param startTime The time that this recipe becomes available
 * @param endTime If not 0, The time that this recipe becomes unavilable
 * @param timeToComplete The amount of time this recipe takes to complete. If 0, this recipe may complete instantly
 * @param maxCrafts The maximum number of times this recipe can be crafted across all users
 * @param currentCrafts The current number of times this recipe has been crafted
 * @param indexToInput Stores a given input that the recipe requires at a given index
 * @param indexToOuput Stores a given output that the recipe requires at a given index
 * @param numberOfInputs The number of inputs this recipe has
 * @param numberOfOutputs The number of outputs this recipe has
 * @param isRandomRequired Indicates if the crafting recipe requires a random number.
 * If it does, it will be split into two transactions. The recipe may still be split into two txns regardless if the recipe takes time.
 */
struct RecipeStorage {
    // Slot 1
    string name;
    // Slot 2
    uint64 startTime;
    uint64 endTime;
    uint64 timeToComplete;
    uint32 maxCrafts;
    uint32 currentCrafts;
    // Slot 3
    mapping(uint16 => RecipeInputStorage) indexToInput;
    // Slot 4
    mapping(uint16 => string) indexToOuput;
    // Slot 5 (40/256)
    uint16 numberOfInputs;
    uint16 numberOfOutputs;
    bool isRandomRequired;
}

/**
 * @dev This struct represents a single input requirement for a recipe. This may have multiple options that can satisfy the "input".
 * @param indexToInputOption Stores a given option that the input requires at a given index
 * @param numberOfOutputs The number of options this recipe has
 * @param amount The amount of times this input needs to be provided. i.e. 11 options to choose from. Any 3 need to be provided.
 * @param isRequired Indicates if this input MUST be satisifed.
 */
struct RecipeInputStorage {
    // Slot 1
    mapping(uint16 => RecipeInputOption) indexToInputOption;
    // Slot 2 (32/256)
    uint16 numberOfInputOptions;
    uint8 amount;
    bool isRequired;
}

/**
 * @dev Represents a single option for a given input requirement for a recipe
 * @param
 */
struct RecipeInputOption {
    // The item that can be supplied
    //
    ItemInfo itemInfo;
    // Indicates if this input is burned or not.
    //
    bool isBurned;
    // The amount of time using this input will reduce the recipe time by.
    //
    uint64 timeReduction;
    // The amount of bugz using this input will reduce the cost by.
    //
    uint256 bugzReduction;
}

// Represents an output of a recipe. This output may have multiple options within it.
// It also may have a chance associated with it.
//
struct RecipeOutput {
    RecipeOutputOption[] outputOptions;
    // This array will indicate how many times the outputOptions are rolled.
    // This may have 0, indicating that this RecipeOutput may not be received.
    //
    uint8[] outputAmount;
    // This array will indicate the odds for each individual outputAmount.
    //
    OutputOdds[] outputOdds;
}

// An individual option within a given output.
//
struct RecipeOutputOption {
    // May be 0.
    //
    uint64 itemId;
    // The min and max for item amount, if different, is a linear odd with no boosting.
    //
    uint64 itemAmountMin;
    uint64 itemAmountMax;
    // If not 0, indicates the badge the user may get for this recipe output.
    //
    uint64 badgeId;
    uint128 bugzAmount;
    // The odds this option is picked out of the RecipeOutput group.
    //
    OutputOdds optionOdds;
}

// This is a generic struct to represent the odds for any output. This could be the odds of how many outputs would be rolled,
// or the odds for a given option.
//
struct OutputOdds {
    uint32 baseOdds;
    // The itemIds to boost these odds. If this shows up ANYWHERE in the inputs, it will be boosted.
    //
    uint64[] boostItemIds;
    // For each boost item, this the change in odds from the base odds.
    //
    int32[] boostOddChanges;
}

// For event
struct CraftingItemOutcome {
    uint64[] itemIds;
    uint64[] itemAmounts;
}

struct ItemInfo {
    uint256 test;
}