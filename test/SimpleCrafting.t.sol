// SPDX-License-Identifier: Unlicense
/*pragma solidity ^0.8.0;

import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

import { DiamondManager, Diamond, IDiamondCut, FacetInfo } from "./utils/DiamondManager.sol";
import { DiamondUtils } from "./utils/DiamondUtils.sol";

import { TestBase } from "./utils/TestBase.sol";

import { SimpleCrafting } from "src/crafting/SimpleCrafting.sol";
import { CraftingRecipe, Ingredient, Result, TokenType } from "src/interfaces/ISimpleCrafting.sol";

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

contract SimpleCraftingTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;

    SimpleCrafting internal simpleCrafting;

    ERC20Consumer internal erc20Consumer;
    ERC721Consumer internal erc721Consumer;
    ERC1155Consumer internal erc1155Consumer;

    uint96 public signerNonce;

    address public roleGranterAddress = address(11);
    address public erc20Admin = address(12);
    address public erc721Admin = address(13);
    address public erc1155Admin = address(14);

    function setUp() public {
        FacetInfo[] memory _facetInfo = new FacetInfo[](3);
        Diamond.Initialization[] memory _initializations = new Diamond.Initialization[](1);

        _facetInfo[0] = FacetInfo(address(new SimpleCrafting()), "SimpleCrafting", IDiamondCut.FacetCutAction.Add);
        _facetInfo[1] = FacetInfo(
            address(new CollectionAccessControlFacet()), "CollectionAccessControlFacet", IDiamondCut.FacetCutAction.Add
        );
        _facetInfo[2] = FacetInfo(address(new SpellcasterGM()), "SpellcasterGM", IDiamondCut.FacetCutAction.Add);

        _initializations[0] = Diamond.Initialization({
            initContract: _facetInfo[1].addr,
            initData: abi.encodeWithSelector(CollectionAccessControlFacet.CollectionAccessControlFacet_init.selector)
        });

        init(_facetInfo, _initializations);

        simpleCrafting = SimpleCrafting(address(diamond));

        diamond.grantRole("ADMIN", deployer);

        erc20Consumer = new ERC20Consumer();
        erc721Consumer = new ERC721Consumer();
        erc1155Consumer = new ERC1155Consumer();

        erc20Consumer.initialize();
        erc721Consumer.initialize();
        erc1155Consumer.initialize();

        erc20Consumer.setWorldAddress(address(simpleCrafting));
        erc721Consumer.setWorldAddress(address(simpleCrafting));
        erc1155Consumer.setWorldAddress(address(simpleCrafting));

        erc20Consumer.mintArbitrary(deployer, 101 * 10 ** 18);
        erc721Consumer.mintArbitrary(deployer, 11);
        erc1155Consumer.mintArbitrary(deployer, 2, 4);

        erc20Consumer.approve(address(simpleCrafting), 100 * 10 ** 18);
        erc721Consumer.setApprovalForAll(address(simpleCrafting), true);
        erc1155Consumer.setApprovalForAll(address(simpleCrafting), true);
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
            address(diamond)
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
            role: LibAccessControlRoles.getCollectionRoleGranterRole(address(_collection))
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

        Ingredient[] memory _ingredients = new Ingredient[](3);
        _ingredients[0] = Ingredient(address(erc20Consumer), TokenType.ERC20, 0, 100 * 10 ** 18);
        _ingredients[1] = Ingredient(address(erc721Consumer), TokenType.ERC721, 10, 0);
        _ingredients[2] = Ingredient(address(erc1155Consumer), TokenType.ERC1155, 2, 3);

        Result[] memory _results = new Result[](3);
        _results[0] = Result(
            address(erc20Consumer),
            bytes4(keccak256(bytes("mintFromWorld(address,uint256)"))),
            abi.encode(20 * 10 ** 18)
        );
        _results[1] =
            Result(address(erc721Consumer), bytes4(keccak256(bytes("mintFromWorld(address,uint256)"))), abi.encode(20));
        _results[2] = Result(
            address(erc1155Consumer),
            bytes4(keccak256(bytes("mintFromWorld(address,uint256,uint256)"))),
            abi.encode(3, 10)
        );

        CraftingRecipe memory _craftingRecipe = CraftingRecipe(_ingredients, _results);

        simpleCrafting.createNewCraftingRecipe(_craftingRecipe);

        SpellcasterGM(address(diamond)).addTrustedSigner(signingAuthority);

        //Generate three requests for three contracts each with the same address as the granter
        CollectionRoleGrantRequest memory _erc20Request =
            generateCollectionRoleGrantRequest(roleGranterAddress, address(erc20Consumer));
        CollectionRoleGrantRequest memory _erc721Request =
            generateCollectionRoleGrantRequest(roleGranterAddress, address(erc721Consumer));
        CollectionRoleGrantRequest memory _erc1155Request =
            generateCollectionRoleGrantRequest(roleGranterAddress, address(erc1155Consumer));

        //Sign all three as a trusted signer
        bytes memory _erc20Sig = signHash(signingPK, collectionRoleGrantRequestToHash(_erc20Request));
        bytes memory _erc721Sig = signHash(signingPK, collectionRoleGrantRequestToHash(_erc721Request));
        bytes memory _erc1155Sig = signHash(signingPK, collectionRoleGrantRequestToHash(_erc1155Request));

        //Prank as random address
        vm.startPrank(address(23548760));
        CollectionAccessControlFacet(address(diamond)).grantCollectionRoleGranter(_erc20Request, _erc20Sig);
        CollectionAccessControlFacet(address(diamond)).grantCollectionRoleGranter(_erc721Request, _erc721Sig);
        vm.stopPrank();
        //Execute this one as deployer.
        CollectionAccessControlFacet(address(diamond)).grantCollectionRoleGranter(_erc1155Request, _erc1155Sig);

        //Prank as role granter.
        vm.startPrank(roleGranterAddress);
        //Grant admin to address 1
        CollectionAccessControlFacet(address(diamond)).grantCollectionAdmin(erc20Admin, address(erc20Consumer));
        //Grant admin to address 2
        CollectionAccessControlFacet(address(diamond)).grantCollectionAdmin(erc721Admin, address(erc721Consumer));
        //Grant admin to address 3
        CollectionAccessControlFacet(address(diamond)).grantCollectionAdmin(erc1155Admin, address(erc1155Consumer));
        //Stop prenk
        vm.stopPrank();

        vm.prank(erc20Admin);
        simpleCrafting.setRecipeToAllowedAsAdmin(address(erc20Consumer), 0);

        vm.prank(erc721Admin);
        simpleCrafting.setRecipeToAllowedAsAdmin(address(erc721Consumer), 0);

        vm.prank(erc1155Admin);
        simpleCrafting.setRecipeToAllowedAsAdmin(address(erc1155Consumer), 0);

        simpleCrafting.craft(0);

        //Balance of _ingredients

        //Should have 1 (leftover) + 20 (result) left of ERC20
        assertEq(erc20Consumer.balanceOf(deployer), 21 * 10 ** 18);
        //Owner of ERC721 token 10 should be crafting
        assertEq(erc721Consumer.ownerOf(10), address(simpleCrafting));
        //Deployer has 1 of token Id 2 left over from ERC1155
        assertEq(erc1155Consumer.balanceOf(deployer, 2), 1);

        //Balances of _results

        //Owner of ERC721 token 20 should be deployer
        assertEq(erc721Consumer.ownerOf(20), address(deployer));
        //Deployer has 10 of token Id 3 from ERC1155
        assertEq(erc1155Consumer.balanceOf(deployer, 3), 10);
    }
}
*/
