// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC721HolderUpgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import { StringsUpgradeable } from "@openzeppelin/contracts-diamond/utils/StringsUpgradeable.sol";

import { ERC20MockDecimals } from "test/mocks/ERC20MockDecimals.sol";
import { ERC1155Mock } from "test/mocks/ERC1155Mock.sol";
import { ERC721Mock } from "test/mocks/ERC721Mock.sol";

import { TestBase } from "test/utils/TestBase.sol";
import { DiamondManager, Diamond, IDiamondCut, FacetInfo } from "./utils/DiamondManager.sol";
import { DiamondUtils } from "test/utils/DiamondUtils.sol";

import { OrganizationFacet, OrganizationManagerStorage } from "src/organizations/OrganizationFacet.sol";
import { OffchainAssetVaultManager } from "src/vaultmanager/OffchainAssetVaultManager.sol";
import { OffchainAssetVault } from "src/vault/OffchainAssetVault.sol";
import { IOffchainAssetVault, AssetKind, WithdrawArgs } from "src/interfaces/IOffchainAssetVault.sol";

contract ERC20AdminMintable is ERC20MockDecimals {
    constructor(uint8 _decimals) ERC20MockDecimals(_decimals) { }

    function adminMint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}

contract OffchainAssetVaultTest is TestBase, DiamondManager, ERC1155HolderUpgradeable, ERC721HolderUpgradeable {
    using DiamondUtils for Diamond;

    bytes32 internal constant WITHDRAW_ARGS_TYPEHASH = keccak256(
        "WithdrawArgs(address asset,uint96 tokenId,uint88 amount,uint8 kind,address to,uint248 nonce,bool isMint)"
    );

    OffchainAssetVaultManager internal manager;
    OffchainAssetVault internal vault1;
    uint64 internal vault1Id;

    ERC20AdminMintable internal erc20;
    ERC721Mock internal erc721;
    ERC1155Mock internal erc1155;

    function setUp() public {
        erc721 = new ERC721Mock();
        erc1155 = new ERC1155Mock();
        erc20 = new ERC20AdminMintable(18);

        FacetInfo[] memory _facetInfo = new FacetInfo[](2);
        Diamond.Initialization[] memory _initializations = new Diamond.Initialization[](1);

        _facetInfo[0] = FacetInfo(
            address(new OffchainAssetVaultManager()), "OffchainAssetVaultManager", IDiamondCut.FacetCutAction.Add
        );
        _facetInfo[1] = FacetInfo(address(new OrganizationFacet()), "OrganizationFacet", IDiamondCut.FacetCutAction.Add);
        _initializations[0] = Diamond.Initialization({
            initContract: _facetInfo[0].addr,
            initData: abi.encodeWithSelector(
                OffchainAssetVaultManager.OffchainAssetVaultManager_init.selector, address(new OffchainAssetVault())
                )
        });

        init(_facetInfo, _initializations);

        manager = OffchainAssetVaultManager(address(diamond));
        OrganizationFacet(address(manager)).createOrganization(org1, "My org", "My descr");

        (address _vaultAddress, uint64 _vaultId) = manager.createVault(org1, address(this), signingAuthority);
        vault1 = OffchainAssetVault(_vaultAddress);
        vault1Id = _vaultId;
    }

    function withdrawHash(WithdrawArgs memory _args) internal view returns (bytes32 hash_) {
        hash_ = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    WITHDRAW_ARGS_TYPEHASH,
                    _args.asset,
                    _args.tokenId,
                    _args.amount,
                    _args.kind,
                    _args.to,
                    _args.nonce,
                    _args.isMint
                )
            ),
            bytes(string.concat("OffchainAssetVault-", StringsUpgradeable.toString(vault1Id))),
            "1.0.0",
            address(vault1)
        );
    }

    function test_init_success() public {
        vm.expectRevert(errAlreadyInitialized("OffchainAssetVault_init"));
        vault1.OffchainAssetVault_init(org1, vault1Id);
    }

    function test_withdraw_erc20_validsig_success() public {
        erc20.mint(address(vault1), 100 ether);

        WithdrawArgs memory _args = WithdrawArgs({
            asset: address(erc20),
            tokenId: 0,
            amount: 5 ether,
            kind: AssetKind.ERC20,
            to: address(this),
            nonce: 0,
            isMint: false
        });
        bytes memory _sig = signHash(signingPK, withdrawHash(_args));

        WithdrawArgs[] memory _argsArr = new WithdrawArgs[](1);
        _argsArr[0] = _args;

        bytes[] memory _sigArr = new bytes[](1);
        _sigArr[0] = _sig;

        vault1.withdraw(_argsArr, _sigArr);

        assertEq(95 ether, erc20.balanceOf(address(vault1)));
        assertEq(5 ether, erc20.balanceOf(address(this)));

        vm.expectRevert(abi.encodeWithSelector(IOffchainAssetVault.NonceUsed.selector, _args.nonce));
        vault1.withdraw(_argsArr, _sigArr);
    }

    function test_withdraw_erc1155_validsig_success() public {
        erc1155.mint(address(vault1), 1, 100);

        WithdrawArgs memory _args = WithdrawArgs({
            asset: address(erc1155),
            tokenId: 1,
            amount: 5,
            kind: AssetKind.ERC1155,
            to: address(this),
            nonce: 0,
            isMint: false
        });
        bytes memory _sig = signHash(signingPK, withdrawHash(_args));

        WithdrawArgs[] memory _argsArr = new WithdrawArgs[](1);
        _argsArr[0] = _args;

        bytes[] memory _sigArr = new bytes[](1);
        _sigArr[0] = _sig;

        vault1.withdraw(_argsArr, _sigArr);

        assertEq(95, erc1155.balanceOf(address(vault1), 1));
        assertEq(5, erc1155.balanceOf(address(this), 1));

        vm.expectRevert(abi.encodeWithSelector(IOffchainAssetVault.NonceUsed.selector, _args.nonce));
        vault1.withdraw(_argsArr, _sigArr);
    }

    function test_withdraw_erc721_validsig_success() public {
        erc721.mint(address(vault1), 1);
        assertEq(address(vault1), erc721.ownerOf(1));

        WithdrawArgs memory _args = WithdrawArgs({
            asset: address(erc721),
            tokenId: 1,
            amount: 0,
            kind: AssetKind.ERC721,
            to: address(this),
            nonce: 0,
            isMint: false
        });
        bytes memory _sig = signHash(signingPK, withdrawHash(_args));

        WithdrawArgs[] memory _argsArr = new WithdrawArgs[](1);
        _argsArr[0] = _args;

        bytes[] memory _sigArr = new bytes[](1);
        _sigArr[0] = _sig;

        vault1.withdraw(_argsArr, _sigArr);

        assertEq(address(this), erc721.ownerOf(1));

        vm.expectRevert(abi.encodeWithSelector(IOffchainAssetVault.NonceUsed.selector, _args.nonce));
        vault1.withdraw(_argsArr, _sigArr);
    }

    function test_withdraw_batch_validsig_success() public {
        erc721.mint(address(vault1), 1);
        erc1155.mint(address(vault1), 1, 100);
        assertEq(address(vault1), erc721.ownerOf(1));

        WithdrawArgs memory _args = WithdrawArgs({
            asset: address(erc721),
            tokenId: 1,
            amount: 0,
            kind: AssetKind.ERC721,
            to: address(this),
            nonce: 0,
            isMint: false
        });
        bytes memory _sig = signHash(signingPK, withdrawHash(_args));

        WithdrawArgs[] memory _argsArr = new WithdrawArgs[](2);
        _argsArr[0] = _args;
        _argsArr[1] = WithdrawArgs({
            asset: address(erc1155),
            tokenId: 1,
            amount: 5,
            kind: AssetKind.ERC1155,
            to: address(this),
            nonce: 1,
            isMint: false
        });

        bytes[] memory _sigArr = new bytes[](2);
        _sigArr[0] = _sig;
        _sigArr[1] = signHash(signingPK, withdrawHash(_argsArr[1]));

        vault1.withdraw(_argsArr, _sigArr);

        assertEq(address(this), erc721.ownerOf(1));
        assertEq(95, erc1155.balanceOf(address(vault1), 1));
        assertEq(5, erc1155.balanceOf(address(this), 1));

        vm.expectRevert(abi.encodeWithSelector(IOffchainAssetVault.NonceUsed.selector, _args.nonce));
        vault1.withdraw(_argsArr, _sigArr);
    }

    function test_withdraw_invalidsig_reverts() public {
        erc20.mint(address(vault1), 100 ether);
        erc1155.mint(address(vault1), 1, 100);
        erc721.mint(address(vault1), 1);

        WithdrawArgs memory _args = WithdrawArgs({
            asset: address(erc20),
            tokenId: 0,
            amount: 5 ether,
            kind: AssetKind.ERC20,
            to: address(this),
            nonce: 0,
            isMint: false
        });
        bytes memory _sig = signHash(12345, withdrawHash(_args));

        WithdrawArgs[] memory _argsArr = new WithdrawArgs[](1);
        _argsArr[0] = _args;

        bytes[] memory _sigArr = new bytes[](1);
        _sigArr[0] = _sig;

        vm.expectRevert(IOffchainAssetVault.InvalidAuthoritySignature.selector);
        vault1.withdraw(_argsArr, _sigArr);

        _argsArr[0] = WithdrawArgs({
            asset: address(erc1155),
            tokenId: 1,
            amount: 5 ether,
            kind: AssetKind.ERC1155,
            to: address(this),
            nonce: 1,
            isMint: false
        });
        _sigArr[0] = signHash(12345, withdrawHash(_argsArr[0]));

        vm.expectRevert(IOffchainAssetVault.InvalidAuthoritySignature.selector);
        vault1.withdraw(_argsArr, _sigArr);

        _argsArr[0] = WithdrawArgs({
            asset: address(erc721),
            tokenId: 1,
            amount: 0,
            kind: AssetKind.ERC721,
            to: address(this),
            nonce: 2,
            isMint: false
        });
        _sigArr[0] = signHash(12345, withdrawHash(_argsArr[0]));

        vm.expectRevert(IOffchainAssetVault.InvalidAuthoritySignature.selector);
        vault1.withdraw(_argsArr, _sigArr);

        WithdrawArgs[] memory _argsArr2 = new WithdrawArgs[](2);
        _argsArr2[0] = WithdrawArgs({
            asset: address(erc721),
            tokenId: 1,
            amount: 0,
            kind: AssetKind.ERC721,
            to: address(this),
            nonce: 3,
            isMint: false
        });
        _argsArr2[1] = _args;
        _sigArr = new bytes[](2);
        _sigArr[0] = signHash(signingPK, withdrawHash(_argsArr2[0]));
        _sigArr[1] = signHash(12345, withdrawHash(_argsArr2[1]));

        vm.expectRevert(IOffchainAssetVault.InvalidAuthoritySignature.selector);
        vault1.withdraw(_argsArr2, _sigArr);
    }

    function test_mint_erc20_validsig_success() public {
        WithdrawArgs memory _args = WithdrawArgs({
            asset: address(erc20),
            tokenId: 0,
            amount: 5 ether,
            kind: AssetKind.ERC20,
            to: address(this),
            nonce: 0,
            isMint: true
        });
        bytes memory _sig = signHash(signingPK, withdrawHash(_args));

        WithdrawArgs[] memory _argsArr = new WithdrawArgs[](1);
        _argsArr[0] = _args;

        bytes[] memory _sigArr = new bytes[](1);
        _sigArr[0] = _sig;

        vault1.withdraw(_argsArr, _sigArr);

        assertEq(0 ether, erc20.balanceOf(address(vault1)));
        assertEq(5 ether, erc20.balanceOf(address(this)));

        vm.expectRevert(abi.encodeWithSelector(IOffchainAssetVault.NonceUsed.selector, _args.nonce));
        vault1.withdraw(_argsArr, _sigArr);
    }
}
