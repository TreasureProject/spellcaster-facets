// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/IERC721Upgradeable.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import { LibAccessControlRoles } from "src/libraries/LibAccessControlRoles.sol";

import {
    IGuildManager,
    GuildInfo,
    GuildCreationRule,
    GuildUserInfo,
    GuildUserStatus,
    GuildOrganizationInfo,
    GuildOrganizationUserInfo,
    MaxUsersPerGuildRule,
    GuildStatus
} from "src/interfaces/IGuildManager.sol";
import { IGuildToken } from "src/interfaces/IGuildToken.sol";
import { ICustomGuildManager } from "src/interfaces/ICustomGuildManager.sol";
import { LibOrganizationManager } from "src/libraries/LibOrganizationManager.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";

import { GuildManagerStorage } from "src/guilds/guildmanager/GuildManagerStorage.sol";

/**
 * @title Guild Manager Library
 * @dev This library is used to implement features that use/update storage data for the Guild Manager contracts
 */
library LibGuildManager {
    // =============================================================
    //                    State Getters/Setters
    // =============================================================

    function setTreasureTagNFTAddress(address _treasureTagNFTAddress) internal {
        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();

        l.treasureTagNFTAddress = _treasureTagNFTAddress;
    }

    function setGuildTokenBeacon(address _beaconImplAddress) internal {
        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();

        if (address(l.guildTokenBeacon) == address(0)) {
            l.guildTokenBeacon = new UpgradeableBeacon(_beaconImplAddress);
        } else if (l.guildTokenBeacon.implementation() != _beaconImplAddress) {
            l.guildTokenBeacon.upgradeTo(_beaconImplAddress);
        }
    }

    function getGuildTokenBeacon() internal view returns (UpgradeableBeacon beacon_) {
        beacon_ = GuildManagerStorage.layout().guildTokenBeacon;
    }

    /**
     * @param _organizationId The id of the org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getGuildOrganizationInfo(bytes32 _organizationId)
        internal
        view
        returns (GuildOrganizationInfo storage info_)
    {
        info_ = GuildManagerStorage.layout().guildOrganizationInfo[_organizationId];
    }

    /**
     * @param _organizationId The id of the org that contains the guild to retrieve info for
     * @param _guildId The id of the guild within the given org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getGuildInfo(bytes32 _organizationId, uint32 _guildId) internal view returns (GuildInfo storage info_) {
        info_ = GuildManagerStorage.layout().organizationIdToGuildIdToInfo[_organizationId][_guildId];
    }

    /**
     * @param _organizationId The id of the org that contains the user to retrieve info for
     * @param _user The id of the user within the given org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getUserInfo(
        bytes32 _organizationId,
        address _user
    ) internal view returns (GuildOrganizationUserInfo storage info_) {
        info_ = GuildManagerStorage.layout().organizationIdToAddressToInfo[_organizationId][_user];
    }

    /**
     * @param _organizationId The id of the org that contains the user to retrieve info for
     * @param _guildId The id of the guild within the given org to retrieve user info for
     * @param _user The id of the user to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getGuildUserInfo(
        bytes32 _organizationId,
        uint32 _guildId,
        address _user
    ) internal view returns (GuildUserInfo storage info_) {
        info_ = GuildManagerStorage.layout().organizationIdToGuildIdToInfo[_organizationId][_guildId]
            .addressToGuildUserInfo[_user];
    }

    // =============================================================
    //                  GuildOrganization Settings
    // =============================================================

    function setMaxGuildsPerUser(bytes32 _organizationId, uint8 _maxGuildsPerUser) internal {
        require(_maxGuildsPerUser > 0, "maxGuildsPerUser must be greater than 0");

        getGuildOrganizationInfo(_organizationId).maxGuildsPerUser = _maxGuildsPerUser;
        emit GuildManagerStorage.MaxGuildsPerUserUpdated(_organizationId, _maxGuildsPerUser);
    }

    function setTimeoutAfterLeavingGuild(bytes32 _organizationId, uint32 _timeoutAfterLeavingGuild) internal {
        getGuildOrganizationInfo(_organizationId).timeoutAfterLeavingGuild = _timeoutAfterLeavingGuild;
        emit GuildManagerStorage.TimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
    }

    function setGuildCreationRule(bytes32 _organizationId, GuildCreationRule _guildCreationRule) internal {
        getGuildOrganizationInfo(_organizationId).creationRule = _guildCreationRule;
        emit GuildManagerStorage.GuildCreationRuleUpdated(_organizationId, _guildCreationRule);
    }

    function setMaxUsersPerGuild(
        bytes32 _organizationId,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant
    ) internal {
        getGuildOrganizationInfo(_organizationId).maxUsersPerGuildRule = _maxUsersPerGuildRule;
        getGuildOrganizationInfo(_organizationId).maxUsersPerGuildConstant = _maxUsersPerGuildConstant;
        emit GuildManagerStorage.MaxUsersPerGuildUpdated(
            _organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant
        );
    }

    function setCustomGuildManagerAddress(bytes32 _organizationId, address _customGuildManagerAddress) internal {
        getGuildOrganizationInfo(_organizationId).customGuildManagerAddress = _customGuildManagerAddress;
        emit GuildManagerStorage.CustomGuildManagerAddressUpdated(_organizationId, _customGuildManagerAddress);
    }

    function setRequireTreasureTagForGuilds(bytes32 _organizationId, bool _requireTreasureTagForGuilds) internal {
        getGuildOrganizationInfo(_organizationId).requireTreasureTagForGuilds = _requireTreasureTagForGuilds;

        emit GuildManagerStorage.RequireTreasureTagForGuildsUpdated(_organizationId, _requireTreasureTagForGuilds);
    }

    // =============================================================
    //                  Guild Settings
    // =============================================================

    /**
     * @dev Assumes permissions have already been checked (only guild owner)
     */
    function setGuildInfo(
        bytes32 _organizationId,
        uint32 _guildId,
        string calldata _name,
        string calldata _description
    ) internal onlyActiveGuild(_organizationId, _guildId) {
        GuildInfo storage _guildInfo = getGuildInfo(_organizationId, _guildId);

        _guildInfo.name = _name;
        _guildInfo.description = _description;

        emit GuildManagerStorage.GuildInfoUpdated(_organizationId, _guildId, _name, _description);
    }

    /**
     * @dev Assumes permissions have already been checked (only guild owner)
     */
    function setGuildSymbol(
        bytes32 _organizationId,
        uint32 _guildId,
        string calldata _symbolImageData,
        bool _isSymbolOnChain
    ) internal onlyActiveGuild(_organizationId, _guildId) {
        GuildInfo storage _guildInfo = getGuildInfo(_organizationId, _guildId);

        _guildInfo.symbolImageData = _symbolImageData;
        _guildInfo.isSymbolOnChain = _isSymbolOnChain;

        emit GuildManagerStorage.GuildSymbolUpdated(_organizationId, _guildId, _symbolImageData, _isSymbolOnChain);
    }

    function getMaxUsersForGuild(bytes32 _organizationId, uint32 _guildId) internal view returns (uint32) {
        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();
        address _guildOwner = l.organizationIdToGuildIdToInfo[_organizationId][_guildId].currentOwner;
        require(_guildOwner != address(0), "Invalid guild");

        GuildOrganizationInfo storage _orgInfo = l.guildOrganizationInfo[_organizationId];
        if (_orgInfo.maxUsersPerGuildRule == MaxUsersPerGuildRule.CONSTANT) {
            return _orgInfo.maxUsersPerGuildConstant;
        } else {
            require(_orgInfo.customGuildManagerAddress != address(0), "CUSTOM_RULE with no config set");
            return ICustomGuildManager(_orgInfo.customGuildManagerAddress).maxUsersForGuild(_organizationId, _guildId);
        }
    }

    // =============================================================
    //                        Create Functions
    // =============================================================

    /**
     * @dev Assumes that the organization already exists. This is used when creating a guild for an organization that
     *  already exists, but has not initialized the guild feature yet.
     * @param _organizationId The id of the organization to create a guild for
     */
    function initializeForOrganization(bytes32 _organizationId) internal {
        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();
        if (l.guildOrganizationInfo[_organizationId].tokenAddress != address(0)) {
            revert GuildManagerStorage.GuildOrganizationAlreadyInitialized(_organizationId);
        }

        // Create new 1155 token to represent this organization.
        bytes memory _guildTokenData = abi.encodeCall(IGuildToken.initialize, (_organizationId));
        address _guildTokenAddress = address(new BeaconProxy(address(l.guildTokenBeacon), _guildTokenData));
        l.guildOrganizationInfo[_organizationId].tokenAddress = _guildTokenAddress;

        // The first guild created will be ID 1.
        l.guildOrganizationInfo[_organizationId].guildIdCur = 1;

        emit GuildManagerStorage.GuildOrganizationInitialized(_organizationId, _guildTokenAddress);
    }

    function createGuild(bytes32 _organizationId) internal {
        if (getGuildOrganizationInfo(_organizationId).requireTreasureTagForGuilds) {
            requireTreasureTagHolder(LibMeta._msgSender());
        }

        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();

        // Check to make sure the user can create a guild
        if (!userCanCreateGuild(_organizationId, LibMeta._msgSender())) {
            revert GuildManagerStorage.UserCannotCreateGuild(_organizationId, LibMeta._msgSender());
        }

        uint32 _newGuildId = l.guildOrganizationInfo[_organizationId].guildIdCur;
        l.guildOrganizationInfo[_organizationId].guildIdCur++;

        //set guild status to active
        l.organizationIdToGuildIdToInfo[_organizationId][_newGuildId].guildStatus = GuildStatus.ACTIVE;

        LibAccessControlRoles.grantGuildTerminator(LibMeta._msgSender(), _organizationId, _newGuildId);
        LibAccessControlRoles.grantGuildAdmin(LibMeta._msgSender(), _organizationId, _newGuildId);

        emit GuildManagerStorage.GuildCreated(_organizationId, _newGuildId);

        // Set the created user as the OWNER.
        // May revert depending on how many guilds this user is already apart of
        // and the rules of the organization.
        _changeUserStatus(_organizationId, _newGuildId, LibMeta._msgSender(), GuildUserStatus.OWNER);

        // Call the hook if they have it setup.
        if (l.guildOrganizationInfo[_organizationId].customGuildManagerAddress != address(0)) {
            return ICustomGuildManager(l.guildOrganizationInfo[_organizationId].customGuildManagerAddress)
                .onGuildCreation(LibMeta._msgSender(), _organizationId, _newGuildId);
        }
    }

    // =============================================================
    //                      Member Functions
    // =============================================================

    function inviteUsers(
        bytes32 _organizationId,
        uint32 _guildId,
        address[] calldata _users
    ) internal onlyGuildOwnerOrAdmin(_organizationId, _guildId, "INVITE") onlyActiveGuild(_organizationId, _guildId) {
        require(_users.length > 0);

        for (uint256 i = 0; i < _users.length; i++) {
            address _userToInvite = _users[i];
            if (_userToInvite == address(0)) {
                revert GuildManagerStorage.InvalidAddress(_userToInvite);
            }

            GuildUserStatus _userStatus = getGuildUserInfo(_organizationId, _guildId, _userToInvite).userStatus;
            if (_userStatus != GuildUserStatus.NOT_ASSOCIATED) {
                revert GuildManagerStorage.UserAlreadyInGuild(_organizationId, _guildId, _userToInvite);
            }

            _changeUserStatus(_organizationId, _guildId, _userToInvite, GuildUserStatus.INVITED);
        }
    }

    function acceptInvitation(
        bytes32 _organizationId,
        uint32 _guildId
    ) internal onlyActiveGuild(_organizationId, _guildId) {
        if (getGuildOrganizationInfo(_organizationId).requireTreasureTagForGuilds) {
            requireTreasureTagHolder(LibMeta._msgSender());
        }

        GuildUserStatus _userStatus = getGuildUserInfo(_organizationId, _guildId, LibMeta._msgSender()).userStatus;
        require(_userStatus == GuildUserStatus.INVITED, "Not invited");

        // Will validate they are not joining too many guilds.
        _changeUserStatus(_organizationId, _guildId, LibMeta._msgSender(), GuildUserStatus.MEMBER);
    }

    function leaveGuild(bytes32 _organizationId, uint32 _guildId) internal {
        GuildUserStatus _userStatus = getGuildUserInfo(_organizationId, _guildId, LibMeta._msgSender()).userStatus;
        require(_userStatus != GuildUserStatus.OWNER, "Owner cannot leave guild");
        require(_userStatus == GuildUserStatus.MEMBER || _userStatus == GuildUserStatus.ADMIN, "Not member of guild");

        _changeUserStatus(_organizationId, _guildId, LibMeta._msgSender(), GuildUserStatus.NOT_ASSOCIATED);
    }

    function kickOrRemoveInvitations(
        bytes32 _organizationId,
        uint32 _guildId,
        address[] calldata _users
    ) internal onlyActiveGuild(_organizationId, _guildId) {
        require(_users.length > 0);

        for (uint256 i = 0; i < _users.length; i++) {
            address _user = _users[i];
            GuildUserStatus _userStatus = getGuildUserInfo(_organizationId, _guildId, _user).userStatus;
            if (_userStatus == GuildUserStatus.OWNER) {
                revert("Cannot kick owner");
            } else if (_userStatus == GuildUserStatus.ADMIN) {
                requireGuildOwner(_organizationId, _guildId, "KICK");
            } else if (_userStatus == GuildUserStatus.NOT_ASSOCIATED) {
                revert("Cannot kick someone unassociated");
            } else {
                // MEMBER or INVITED
                requireGuildOwnerOrAdmin(_organizationId, _guildId, "KICK");
            }
            _changeUserStatus(_organizationId, _guildId, _user, GuildUserStatus.NOT_ASSOCIATED);
        }
    }

    // =============================================================
    //                Guild Administration Functions
    // =============================================================

    function changeGuildAdmins(
        bytes32 _organizationId,
        uint32 _guildId,
        address[] calldata _users,
        bool[] calldata _isAdmins
    ) internal onlyGuildOwner(_organizationId, _guildId, "CHANGE_ADMINS") onlyActiveGuild(_organizationId, _guildId) {
        require(_users.length > 0);
        require(_users.length == _isAdmins.length);

        for (uint256 i = 0; i < _users.length; i++) {
            address _user = _users[i];
            bool _willBeAdmin = _isAdmins[i];

            GuildUserStatus _userStatus = getGuildUserInfo(_organizationId, _guildId, _user).userStatus;

            if (_willBeAdmin) {
                if (_userStatus != GuildUserStatus.MEMBER) {
                    revert GuildManagerStorage.UserNotGuildMember(_organizationId, _guildId, _user);
                }
                _changeUserStatus(_organizationId, _guildId, _user, GuildUserStatus.ADMIN);
            } else {
                require(_userStatus == GuildUserStatus.ADMIN, "Can only demote admins");
                _changeUserStatus(_organizationId, _guildId, _user, GuildUserStatus.MEMBER);
            }
        }
    }

    function adjustMemberLevel(
        bytes32 _organizationId,
        uint32 _guildId,
        address _user,
        uint8 _memberLevel
    ) internal onlyActiveGuild(_organizationId, _guildId) {
        require(_memberLevel > 0 && _memberLevel < 6, "Not a valid member level.");

        //Make this require the specific role.
        LibAccessControlRoles.requireGuildAdmin(LibMeta._msgSender(), _organizationId, _guildId);

        GuildUserInfo storage _userInfo = getGuildUserInfo(_organizationId, _guildId, _user);

        _userInfo.memberLevel = _memberLevel;

        emit GuildManagerStorage.MemberLevelUpdated(_organizationId, _guildId, _user, _memberLevel);
    }

    function changeGuildOwner(
        bytes32 _organizationId,
        uint32 _guildId,
        address _newOwner
    ) internal onlyGuildOwner(_organizationId, _guildId, "TRANSFER_OWNER") onlyActiveGuild(_organizationId, _guildId) {
        GuildUserStatus _newOwnerOldStatus = getGuildUserInfo(_organizationId, _guildId, _newOwner).userStatus;
        require(
            _newOwnerOldStatus == GuildUserStatus.MEMBER || _newOwnerOldStatus == GuildUserStatus.ADMIN,
            "Can only make member owner"
        );

        _changeUserStatus(_organizationId, _guildId, LibMeta._msgSender(), GuildUserStatus.MEMBER);
        _changeUserStatus(_organizationId, _guildId, _newOwner, GuildUserStatus.OWNER);
    }

    function terminateGuild(
        bytes32 _organizationId,
        uint32 _guildId,
        string calldata _reason
    ) internal onlyActiveGuild(_organizationId, _guildId) {
        LibAccessControlRoles.requireGuildTerminator(LibMeta._msgSender(), _organizationId, _guildId);

        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();

        l.organizationIdToGuildIdToInfo[_organizationId][_guildId].guildStatus = GuildStatus.TERMINATED;

        emit GuildManagerStorage.GuildTerminated(_organizationId, _guildId, LibMeta._msgSender(), _reason);
    }

    // =============================================================
    //                        View Functions
    // =============================================================

    function userCanCreateGuild(bytes32 _organizationId, address _user) internal view returns (bool) {
        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();
        GuildCreationRule _creationRule = l.guildOrganizationInfo[_organizationId].creationRule;
        if (_creationRule == GuildCreationRule.ANYONE) {
            return true;
        } else if (_creationRule == GuildCreationRule.ADMIN_ONLY) {
            return _user == LibOrganizationManager.getOrganizationInfo(_organizationId).admin;
        } else {
            // CUSTOM_RULE
            address _customGuildManagerAddress = l.guildOrganizationInfo[_organizationId].customGuildManagerAddress;
            require(
                _customGuildManagerAddress != address(0), "Creation Rule set to CUSTOM_RULE, but no custom manager set."
            );

            return ICustomGuildManager(_customGuildManagerAddress).canCreateGuild(_user, _organizationId);
        }
    }

    function isGuildOwner(bytes32 _organizationId, uint32 _guildId, address _user) internal view returns (bool) {
        return getGuildUserInfo(_organizationId, _guildId, _user).userStatus == GuildUserStatus.OWNER;
    }

    function isGuildAdminOrOwner(
        bytes32 _organizationId,
        uint32 _guildId,
        address _user
    ) internal view returns (bool) {
        GuildUserStatus _userStatus = getGuildUserInfo(_organizationId, _guildId, _user).userStatus;
        return _userStatus == GuildUserStatus.OWNER || _userStatus == GuildUserStatus.ADMIN;
    }

    function getGuildStatus(bytes32 _organizationId, uint32 _guildId) internal view returns (GuildStatus) {
        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();

        return l.organizationIdToGuildIdToInfo[_organizationId][_guildId].guildStatus;
    }

    // =============================================================
    //                         Assertions
    // =============================================================

    function requireGuildOwner(bytes32 _organizationId, uint32 _guildId, string memory _action) internal view {
        if (!isGuildOwner(_organizationId, _guildId, LibMeta._msgSender())) {
            revert GuildManagerStorage.NotGuildOwner(LibMeta._msgSender(), _action);
        }
    }

    function requireGuildOwnerOrAdmin(bytes32 _organizationId, uint32 _guildId, string memory _action) internal view {
        if (!isGuildAdminOrOwner(_organizationId, _guildId, LibMeta._msgSender())) {
            revert GuildManagerStorage.NotGuildOwnerOrAdmin(LibMeta._msgSender(), _action);
        }
    }

    function requireActiveGuild(bytes32 _organizationId, uint32 _guildId) internal view {
        GuildStatus _guildStatus = getGuildStatus(_organizationId, _guildId);

        if (_guildStatus != GuildStatus.ACTIVE) {
            revert GuildManagerStorage.GuildIsNotActive(_organizationId, _guildId);
        }
    }

    function requireTreasureTagHolder(address _user) internal view {
        GuildManagerStorage.Layout storage l = GuildManagerStorage.layout();

        if (IERC721Upgradeable(l.treasureTagNFTAddress).balanceOf(_user) == 0) {
            revert GuildManagerStorage.UserDoesNotOwnTreasureTag(_user);
        }
    }

    // =============================================================
    //                          Private
    // =============================================================

    // Changes the status for the given user/guild/org combination.
    // This function does validation and adjust user membership per organization.
    // This function does not do ANY permissions check to see if this user should be set
    // to the status.
    function _changeUserStatus(
        bytes32 _organizationId,
        uint32 _guildId,
        address _user,
        GuildUserStatus _newStatus
    ) private {
        GuildUserInfo storage _guildUserInfo = getGuildInfo(_organizationId, _guildId).addressToGuildUserInfo[_user];

        GuildUserStatus _oldStatus = _guildUserInfo.userStatus;

        require(_oldStatus != _newStatus, "Can't set user to same status.");

        _guildUserInfo.userStatus = _newStatus;

        if (_newStatus == GuildUserStatus.OWNER) {
            getGuildInfo(_organizationId, _guildId).currentOwner = _user;
        }

        bool _wasInGuild = _oldStatus != GuildUserStatus.NOT_ASSOCIATED && _oldStatus != GuildUserStatus.INVITED;
        bool _isNowInGuild = _newStatus != GuildUserStatus.NOT_ASSOCIATED && _newStatus != GuildUserStatus.INVITED;

        if (!_wasInGuild && _isNowInGuild) {
            _onUserJoinedGuild(_organizationId, _guildId, _user);
        } else if (_wasInGuild && !_isNowInGuild) {
            _onUserLeftGuild(_organizationId, _guildId, _user);
        }

        emit GuildManagerStorage.GuildUserStatusChanged(_organizationId, _guildId, _user, _newStatus);
    }

    function _onUserJoinedGuild(bytes32 _organizationId, uint32 _guildId, address _user) private {
        GuildOrganizationInfo storage orgInfo = getGuildOrganizationInfo(_organizationId);
        GuildInfo storage guildInfo = getGuildInfo(_organizationId, _guildId);
        GuildOrganizationUserInfo storage _orgUserInfo = getUserInfo(_organizationId, _user);
        GuildUserInfo storage _guildUserInfo = guildInfo.addressToGuildUserInfo[_user];

        _orgUserInfo.guildIdsAMemberOf.push(_guildId);
        _guildUserInfo.timeUserJoined = uint64(block.timestamp);
        if (orgInfo.maxGuildsPerUser < _orgUserInfo.guildIdsAMemberOf.length) {
            revert GuildManagerStorage.UserInTooManyGuilds(_organizationId, _user);
        }

        _guildUserInfo.memberLevel = 1;

        guildInfo.usersInGuild++;

        uint32 _maxUsersForGuild = getMaxUsersForGuild(_organizationId, _guildId);
        if (_maxUsersForGuild < guildInfo.usersInGuild) {
            revert GuildManagerStorage.GuildFull(_organizationId, _guildId);
        }

        // Mint their membership NFT
        IGuildToken(orgInfo.tokenAddress).adminMint(_user, _guildId, 1);

        // Check to make sure the user is not in guild joining timeout
        require(
            block.timestamp >= _orgUserInfo.timeUserLeftGuild + orgInfo.timeoutAfterLeavingGuild, "Cooldown not over."
        );
    }

    function _onUserLeftGuild(bytes32 _organizationId, uint32 _guildId, address _user) private {
        GuildUserInfo storage _guildUserInfo = getGuildInfo(_organizationId, _guildId).addressToGuildUserInfo[_user];
        GuildOrganizationUserInfo storage _orgUserInfo = getUserInfo(_organizationId, _user);

        for (uint256 i = 0; i < _orgUserInfo.guildIdsAMemberOf.length; i++) {
            uint32 _guildIdAMemberOf = _orgUserInfo.guildIdsAMemberOf[i];
            if (_guildIdAMemberOf == _guildId) {
                _orgUserInfo.guildIdsAMemberOf[i] =
                    _orgUserInfo.guildIdsAMemberOf[_orgUserInfo.guildIdsAMemberOf.length - 1];
                _orgUserInfo.guildIdsAMemberOf.pop();
                break;
            }
        }

        delete _guildUserInfo.timeUserJoined;
        delete _guildUserInfo.memberLevel;

        getGuildInfo(_organizationId, _guildId).usersInGuild--;

        // Burn their membership NFT
        IGuildToken(getGuildOrganizationInfo(_organizationId).tokenAddress).adminBurn(_user, _guildId, 1);

        // Mark down when the user is leaving the guild.
        _orgUserInfo.timeUserLeftGuild = uint64(block.timestamp);
    }

    // =============================================================
    //                      PRIVATE MODIFIERS
    // =============================================================

    modifier onlyGuildOwner(bytes32 _organizationId, uint32 _guildId, string memory _action) {
        requireGuildOwner(_organizationId, _guildId, _action);
        _;
    }

    modifier onlyGuildOwnerOrAdmin(bytes32 _organizationId, uint32 _guildId, string memory _action) {
        requireGuildOwnerOrAdmin(_organizationId, _guildId, _action);
        _;
    }

    modifier onlyActiveGuild(bytes32 _organizationId, uint32 _guildId) {
        requireActiveGuild(_organizationId, _guildId);
        _;
    }
}
