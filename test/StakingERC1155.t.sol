// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

import {TestBase} from "./utils/TestBase.sol";
import {StakingERC1155, WithdrawRequest, Signature} from "../src/StakingERC1155.sol";
import {ERC1155Consumer} from "../src/mocks/ERC1155Consumer.sol";

contract StakingERC1155Impl is StakingERC1155 {
    function initialize() public initializer{
        __StakingERC1155_init();
    }
}

contract StakingERC1155Test is TestBase, ERC1155HolderUpgradeable {
    StakingERC1155Impl internal _staking;
    ERC1155Consumer internal _consumer;

    uint256 constant _tokenId = 2;

    function setUp() public {
        _staking = new StakingERC1155Impl();
        _consumer = new ERC1155Consumer();

        _staking.initialize();
        _consumer.initialize();

        _consumer.setWorldAddress(address(_staking));
        _consumer.mintArbitrary(deployer, 2, 2);
    }

    function toSigHash(uint256 nonce, address token, uint256 tokenId, uint256 amount, address recipient) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(nonce,token,tokenId,amount,recipient));
    }

    function getIds() internal pure returns(uint256[] memory) {
        uint256[] memory ids = new uint256[](20);
        for (uint i = 0; i < 20; i++) {
            ids[i] = i;
        }
        return ids;
    }

    function testDepositsAndWithdraws2TokensFromWorld() public {
        _consumer.setApprovalForAll(address(_staking), true);
        assertEq(2, _consumer.balanceOf(deployer, _tokenId));
        uint256[] memory idAndAmount = new uint256[](1);
        idAndAmount[0] = 2;
        _staking.depositERC1155(address(_consumer), deployer, idAndAmount, idAndAmount);

        assertEq(0, _consumer.balanceOf(deployer, _tokenId));

        WithdrawRequest[] memory req = new WithdrawRequest[](1);
        req[0] = WithdrawRequest({
            tokenAddress: address(_consumer),
            reciever: deployer,
            tokenId: _tokenId,
            amount: 2,
            nonce: 0,
            stored: true,
            signature: Signature(0, 0x0, 0x0)
        });
        _staking.withdrawERC1155(req);

        assertEq(2, _consumer.balanceOf(deployer, _tokenId));
    }

    function testAllowTrustedWithdraw() public {
        (address addr, uint256 pk) = makeAddrAndKey("trustedSigner");
        _consumer.setAdmin(addr, true);

        (uint8 v, bytes32 r, bytes32 s) = signHashEthVRS(pk, toSigHash(0, address(_consumer), _tokenId, 20, deployer));

        WithdrawRequest[] memory req = new WithdrawRequest[](1);
        req[0] = WithdrawRequest({
            tokenAddress: address(_consumer),
            reciever: deployer,
            tokenId: _tokenId,
            amount: 20,
            nonce: 0,
            stored: false,
            signature: Signature(v, r, s)
        });

        _staking.withdrawERC1155(req);
        assertEq(22, _consumer.balanceOf(deployer, _tokenId));
    }

    function test() public {
    }

}