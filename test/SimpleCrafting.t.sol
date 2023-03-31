// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

import { DiamondManager, Diamond, IDiamondCut, FacetInfo } from "./utils/DiamondManager.sol";
import { DiamondUtils } from "./utils/DiamondUtils.sol";

import { TestBase } from "./utils/TestBase.sol";

import { SimpleCrafting } from "src/crafting/SimpleCrafting.sol";
import { CraftingRecipe, Ingredient, Result, TOKENTYPE } from "src/crafting/SimpleCraftingStorage.sol";

import { LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE } from "src/libraries/LibAccessControlRoles.sol";

import { AccessControlFacet } from "src/access/AccessControlFacet.sol";

import { ERC20Consumer } from "src/mocks/ERC20Consumer.sol";
import { ERC721Consumer } from "src/mocks/ERC721Consumer.sol";
import { ERC1155Consumer } from "src/mocks/ERC1155Consumer.sol";

import {
    CollectionAccessControlFacet,
    CollectionRoleGrantRequest,
    COLLECTION_ROLE_GRANT_REQUEST_TYPEHASH
} from "src/access/CollectionAccessControlFacet.sol";

import { SpellcasterGM } from "src/spellcaster/SpellcasterGM.sol";

import "forge-std/console.sol";

contract SimpleCraftingTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;

    SimpleCrafting internal _simpleCrafting;

    ERC20Consumer internal _ERC20Consumer;
    ERC721Consumer internal _ERC721Consumer;
    ERC1155Consumer internal _ERC1155Consumer;

    uint96 signerNonce;

    address roleGranterAddress = address(11);
    address erc20Admin = address(12);
    address erc721Admin = address(13);
    address erc1155Admin = address(14);

    function setUp() public {
        FacetInfo[] memory facetInfo = new FacetInfo[](3);
        Diamond.Initialization[] memory initializations = new Diamond.Initialization[](1);

        facetInfo[0] = FacetInfo(address(new SimpleCrafting()), "SimpleCrafting", IDiamondCut.FacetCutAction.Add);
        facetInfo[1] = FacetInfo(
            address(new CollectionAccessControlFacet()), "CollectionAccessControlFacet", IDiamondCut.FacetCutAction.Add
        );
        facetInfo[2] = FacetInfo(address(new SpellcasterGM()), "SpellcasterGM", IDiamondCut.FacetCutAction.Add);

        initializations[0] = Diamond.Initialization({
            initContract: facetInfo[1].addr,
            initData: abi.encodeWithSelector(CollectionAccessControlFacet.CollectionAccessControlFacet_init.selector)
        });

        init(facetInfo, initializations);

        _simpleCrafting = SimpleCrafting(address(_diamond));

        _diamond.grantRole("ADMIN", deployer);

        _ERC20Consumer = new ERC20Consumer();
        _ERC721Consumer = new ERC721Consumer();
        _ERC1155Consumer = new ERC1155Consumer();

        _ERC20Consumer.initialize();
        _ERC721Consumer.initialize();
        _ERC1155Consumer.initialize();

        _ERC20Consumer.setWorldAddress(address(_simpleCrafting));
        _ERC721Consumer.setWorldAddress(address(_simpleCrafting));
        _ERC1155Consumer.setWorldAddress(address(_simpleCrafting));

        _ERC20Consumer.mintArbitrary(deployer, 101 * 10 ** 18);
        _ERC721Consumer.mintArbitrary(deployer, 11);
        _ERC1155Consumer.mintArbitrary(deployer, 2, 4);

        _ERC20Consumer.approve(address(_simpleCrafting), 100 * 10 ** 18);
        _ERC721Consumer.setApprovalForAll(address(_simpleCrafting), true);
        _ERC1155Consumer.setApprovalForAll(address(_simpleCrafting), true);
    }

    function collectionRoleGrantRequestToHash(CollectionRoleGrantRequest memory _collectionRoleGrantRequest)
        internal
        view
        returns (bytes32)
    {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    COLLECTION_ROLE_GRANT_REQUEST_TYPEHASH,
                    _collectionRoleGrantRequest.collection,
                    _collectionRoleGrantRequest.nonce,
                    _collectionRoleGrantRequest.receiver,
                    _collectionRoleGrantRequest.role
                )
            ),
            "Spellcaster",
            "1.0.0",
            address(_diamond)
        );
    }

    function generateCollectionRoleGrantRequest(
        address _reciever,
        address _collection
    ) internal returns (CollectionRoleGrantRequest memory) {
        return CollectionRoleGrantRequest({
            collection: address(_collection),
            nonce: signerNonce++,
            receiver: _reciever,
            role: keccak256(abi.encodePacked("COLLECTION_ROLE_GRANTER_ROLE_", address(_collection)))
        });
    }

    function testSetCraftingRecipe() public {
        //Create recipe that uses
        //100 ERC20
        //Id 10 of ERC721
        //3 of ID 2 of ERC1155

        //Outputs
        //20 ERC20
        //Id 20 of ERC721
        //10 of ID 3 of ERC1155

        Ingredient[] memory ingredients = new Ingredient[](3);
        ingredients[0] = Ingredient(address(_ERC20Consumer), TOKENTYPE.ERC20, 0, 100 * 10 ** 18);
        ingredients[1] = Ingredient(address(_ERC721Consumer), TOKENTYPE.ERC721, 10, 0);
        ingredients[2] = Ingredient(address(_ERC1155Consumer), TOKENTYPE.ERC1155, 2, 3);

        Result[] memory results = new Result[](3);
        results[0] = Result(
            address(_ERC20Consumer),
            bytes4(keccak256(bytes("mintFromWorld(address,uint256)"))),
            abi.encode(20 * 10 ** 18)
        );
        results[1] =
            Result(address(_ERC721Consumer), bytes4(keccak256(bytes("mintFromWorld(address,uint256)"))), abi.encode(20));
        results[2] = Result(
            address(_ERC1155Consumer),
            bytes4(keccak256(bytes("mintFromWorld(address,uint256,uint256)"))),
            abi.encode(3, 10)
        );

        CraftingRecipe memory _craftingRecipe = CraftingRecipe(ingredients, results);

        _simpleCrafting.createNewCraftingRecipe(_craftingRecipe);

        SpellcasterGM(address(_diamond)).addTrustedSigner(signingAuthority);

        //Generate three requests for three contracts each with the same address as the granter
        CollectionRoleGrantRequest memory erc20Request =
            generateCollectionRoleGrantRequest(roleGranterAddress, address(_ERC20Consumer));
        CollectionRoleGrantRequest memory erc721Request =
            generateCollectionRoleGrantRequest(roleGranterAddress, address(_ERC721Consumer));
        CollectionRoleGrantRequest memory erc1155Request =
            generateCollectionRoleGrantRequest(roleGranterAddress, address(_ERC1155Consumer));

        //Sign all three as a trusted signer
        bytes memory erc20Sig = signHash(signingPK, collectionRoleGrantRequestToHash(erc20Request));
        bytes memory erc721Sig = signHash(signingPK, collectionRoleGrantRequestToHash(erc721Request));
        bytes memory erc1155Sig = signHash(signingPK, collectionRoleGrantRequestToHash(erc1155Request));

        //Prank as random address
        vm.startPrank(address(23548760));
        CollectionAccessControlFacet(address(_diamond)).grantCollectionRoleGranter(erc20Request, erc20Sig);
        CollectionAccessControlFacet(address(_diamond)).grantCollectionRoleGranter(erc721Request, erc721Sig);
        vm.stopPrank();
        //Execute this one as deployer.
        CollectionAccessControlFacet(address(_diamond)).grantCollectionRoleGranter(erc1155Request, erc1155Sig);

        //Prank as role granter.
        vm.startPrank(roleGranterAddress);
        //Grant admin to address 1
        CollectionAccessControlFacet(address(_diamond)).grantCollectionAdmin(erc20Admin, address(_ERC20Consumer));
        //Grant admin to address 2
        CollectionAccessControlFacet(address(_diamond)).grantCollectionAdmin(erc721Admin, address(_ERC721Consumer));
        //Grant admin to address 3
        CollectionAccessControlFacet(address(_diamond)).grantCollectionAdmin(erc1155Admin, address(_ERC1155Consumer));
        //Stop prenk
        vm.stopPrank();

        vm.prank(erc20Admin);
        _simpleCrafting.setRecipeToAllowedAsAdmin(address(_ERC20Consumer), 0);

        vm.prank(erc721Admin);
        _simpleCrafting.setRecipeToAllowedAsAdmin(address(_ERC721Consumer), 0);

        vm.prank(erc1155Admin);
        _simpleCrafting.setRecipeToAllowedAsAdmin(address(_ERC1155Consumer), 0);

        _simpleCrafting.craft(0);

        //Balance of ingredients

        //Should have 1 (leftover) + 20 (result) left of ERC20
        assertEq(_ERC20Consumer.balanceOf(deployer), 21 * 10 ** 18);
        //Owner of ERC721 token 10 should be crafting
        assertEq(_ERC721Consumer.ownerOf(10), address(_simpleCrafting));
        //Deployer has 1 of token Id 2 left over from ERC1155
        assertEq(_ERC1155Consumer.balanceOf(deployer, 2), 1);

        //Balances of results

        //Owner of ERC721 token 20 should be deployer
        assertEq(_ERC721Consumer.ownerOf(20), address(deployer));
        //Deployer has 10 of token Id 3 from ERC1155
        assertEq(_ERC1155Consumer.balanceOf(deployer, 3), 10);
    }
}
