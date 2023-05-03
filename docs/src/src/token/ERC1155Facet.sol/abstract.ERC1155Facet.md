# ERC1155Facet
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/token/ERC1155Facet.sol)

**Inherits:**
[FacetInitializable](/src/utils/FacetInitializable.sol/abstract.FacetInitializable.md), [SupportsMetaTx](/src/metatx/SupportsMetaTx.sol/abstract.SupportsMetaTx.md), ERC1155Upgradeable

*Use/inherit this facet to limit the spread of third-party dependency references and allow new functionality to be shared*


## Functions
### __ERC1155Facet_init


```solidity
function __ERC1155Facet_init(string memory uri_) internal onlyFacetInitializing;
```

### supportsInterface

*Overrides ERC1155Ugradeable and passes through to it.
This is to have multiple inheritance overrides to be from this repo instead of OZ*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```

### setApprovalForAll

*Adding support for meta transactions*


```solidity
function setApprovalForAll(address operator, bool approved) public virtual override supportsMetaTxNoId;
```

### safeBatchTransferFrom

*Adding support for meta transactions*


```solidity
function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
) public virtual override supportsMetaTxNoId;
```

### safeTransferFrom

*Adding support for meta transactions*


```solidity
function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
) public virtual override supportsMetaTxNoId;
```

