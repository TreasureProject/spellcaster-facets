// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";

import {
    CreateRecipeArgs,
    RecipeInputArgs,
    RecipeInputOptionArgs,
    ItemInfoArgs,
    RecipeLootTableArgs,
    RecipeLootTableOptionArgs,
    InputType
} from "src/interfaces/IAdvancedCrafting.sol";

import { LibAdvancedCraftingStorage, RecipeInfo } from "src/advanced-crafting/LibAdvancedCraftingStorage.sol";

/**
 * @title Advanced Crafting Library
 * @dev This library is used to implement features that use/update storage data for the Advanced Crafting contracts
 */
library LibAdvancedCrafting {
    function AdvancedCrafting_init() internal {
        setRecipeIdCur(1);
        setCraftingIdCur(1);
    }

    function getRecipeIdCur() internal view returns (uint64) {
        return LibAdvancedCraftingStorage.layout().recipeIdCur;
    }

    function setRecipeIdCur(uint64 _recipeIdCur) internal {
        LibAdvancedCraftingStorage.layout().recipeIdCur = _recipeIdCur;
    }

    function getCraftingIdCur() internal view returns (uint64) {
        return LibAdvancedCraftingStorage.layout().craftingIdCur;
    }

    function setCraftingIdCur(uint64 _craftingIdCur) internal {
        LibAdvancedCraftingStorage.layout().craftingIdCur = _craftingIdCur;
    }

    function getRecipeInfo(uint64 _recipeId) internal view returns (RecipeInfo storage) {
        return LibAdvancedCraftingStorage.layout().recipeIdToInfo[_recipeId];
    }

    function requireValidRecipe(uint64 _recipeId) internal view {
        if (_recipeId == 0 || _recipeId >= LibAdvancedCraftingStorage.layout().recipeIdCur) {
            revert LibAdvancedCraftingStorage.InvalidRecipeId();
        }
    }

    function requireRecipeOwner(uint64 _recipeId, address _user) internal view {
        if (_user != getRecipeInfo(_recipeId).owner) {
            revert LibAdvancedCraftingStorage.RecipeOwnerOnly();
        }
    }

    function createRecipe(bytes32 _organizationId, CreateRecipeArgs calldata _recipeArgs) public {
        if (_recipeArgs.startTime == 0 || (_recipeArgs.endTime != 0 && _recipeArgs.startTime > _recipeArgs.endTime)) {
            revert LibAdvancedCraftingStorage.BadRecipeStartEndTime();
        }

        uint64 _recipeId = getRecipeIdCur();
        setRecipeIdCur(_recipeId + 1);

        RecipeInfo storage _recipeInfo = getRecipeInfo(_recipeId);
        _recipeInfo.name = _recipeArgs.name;
        _recipeInfo.organizationId = _organizationId;
        _recipeInfo.startTime = _recipeArgs.startTime;
        _recipeInfo.endTime = _recipeArgs.endTime;
        _recipeInfo.timeToComplete = _recipeArgs.timeToComplete;
        _recipeInfo.maxCrafts = _recipeArgs.maxCrafts;
        _recipeInfo.owner = LibMeta._msgSender();

        if (_recipeArgs.recipeHandler != address(0)) {
            _recipeInfo.recipeHandler = _recipeArgs.recipeHandler;
            _recipeInfo.contractsThatNeedApproved.push(_recipeArgs.recipeHandler);
        }

        _recipeInfo.numberOfInputs = uint16(_recipeArgs.inputs.length);
        // Input validation
        for (uint16 _i = 0; _i < _recipeArgs.inputs.length; _i++) {
            RecipeInputArgs calldata _input = _recipeArgs.inputs[_i];
            if (_input.options.length == 0) {
                revert LibAdvancedCraftingStorage.NoInputOptionsSupplied();
            }
            if (_input.amount == 0) {
                revert LibAdvancedCraftingStorage.BadInputAmount();
            }

            _recipeInfo.indexToInput[_i].amount = _input.amount;
            _recipeInfo.indexToInput[_i].isRequired = _input.isRequired;
            _recipeInfo.indexToInput[_i].numberOfInputOptions = uint16(_input.options.length);

            for (uint16 _j = 0; _j < _input.options.length; _j++) {
                RecipeInputOptionArgs calldata _inputOption = _input.options[_j];

                if (_inputOption.itemInfo.collectionAddress == address(0) && _inputOption.inputType != InputType.CUSTOM)
                {
                    revert LibAdvancedCraftingStorage.InvalidInputOption();
                }

                _recipeInfo.indexToInput[_i].indexToInputOption[_j].inputType = _inputOption.inputType;
                _recipeInfo.indexToInput[_i].indexToInputOption[_j].timeReduction = _inputOption.timeReduction;
                _recipeInfo.indexToInput[_i].indexToInputOption[_j].itemInfo.tokenId = _inputOption.itemInfo.tokenId;
                _recipeInfo.indexToInput[_i].indexToInputOption[_j].itemInfo.amount = _inputOption.itemInfo.amount;
                _recipeInfo.indexToInput[_i].indexToInputOption[_j].itemInfo.collectionType =
                    _inputOption.itemInfo.collectionType;
                _recipeInfo.indexToInput[_i].indexToInputOption[_j].itemInfo.collectionAddress =
                    _inputOption.itemInfo.collectionAddress;
            }
        }

        _recipeInfo.numberOfLootTables = uint16(_recipeArgs.lootTables.length);
        // Loot table validation.
        bool _isRandomRequiredForRecipe;
        for (uint16 _i = 0; _i < _recipeArgs.lootTables.length; _i++) {
            RecipeLootTableArgs calldata _lootTable = _recipeArgs.lootTables[_i];

            if (
                _lootTable.rollAmounts.length == 0 && _lootTable.rollAmounts.length != _lootTable.rollOdds.length
                    && _lootTable.options.length == 0
            ) {
                revert LibAdvancedCraftingStorage.BadLootTable();
            }

            _recipeInfo.indexToLootTable[_i].rollAmounts = _lootTable.rollAmounts;

            // If there is a variable amount for this LootTable or multiple options,
            // a random is required.
            _isRandomRequiredForRecipe =
                _isRandomRequiredForRecipe || _lootTable.options.length > 1 || _lootTable.rollAmounts.length > 1;

            for (uint16 _j = 0; _j < _lootTable.rollAmounts.length; _j++) {
                _recipeInfo.indexToLootTable[_i].rollIndexToOdds[_j].baseOdds = _lootTable.rollOdds[_j].baseOdds;
                _recipeInfo.indexToLootTable[_i].rollIndexToOdds[_j].numberOfBoostOdds =
                    uint16(_lootTable.rollOdds[_j].boostOdds.length);
                for (uint16 _k = 0; _k < _lootTable.rollOdds[_j].boostOdds.length; _k++) {
                    _recipeInfo.indexToLootTable[_i].rollIndexToOdds[_j].indexToBoostOdds[_k].collectionAddress =
                        _lootTable.rollOdds[_j].boostOdds[_k].collectionAddress;
                    _recipeInfo.indexToLootTable[_i].rollIndexToOdds[_j].indexToBoostOdds[_k].tokenId =
                        _lootTable.rollOdds[_j].boostOdds[_k].tokenId;
                    _recipeInfo.indexToLootTable[_i].rollIndexToOdds[_j].indexToBoostOdds[_k].minimumAmount =
                        _lootTable.rollOdds[_j].boostOdds[_k].minimumAmount;
                    _recipeInfo.indexToLootTable[_i].rollIndexToOdds[_j].indexToBoostOdds[_k].boostOddChanges =
                        _lootTable.rollOdds[_j].boostOdds[_k].boostOddChanges;
                }
            }

            _recipeInfo.indexToLootTable[_i].numberOfOptions = uint16(_lootTable.options.length);
            for (uint16 _j = 0; _j < _lootTable.options.length; _j++) {
                RecipeLootTableOptionArgs calldata _option = _lootTable.options[_j];
                _recipeInfo.indexToLootTable[_i].indexToOption[_j].optionOdds.baseOdds = _option.optionOdds.baseOdds;
                _recipeInfo.indexToLootTable[_i].indexToOption[_j].optionOdds.numberOfBoostOdds =
                    uint16(_option.optionOdds.boostOdds.length);
                for (uint16 _k = 0; _k < _option.optionOdds.boostOdds.length; _k++) {
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].optionOdds.indexToBoostOdds[_k].collectionAddress
                    = _option.optionOdds.boostOdds[_k].collectionAddress;
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].optionOdds.indexToBoostOdds[_k].tokenId =
                        _option.optionOdds.boostOdds[_k].tokenId;
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].optionOdds.indexToBoostOdds[_k].minimumAmount =
                        _option.optionOdds.boostOdds[_k].minimumAmount;
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].optionOdds.indexToBoostOdds[_k].boostOddChanges =
                        _option.optionOdds.boostOdds[_k].boostOddChanges;
                }

                _recipeInfo.indexToLootTable[_i].indexToOption[_j].numberOfResults = uint16(_option.results.length);
                for (uint16 _k = 0; _k < _option.results.length; _k++) {
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].indexToResults[_k].collectionAddress =
                        _option.results[_k].collectionAddress;
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].indexToResults[_k].collectionType =
                        _option.results[_k].collectionType;
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].indexToResults[_k].tokenId =
                        _option.results[_k].tokenId;
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].indexToResults[_k].amount =
                        _option.results[_k].amount;
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].indexToResults[_k].mintSelector =
                        _option.results[_k].mintSelector;
                    _recipeInfo.indexToLootTable[_i].indexToOption[_j].indexToResults[_k].resultType =
                        _option.results[_k].resultType;

                    // Track this collection as one that needs to be approved.
                    if (_option.results[_k].collectionAddress != address(0)) {
                        bool _wasFound = false;

                        for (uint16 _l = 0; _l < _recipeInfo.contractsThatNeedApproved.length; _l++) {
                            if (_recipeInfo.contractsThatNeedApproved[_l] == _option.results[_k].collectionAddress) {
                                _wasFound = true;
                                break;
                            }
                        }

                        if (!_wasFound) {
                            _recipeInfo.contractsThatNeedApproved.push(_option.results[_k].collectionAddress);
                        }
                    }
                }
            }
        }

        _recipeInfo.isRandomRequired = _isRandomRequiredForRecipe;

        emit LibAdvancedCraftingStorage.RecipeCreated(
            _recipeId, _organizationId, _recipeArgs, _isRandomRequiredForRecipe
        );
    }

    function deleteRecipe(uint64 _recipeId) public {
        requireValidRecipe(_recipeId);
        requireRecipeOwner(_recipeId, LibMeta._msgSender());

        getRecipeInfo(_recipeId).endTime = uint64(block.timestamp);

        emit LibAdvancedCraftingStorage.RecipeDeleted(_recipeId);
    }
}
