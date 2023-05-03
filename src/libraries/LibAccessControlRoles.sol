// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Assumes we are going to use the AccessControlFacet at src/access/AccessControlStorage.sol
import { AccessControlStorage } from "@openzeppelin/contracts-diamond/access/AccessControlStorage.sol";
import { LibDiamond } from "../diamond/LibDiamond.sol";
import { AccessControlEnumerableStorage } from
    "@openzeppelin/contracts-diamond/access/AccessControlEnumerableStorage.sol";
import { LibMeta } from "./LibMeta.sol";

import { EnumerableSetUpgradeable } from "@openzeppelin/contracts-diamond/utils/structs/EnumerableSetUpgradeable.sol";

bytes32 constant ADMIN_ROLE = keccak256("ADMIN");
bytes32 constant ADMIN_GRANTER_ROLE = keccak256("ADMIN_GRANTER");
bytes32 constant UPGRADER_ROLE = keccak256("UPGRADER");
bytes32 constant ROLE_GRANTER_ROLE = keccak256("ROLE_GRANTER");

library LibAccessControlRoles {
    using AccessControlEnumerableStorage for AccessControlEnumerableStorage.Layout;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /**
     * @dev Emitted when an account is missing a role from two options.
     * @param _account The account address
     * @param _roleOption1 The first role option
     * @param _roleOption2 The second role option
     */
    error MissingEitherRole(address _account, bytes32 _roleOption1, bytes32 _roleOption2);

    /**
     * @dev Emitted when an account does not have a given role and is not owner.
     * @param _account The account address
     * @param _role The role
     */
    error MissingRoleAndNotOwner(address _account, bytes32 _role);

    /**
     * @dev Emitted when an account does not have a given role.
     * @param _account The account address
     * @param _role The role
     */
    error MissingRole(address _account, bytes32 _role);

    /**
     * @dev Emitted when an account is not contract owner.
     * @param _account The account address
     */
    error IsNotContractOwner(address _account);

    /**
     * @dev Emitted when an account is not a collection admin.
     * @param _account The account address
     * @param _collection The collection address
     */
    error IsNotCollectionAdmin(address _account, address _collection);

    /**
     * @dev Emitted when an account is not a collection role granter.
     * @param _account The account address
     * @param _collection The collection address
     */
    error IsNotCollectionRoleGranter(address _account, address _collection);

    /**
     * @dev Error when trying to terminate a guild but you are not a guild terminator
     * @param _account The address of the sender
     * @param _organizationId The ID of the guild's organization
     * @param _guildId The ID of the guild
     */
    error IsNotGuildTerminator(address _account, bytes32 _organizationId, uint32 _guildId);

    /**
     * @dev Error when trying to interact with an admin function of a guild but you are not a guild admin
     * @param _account The address of the sender
     * @param _organizationId The ID of the guild's organization
     * @param _guildId The ID of the guild
     */
    error IsNotGuildAdmin(address _account, bytes32 _organizationId, uint32 _guildId);

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

    /**
     * @dev Require an address has a specific role
     * @param _role The role to check.
     * @param _account The address to check.
     */
    function requireRole(bytes32 _role, address _account) internal view {
        if (!hasRole(_role, _account)) {
            revert MissingRole(_account, _role);
        }
    }

    /**
     * @dev Requires the inputted address to be the contract owner.
     * @param _account The address of the signer.
     */
    function requireOwner(address _account) internal view {
        if (_account != contractOwner()) {
            revert IsNotContractOwner(_account);
        }
    }

    /**
     * @dev Returns the current diamond contract owner.
     * @return contractOwner_ The address of the owner
     */
    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = LibDiamond.contractOwner();
    }

    /**
     * @dev Returns whether the inputted address is the inputted collection admin.
     * @param _account The address of the admin.
     * @param _collection The address of the collection.
     */
    function isCollectionAdmin(address _account, address _collection) internal view returns (bool) {
        return hasRole(getCollectionAdminRole(_collection), _account);
    }

    /**
     * @dev Returns whether the inputted address is the inputted collection role granter.
     * @param _account The address of the role granter.
     * @param _collection The address of the collection.
     */
    function isCollectionRoleGranter(address _account, address _collection) internal view returns (bool) {
        return hasRole(getCollectionRoleGranterRole(_collection), _account);
    }

    /**
     * @dev Requires the inputted address to be the inputted collection role granter.
     * @param _account The address of the admin.
     * @param _collection The address of the collection.
     */
    function requireCollectionAdmin(address _account, address _collection) internal view {
        if (!isCollectionAdmin(_account, _collection)) revert IsNotCollectionAdmin(_account, _collection);
    }

    /**
     * @dev Requires the inputted address to be the inputted collection role granter.
     * @param _account The address of the role granter.
     * @param _collection The address of the collection.
     */
    function requireCollectionRoleGranter(address _account, address _collection) internal view {
        if (!isCollectionRoleGranter(_account, _collection)) revert IsNotCollectionRoleGranter(_account, _collection);
    }

    /**
     * @dev Give the collection role granter role to this account.
     * @param _account The address of the account to grant.
     * @param _collection The address of the collection.
     */
    function grantCollectionRoleGranter(address _account, address _collection) internal {
        _grantRole(getCollectionRoleGranterRole(_collection), _account);
    }

    /**
     * @dev Give the collection admin role to this account.
     * @param _account The address of the account to grant.
     * @param _collection The address of the collection.
     */
    function grantCollectionAdmin(address _account, address _collection) internal {
        _grantRole(getCollectionAdminRole(_collection), _account);
    }


    function getCollectionRoleGranterRole(address _collection) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("COLLECTION_ROLE_GRANTER_ROLE_", _collection));
    }

    function getCollectionAdminRole(address _collection) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("COLLECTION_ADMIN_ROLE_", _collection));
    }

    /**
     * @dev Give the guild terminator role to this account.
     * @param _account The address of the account to grant.
     * @param _organizationId The organization Id of this guild
     * @param _guildId The guild Id
     */
    function grantGuildTerminator(address _account, bytes32 _organizationId, uint32 _guildId) internal {
        _grantRole(getGuildTerminatorRole(_organizationId, _guildId), _account);
    }

    function getGuildTerminatorRole(bytes32 _organizationId, uint32 _guildId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("TERMINATOR_ROLE_", keccak256(abi.encodePacked(_organizationId)), keccak256(abi.encodePacked(_guildId))));
    }

    /**
     * @dev Returns whether the inputted address is a guild terminator
     * @param _account The address of the account.
     * @param _organizationId The organization Id of this guild
     * @param _guildId The guild Id
     */
    function isGuildTerminator(address _account, bytes32 _organizationId, uint32 _guildId) internal view returns (bool) {
        return hasRole(getGuildTerminatorRole(_organizationId, _guildId), _account);
    }

    function requireGuildTerminator(address _account, bytes32 _organizationId, uint32 _guildId) internal view {
        if (!isGuildTerminator(_account, _organizationId, _guildId)) revert IsNotGuildTerminator(_account, _organizationId, _guildId);
    }

    
    /**
     * @dev Give the guild admin role to this account.
     * @param _account The address of the account to grant.
     * @param _organizationId The organization Id of this guild
     * @param _guildId The guild Id
     */
    function grantGuildAdmin(address _account, bytes32 _organizationId, uint32 _guildId) internal {
        _grantRole(getGuildAdminRole(_organizationId, _guildId), _account);
    }

    function getGuildAdminRole(bytes32 _organizationId, uint32 _guildId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("ADMIN_ROLE_", keccak256(abi.encodePacked(_organizationId)), keccak256(abi.encodePacked(_guildId))));
    }

    /**
     * @dev Returns whether the inputted address is a guild admin
     * @param _account The address of the account.
     * @param _organizationId The organization Id of this guild
     * @param _guildId The guild Id
     */
    function isGuildAdmin(address _account, bytes32 _organizationId, uint32 _guildId) internal view returns (bool) {
        return hasRole(getGuildAdminRole(_organizationId, _guildId), _account);
    }

    function requireGuildAdmin(address _account, bytes32 _organizationId, uint32 _guildId) internal view {
        if (!isGuildAdmin(_account, _organizationId, _guildId)) revert IsNotGuildAdmin(_account, _organizationId, _guildId);
    }

}
