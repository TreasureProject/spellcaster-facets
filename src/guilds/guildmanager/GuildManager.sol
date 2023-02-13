//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GuildManagerOrganization} from "./GuildManagerOrganization.sol";
import {IGuildOrganizationConfig} from "../interfaces/IGuildOrganizationConfig.sol";
import {IGuildToken} from "../guildtoken/IGuildToken.sol";

contract GuildManager is GuildManagerOrganization {

    function GuildManager_init() external facetInitializer(keccak256("GuildManager")) {
        GuildManagerOrganization.__GuildManagerOrganization_init();
    }

    function createGuild(
        uint32 _organizationId)
    contractsAreSet
    whenNotPaused
    external
    {
        // Check to make sure the user can create a guild
        //
        require(userCanCreateGuild(_organizationId, msg.sender), "Do not have permission to create guild");

        uint32 _newGuildId = organizationIdToInfo[_organizationId].guildIdCur;
        organizationIdToInfo[_organizationId].guildIdCur++;

        emit GuildCreated(_organizationId, _newGuildId);

        // Set the created user as the OWNER.
        // May revert depending on how many guilds this user is already apart of
        // and the rules of the organization.
        //
        _changeUserStatus(_organizationId, _newGuildId, msg.sender, GuildUserStatus.OWNER);

        // Call the hook if they have it setup.
        //
        if(organizationIdToInfo[_organizationId].organizationConfigAddress != address(0))  {
            return IGuildOrganizationConfig(organizationIdToInfo[_organizationId].organizationConfigAddress)
                .onGuildCreation(msg.sender, _organizationId, _newGuildId);
        }
    }

    function updateGuildInfo(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _name,
        string calldata _description)
    contractsAreSet
    whenNotPaused
    external
    {
        require(_isGuildOwner(_organizationId, _guildId, msg.sender), "Only Guild owner can call");

        GuildInfo storage _guildInfo = organizationIdToGuildIdToInfo[_organizationId][_guildId];

        _guildInfo.name = _name;
        _guildInfo.description = _description;

        emit GuildInfoUpdated(_organizationId, _guildId, _name, _description);
    }

    function updateGuildSymbol(
        uint32 _organizationId,
        uint32 _guildId,
        string calldata _symbolImageData,
        bool _isSymbolOnChain)
    contractsAreSet
    whenNotPaused
    external
    {
        require(_isGuildOwner(_organizationId, _guildId, msg.sender), "Only Guild owner can call");

        GuildInfo storage _guildInfo = organizationIdToGuildIdToInfo[_organizationId][_guildId];

        _guildInfo.symbolImageData = _symbolImageData;
        _guildInfo.isSymbolOnChain = _isSymbolOnChain;

        emit GuildSymbolUpdated(_organizationId, _guildId, _symbolImageData, _isSymbolOnChain);
    }

    function inviteUsers(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users)
    external
    whenNotPaused
    {
        require(_isGuildAdminOrOwner(_organizationId, _guildId, msg.sender), "Do not have permission to invite user.");
        require(_users.length > 0);

        for(uint256 i = 0; i < _users.length; i++) {
            address _userToInvite = _users[i];
            require(_userToInvite != address(0), "Bad user address");

            GuildUserStatus _userStatus = guildStatusForUser(_organizationId, _guildId, _userToInvite);
            require(_userStatus == GuildUserStatus.NOT_ASSOCIATED, "User is already invited or a member");

            _changeUserStatus(_organizationId, _guildId, _userToInvite, GuildUserStatus.INVITED);
        }
    }

    function acceptInvitation(
        uint32 _organizationId,
        uint32 _guildId)
    external
    whenNotPaused
    {
        GuildUserStatus _userStatus = guildStatusForUser(_organizationId, _guildId, msg.sender);
        require(_userStatus == GuildUserStatus.INVITED, "Not invited");

        // Will validate they are not joining too many guilds.
        //
        _changeUserStatus(_organizationId, _guildId, msg.sender, GuildUserStatus.MEMBER);
    }

    function changeGuildAdmins(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users,
        bool[] calldata _isAdmins)
    external
    whenNotPaused
    {
        require(_isGuildOwner(_organizationId, _guildId, msg.sender), "Only owner can make admins");
        require(_users.length > 0);
        require(_users.length == _isAdmins.length);

        for(uint256 i = 0; i < _users.length; i++) {
            address _user = _users[i];
            bool _willBeAdmin = _isAdmins[i];

            GuildUserStatus _userStatus = guildStatusForUser(_organizationId, _guildId, _user);

            if(_willBeAdmin) {
                require(_userStatus == GuildUserStatus.MEMBER, "Can only promote members to admins");
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
    external
    whenNotPaused
    {
        require(_isGuildOwner(_organizationId, _guildId, msg.sender), "Only owner can make admins");

        GuildUserStatus _newOwnerOldStatus = guildStatusForUser(_organizationId, _guildId, _newOwner);
        require(_newOwnerOldStatus == GuildUserStatus.MEMBER || _newOwnerOldStatus == GuildUserStatus.ADMIN, "Can only make member owner");

        _changeUserStatus(_organizationId, _guildId, msg.sender, GuildUserStatus.MEMBER);
        _changeUserStatus(_organizationId, _guildId, _newOwner, GuildUserStatus.OWNER);
    }

    function leaveGuild(
        uint32 _organizationId,
        uint32 _guildId)
    external
    whenNotPaused
    {
        GuildUserStatus _userStatus = guildStatusForUser(_organizationId, _guildId, msg.sender);
        require(_userStatus != GuildUserStatus.OWNER, "Owner cannot leave guild");
        require(_userStatus == GuildUserStatus.MEMBER || _userStatus == GuildUserStatus.ADMIN, "Not member of guild");

        _changeUserStatus(_organizationId, _guildId, msg.sender, GuildUserStatus.NOT_ASSOCIATED);
    }

    function kickOrRemoveInvitations(
        uint32 _organizationId,
        uint32 _guildId,
        address[] calldata _users)
    external
    whenNotPaused
    {
        require(_users.length > 0);

        for(uint256 i = 0; i < _users.length; i++) {
            address _user = _users[i];
            GuildUserStatus _userStatus = guildStatusForUser(_organizationId, _guildId, _user);
            if(_userStatus == GuildUserStatus.OWNER) {
                revert("Cannot kick owner");
            } else if(_userStatus == GuildUserStatus.ADMIN) {
                require(_isGuildOwner(_organizationId, _guildId, msg.sender), "Only owner can kick admin");
            } else if(_userStatus == GuildUserStatus.NOT_ASSOCIATED) {
                revert("Cannot kick someone unassociated");
            } else { // MEMBER or INVITED
                require(_isGuildAdminOrOwner(_organizationId, _guildId, msg.sender), "Only owner/admin can kick");
            }
            _changeUserStatus(_organizationId, _guildId, _user, GuildUserStatus.NOT_ASSOCIATED);
        }
    }

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
        GuildUserInfo storage _guildUserInfo = organizationIdToGuildIdToInfo[_organizationId][_guildId].addressToGuildUserInfo[_user];

        GuildUserStatus _oldStatus = _guildUserInfo.userStatus;

        require(_oldStatus != _newStatus, "Can't set user to same status.");

        _guildUserInfo.userStatus = _newStatus;

        if(_newStatus == GuildUserStatus.OWNER) {
            organizationIdToGuildIdToInfo[_organizationId][_guildId].currentOwner = _user;
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
        GuildUserInfo storage _guildUserInfo = organizationIdToGuildIdToInfo[_organizationId][_guildId].addressToGuildUserInfo[_user];
        OrganizationUserInfo storage _orgUserInfo = organizationIdToAddressToInfo[_organizationId][_user];

        _orgUserInfo.guildIdsAMemberOf.push(_guildId);
        _guildUserInfo.timeUserJoined = uint64(block.timestamp);
        require(organizationIdToInfo[_organizationId].maxGuildsPerUser >= _orgUserInfo.guildIdsAMemberOf.length, "Joining too many guilds");

        organizationIdToGuildIdToInfo[_organizationId][_guildId].usersInGuild++;

        uint32 _maxUsersForGuild = maxUsersForGuild(_organizationId, _guildId);
        require(_maxUsersForGuild >= organizationIdToGuildIdToInfo[_organizationId][_guildId].usersInGuild, "Too many users in guild");

        // Mint their membership NFT
        IGuildToken(organizationIdToInfo[_organizationId].tokenAddress).adminMint(_user, _guildId, 1);

        // Check to make sure the user is not in guild joining timeout
        require(block.timestamp >= _orgUserInfo.timeUserLeftGuild + organizationIdToInfo[_organizationId].timeoutAfterLeavingGuild);
    }

    function _onUserLeftGuild(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    private
    {
        GuildUserInfo storage _guildUserInfo = organizationIdToGuildIdToInfo[_organizationId][_guildId].addressToGuildUserInfo[_user];
        OrganizationUserInfo storage _orgUserInfo = organizationIdToAddressToInfo[_organizationId][_user];

        for(uint256 i = 0; i < _orgUserInfo.guildIdsAMemberOf.length; i++) {
            uint32 _guildIdAMemberOf = _orgUserInfo.guildIdsAMemberOf[i];
            if(_guildIdAMemberOf == _guildId) {
                _orgUserInfo.guildIdsAMemberOf[i] = _orgUserInfo.guildIdsAMemberOf[_orgUserInfo.guildIdsAMemberOf.length - 1];
                _orgUserInfo.guildIdsAMemberOf.pop();
                break;
            }
        }

        delete _guildUserInfo.timeUserJoined;

        organizationIdToGuildIdToInfo[_organizationId][_guildId].usersInGuild--;

        // Burn their membership NFT
        //
        IGuildToken(organizationIdToInfo[_organizationId].tokenAddress).adminBurn(_user, _guildId, 1);

        // Mark down when the user is leaving the guild.
        //
        _orgUserInfo.timeUserLeftGuild = uint64(block.timestamp);
    }

    function userCanCreateGuild(
        uint32 _organizationId,
        address _user)
    onlyValidOrganization(_organizationId)
    public
    view
    returns(bool)
    {
        GuildCreationRule _creationRule = organizationIdToInfo[_organizationId].creationRule;
        if(_creationRule == GuildCreationRule.ANYONE) {
            return true;
        } else if(_creationRule == GuildCreationRule.ADMIN_ONLY) {
            return _user == organizationIdToInfo[_organizationId].admin;
        } else {
            // CUSTOM_RULE
            address _organizationConfigAddress = organizationIdToInfo[_organizationId].organizationConfigAddress;
            require(_organizationConfigAddress != address(0), "Creation Rule set to CUSTOM_RULE, but no config set.");

            return IGuildOrganizationConfig(_organizationConfigAddress).canCreateGuild(_user, _organizationId);
        }
    }

    function maxUsersForGuild(
        uint32 _organizationId,
        uint32 _guildId)
    public
    view
    returns(uint32)
    {
        address _guildOwner = organizationIdToGuildIdToInfo[_organizationId][_guildId].currentOwner;
        require(_guildOwner != address(0), "Invalid guild");

        OrganizationInfo storage _orgInfo = organizationIdToInfo[_organizationId];
        if(_orgInfo.maxUsersPerGuildRule == MaxUsersPerGuildRule.CONSTANT) {
            return _orgInfo.maxUsersPerGuildConstant;
        } else {
            require(_orgInfo.organizationConfigAddress != address(0), "CUSTOM_RULE with no config set");
            return IGuildOrganizationConfig(_orgInfo.organizationConfigAddress)
                .maxUsersForGuild(_guildOwner, _organizationId, _guildId);
        }
    }

    function _isGuildOwner(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    private
    view
    returns(bool)
    {
        return guildStatusForUser(_organizationId, _guildId, _user) == GuildUserStatus.OWNER;
    }

    function _isGuildAdminOrOwner(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    private
    view
    returns(bool)
    {
        GuildUserStatus _userStatus = guildStatusForUser(_organizationId, _guildId, _user);
        return _userStatus == GuildUserStatus.OWNER || _userStatus == GuildUserStatus.ADMIN;
    }

    function guildStatusForUser(
        uint32 _organizationId,
        uint32 _guildId,
        address _user)
    public
    view
    returns(GuildUserStatus)
    {
        return organizationIdToGuildIdToInfo[_organizationId][_guildId].addressToGuildUserInfo[_user].userStatus;
    }

    function isValidGuild(uint32 _organizationId, uint32 _guildId) external view returns(bool) {
        return organizationIdToInfo[_organizationId].guildIdCur > _guildId && _guildId != 0;
    }

    function organizationToken(uint32 _organizationId) external view returns(address) {
        return organizationIdToInfo[_organizationId].tokenAddress;
    }

    function guildName(uint32 _organizationId, uint32 _guildId) external view returns(string memory) {
        return organizationIdToGuildIdToInfo[_organizationId][_guildId].name;
    }

    function guildDescription(uint32 _organizationId, uint32 _guildId) external view returns(string memory) {
        return organizationIdToGuildIdToInfo[_organizationId][_guildId].description;
    }

    function guildSymbolInfo(uint32 _organizationId, uint32 _guildId) external view returns(string memory _symbolImageData, bool _isSymbolOnChain) {
        GuildInfo storage _guildInfo = organizationIdToGuildIdToInfo[_organizationId][_guildId];
        _symbolImageData = _guildInfo.symbolImageData;
        _isSymbolOnChain = _guildInfo.isSymbolOnChain;
    }
}
