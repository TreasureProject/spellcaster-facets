// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { TestBase } from "./utils/TestBase.sol";
import { StakingERC721, WithdrawRequest, Signature } from "../src/StakingERC721.sol";
import { ERC721Consumer } from "../src/mocks/ERC721Consumer.sol";

contract StakingERC721Test is TestBase {
    StakingERC721 internal _staking;
    ERC721Consumer internal _consumer;

    function setUp() public {
        _staking = new StakingERC721();
        _consumer = new ERC721Consumer();

        _staking.initialize();
        _consumer.initialize();

        _consumer.setWorldAddress(address(_staking));
        _consumer.mintArbitrary(deployer, 20);
    }

    function toSigHash(
        uint256 nonce,
        address token,
        uint256 tokenId,
        address recipient
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(nonce, token, tokenId, recipient));
    }

    function getIds() internal pure returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](20);
        for (uint256 i = 0; i < 20; i++) {
            ids[i] = i;
        }
        return ids;
    }

    function testDepositsAndWithdraws20TokensFromWorld() public {
        _consumer.setApprovalForAll(address(_staking), true);
        assertEq(20, _consumer.balanceOf(deployer));
        uint256[] memory ids = getIds();
        _staking.depositERC721(address(_consumer), deployer, ids);

        assertEq(0, _consumer.balanceOf(deployer));

        WithdrawRequest[] memory req = new WithdrawRequest[](20);
        for (uint256 i = 0; i < ids.length; i++) {
            req[i] = WithdrawRequest({
                tokenAddress: address(_consumer),
                reciever: deployer,
                tokenId: i,
                nonce: 0,
                stored: true,
                signature: Signature(0, 0x0, 0x0)
            });
        }
        _staking.withdrawERC721(req);

        assertEq(20, _consumer.balanceOf(deployer));
    }

    function testAllowTrustedWithdraw() public {
        (address addr, uint256 pk) = makeAddrAndKey("trustedSigner");
        _consumer.setAdmin(addr, true);

        WithdrawRequest[] memory req = new WithdrawRequest[](10);
        for (uint256 i = 0; i < 10; i++) {
            uint256 tokenId = i + 20; // offset from initial 20 minted
            (uint8 v1, bytes32 r1, bytes32 s1) =
                signHashEthVRS(pk, toSigHash(tokenId, address(_consumer), tokenId, deployer));

            req[i] = WithdrawRequest({
                tokenAddress: address(_consumer),
                reciever: deployer,
                tokenId: tokenId,
                nonce: tokenId,
                stored: false,
                signature: Signature(v1, r1, s1)
            });
        }

        _staking.withdrawERC721(req);
        assertEq(30, _consumer.balanceOf(deployer));
    }

    function test() public { }
}
