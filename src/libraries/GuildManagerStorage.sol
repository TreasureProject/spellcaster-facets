// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UpgradeableBeacon} from '@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol';
import {BeaconProxy} from '@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol';

import {
    IGuildManager,
    GuildInfo,
    GuildCreationRule,
    GuildUserInfo,
    GuildUserStatus,
    OrganizationInfo,
    OrganizationUserInfo,
    MaxUsersPerGuildRule
} from "src/interfaces/IGuildManager.sol";
import {IGuildToken} from "../guilds/guildtoken/IGuildToken.sol";
import {IGuildOrganizationConfig} from "../guilds/interfaces/IGuildOrganizationConfig.sol";

/// @title Library for handling storage interfacing for Guild Manager contracts
library GuildManagerStorage {
    event OrganizationCreated(uint32 organizationId, address tokenAddress);
    event OrganizationInfoUpdated(uint32 organizationId, string name, string description);
    event OrganizationAdminUpdated(uint32 organizationId, address admin);
    event OrganizationTimeoutAfterLeavingGuild(uint32 organizationId, uint32 timeoutAfterLeavingGuild);
    event OrganizationMaxGuildsPerUserUpdated(uint32 organizationId, uint8 maxGuildsPerUser);
    event OrganizationMaxUsersPerGuildUpdated(uint32 organizationId, MaxUsersPerGuildRule rule, uint32 maxUsersPerGuildConstant);
    event OrganizationCreationRuleUpdated(uint32 organizationId, GuildCreationRule creationRule);
    event OrganizationConfigAddressUpdated(uint32 organizationId, address organizationConfigAddress);

    event GuildCreated(uint32 organizationId, uint32 guildId);
    event GuildInfoUpdated(uint32 organizationId, uint32 guildId, string name, string description);
    event GuildSymbolUpdated(uint32 organizationId, uint32 guildId, string symbolImageData, bool isSymbolOnChain);

    event GuildUserStatusChanged(uint32 organizationId, uint32 guildId, address user, GuildUserStatus status);

    error UserCannotCreateGuild(uint32 organizationId, address user);
    error NonexistantOrganization(uint32 organizationId);
    error UserAlreadyInGuild(uint32 organizationId, uint32 guildId, address user);
    error UserNotGuildMember(uint32 organizationId, uint32 guildId, address user);
    error NotOrganizationAdmin(address sender);
    error InvalidAddress(address user);
    error NotGuildOwner(address sender, string action);
    error NotGuildOwnerOrAdmin(address sender, string action);

    struct Layout {
        UpgradeableBeacon guildTokenBeacon;
        uint32 organizationIdCur;
        mapping(uint32 => OrganizationInfo) organizationIdToInfo;
        mapping(uint32 => mapping(uint32 => GuildInfo)) organizationIdToGuildIdToInfo;
        mapping(uint32 => mapping(address => OrganizationUserInfo)) organizationIdToAddressToInfo;
    }

    bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.guildmanager");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = FACET_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

    // =============================================================
    //                      Getters/Setters
    // =============================================================

    function getGuildTokenBeacon() internal view returns (UpgradeableBeacon beacon_) {
        beacon_ = layout().guildTokenBeacon;
    }

    function getOrganizationIdCur() internal view returns (uint32 orgIdCur_) {
        orgIdCur_ = layout().organizationIdCur;
    }

    /**
     * @param _orgId The id of the org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getOrganizationInfo(uint32 _orgId) internal view returns (OrganizationInfo storage info_) {
        info_ = layout().organizationIdToInfo[_orgId];
    }

    /**
     * @param _orgId The id of the org that contains the guild to retrieve info for
     * @param _guildId The id of the guild within the given org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getGuildInfo(uint32 _orgId, uint32 _guildId) internal view returns (GuildInfo storage info_) {
        info_ = layout().organizationIdToGuildIdToInfo[_orgId][_guildId];
    }

    /**
     * @param _orgId The id of the org that contains the user to retrieve info for
     * @param _user The id of the user within the given org to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getUserInfo(uint32 _orgId, address _user) internal view returns (OrganizationUserInfo storage info_) {
        info_ = layout().organizationIdToAddressToInfo[_orgId][_user];
    }

    function setGuildTokenBeacon(address _beaconImplAddress) internal {
        Layout storage l = layout();

        if(address(l.guildTokenBeacon) == address(0)) {
            l.guildTokenBeacon = new UpgradeableBeacon(_beaconImplAddress);
        } else if(l.guildTokenBeacon.implementation() != _beaconImplAddress) {
            l.guildTokenBeacon.upgradeTo(_beaconImplAddress);
        }
    }

    function setOrganizationNameAndDescription(
        uint32 _organizationId,
        string calldata _name,
        string calldata _description)
    internal
    {
        OrganizationInfo storage _info = GuildManagerStorage.getOrganizationInfo(_organizationId);
        _info.name = _name;
        _info.description = _description;
        emit OrganizationInfoUpdated(_organizationId, _name, _description);
    }

    function setOrganizationAdmin(
        uint32 _organizationId,
        address _admin)
    internal
    {
        getOrganizationInfo(_organizationId).admin = _admin;
        emit OrganizationAdminUpdated(_organizationId, _admin);
    }

    function setOrganizationMaxGuildsPerUser(
        uint32 _organizationId,
        uint8 _maxGuildsPerUser)
    internal
    {
        require(_maxGuildsPerUser > 0, "maxGuildsPerUser must be greater than 0");

        getOrganizationInfo(_organizationId).maxGuildsPerUser = _maxGuildsPerUser;
        emit OrganizationMaxGuildsPerUserUpdated(_organizationId, _maxGuildsPerUser);
    }

    function setOrganizationTimeoutAfterLeavingGuild(
        uint32 _organizationId,
        uint32 _timeoutAfterLeavingGuild)
    internal
    {
        getOrganizationInfo(_organizationId).timeoutAfterLeavingGuild = _timeoutAfterLeavingGuild;
        emit OrganizationTimeoutAfterLeavingGuild(_organizationId, _timeoutAfterLeavingGuild);
    }

    function setOrganizationCreationRule(
        uint32 _organizationId,
        GuildCreationRule _guildCreationRule)
    internal
    {
        getOrganizationInfo(_organizationId).creationRule = _guildCreationRule;
        emit OrganizationCreationRuleUpdated(_organizationId, _guildCreationRule);
    }

    function setOrganizationMaxUsersPerGuild(
        uint32 _organizationId,
        MaxUsersPerGuildRule _maxUsersPerGuildRule,
        uint32 _maxUsersPerGuildConstant)
    internal
    {
        getOrganizationInfo(_organizationId).maxUsersPerGuildRule = _maxUsersPerGuildRule;
        getOrganizationInfo(_organizationId).maxUsersPerGuildConstant = _maxUsersPerGuildConstant;
        emit OrganizationMaxUsersPerGuildUpdated(_organizationId, _maxUsersPerGuildRule, _maxUsersPerGuildConstant);
    }

    function setOrganizationConfigAddress(
        uint32 _organizationId,
        address _organizationConfigAddress)
    internal
    {
        getOrganizationInfo(_organizationId).organizationConfigAddress = _organizationConfigAddress;
        emit OrganizationConfigAddressUpdated(_organizationId, _organizationConfigAddress);
    }

    // =============================================================
    //                        Create Functions
    // =============================================================

    function createOrganization() internal returns(uint32 newOrganizationId_) {
        Layout storage l = layout();

        newOrganizationId_ = l.organizationIdCur;
        l.organizationIdCur++;

        // Create new 1155 token to represent this organization.
        bytes memory _guildTokenData = abi.encodeCall(IGuildToken.initialize, (newOrganizationId_));
        address _guildTokenAddress = address(new BeaconProxy(address(l.guildTokenBeacon), _guildTokenData));
        l.organizationIdToInfo[newOrganizationId_].tokenAddress = _guildTokenAddress;

        // The first guild created will be ID 1.
        l.organizationIdToInfo[newOrganizationId_].guildIdCur = 1;

        emit OrganizationCreated(newOrganizationId_, _guildTokenAddress);
    }

    function createGuild(
        uint32 _organizationId)
    internal
    {
        Layout storage l = layout();

        // Check to make sure the user can create a guild
        if(!userCanCreateGuild(_organizationId, msg.sender)) {
            revert UserCannotCreateGuild(_organizationId, msg.sender);
        }

        uint32 _newGuildId = l.organizationIdToInfo[_organizationId].guildIdCur;
        l.organizationIdToInfo[_organizationId].guildIdCur++;

        emit GuildCreated(_organizationId, _newGuildId);

        // Set the created user as the OWNER.
        // May revert depending on how many guilds this user is already apart of
        // and the rules of the organization.
        _changeUserStatus(_organizationId, _newGuildId, msg.sender, GuildUserStatus.OWNER);

        // Call the hook if they have it setup.
        if(l.organizationIdToInfo[_organizationId].organizationConfigAddress != address(0))  {
            return IGuildOrganizationConfig(l.organizationIdToInfo[_organizationId].organizationConfigAddress)
                .onGuildCreation(msg.sender, _organizationId, _newGuildId);
        }
    }

    // =============================================================
    //                       Update Functions
    // =============================================================

    function updateGuildInfo(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _name,
        string calldata _description)
    internal
    onlyGuildOwner(_organizationId, _guildId, "UPDATE_INFO")
    {
        GuildInfo storage _guildInfo = getGuildInfo(_organizationId, _guildId);

        _guildInfo.name = _name;
        _guildInfo.description = _description;

        emit GuildInfoUpdated(_organizationId, _guildId, _name, _description);
    }

    function updateGuildSymbol(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _symbolImageData,
        bool _isSymbolOnChain)
    internal
    onlyGuildOwner(_organizationId, _guildId, "UPDATE_SYMBOL")
    {

        GuildInfo storage _guildInfo = getGuildInfo(_organizationId, _guildId);

        _guildInfo.symbolImageData = _symbolImageData;
        _guildInfo.isSymbolOnChain = _isSymbolOnChain;

        emit GuildSymbolUpdated(_organizationId, _guildId, _symbolImageData, _isSymbolOnChain);
    }

    // =============================================================
    //                      Member Functions
    // =============================================================

    function inviteUsers(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users)
    internal
    onlyGuildOwnerOrAdmin(_organizationId, _guildId, "INVITE")
    {
        require(_users.length > 0);

        for(uint256 i = 0; i < _users.length; i++) {
            address _userToInvite = _users[i];
            if(_userToInvite == address(0)) {
                revert InvalidAddress(_userToInvite);
            }

            GuildUserStatus _userStatus = getGuildMemberStatus(_organizationId, _guildId, _userToInvite);
            if(_userStatus != GuildUserStatus.NOT_ASSOCIATED) {
                revert UserAlreadyInGuild(_organizationId, _guildId, _userToInvite);
            }

            _changeUserStatus(_organizationId, _guildId, _userToInvite, GuildUserStatus.INVITED);
        }
    }

    function acceptInvitation(
        uint32 _organizationId,
        uint32 _guildId)
    internal
    {
        GuildUserStatus _userStatus = getGuildMemberStatus(_organizationId, _guildId, msg.sender);
        require(_userStatus == GuildUserStatus.INVITED, "Not invited");

        // Will validate they are not joining too many guilds.
        _changeUserStatus(_organizationId, _guildId, msg.sender, GuildUserStatus.MEMBER);
    }

    function leaveGuild(
        uint32 _organizationId,
        uint32 _guildId)
    internal
    {
        GuildUserStatus _userStatus = getGuildMemberStatus(_organizationId, _guildId, msg.sender);
        require(_userStatus != GuildUserStatus.OWNER, "Owner cannot leave guild");
        require(_userStatus == GuildUserStatus.MEMBER || _userStatus == GuildUserStatus.ADMIN, "Not member of guild");

        _changeUserStatus(_organizationId, _guildId, msg.sender, GuildUserStatus.NOT_ASSOCIATED);
    }

    function kickOrRemoveInvitations(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users)
    internal
    {
        require(_users.length > 0);

        for(uint256 i = 0; i < _users.length; i++) {
            address _user = _users[i];
            GuildUserStatus _userStatus = getGuildMemberStatus(_organizationId, _guildId, _user);
            if(_userStatus == GuildUserStatus.OWNER) {
                revert("Cannot kick owner");
            } else if(_userStatus == GuildUserStatus.ADMIN) {
                requireGuildOwner(_organizationId, _guildId, "KICK");
            } else if(_userStatus == GuildUserStatus.NOT_ASSOCIATED) {
                revert("Cannot kick someone unassociated");
            } else { // MEMBER or INVITED
                requireGuildOwnerOrAdmin(_organizationId, _guildId, "KICK");
            }
            _changeUserStatus(_organizationId, _guildId, _user, GuildUserStatus.NOT_ASSOCIATED);
        }
    }

    // =============================================================
    //                Guild Administration Functions
    // =============================================================

    function changeGuildAdmins(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users,
        bool[] calldata _isAdmins)
    internal
    onlyGuildOwner(_organizationId, _guildId, "CHANGE_ADMINS")
    {
        require(_users.length > 0);
        require(_users.length == _isAdmins.length);

        for(uint256 i = 0; i < _users.length; i++) {
            address _user = _users[i];
            bool _willBeAdmin = _isAdmins[i];

            GuildUserStatus _userStatus = getGuildMemberStatus(_organizationId, _guildId, _user);

            if(_willBeAdmin) {
                if(_userStatus != GuildUserStatus.MEMBER) {
                    revert UserNotGuildMember(_organizationId, _guildId, _user);
                }
                _changeUserStatus(_organizationId, _guildId, _user, GuildUserStatus.ADMIN);
            } else {
                require(_userStatus == GuildUserStatus.ADMIN, "Can only demote admins");
                _changeUserStatus(_organizationId, _guildId, _user, GuildUserStatus.MEMBER);
            }
        }
    }

    function changeGuildOwner(
        uint32 _organizationId,
        uint32 _guildId,
        address _newOwner)
    internal
    onlyGuildOwner(_organizationId, _guildId, "TRANSFER_OWNER")
    {

        GuildUserStatus _newOwnerOldStatus = getGuildMemberStatus(_organizationId, _guildId, _newOwner);
        require(_newOwnerOldStatus == GuildUserStatus.MEMBER || _newOwnerOldStatus == GuildUserStatus.ADMIN, "Can only make member owner");

        _changeUserStatus(_organizationId, _guildId, msg.sender, GuildUserStatus.MEMBER);
        _changeUserStatus(_organizationId, _guildId, _newOwner, GuildUserStatus.OWNER);
    }

    // =============================================================
    //                        View Functions
    // =============================================================

    function userCanCreateGuild(
        uint32 _organizationId,
        address _user)
    internal
    view
    returns(bool)
    {
        Layout storage l = layout();
        GuildCreationRule _creationRule = l.organizationIdToInfo[_organizationId].creationRule;
        if(_creationRule == GuildCreationRule.ANYONE) {
            return true;
        } else if(_creationRule == GuildCreationRule.ADMIN_ONLY) {
            return _user == l.organizationIdToInfo[_organizationId].admin;
        } else {
            // CUSTOM_RULE
            address _organizationConfigAddress = l.organizationIdToInfo[_organizationId].organizationConfigAddress;
            require(_organizationConfigAddress != address(0), "Creation Rule set to CUSTOM_RULE, but no config set.");

            return IGuildOrganizationConfig(_organizationConfigAddress).canCreateGuild(_user, _organizationId);
        }
    }

    function maxUsersForGuild(
        uint32 _organizationId,
        uint32 _guildId)
    internal
    view
    returns(uint32)
    {
        Layout storage l = layout();
        address _guildOwner = l.organizationIdToGuildIdToInfo[_organizationId][_guildId].currentOwner;
        require(_guildOwner != address(0), "Invalid guild");

        OrganizationInfo storage _orgInfo = l.organizationIdToInfo[_organizationId];
        if(_orgInfo.maxUsersPerGuildRule == MaxUsersPerGuildRule.CONSTANT) {
            return _orgInfo.maxUsersPerGuildConstant;
        } else {
            require(_orgInfo.organizationConfigAddress != address(0), "CUSTOM_RULE with no config set");
            return IGuildOrganizationConfig(_orgInfo.organizationConfigAddress)
                .maxUsersForGuild(_guildOwner, _organizationId, _guildId);
        }
    }

    function getGuildMemberStatus(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    internal
    view
    returns(GuildUserStatus)
    {
        return getGuildInfo(_organizationId, _guildId).addressToGuildUserInfo[_user].userStatus;
    }

    function isGuildOwner(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    internal
    view
    returns(bool)
    {
        return getGuildMemberStatus(_organizationId, _guildId, _user) == GuildUserStatus.OWNER;
    }

    function isGuildAdminOrOwner(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    internal
    view
    returns(bool)
    {
        GuildUserStatus _userStatus = getGuildMemberStatus(_organizationId, _guildId, _user);
        return _userStatus == GuildUserStatus.OWNER || _userStatus == GuildUserStatus.ADMIN;
    }

    // =============================================================
    //                          Private
    // =============================================================

    // Changes the status for the given user/guild/org combination.
    // This function does validation and adjust user membership per organization.
    // This function does not do ANY permissions check to see if this user should be set
    // to the status.
    function _changeUserStatus(
        uint32 _organizationId,
        uint32 _guildId,
        address _user,
        GuildUserStatus _newStatus)
    private
    {
        GuildUserInfo storage _guildUserInfo = getGuildInfo(_organizationId, _guildId).addressToGuildUserInfo[_user];

        GuildUserStatus _oldStatus = _guildUserInfo.userStatus;

        require(_oldStatus != _newStatus, "Can't set user to same status.");

        _guildUserInfo.userStatus = _newStatus;

        if(_newStatus == GuildUserStatus.OWNER) {
            getGuildInfo(_organizationId, _guildId).currentOwner = _user;
        }

        bool _wasInGuild = _oldStatus != GuildUserStatus.NOT_ASSOCIATED && _oldStatus != GuildUserStatus.INVITED;
        bool _isNowInGuild = _newStatus != GuildUserStatus.NOT_ASSOCIATED && _newStatus != GuildUserStatus.INVITED;

        if(!_wasInGuild && _isNowInGuild) {
            _onUserJoinedGuild(_organizationId, _guildId, _user);
        } else if(_wasInGuild && !_isNowInGuild) {
            _onUserLeftGuild(_organizationId, _guildId, _user);
        }

        emit GuildUserStatusChanged(_organizationId, _guildId, _user, _newStatus);
    }

    function _onUserJoinedGuild(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    private
    {
        OrganizationInfo storage orgInfo = getOrganizationInfo(_organizationId);
        GuildInfo storage guildInfo = getGuildInfo(_organizationId, _guildId);
        OrganizationUserInfo storage _orgUserInfo = getUserInfo(_organizationId, _user);
        GuildUserInfo storage _guildUserInfo = guildInfo.addressToGuildUserInfo[_user];

        _orgUserInfo.guildIdsAMemberOf.push(_guildId);
        _guildUserInfo.timeUserJoined = uint64(block.timestamp);
        require(orgInfo.maxGuildsPerUser >= _orgUserInfo.guildIdsAMemberOf.length, "Joining too many guilds");

        guildInfo.usersInGuild++;

        uint32 _maxUsersForGuild = maxUsersForGuild(_organizationId, _guildId);
        require(_maxUsersForGuild >= guildInfo.usersInGuild, "Too many users in guild");

        // Mint their membership NFT
        IGuildToken(orgInfo.tokenAddress).adminMint(_user, _guildId, 1);

        // Check to make sure the user is not in guild joining timeout
        require(block.timestamp >= _orgUserInfo.timeUserLeftGuild + orgInfo.timeoutAfterLeavingGuild);
    }

    function requireGuildOwner(
        uint32 _organizationId,
        uint32 _guildId,
        string memory _action)
    private
    view
    {
        if(!isGuildOwner(_organizationId, _guildId, msg.sender)) {
            revert NotGuildOwner(msg.sender, _action);
        }
    }

    function requireGuildOwnerOrAdmin(
        uint32 _organizationId,
        uint32 _guildId,
        string memory _action)
    private
    view
    {
        if(!isGuildAdminOrOwner(_organizationId, _guildId, msg.sender)) {
            revert NotGuildOwnerOrAdmin(msg.sender, _action);
        }
    }

    function _onUserLeftGuild(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    private
    {
        GuildUserInfo storage _guildUserInfo = getGuildInfo(_organizationId, _guildId).addressToGuildUserInfo[_user];
        OrganizationUserInfo storage _orgUserInfo = getUserInfo(_organizationId, _user);

        for(uint256 i = 0; i < _orgUserInfo.guildIdsAMemberOf.length; i++) {
            uint32 _guildIdAMemberOf = _orgUserInfo.guildIdsAMemberOf[i];
            if(_guildIdAMemberOf == _guildId) {
                _orgUserInfo.guildIdsAMemberOf[i] = _orgUserInfo.guildIdsAMemberOf[_orgUserInfo.guildIdsAMemberOf.length - 1];
                _orgUserInfo.guildIdsAMemberOf.pop();
                break;
            }
        }

        delete _guildUserInfo.timeUserJoined;

        getGuildInfo(_organizationId, _guildId).usersInGuild--;

        // Burn their membership NFT
        IGuildToken(getOrganizationInfo(_organizationId).tokenAddress).adminBurn(_user, _guildId, 1);

        // Mark down when the user is leaving the guild.
        _orgUserInfo.timeUserLeftGuild = uint64(block.timestamp);
    }

    // =============================================================
    //                      PRIVATE MODIFIERS
    // =============================================================

    modifier onlyGuildOwner(
        uint32 _organizationId,
        uint32 _guildId,
        string memory _action)
    {
        requireGuildOwner(_organizationId, _guildId, _action);
        _;
    }

    modifier onlyGuildOwnerOrAdmin(
        uint32 _organizationId,
        uint32 _guildId,
        string memory _action)
    {
        requireGuildOwnerOrAdmin(_organizationId, _guildId, _action);
        _;
    }

}
