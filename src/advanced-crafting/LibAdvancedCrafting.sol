// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import { IERC1155Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/utils/SafeERC20Upgradeable.sol";

import {
    CollectionType,
    CreateRecipeArgs,
    RecipeInputArgs,
    RecipeInputOptionArgs,
    ItemInfoArgs,
    RecipeLootTableArgs,
    RecipeLootTableOptionArgs,
    InputType
} from "src/interfaces/IAdvancedCrafting.sol";

import {
    CraftingInfo,
    RecipeInput,
    RecipeInputOption,
    LibAdvancedCraftingStorage,
    RecipeInfo,
    ItemInfo
} from "src/advanced-crafting/LibAdvancedCraftingStorage.sol";

/**
 * @title Advanced Crafting Library
 * @dev This library is used to implement features that use/update storage data for the Advanced Crafting contracts
 */
library LibAdvancedCrafting {
    using SafeERC20Upgradeable for IERC20Upgradeable;

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

    function getCraftingInfo(address _user, uint64 _craftingId) internal view returns (CraftingInfo storage) {
        return LibAdvancedCraftingStorage.layout().userToCraftingIdToInfo[_user][_craftingId];
    }

    function _requireValidRecipe(uint64 _recipeId) private view {
        if (_recipeId == 0 || _recipeId >= LibAdvancedCraftingStorage.layout().recipeIdCur) {
            revert LibAdvancedCraftingStorage.InvalidRecipeId();
        }
    }

    function _requireRecipeOwner(uint64 _recipeId, address _user) private view {
        if (_user != getRecipeInfo(_recipeId).owner) {
            revert LibAdvancedCraftingStorage.RecipeOwnerOnly();
        }
    }

    function _requireApprovedRecipe(uint64 _recipeId) private view {
        if (getRecipeInfo(_recipeId).contractsThatNeedApproved.length > 0) {
            revert LibAdvancedCraftingStorage.RecipeNotApproved();
        }
    }

    function _requireActiveRecipe(uint64 _recipeId) private view {
        RecipeInfo storage _recipeInfo = getRecipeInfo(_recipeId);
        if (
            _recipeInfo.startTime < block.timestamp
                || (_recipeInfo.endTime > 0 && _recipeInfo.endTime < block.timestamp)
        ) {
            revert LibAdvancedCraftingStorage.RecipeNotActive();
        }
    }

    function _validateAndIncrementRecipeUsage(uint64 _recipeId) private {
        RecipeInfo storage _recipeInfo = getRecipeInfo(_recipeId);
        if (_recipeInfo.maxCrafts != 0 && _recipeInfo.currentCrafts >= _recipeInfo.maxCrafts) {
            revert LibAdvancedCraftingStorage.RecipeCraftedTooManyTimes();
        }

        _recipeInfo.currentCrafts++;
    }

    function _requestRandomNumber() private returns (uint64) {
        return uint64(LibAdvancedCraftingStorage.layout().randomizer.requestRandomNumber());
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
        _requireValidRecipe(_recipeId);
        _requireRecipeOwner(_recipeId, LibMeta._msgSender());

        getRecipeInfo(_recipeId).endTime = uint64(block.timestamp);

        emit LibAdvancedCraftingStorage.RecipeDeleted(_recipeId);
    }

    function startCraftingBatch(StartCraftingParams[] calldata _params) internal {
        require(_params.length > 0, "Bad length");

        for (uint256 i = 0; i < _params.length; i++) {
            (uint64 _craftingId, bool _isRecipeInstant) = _startCrafting(_params[i]);
            if (_isRecipeInstant) {
                // No random is required if _isRecipeInstant == true.
                // Safe to pass in 0.
                //
                _endCraftingPostValidation(_craftingId, 0);
            }
        }
    }

    // Verifies recipe info, inputs, and transfers those inputs.
    // Returns if this recipe can be completed instantly
    function _startCrafting(StartCraftingParams calldata _craftingParams) private returns (uint64, bool) {
        _requireValidRecipe(_craftingParams.recipeId);
        _requireApprovedRecipe(_craftingParams.recipeId);
        _requireActiveRecipe(_craftingParams.recipeId);

        _validateAndIncrementRecipeUsage(_craftingParams.recipeId);

        uint64 _craftingId = getCraftingIdCur();
        setCraftingIdCur(_craftingId + 1);

        RecipeInfo storage _recipeInfo = getRecipeInfo(_craftingParams.recipeId);

        uint64 _totalTimeReduction = _validateAndHandleInputs(_recipeInfo, _craftingParams);

        CraftingInfo storage _userCrafting = getCraftingInfo(LibMeta._msgSender(), _craftingId);

        if (_recipeInfo.timeToComplete > _totalTimeReduction) {
            _userCrafting.timeOfCompletion = uint64(block.timestamp + _recipeInfo.timeToComplete - _totalTimeReduction);
        }

        if (_recipeInfo.isRandomRequired) {
            _userCrafting.requestId = _requestRandomNumber();
        }

        _userCrafting.recipeId = _craftingParams.recipeId;

        // Indicates if this recipe will complete in the same txn as the startCrafting txn.
        bool _isRecipeInstant = !_recipeInfo.isRandomRequired && _userCrafting.timeOfCompletion == 0;

        emit LibAdvancedCraftingStorage.CraftingStarted(
            _craftingParams.recipeId, LibMeta._msgSender(), _craftingParams.inputOptionsIndices
        );

        return (_craftingId, _isRecipeInstant);
    }

    function _validateAndHandleInputs(
        RecipeInfo storage _recipeInfo,
        StartCraftingParams calldata _craftingParams
    ) private returns (uint64 totalTimeReduction_) {
        // Because the inputs can have a given "amount" of inputs that must be supplied,
        // the input index provided, and those in the recipe may not be identical.
        uint8 _paramInputIndex;

        for (uint16 _i = 0; _i < _recipeInfo.numberOfInputs; _i++) {
            RecipeInput storage _recipeInput = _recipeInfo.indexToInput[_i];

            for (uint256 _j = 0; _j < _recipeInput.amount; _j++) {
                require(_paramInputIndex < _craftingParams.inputOptionsIndices.length, "Bad number of inputs");
                uint16 _index = _craftingParams.inputOptionsIndices[_paramInputIndex];
                _paramInputIndex++;

                if (_index >= _recipeInput.numberOfInputOptions) {
                    revert("Bad Input index");
                }

                // J must equal 0. If they are trying to skip an optional amount, it MUST be the first input supplied for the RecipeInput
                if (_j == 0 && _index == type(uint16).max && !_recipeInput.isRequired) {
                    // Break out of the amount loop. They are not providing any of the input
                    break;
                } else if (_index == type(uint16).max) {
                    revert("Supplied no input to required input");
                } else {
                    RecipeInputOption storage _inputOption = _recipeInput.indexToInputOption[_index];

                    totalTimeReduction_ += _inputOption.timeReduction;

                    if (_inputOption.inputType == InputType.BURNED) {
                        _transferAsset(_inputOption.itemInfo, LibMeta._msgSender(), address(0xdead));
                    } else if (_inputOption.inputType == InputType.TRANSFERED) {
                        _transferAsset(_inputOption.itemInfo, LibMeta._msgSender(), address(this));
                    } else {
                        // OWNED
                        _verifyOwnership(_inputOption.itemInfo, LibMeta._msgSender());
                    }
                }
            }
        }
    }

    function _transferAsset(ItemInfo storage _itemInfo, address _from, address _to) private {
        if (_itemInfo.collectionType == CollectionType.ERC1155) {
            IERC1155Upgradeable(_itemInfo.collectionAddress).safeTransferFrom(
                _from, _to, _itemInfo.tokenId, _itemInfo.amount, ""
            );
        } else {
            // ERC20
            IERC20Upgradeable(_itemInfo.collectionAddress).safeTransferFrom(_from, _to, _itemInfo.amount);
        }
    }

    function _verifyOwnership(ItemInfo storage _itemInfo, address _user) private view {
        uint256 _amountOwned;
        if (_itemInfo.collectionType == CollectionType.ERC1155) {
            _amountOwned = IERC1155Upgradeable(_itemInfo.collectionAddress).balanceOf(_user, _itemInfo.tokenId);
        } else {
            // ERC20
            _amountOwned = IERC20Upgradeable(_itemInfo.collectionAddress).balanceOf(_user);
        }

        if (_amountOwned < _itemInfo.amount) {
            revert LibAdvancedCraftingStorage.DoesNotOwnEnoughItem(
                _itemInfo.collectionAddress, _itemInfo.tokenId, _itemInfo.amount
            );
        }
    }

    function _endCraftingPostValidation(uint64 _craftingId, uint256 _randomNumber) private { }
}

struct StartCraftingParams {
    uint64 recipeId;
    uint16[] inputOptionsIndices;
}
