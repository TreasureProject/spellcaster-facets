// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAdvancedCrafting { }

struct CreateRecipeArgs {
    string name;
    uint64 startTime;
    uint64 endTime;
    uint64 timeToComplete;
    uint32 maxCrafts;
    RecipeInputArgs[] inputs;
    RecipeLootTableArgs[] lootTables;
}

struct RecipeInputArgs {
    RecipeInputOptionArgs[] options;
    uint8 amount;
    bool isRequired;
}

struct RecipeInputOptionArgs {
    ItemInfoArgs itemInfo;
    InputType inputType;
    uint64 timeReduction;
}

struct ItemInfoArgs {
    uint256 tokenId;
    uint256 amount;
    CollectionType collectionType;
    address collectionAddress;
}

struct RecipeLootTableArgs {
    RecipeLootTableOptionArgs[] options;
    uint8[] rollAmounts;
    LootTableOddsArgs[] rollOdds;
}

struct RecipeLootTableOptionArgs {
    LootTableResultArgs[] results;
    LootTableOddsArgs optionOdds;
}

struct LootTableOddsArgs {
    uint32 baseOdds;
    LootTableBoostOddsArgs[] boostOdds;
}

struct LootTableBoostOddsArgs {
    address collectionAddress;
    uint256 tokenId;
    uint256 minimumAmount;
    int32 boostOddChanges;
}

struct LootTableResultArgs {
    address collectionAddress;
    CollectionType collectionType;
    uint256 tokenId;
    uint256 amount;
    // Mint function selector. Must be (address user, uint256 tokenId, uint256 amount) for 1155 and (address user, uint256 amount) for ERC20.
    bytes4 mintSelector;
    ResultType resultType;
}

enum ResultType
// The given result is minted
{ MINT }

enum CollectionType {
    ERC1155,
    ERC20
}

enum InputType
// This input is burned. Sent to the 0xdead address.
{
    BURNED,
    // This input is transferred to the crafting contract while the craft occurs
    TRANSFERED,
    // This input is verified to be owned by the user, but not transfered.
    OWNED
}
