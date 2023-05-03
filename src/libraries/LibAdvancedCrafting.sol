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

import { AdvancedCraftingStorage, RecipeInfo } from "src/advanced-crafting/AdvancedCraftingStorage.sol";

/**
 * @title Advanced Crafting Library
 * @dev This library is used to implement features that use/update storage data for the Advanced Crafting contracts
 */
library LibAdvancedCrafting {
    function getRecipeIdCur() public view returns (uint64) {
        return AdvancedCraftingStorage.layout().recipeIdCur;
    }

    function setRecipeIdCur(uint64 _recipeIdCur) public {
        AdvancedCraftingStorage.layout().recipeIdCur = _recipeIdCur;
    }

    function getCraftingIdCur() public view returns (uint64) {
        return AdvancedCraftingStorage.layout().craftingIdCur;
    }

    function setCraftingIdCur(uint64 _craftingIdCur) public {
        AdvancedCraftingStorage.layout().craftingIdCur = _craftingIdCur;
    }

    function getRecipeInfo(uint64 _recipeId) internal view returns (RecipeInfo storage) {
        return AdvancedCraftingStorage.layout().recipeIdToInfo[_recipeId];
    }

    function requireValidRecipe(uint64 _recipeId) internal view {
        if (_recipeId == 0 || _recipeId >= AdvancedCraftingStorage.layout().recipeIdCur) {
            revert AdvancedCraftingStorage.InvalidRecipeId();
        }
    }

    function requireRecipeOwner(uint64 _recipeId, address _user) internal view {
        if (_user != getRecipeInfo(_recipeId).owner) {
            revert AdvancedCraftingStorage.RecipeOwnerOnly();
        }
    }

    function createRecipe(bytes32 _organizationId, CreateRecipeArgs calldata _recipeArgs) public {
        if (_recipeArgs.startTime == 0 || (_recipeArgs.endTime != 0 && _recipeArgs.startTime > _recipeArgs.endTime)) {
            revert AdvancedCraftingStorage.BadRecipeStartEndTime();
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
        for (uint16 i = 0; i < _recipeArgs.inputs.length; i++) {
            RecipeInputArgs calldata _input = _recipeArgs.inputs[i];
            if (_input.options.length == 0) {
                revert AdvancedCraftingStorage.NoInputOptionsSupplied();
            }
            if (_input.amount == 0) {
                revert AdvancedCraftingStorage.BadInputAmount();
            }

            _recipeInfo.indexToInput[i].amount = _input.amount;
            _recipeInfo.indexToInput[i].isRequired = _input.isRequired;
            _recipeInfo.indexToInput[i].numberOfInputOptions = uint16(_input.options.length);

            for (uint16 j = 0; j < _input.options.length; j++) {
                RecipeInputOptionArgs calldata _inputOption = _input.options[j];

                if (_inputOption.itemInfo.collectionAddress == address(0) && _inputOption.inputType != InputType.CUSTOM)
                {
                    revert AdvancedCraftingStorage.InvalidInputOption();
                }

                _recipeInfo.indexToInput[i].indexToInputOption[j].inputType = _inputOption.inputType;
                _recipeInfo.indexToInput[i].indexToInputOption[j].timeReduction = _inputOption.timeReduction;
                _recipeInfo.indexToInput[i].indexToInputOption[j].itemInfo.tokenId = _inputOption.itemInfo.tokenId;
                _recipeInfo.indexToInput[i].indexToInputOption[j].itemInfo.amount = _inputOption.itemInfo.amount;
                _recipeInfo.indexToInput[i].indexToInputOption[j].itemInfo.collectionType =
                    _inputOption.itemInfo.collectionType;
                _recipeInfo.indexToInput[i].indexToInputOption[j].itemInfo.collectionAddress =
                    _inputOption.itemInfo.collectionAddress;
            }
        }

        _recipeInfo.numberOfLootTables = uint16(_recipeArgs.lootTables.length);
        // Loot table validation.
        bool _isRandomRequiredForRecipe;
        for (uint16 i = 0; i < _recipeArgs.lootTables.length; i++) {
            RecipeLootTableArgs calldata _lootTable = _recipeArgs.lootTables[i];

            if (
                _lootTable.rollAmounts.length == 0 && _lootTable.rollAmounts.length != _lootTable.rollOdds.length
                    && _lootTable.options.length == 0
            ) {
                revert AdvancedCraftingStorage.BadLootTable();
            }

            _recipeInfo.indexToLootTable[i].rollAmounts = _lootTable.rollAmounts;

            // If there is a variable amount for this LootTable or multiple options,
            // a random is required.
            _isRandomRequiredForRecipe =
                _isRandomRequiredForRecipe || _lootTable.options.length > 1 || _lootTable.rollAmounts.length > 1;

            for (uint16 j = 0; j < _lootTable.rollAmounts.length; j++) {
                _recipeInfo.indexToLootTable[i].rollIndexToOdds[j].baseOdds = _lootTable.rollOdds[j].baseOdds;
                _recipeInfo.indexToLootTable[i].rollIndexToOdds[j].numberOfBoostOdds =
                    uint16(_lootTable.rollOdds[j].boostOdds.length);
                for (uint16 k = 0; k < _lootTable.rollOdds[j].boostOdds.length; k++) {
                    _recipeInfo.indexToLootTable[i].rollIndexToOdds[j].indexToBoostOdds[k].collectionAddress =
                        _lootTable.rollOdds[j].boostOdds[k].collectionAddress;
                    _recipeInfo.indexToLootTable[i].rollIndexToOdds[j].indexToBoostOdds[k].tokenId =
                        _lootTable.rollOdds[j].boostOdds[k].tokenId;
                    _recipeInfo.indexToLootTable[i].rollIndexToOdds[j].indexToBoostOdds[k].minimumAmount =
                        _lootTable.rollOdds[j].boostOdds[k].minimumAmount;
                    _recipeInfo.indexToLootTable[i].rollIndexToOdds[j].indexToBoostOdds[k].boostOddChanges =
                        _lootTable.rollOdds[j].boostOdds[k].boostOddChanges;
                }
            }

            _recipeInfo.indexToLootTable[i].numberOfOptions = uint16(_lootTable.options.length);
            for (uint16 j = 0; j < _lootTable.options.length; j++) {
                RecipeLootTableOptionArgs calldata _option = _lootTable.options[j];
                _recipeInfo.indexToLootTable[i].indexToOption[j].optionOdds.baseOdds = _option.optionOdds.baseOdds;
                _recipeInfo.indexToLootTable[i].indexToOption[j].optionOdds.numberOfBoostOdds =
                    uint16(_option.optionOdds.boostOdds.length);
                for (uint16 k = 0; k < _option.optionOdds.boostOdds.length; k++) {
                    _recipeInfo.indexToLootTable[i].indexToOption[j].optionOdds.indexToBoostOdds[k].collectionAddress =
                        _option.optionOdds.boostOdds[k].collectionAddress;
                    _recipeInfo.indexToLootTable[i].indexToOption[j].optionOdds.indexToBoostOdds[k].tokenId =
                        _option.optionOdds.boostOdds[k].tokenId;
                    _recipeInfo.indexToLootTable[i].indexToOption[j].optionOdds.indexToBoostOdds[k].minimumAmount =
                        _option.optionOdds.boostOdds[k].minimumAmount;
                    _recipeInfo.indexToLootTable[i].indexToOption[j].optionOdds.indexToBoostOdds[k].boostOddChanges =
                        _option.optionOdds.boostOdds[k].boostOddChanges;
                }

                _recipeInfo.indexToLootTable[i].indexToOption[j].numberOfResults = uint16(_option.results.length);
                for (uint16 k = 0; k < _option.results.length; k++) {
                    _recipeInfo.indexToLootTable[i].indexToOption[j].indexToResults[k].collectionAddress =
                        _option.results[k].collectionAddress;
                    _recipeInfo.indexToLootTable[i].indexToOption[j].indexToResults[k].collectionType =
                        _option.results[k].collectionType;
                    _recipeInfo.indexToLootTable[i].indexToOption[j].indexToResults[k].tokenId =
                        _option.results[k].tokenId;
                    _recipeInfo.indexToLootTable[i].indexToOption[j].indexToResults[k].amount =
                        _option.results[k].amount;
                    _recipeInfo.indexToLootTable[i].indexToOption[j].indexToResults[k].mintSelector =
                        _option.results[k].mintSelector;
                    _recipeInfo.indexToLootTable[i].indexToOption[j].indexToResults[k].resultType =
                        _option.results[k].resultType;

                    // Track this collection as one that needs to be approved.
                    if (_option.results[k].collectionAddress != address(0)) {
                        bool _wasFound = false;

                        for (uint16 l = 0; l < _recipeInfo.contractsThatNeedApproved.length; l++) {
                            if (_recipeInfo.contractsThatNeedApproved[l] == _option.results[k].collectionAddress) {
                                _wasFound = true;
                                break;
                            }
                        }

                        if (!_wasFound) {
                            _recipeInfo.contractsThatNeedApproved.push(_option.results[k].collectionAddress);
                        }
                    }
                }
            }
        }

        _recipeInfo.isRandomRequired = _isRandomRequiredForRecipe;

        emit AdvancedCraftingStorage.RecipeCreated(_recipeId, _organizationId, _recipeArgs, _isRandomRequiredForRecipe);
    }

    function deleteRecipe(uint64 _recipeId) public {
        requireValidRecipe(_recipeId);
        requireRecipeOwner(_recipeId, LibMeta._msgSender());

        getRecipeInfo(_recipeId).endTime = uint64(block.timestamp);

        emit AdvancedCraftingStorage.RecipeDeleted(_recipeId);
    }
}
