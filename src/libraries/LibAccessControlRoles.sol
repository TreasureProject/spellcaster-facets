// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Assumes we are going to use the AccessControlFacet at src/access/AccessControlStorage.sol
import { AccessControlStorage } from "@openzeppelin/contracts-diamond/access/AccessControlStorage.sol";
import { LibDiamond } from "../diamond/LibDiamond.sol";
import {AccessControlEnumerableStorage} from "@openzeppelin/contracts-diamond/access/AccessControlEnumerableStorage.sol";
import {LibMeta} from './LibMeta.sol';

import {EnumerableSetUpgradeable} from "@openzeppelin/contracts-diamond/utils/structs/EnumerableSetUpgradeable.sol";

bytes32 constant ADMIN_ROLE = keccak256("ADMIN");
bytes32 constant ADMIN_GRANTER_ROLE = keccak256("ADMIN_GRANTER");
bytes32 constant UPGRADER_ROLE = keccak256("UPGRADER");
bytes32 constant ROLE_GRANTER_ROLE = keccak256("ROLE_GRANTER");

library LibAccessControlRoles {
    using AccessControlEnumerableStorage for AccessControlEnumerableStorage.Layout;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    error MissingEitherRole(address _account, bytes32 _roleOption1, bytes32 _roleOption2);
    error MissingRoleAndNotOwner(address _account, bytes32 _role);
    error MissingRole(address _account, bytes32 _role);
    error IsNotContractOwner(address _account);

    
    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    // Taken from AccessControlUpgradeable
    function hasRole(bytes32 _role, address _account) internal view returns (bool) {
        return AccessControlStorage.layout()._roles[_role].members[_account];
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            AccessControlStorage.layout()._roles[role].members[account] = true;
            emit RoleGranted(role, account, LibMeta._msgSender());
        }

        AccessControlEnumerableStorage.layout()._roleMembers[role].add(account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            AccessControlStorage.layout()._roles[role].members[account] = false;
            emit RoleRevoked(role, account, LibMeta._msgSender());
        }
  
        AccessControlEnumerableStorage.layout()._roleMembers[role].remove(account);
    }

    function requireRole(bytes32 _role, address _account) internal view {
        if (!hasRole(_role, _account)) {
            revert MissingRole(_account, _role);
        }
    }

    function requireOwner(address _account) internal view {
        if (_account != contractOwner()) {
            revert IsNotContractOwner(_account);
        }
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = LibDiamond.contractOwner();
    }

    function isCollectionAdmin(address _user, address _collection) internal view returns (bool) {
        return hasRole(keccak256(abi.encodePacked("ADMIN_ROLE_SIMPLE_CRAFTING_V1_", _collection)), _user);
    }
}
