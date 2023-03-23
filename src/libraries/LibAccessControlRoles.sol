// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Assumes we are going to use the AccessControlFacet at src/access/AccessControlStorage.sol
import { AccessControlStorage } from "@openzeppelin/contracts-diamond/access/AccessControlStorage.sol";
import { LibDiamond } from "../diamond/LibDiamond.sol";

bytes32 constant ADMIN_ROLE = keccak256("ADMIN");
bytes32 constant ADMIN_GRANTER_ROLE = keccak256("ADMIN_GRANTER");
bytes32 constant UPGRADER_ROLE = keccak256("UPGRADER");
bytes32 constant ROLE_GRANTER_ROLE = keccak256("ROLE_GRANTER");

library LibAccessControlRoles {
    error MissingEitherRole(address _account, bytes32 _roleOption1, bytes32 _roleOption2);
    error MissingRoleAndNotOwner(address _account, bytes32 _role);
    error MissingRole(address _account, bytes32 _role);
    error IsNotContractOwner(address _account);

    // Taken from AccessControlUpgradeable
    function hasRole(bytes32 _role, address _account) internal view returns (bool) {
        return AccessControlStorage.layout()._roles[_role].members[_account];
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
