// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC1155HolderUpgradeable } from
    "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

import { TestBase } from "./utils/TestBase.sol";
import { StakingERC1155, WithdrawRequest, Signature } from "../src/StakingERC1155.sol";
import { ERC1155Consumer } from "../src/mocks/ERC1155Consumer.sol";

contract StakingERC1155Test is TestBase, ERC1155HolderUpgradeable {
    StakingERC1155 internal staking;
    ERC1155Consumer internal consumer;

    uint256 public constant tokenId = 2;

    function setUp() public {
        staking = new StakingERC1155();
        consumer = new ERC1155Consumer();

        staking.initialize();
        consumer.initialize();

        consumer.setWorldAddress(address(staking));
        consumer.mintArbitrary(deployer, 2, 2);
    }

    function toSigHash(
        uint256 _nonce,
        address _token,
        uint256 _tokenId,
        uint256 _amount,
        address _recipient
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_nonce, _token, _tokenId, _amount, _recipient));
    }

    function getIds() internal pure returns (uint256[] memory) {
        uint256[] memory _ids = new uint256[](20);
        for (uint256 i = 0; i < 20; i++) {
            _ids[i] = i;
        }
        return _ids;
    }

    function testDepositsAndWithdraws2TokensFromWorld() public {
        consumer.setApprovalForAll(address(staking), true);
        assertEq(2, consumer.balanceOf(deployer, tokenId));
        uint256[] memory _idAndAmount = new uint256[](1);
        _idAndAmount[0] = 2;
        staking.depositERC1155(address(consumer), deployer, _idAndAmount, _idAndAmount);

        assertEq(0, consumer.balanceOf(deployer, tokenId));

        WithdrawRequest[] memory _req = new WithdrawRequest[](1);
        _req[0] = WithdrawRequest({
            tokenAddress: address(consumer),
            reciever: deployer,
            tokenId: tokenId,
            amount: 2,
            nonce: 0,
            stored: true,
            signature: Signature(0, 0x0, 0x0)
        });
        staking.withdrawERC1155(_req);

        assertEq(2, consumer.balanceOf(deployer, tokenId));
    }

    function testAllowTrustedWithdraw() public {
        (address _addr, uint256 _pk) = makeAddrAndKey("trustedSigner");
        consumer.setAdmin(_addr, true);

        (uint8 _v, bytes32 _r, bytes32 _s) = signHashEthVRS(_pk, toSigHash(0, address(consumer), tokenId, 20, deployer));

        WithdrawRequest[] memory _req = new WithdrawRequest[](1);
        _req[0] = WithdrawRequest({
            tokenAddress: address(consumer),
            reciever: deployer,
            tokenId: tokenId,
            amount: 20,
            nonce: 0,
            stored: false,
            signature: Signature(_v, _r, _s)
        });

        staking.withdrawERC1155(_req);
        assertEq(22, consumer.balanceOf(deployer, tokenId));
    }

    function test() public { }
}
