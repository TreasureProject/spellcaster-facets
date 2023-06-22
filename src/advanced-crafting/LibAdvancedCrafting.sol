// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import { IERC1155Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC1155/IERC1155Upgradeable.sol";
import { SafeERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/utils/SafeERC20Upgradeable.sol";
import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

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
    LootTableOutcome,
    LootTableOptionOutcome,
    CraftingInfo,
    RecipeInput,
    RecipeInputOption,
    LibAdvancedCraftingStorage,
    RecipeInfo,
    RecipeLootTable,
    ItemInfo,
    RecipeLootTableOption,
    LootTableOdds,
    CraftingStatus,
    LootTableResult,
    LootTableBoostOdds
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

    function _revealRandomNumber(uint64 _requestId) private view returns (uint256) {
        return LibAdvancedCraftingStorage.layout().randomizer.revealRandomNumber(_requestId);
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
        CraftingInfo storage _userCrafting = getCraftingInfo(LibMeta._msgSender(), _craftingId);

        uint64 _totalTimeReduction = _validateAndHandleInputs(_userCrafting, _recipeInfo, _craftingParams);

        if (_recipeInfo.timeToComplete > _totalTimeReduction) {
            _userCrafting.timeOfCompletion = uint64(block.timestamp + _recipeInfo.timeToComplete - _totalTimeReduction);
        }

        if (_recipeInfo.isRandomRequired) {
            _userCrafting.requestId = _requestRandomNumber();
        }

        _userCrafting.recipeId = _craftingParams.recipeId;
        _userCrafting.status = CraftingStatus.ACTIVE;

        // Indicates if this recipe will complete in the same txn as the startCrafting txn.
        bool _isRecipeInstant = !_recipeInfo.isRandomRequired && _userCrafting.timeOfCompletion == 0;

        emit LibAdvancedCraftingStorage.CraftingStarted(
            _craftingParams.recipeId, _craftingId, LibMeta._msgSender(), _craftingParams.inputOptionsIndices
        );

        return (_craftingId, _isRecipeInstant);
    }

    function _validateAndHandleInputs(
        CraftingInfo storage _craftingInfo,
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

                    _craftingInfo.collectionToItemIdToAmountProvided[_inputOption.itemInfo.collectionAddress][_inputOption
                        .itemInfo
                        .tokenId] += _inputOption.itemInfo.amount;

                    totalTimeReduction_ += _inputOption.timeReduction;

                    if (_inputOption.inputType == InputType.BURNED) {
                        _transferAsset(_inputOption.itemInfo, LibMeta._msgSender(), address(0xdead));
                    } else if (_inputOption.inputType == InputType.TRANSFERED) {
                        _craftingInfo.inputsToTransferBack.push(_inputOption.itemInfo);

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

    function endCraftingBatch(uint64[] calldata _craftingIds) internal {
        require(_craftingIds.length > 0, "Bad length");

        for (uint256 _i = 0; _i < _craftingIds.length; _i++) {
            _endCrafting(_craftingIds[_i]);
        }
    }

    function _endCrafting(uint64 _craftingId) private {
        CraftingInfo storage _craftingInfo = getCraftingInfo(LibMeta._msgSender(), _craftingId);
        require(_craftingInfo.user == LibMeta._msgSender(), "Not your crafting instance");
        require(block.timestamp >= _craftingInfo.timeOfCompletion, "Crafting is not complete");
        require(_craftingInfo.status == CraftingStatus.ACTIVE, "Bad crafting status");

        uint256 _randomNumber;
        if (_craftingInfo.requestId > 0) {
            _randomNumber = _revealRandomNumber(_craftingInfo.requestId);
        }

        _endCraftingPostValidation(_craftingId, _randomNumber);
    }

    function _endCraftingPostValidation(uint64 _craftingId, uint256 _randomNumber) private {
        CraftingInfo storage _craftingInfo = getCraftingInfo(LibMeta._msgSender(), _craftingId);
        RecipeInfo storage _recipeInfo = getRecipeInfo(_craftingInfo.recipeId);

        _craftingInfo.status = CraftingStatus.FINISHED;

        LootTableOutcome[] memory _outcomes = new LootTableOutcome[](_recipeInfo.numberOfLootTables);

        for (uint16 _i = 0; _i < _recipeInfo.numberOfLootTables; _i++) {
            // If needed, get a fresh random for the next output decision.
            if (_i != 0 && _randomNumber != 0) {
                _randomNumber = uint256(keccak256(abi.encodePacked(_randomNumber, _randomNumber)));
            }

            _outcomes[_i] = _determineAndMintLootTable(_recipeInfo.indexToLootTable[_i], _craftingInfo, _randomNumber);
        }

        for (uint256 i = 0; i < _craftingInfo.inputsToTransferBack.length; i++) {
            ItemInfo storage _inputToTransferBack = _craftingInfo.inputsToTransferBack[i];

            _transferAsset(_inputToTransferBack, address(this), LibMeta._msgSender());
        }

        emit LibAdvancedCraftingStorage.CraftingEnded(_craftingId, _outcomes);
    }

    function _determineAndMintLootTable(
        RecipeLootTable storage _lootTable,
        CraftingInfo storage _craftingInfo,
        uint256 _randomNumber
    ) private returns (LootTableOutcome memory _outcome) {
        uint8 _rollAmount = _determineRollAmount(_lootTable, _craftingInfo, _randomNumber);

        _randomNumber = uint256(keccak256(abi.encodePacked(_randomNumber, _randomNumber)));

        _outcome.outcomes = new LootTableOptionOutcome[](_rollAmount);

        for (uint256 _i = 0; _i < _rollAmount; _i++) {
            if (_i != 0 && _randomNumber != 0) {
                _randomNumber = uint256(keccak256(abi.encodePacked(_randomNumber, _randomNumber)));
            }

            RecipeLootTableOption storage _selectedOption =
                _determineLootTableOption(_lootTable, _craftingInfo, _randomNumber);
            _randomNumber = uint256(keccak256(abi.encodePacked(_randomNumber, _randomNumber)));

            _outcome.outcomes[_i] = _mintLootTableOption(_selectedOption);
        }
    }

    function _determineLootTableOption(
        RecipeLootTable storage _lootTable,
        CraftingInfo storage _craftingInfo,
        uint256 _randomNumber
    ) private view returns (RecipeLootTableOption storage) {
        if (_lootTable.numberOfOptions == 1) {
            return _lootTable.indexToOption[0];
        } else {
            uint256 _lootTableOptionResult = _randomNumber % 100000;
            uint32 _topRange = 0;
            for (uint16 _j = 0; _j < _lootTable.numberOfOptions; _j++) {
                RecipeLootTableOption storage _outputOption = _lootTable.indexToOption[_j];
                uint32 _adjustedOdds = _adjustLootTableOdds(_outputOption.optionOdds, _craftingInfo);
                _topRange += _adjustedOdds;
                if (_lootTableOptionResult < _topRange) {
                    return _outputOption;
                }
            }
        }

        revert("No RecipeLootTableOption found");
    }

    // Determines how many "rolls" the user has for the passed in loot table.
    function _determineRollAmount(
        RecipeLootTable storage _lootTable,
        CraftingInfo storage _craftingInfo,
        uint256 _randomNumber
    ) private view returns (uint8) {
        uint8 _rollAmount;
        if (_lootTable.rollAmounts.length == 1) {
            _rollAmount = _lootTable.rollAmounts[0];
        } else {
            uint256 _rollAmountResult = _randomNumber % 100000;
            uint32 _topRange = 0;

            for (uint16 _i = 0; _i < _lootTable.rollAmounts.length; _i++) {
                uint32 _adjustedOdds = _adjustLootTableOdds(_lootTable.rollIndexToOdds[_i], _craftingInfo);
                _topRange += _adjustedOdds;
                if (_rollAmountResult < _topRange) {
                    _rollAmount = _lootTable.rollAmounts[_i];
                    break;
                }
            }
        }
        return _rollAmount;
    }

    function _mintLootTableOption(RecipeLootTableOption storage _selectedOption)
        private
        returns (LootTableOptionOutcome memory _outcome)
    {
        _outcome.mintedItems = new ItemInfo[](_selectedOption.numberOfResults);

        for (uint16 _i; _i < _selectedOption.numberOfResults; _i++) {
            LootTableResult storage _result = _selectedOption.indexToResults[_i];

            if (_result.collectionType == CollectionType.ERC1155) {
                AddressUpgradeable.functionCall(
                    _result.collectionAddress,
                    abi.encodePacked(
                        _result.mintSelector, abi.encode(LibMeta._msgSender()), _result.tokenId, _result.amount
                    )
                );
            } else {
                // ERC20
                AddressUpgradeable.functionCall(
                    _result.collectionAddress,
                    abi.encodePacked(_result.mintSelector, abi.encode(LibMeta._msgSender()), _result.amount)
                );
            }

            _outcome.mintedItems[_i] =
                ItemInfo(_result.tokenId, _result.amount, _result.collectionType, _result.collectionAddress);
        }
    }

    function _adjustLootTableOdds(
        LootTableOdds storage _lootTableOdds,
        CraftingInfo storage _craftingInfo
    ) private view returns (uint32) {
        if (_lootTableOdds.numberOfBoostOdds == 0) {
            return _lootTableOdds.baseOdds;
        }

        int32 _trueOdds = int32(_lootTableOdds.baseOdds);

        for (uint16 _i = 0; _i < _lootTableOdds.numberOfBoostOdds; _i++) {
            LootTableBoostOdds storage _boostOdds = _lootTableOdds.indexToBoostOdds[_i];
            uint256 _amountProvided =
                _craftingInfo.collectionToItemIdToAmountProvided[_boostOdds.collectionAddress][_boostOdds.tokenId];
            if (_amountProvided < _boostOdds.minimumAmount) {
                continue;
            }

            _trueOdds += _boostOdds.boostOddChanges;
        }

        if (_trueOdds > 100000) {
            return 100000;
        } else if (_trueOdds < 0) {
            return 0;
        } else {
            return uint32(_trueOdds);
        }
    }
}

struct StartCraftingParams {
    uint64 recipeId;
    uint16[] inputOptionsIndices;
}
