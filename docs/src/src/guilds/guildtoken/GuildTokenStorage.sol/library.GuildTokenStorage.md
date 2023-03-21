# GuildTokenStorage
[Git Source](https://github.com-treasure/TreasureProject/spellcaster-facets/blob/e61aea147da628641c6f090a95c62cf081f729f5/src/guilds/guildtoken/GuildTokenStorage.sol)

This library contains the storage layout and events/errors for the GuildTokenFacet contract.


## State Variables
### FACET_STORAGE_POSITION

```solidity
bytes32 internal constant FACET_STORAGE_POSITION = keccak256("spellcaster.storage.guildtoken");
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage s);
```

## Errors
### GuildOrganizationAlreadyInitialized
*Emitted when a guild organization has already been initialized.*


```solidity
error GuildOrganizationAlreadyInitialized(bytes32 organizationId);
```

## Structs
### Layout

```solidity
struct Layout {
    IGuildManager guildManager;
    bytes32 organizationId;
}
```

