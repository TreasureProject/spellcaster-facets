# GuildManagerStorage
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/guilds/guildmanager/GuildManagerStorage.sol)

This library contains the storage layout and events/errors for the GuildManagerFacet contract.


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.guildmanager");
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Events
### GuildOrganizationInitialized
*Emitted when a guild organization is initialized.*


```solidity
event GuildOrganizationInitialized(bytes32 organizationId, address tokenAddress);
```

### TimeoutAfterLeavingGuild
*Emitted when the timeout period after leaving a guild is updated.*


```solidity
event TimeoutAfterLeavingGuild(bytes32 organizationId, uint32 timeoutAfterLeavingGuild);
```

### MaxGuildsPerUserUpdated
*Emitted when the maximum number of guilds per user is updated.*


```solidity
event MaxGuildsPerUserUpdated(bytes32 organizationId, uint8 maxGuildsPerUser);
```

### MaxUsersPerGuildUpdated
*Emitted when the maximum number of users per guild is updated.*


```solidity
event MaxUsersPerGuildUpdated(bytes32 organizationId, MaxUsersPerGuildRule rule, uint32 maxUsersPerGuildConstant);
```

### GuildCreationRuleUpdated
*Emitted when the guild creation rule is updated.*


```solidity
event GuildCreationRuleUpdated(bytes32 organizationId, GuildCreationRule creationRule);
```

### CustomGuildManagerAddressUpdated
*Emitted when the custom guild manager address is updated.*


```solidity
event CustomGuildManagerAddressUpdated(bytes32 organizationId, address customGuildManagerAddress);
```

### GuildCreated
*Emitted when a new guild is created.*


```solidity
event GuildCreated(bytes32 organizationId, uint32 guildId);
```

### GuildInfoUpdated
*Emitted when a guild's information is updated.*


```solidity
event GuildInfoUpdated(bytes32 organizationId, uint32 guildId, string name, string description);
```

### GuildSymbolUpdated
*Emitted when a guild's symbol is updated.*


```solidity
event GuildSymbolUpdated(bytes32 organizationId, uint32 guildId, string symbolImageData, bool isSymbolOnChain);
```

### GuildUserStatusChanged
*Emitted when a user's status in a guild is changed.*


```solidity
event GuildUserStatusChanged(bytes32 organizationId, uint32 guildId, address user, GuildUserStatus status);
```

## Errors
### GuildOrganizationAlreadyInitialized
*Emitted when a guild organization has already been initialized.*


```solidity
error GuildOrganizationAlreadyInitialized(bytes32 organizationId);
```

### UserCannotCreateGuild
*Emitted when a user is not allowed to create a guild.*


```solidity
error UserCannotCreateGuild(bytes32 organizationId, address user);
```

### NotGuildOwner
*Emitted when the sender is not the guild owner and tries to perform an owner-only action.*


```solidity
error NotGuildOwner(address sender, string action);
```

### NotGuildOwnerOrAdmin
*Emitted when the sender is neither the guild owner nor an admin and tries to perform an owner or admin action.*


```solidity
error NotGuildOwnerOrAdmin(address sender, string action);
```

### GuildFull
*Emitted when a guild is full and cannot accept new members.*


```solidity
error GuildFull(bytes32 organizationId, uint32 guildId);
```

### UserAlreadyInGuild
*Emitted when a user is already a member of a guild.*


```solidity
error UserAlreadyInGuild(bytes32 organizationId, uint32 guildId, address user);
```

### UserInTooManyGuilds
*Emitted when a user is a member of too many guilds.*


```solidity
error UserInTooManyGuilds(bytes32 organizationId, address user);
```

### UserNotGuildMember
*Emitted when a user is not a member of a guild.*


```solidity
error UserNotGuildMember(bytes32 organizationId, uint32 guildId, address user);
```

### InvalidAddress
*Emitted when an invalid address is provided.*


```solidity
error InvalidAddress(address user);
```

## Structs
### Layout

```solidity
struct Layout {
    UpgradeableBeacon guildTokenBeacon;
    mapping(bytes32 => GuildOrganizationInfo) guildOrganizationInfo;
    mapping(bytes32 => mapping(uint32 => GuildInfo)) organizationIdToGuildIdToInfo;
    mapping(bytes32 => mapping(address => GuildOrganizationUserInfo)) organizationIdToAddressToInfo;
}
```

