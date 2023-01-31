// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {TestBase} from "./utils/TestBase.sol";
import {WorldStakingERC20, WithdrawRequest, Signature} from "../src/WorldStakingERC20.sol";
import {ERC20Consumer} from "../src/mocks/ERC20Consumer.sol";

contract WorldStakingERC20Impl is WorldStakingERC20 {
    function initialize() public initializer{
        __WorldStakingERC20_init();
    }
}

contract WorldStakingERC20Test is TestBase {
    WorldStakingERC20Impl internal _staking;
    ERC20Consumer internal _consumer;

    function setUp() public {
        _staking = new WorldStakingERC20Impl();
        _consumer = new ERC20Consumer();

        _staking.initialize();
        _consumer.initialize();

        _consumer.setWorldAddress(address(_staking));
        _consumer.mintArbitrary(deployer, 2_000 ether);
    }

    function toSigHash(uint256 nonce, address token, uint256 amount, address recipient) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(nonce,token,amount,recipient));
    }

    function testDepositsAndWithdraws2000TokensFromWorld() public {
        _consumer.approve(address(_staking), 2_000 ether);

        assertEq(2_000 ether, _consumer.balanceOf(deployer));

        _staking.depositERC20(address(_consumer), deployer, 2_000 ether);

        assertEq(0, _consumer.balanceOf(deployer));

        WithdrawRequest[] memory req = new WithdrawRequest[](1);
        req[0] = WithdrawRequest({
            tokenAddress: address(_consumer),
            reciever: deployer,
            amount: 2_000 ether,
            nonce: 0,
            stored: true,
            signature: Signature(0, 0x0, 0x0)
        });
        _staking.withdrawERC20(req);

        assertEq(2_000 ether, _consumer.balanceOf(deployer));
    }

    function testAllowTrustedWithdraw() public {
        (address addr, uint256 pk) = makeAddrAndKey("trustedSigner");
        _consumer.setAdmin(addr, true);

        (uint8 v1, bytes32 r1, bytes32 s1) = signHashEthVRS(pk, toSigHash(0, address(_consumer), 2_000 ether, deployer));
        (uint8 v2, bytes32 r2, bytes32 s2) = signHashEthVRS(pk, toSigHash(1, address(_consumer), 1_000 ether, deployer));

        WithdrawRequest[] memory req = new WithdrawRequest[](2);
        req[0] = WithdrawRequest({
            tokenAddress: address(_consumer),
            reciever: deployer,
            amount: 2_000 ether,
            nonce: 0,
            stored: false,
            signature: Signature(v1, r1, s1)
        });
        req[1] = WithdrawRequest({
            tokenAddress: address(_consumer),
            reciever: deployer,
            amount: 1_000 ether,
            nonce: 1,
            stored: false,
            signature: Signature(v2, r2, s2)
        });

        _staking.withdrawERC20(req);
        assertEq(5_000 ether, _consumer.balanceOf(deployer));
    }

    function test() public {
    }

}