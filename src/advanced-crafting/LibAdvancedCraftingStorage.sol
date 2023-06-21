//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { CreateRecipeArgs, ResultType, CollectionType, InputType } from "src/interfaces/IAdvancedCrafting.sol";

library LibAdvancedCraftingStorage {
    struct Layout {
        /**
         * @dev Returns a recipe for the given id
         */
        mapping(uint64 => RecipeInfo) recipeIdToInfo;
        /**
         * @dev Returns info about a specific crafting instance for the given user and id.
         */
        mapping(address => mapping(uint64 => CraftingInfo)) userToCraftingIdToInfo;
        /**
         * @dev The next recipe ID that will be used for the next created recipe
         */
        uint64 recipeIdCur;
        /**
         * @dev The next crafting instance ID that will be used for the next craft started
         */
        uint64 craftingIdCur;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.crafting.advanced");

    function layout() internal pure returns (Layout storage l_) {
        bytes32 _position = FACET_STORAGE_POSITION;
        assembly {
            l_.slot := _position
        }
    }

    event RecipeCreated(
        uint64 indexed recipeId, bytes32 indexed organizationId, CreateRecipeArgs recipeArgs, bool isRandomRequired
    );

    event RecipeDeleted(uint64 indexed recipeId);

    error InvalidRecipeId();

    error RecipeOwnerOnly();

    error BadRecipeStartEndTime();

    error NoInputOptionsSupplied();

    error InvalidInputOption();

    error BadInputAmount();

    error BadLootTable();
}

struct CraftingInfo {
    CraftingStatus status;
    uint64 timeOfCompletion;
    uint64 recipeId;
    uint64 requestId;
}
// Maybe store which inputs were used?

enum CraftingStatus {
    INACTIVE,
    ACTIVE,
    FINISHED
}

/**
 * @dev Stores all data related to a recipe
 * @param name The name of the recipe. Only used for external tracking purposes
 * @param organizationId The organization id that this recipe belongs to.
 * @param startTime The time that this recipe becomes available
 * @param endTime If not 0, the time that this recipe becomes unavailable
 * @param timeToComplete The amount of time this recipe takes to complete. If 0, this recipe may complete instantly
 * @param maxCrafts The maximum number of times this recipe can be crafted across all users
 * @param currentCrafts The current number of times this recipe has been crafted
 * @param contractsThatNeedApproved A list of contracts that must be approved for this recipe. These are the handler and contracts that will be minted from.
 * @param contractToIsApproved A mapping of a contract address to whether it has been approved.
 * @param indexToInput Stores a given input that the recipe requires at a given index
 * @param indexToLootTable Stores a given loot table that the recipe contains at a given index
 * @param numberOfInputs The number of inputs this recipe has
 * @param numberOfLootTables The number of loot tables this recipe has
 * @param isRandomRequired Indicates if the crafting recipe requires a random number.
 * If it does, it will be split into two transactions. The recipe may still be split into two txns regardless if the recipe takes time.
 * @param isRecipeApproved Indicates if all the necessary contractsThatNeedApproved have been approved. This way, no looping needs to be done when the craft occurs.
 * @param recipeHandler If set, this contract will handle custom hooks or custom inputs/outputs for this recipe.
 * @param owner The owner of the recipe
 */
struct RecipeInfo {
    // Slot 1
    string name;
    // Slot 2
    bytes32 organizationId;
    // Slot 3
    uint64 startTime;
    uint64 endTime;
    uint64 timeToComplete;
    uint32 maxCrafts;
    uint32 currentCrafts;
    // Slot 4
    address[] contractsThatNeedApproved;
    // Slot 5
    mapping(address => bool) contractToIsApproved;
    // Slot 6
    mapping(uint16 => RecipeInput) indexToInput;
    // Slot 7
    mapping(uint16 => RecipeLootTable) indexToLootTable;
    // Slot 8 (208/256)
    uint16 numberOfInputs;
    uint16 numberOfLootTables;
    bool isRandomRequired;
    bool isRecipeApproved;
    address recipeHandler;
    // Slot 9 (160/256)
    address owner;
}

/**
 * @dev This struct represents a single input requirement for a recipe. This may have multiple options that can satisfy the "input".
 * @param indexToInputOption Stores a given option that the input requires at a given index
 * @param numberOfOutputs The number of options this recipe has
 * @param amount The amount of times this input needs to be provided. i.e. 11 options to choose from. Any 3 need to be provided.
 * @param isRequired Indicates if this input MUST be satisifed.
 */
struct RecipeInput {
    // Slot 1
    mapping(uint16 => RecipeInputOption) indexToInputOption;
    // Slot 2 (32/256)
    uint16 numberOfInputOptions;
    uint8 amount;
    bool isRequired;
}

/**
 * @dev Represents a single option for a given input requirement for a recipe
 * @param itemInfo The item that can be supplied
 * @param inputType Indicates the type of input this is
 * @param timeReduction he amount of time using this input will reduce the recipe time by
 */
struct RecipeInputOption {
    // Slot 1-3
    ItemInfo itemInfo;
    // Slot 4 (72/256)
    InputType inputType;
    uint64 timeReduction;
}

/**
 * @dev Represents an individual loot table for a recipe. This loot table may have multiple options within it.
 * It also may have a chance associated with it via the rollAmounts/rollOdds
 * @param indexToOption The option at a given index
 * @param rollAmount This array will indicate how many times the loot table options are rolled.
 * This may have 0, indicating that this RecipeLootTable may not be received.
 * @param rollIndexToOdds For each rollAmount (based on index), this contains the odds for that roll
 * @param numberOfOptions The number of options for this loot box
 */
struct RecipeLootTable {
    // Slot 1
    mapping(uint16 => RecipeLootTableOption) indexToOption;
    // Slot 2
    uint8[] rollAmounts;
    // Slot 3
    mapping(uint16 => LootTableOdds) rollIndexToOdds;
    // Slot 4 (16/256)
    uint16 numberOfOptions;
}

/**
 * @dev Represents an individual loot table option for a given loot table.
 * @param indexToResults The items that will be minted for this option. May include custom handling as well.
 * @param optionOdds The odds this option will be selected
 * @param numberOfResults The number of results this option contains
 */
struct RecipeLootTableOption {
    // Slot 1
    mapping(uint16 => LootTableResult) indexToResults;
    // Slot 2-4
    LootTableOdds optionOdds;
    // Slot 5 (16/256)
    uint16 numberOfResults;
}

/**
 * @dev This is a generic struct to represent the odds for anything related to loot tables.
 * @param baseOdds The base odds out of 100,000 (100% = 100,000).
 * @param numberOfBoostOdds The number of boosting odds this odds has.
 * @param indexToBoostOdds If any of the following appear as an input, the baseOdds will be boosted by the given amount.
 */
struct LootTableOdds {
    // Slot 1 (47/256)
    uint32 baseOdds;
    uint16 numberOfBoostOdds;
    // Slot 2
    mapping(uint16 => LootTableBoostOdds) indexToBoostOdds;
}

struct LootTableBoostOdds {
    address collectionAddress;
    uint256 tokenId;
    uint256 minimumAmount;
    int32 boostOddChanges;
}

struct LootTableResult {
    address collectionAddress;
    CollectionType collectionType;
    uint256 tokenId;
    uint256 amount;
    // Mint function selector. Must be (address user, uint256 tokenId, uint256 amount) for 1155 and (address user, uint256 amount) for ERC20.
    bytes4 mintSelector;
    ResultType resultType;
}

struct ItemInfo {
    // Slot 1
    uint256 tokenId;
    // Slot 2
    uint256 amount;
    // Slot 3 (168/256)
    CollectionType collectionType;
    address collectionAddress;
}
