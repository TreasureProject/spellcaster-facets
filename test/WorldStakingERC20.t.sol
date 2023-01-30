// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {TestBase} from "./utils/TestBase.sol";
import {WorldStakingERC20} from "../src/WorldStakingERC20.sol";
import {ERC20Consumer} from "../src/mocks/ERC20Consumer.sol";

contract WorldStakingERC20Test is TestBase {
    WorldStakingERC20 internal _staking;
    ERC20Consumer internal _consumer;

    function setUp() public {
        _staking = new WorldStakingERC20();
        _consumer = new ERC20Consumer();

        _staking.initialize();
        _consumer.initialize();

        _consumer.setWorldAddress(address(_staking));
        _consumer.setAdmin(leet);
        _consumer.mintArbitrary(deployer, 2_000 ether);
    }

    function testDepositsAndWithdraws2000TokensFromWorld() public {
        _consumer.approve(address(_staking), 2_000 ether);
        _staking.depositERC20(address(_consumer), deployer, 2_000 ether);

        assertEq(0, _consumer.balanceOf(deployer));
    }

    function test() public {
    }

}