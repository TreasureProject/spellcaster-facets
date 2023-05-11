// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { IDiamondCut } from "src/diamond/IDiamondCut.sol";
import { Diamond } from "src/diamond/Diamond.sol";
import { DiamondCutFacet } from "src/diamond/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "src/diamond/DiamondLoupeFacet.sol";
import { AccessControlFacet } from "src/access/AccessControlFacet.sol";
import { OwnershipFacet } from "src/access/OwnershipFacet.sol";
import { PausableFacet } from "src/security/PausableFacet.sol";
import { MetaTxFacet } from "src/metatx/MetaTxFacet.sol";

struct FacetInfo {
    address addr;
    string name;
    IDiamondCut.FacetCutAction action;
}

contract DiamondManager is Script {
    Diamond internal diamond;

    /**
     * @dev Creates and sets up a new Diamond. Includes AccessControl and OwnershipFacets automatically
     */
    function init() public {
        init(new FacetInfo[](0), new Diamond.Initialization[](0));
    }

    /**
     * @dev Creates and sets up a new Diamond with the given facets. Includes AccessControl and OwnershipFacets automatically
     */
    function init(FacetInfo[] memory _facets) public {
        init(_facets, new Diamond.Initialization[](0));
    }

    /**
     * @dev Creates and sets up a new Diamond with the given facets and runs the given init bytecode.
     *  Includes AccessControl and OwnershipFacets automatically
     */
    function init(FacetInfo[] memory _facets, Diamond.Initialization[] memory _inits) public {
        diamond = createDiamondAndInit(_facets, _inits);
    }

    function createDiamondAndInit() internal returns (Diamond) {
        return createDiamondAndInit(new FacetInfo[](0), new Diamond.Initialization[](0));
    }

    function createDiamondAndInit(FacetInfo[] memory _facets) internal returns (Diamond) {
        return createDiamondAndInit(_facets, new Diamond.Initialization[](0));
    }

    function createDiamondAndInit(
        FacetInfo[] memory _facets,
        Diamond.Initialization[] memory _inits
    ) internal returns (Diamond) {
        return createDiamondAndInit(_facets, _inits, new FacetInfo[](0));
    }

    function createDiamondAndInit(
        FacetInfo[] memory _facets,
        Diamond.Initialization[] memory _inits,
        FacetInfo[] memory _optionalFacets
    ) internal returns (Diamond) {
        DiamondCutFacet _diamondCut = new DiamondCutFacet();
        DiamondLoupeFacet _diamondLoupe = new DiamondLoupeFacet();
        OwnershipFacet _ownership = new OwnershipFacet();
        AccessControlFacet _accessControl = new AccessControlFacet();
        PausableFacet _pausable = new PausableFacet();
        MetaTxFacet _meta = new MetaTxFacet();

        FacetInfo[6] memory _staticFacets = [
            FacetInfo(address(_diamondCut), "DiamondCutFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(_diamondLoupe), "DiamondLoupeFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(_ownership), "OwnershipFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(_pausable), "PausableFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(_accessControl), "AccessControlFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(_meta), "MetaTxFacet", IDiamondCut.FacetCutAction.Add)
        ];

        IDiamondCut.FacetCut[] memory _cuts =
            new IDiamondCut.FacetCut[](_staticFacets.length + _facets.length + _optionalFacets.length);

        for (uint256 i = 0; i < _staticFacets.length; i++) {
            _cuts[i] = IDiamondCut.FacetCut(
                _staticFacets[i].addr, _staticFacets[i].action, generateSelectors(_staticFacets[i].name)
            );
        }

        for (uint256 i = 0; i < _facets.length; i++) {
            if (_facets[i].addr == address(0)) {
                revert("TEST: Invalid FacetInfo given");
            }
            _cuts[i + _staticFacets.length] =
                IDiamondCut.FacetCut(_facets[i].addr, _facets[i].action, generateSelectors(_facets[i].name));
        }

        for (uint256 i = 0; i < _optionalFacets.length; i++) {
            _cuts[i + _staticFacets.length + _facets.length] = IDiamondCut.FacetCut(
                _optionalFacets[i].addr, _optionalFacets[i].action, generateSelectors(_optionalFacets[i].name)
            );
        }

        Diamond.Initialization[] memory _initsAll = new Diamond.Initialization[](1 + _inits.length);
        _initsAll[0] = Diamond.Initialization({
            initContract: address(_accessControl),
            initData: abi.encodeWithSelector(AccessControlFacet.AccessControlFacet_init.selector)
        });

        for (uint256 i = 0; i < _inits.length; i++) {
            _initsAll[i + 1] = _inits[i];
        }

        return new Diamond(address(this), _cuts, _initsAll);
    }

    function diamondCutInit(address _facetAddr, bytes memory _calldata) internal {
        IDiamondCut(address(diamond)).diamondCut(new IDiamondCut.FacetCut[](0), _facetAddr, _calldata);
    }

    function generateSelectors(string memory _facetName) internal returns (bytes4[] memory _selectors) {
        string[] memory _cmd = new string[](2);
        _cmd[0] = "_target/debug/get_facet_selectors";
        _cmd[1] = _facetName;

        bytes memory _res = vm.ffi(_cmd);
        _selectors = abi.decode(_res, (bytes4[]));
    }
}
