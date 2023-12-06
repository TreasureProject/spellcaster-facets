# GuildTokenBase
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/guilds/guildtoken/GuildTokenBase.sol)

**Inherits:**
[IGuildToken](/src/interfaces/IGuildToken.sol/interface.IGuildToken.md), [MetaTxFacet](/src/metatx/MetaTxFacet.sol/contract.MetaTxFacet.md), [AccessControlFacet](/src/access/AccessControlFacet.sol/contract.AccessControlFacet.md), [ERC1155Facet](/src/token/ERC1155Facet.sol/abstract.ERC1155Facet.md)

Token contract to manage all of the guilds within an organization. Each tokenId is a different guild

*This contract is not expected to me part of a diamond since it is an asset contract that is dynamically created
by the GuildManager contract.*


## Functions
### __GuildTokenBase_init


```solidity
function __GuildTokenBase_init() internal onlyFacetInitializing;
```

### supportsInterface

*Overrides and passes through to ERC1155*


```solidity
function supportsInterface(bytes4 interfaceId) public view override(AccessControlFacet, ERC1155Facet) returns (bool);
```

### _msgSender

*Overrides the _msgSender function for all dependent contracts that implement it.
This must be done outside of the OZ-wrapped facets to avoid conflicting overrides needing explicit declaration*


```solidity
function _msgSender() internal view override returns (address);
```

### whenNotPaused


```solidity
modifier whenNotPaused();
```

### supportsMetaTxNoId


```solidity
modifier supportsMetaTxNoId() override;
```

