// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { TestBase } from "./utils/TestBase.sol";
import { StakingERC721, WithdrawRequest, Signature } from "../src/StakingERC721.sol";
import { ERC721Consumer } from "../src/mocks/ERC721Consumer.sol";

contract StakingERC721Test is TestBase {
    StakingERC721 internal staking;
    ERC721Consumer internal consumer;

    function setUp() public {
        staking = new StakingERC721();
        consumer = new ERC721Consumer();

        staking.initialize();
        consumer.initialize();

        consumer.setWorldAddress(address(staking));
        consumer.mintArbitrary(deployer, 20);
    }

    function toSigHash(
        uint256 _nonce,
        address _token,
        uint256 _tokenId,
        address _recipient
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_nonce, _token, _tokenId, _recipient));
    }

    function getIds() internal pure returns (uint256[] memory) {
        uint256[] memory _ids = new uint256[](20);
        for (uint256 i = 0; i < 20; i++) {
            _ids[i] = i;
        }
        return _ids;
    }

    function testDepositsAndWithdraws20TokensFromWorld() public {
        consumer.setApprovalForAll(address(staking), true);
        assertEq(20, consumer.balanceOf(deployer));
        uint256[] memory _ids = getIds();
        staking.depositERC721(address(consumer), deployer, _ids);

        assertEq(0, consumer.balanceOf(deployer));

        WithdrawRequest[] memory _req = new WithdrawRequest[](20);
        for (uint256 i = 0; i < _ids.length; i++) {
            _req[i] = WithdrawRequest({
                tokenAddress: address(consumer),
                reciever: deployer,
                tokenId: i,
                nonce: 0,
                stored: true,
                signature: Signature(0, 0x0, 0x0)
            });
        }
        staking.withdrawERC721(_req);

        assertEq(20, consumer.balanceOf(deployer));
    }

    function testAllowTrustedWithdraw() public {
        (address _addr, uint256 _pk) = makeAddrAndKey("trustedSigner");
        consumer.setAdmin(_addr, true);

        WithdrawRequest[] memory _req = new WithdrawRequest[](10);
        for (uint256 i = 0; i < 10; i++) {
            uint256 _tokenId = i + 20; // offset from initial 20 minted
            (uint8 _v1, bytes32 _r1, bytes32 _s1) =
                signHashEthVRS(_pk, toSigHash(_tokenId, address(consumer), _tokenId, deployer));

            _req[i] = WithdrawRequest({
                tokenAddress: address(consumer),
                reciever: deployer,
                tokenId: _tokenId,
                nonce: _tokenId,
                stored: false,
                signature: Signature(_v1, _r1, _s1)
            });
        }

        staking.withdrawERC721(_req);
        assertEq(30, consumer.balanceOf(deployer));
    }

    function test() public { }
}
