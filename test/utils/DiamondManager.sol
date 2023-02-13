// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {IDiamondCut} from "../../src/diamond/IDiamondCut.sol";
import {Diamond} from "../../src/diamond/Diamond.sol";
import {DiamondCutFacet} from "../../src/diamond/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/diamond/DiamondLoupeFacet.sol";
import {AccessControlFacet} from "../../src/access/AccessControlFacet.sol";
import {OwnershipFacet} from "../../src/access/OwnershipFacet.sol";
import {PausableFacet} from "../../src/security/PausableFacet.sol";

struct FacetInfo {
    address addr;
    string name;
    IDiamondCut.FacetCutAction action;
}

contract DiamondManager is Script {
    Diamond internal _diamond;

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
        _diamond = createDiamondAndInit(_facets, _inits);
    }

    function createDiamondAndInit() internal returns (Diamond) {
        return createDiamondAndInit(new FacetInfo[](0), new Diamond.Initialization[](0));
    }

    function createDiamondAndInit(FacetInfo[] memory _facets) internal returns (Diamond) {
        return createDiamondAndInit(_facets, new Diamond.Initialization[](0));
    }

    function createDiamondAndInit(FacetInfo[] memory _facets, Diamond.Initialization[] memory _inits) internal returns (Diamond) {
        return createDiamondAndInit(_facets, _inits, new FacetInfo[](0));
    }

    function createDiamondAndInit(FacetInfo[] memory _facets, Diamond.Initialization[] memory _inits, FacetInfo[] memory _optionalFacets) internal returns (Diamond) {
        DiamondCutFacet diamondCut = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupe = new DiamondLoupeFacet();
        OwnershipFacet ownership = new OwnershipFacet();
        AccessControlFacet accessControl = new AccessControlFacet();
        PausableFacet pausable = new PausableFacet();
        
        FacetInfo[5] memory staticFacets = [
            FacetInfo(address(diamondCut), "DiamondCutFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(diamondLoupe), "DiamondLoupeFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(ownership), "OwnershipFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(pausable), "PausableFacet", IDiamondCut.FacetCutAction.Add),
            FacetInfo(address(accessControl), "AccessControlFacet", IDiamondCut.FacetCutAction.Add)
        ];

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](staticFacets.length + _facets.length + _optionalFacets.length);

        for (uint i = 0; i < staticFacets.length; i++) {
            cuts[i] = IDiamondCut.FacetCut(
                staticFacets[i].addr,
                staticFacets[i].action,
                generateSelectors(staticFacets[i].name)
            );
        }

        for (uint i = 0; i < _facets.length; i++) {
            if(_facets[i].addr == address(0)) {
                revert("TEST ARGS INVALID: Invalid FacetInfo given");
            }
            cuts[i + staticFacets.length] = IDiamondCut.FacetCut(
                _facets[i].addr,
                _facets[i].action,
                generateSelectors(_facets[i].name)
            );
        }

        for (uint i = 0; i < _optionalFacets.length; i++) {
            cuts[i  + staticFacets.length + _facets.length] = IDiamondCut.FacetCut(
                _optionalFacets[i].addr,
                _optionalFacets[i].action,
                generateSelectors(_optionalFacets[i].name)
            );
        }

        Diamond.Initialization[] memory _initsAll = new Diamond.Initialization[](1 + _inits.length);
        _initsAll[0] = Diamond.Initialization({
            initContract: address(accessControl),
            initData: abi.encodeWithSelector(AccessControlFacet.AccessControlFacet_init.selector)
        });

        for (uint i = 0; i < _inits.length; i++) {
            _initsAll[i+1] = _inits[i];
        }

        return new Diamond(address(this), cuts, _initsAll);
    }

    function diamondCutInit(address _facetAddr, bytes memory _calldata) internal {
        IDiamondCut(address(_diamond)).diamondCut(new IDiamondCut.FacetCut[](0), _facetAddr, _calldata);
    }

    function generateSelectors(string memory _facetName) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](2);
        cmd[0] = "_target/debug/get_facet_selectors";
        cmd[1] = _facetName;

        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }
}