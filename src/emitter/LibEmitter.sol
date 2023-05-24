// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";

import { LibEmitterStorage } from "src/emitter/LibEmitterStorage.sol";

/**
 * @title Emitter Library
 * @dev This library is used to implement features that use/update storage data for the Emitter contracts
 */
library LibEmitter { }
