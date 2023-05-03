# LibDiamond
[Git Source](https://github.com/TreasureProject/spellcaster-facets/blob/35a5f7a33e5c726475104b88b7e2a468bb5aa2b7/src/diamond/LibDiamond.sol)

\
Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/*****************************************************************************


## State Variables
### DIAMOND_STORAGE_POSITION

```solidity
bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
```


## Functions
### diamondStorage


```solidity
function diamondStorage() internal pure returns (DiamondStorage storage ds);
```

### setContractOwner


```solidity
function setContractOwner(address _newOwner) internal;
```

### contractOwner


```solidity
function contractOwner() internal view returns (address contractOwner_);
```

### enforceIsContractOwner


```solidity
function enforceIsContractOwner() internal view;
```

### diamondCut


```solidity
function diamondCut(IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) internal;
```

### addFunctions


```solidity
function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```

### replaceFunctions


```solidity
function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```

### removeFunctions


```solidity
function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```

### addFacet


```solidity
function addFacet(DiamondStorage storage ds, address _facetAddress) internal;
```

### addFunction


```solidity
function addFunction(
    DiamondStorage storage ds,
    bytes4 _selector,
    uint96 _selectorPosition,
    address _facetAddress
) internal;
```

### removeFunction


```solidity
function removeFunction(DiamondStorage storage ds, address _facetAddress, bytes4 _selector) internal;
```

### initializeDiamondCut


```solidity
function initializeDiamondCut(address _init, bytes memory _calldata) internal;
```

### enforceHasContractCode


```solidity
function enforceHasContractCode(address _contract, string memory _errorMessage) internal view;
```

## Events
### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

### DiamondCut

```solidity
event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);
```

## Structs
### FacetAddressAndPosition

```solidity
struct FacetAddressAndPosition {
    address facetAddress;
    uint16 functionSelectorPosition;
}
```

### FacetFunctionSelectors

```solidity
struct FacetFunctionSelectors {
    bytes4[] functionSelectors;
    uint16 facetAddressPosition;
}
```

### DiamondStorage

```solidity
struct DiamondStorage {
    mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
    mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
    address[] facetAddresses;
    mapping(bytes4 => bool) supportedInterfaces;
    address contractOwner;
}
```

