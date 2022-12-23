const { ethers, waffle } = require("hardhat");
const { expect } = require("chai");
const Promise = require("bluebird");

var signer1;
var owner;

const ids = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
];

before(async function () {
  _ERC721Consumer = await ethers.getContractFactory("ERC721Consumer");
  ERC721Consumer = await _ERC721Consumer.deploy();

  _WorldStakingERC721 = await ethers.getContractFactory("WorldStakingERC721");
  WorldStakingERC721 = await _WorldStakingERC721.deploy();

  [owner, signer1] = await ethers.getSigners();

  await ERC721Consumer.setAdmin(signer1.address, true);
  await ERC721Consumer.setWorldAddress(WorldStakingERC721.address);

  await ERC721Consumer.mintArbitrary(owner.address, 20);
});

var signerNonce = 1;
var tokenIdToEmit = 100000;

describe("Tests", function () {
  it("deposits and withdraws 20 tokens from world", async function () {
    await ERC721Consumer.setApprovalForAll(WorldStakingERC721.address, true);
    await WorldStakingERC721.depositERC721(ERC721Consumer.address, owner.address, ids);

    const withdrawRequests = ids.map((a) => {
      return {
        tokenAddress: ERC721Consumer.address,
        reciever: owner.address,
        tokenId: a,
        nonce: 0,
        stored: true,
        signature: {
          v: 0,
          r: "0x0000000000000000000000000000000000000000000000000000000000000000",
          s: "0x0000000000000000000000000000000000000000000000000000000000000000",
        },
      };
    });

    expect(await ERC721Consumer.balanceOf(owner.address)).to.equal(0)

    await WorldStakingERC721.withdrawERC721(withdrawRequests);

    expect(await ERC721Consumer.balanceOf(owner.address)).to.equal(20)
  });

  it("Withdraw 10 tokens that the signer allows it to", async function () {
    const withdrawRequests = await Promise.mapSeries(ids, async (id, index) => {
      const message = ethers.utils.solidityPack(
        ["uint", "address", "uint", "address"],
        [signerNonce, ERC721Consumer.address, tokenIdToEmit, owner.address]
      );

      const messageHash = ethers.utils.keccak256(message);


      let messageHashBytes = ethers.utils.arrayify(messageHash);

      const flatSig = await signer1.signMessage(messageHashBytes);

      const splitSig = ethers.utils.splitSignature(flatSig);

      const withdrawRequest = {
        tokenAddress: ERC721Consumer.address,
        reciever: owner.address,
        tokenId: tokenIdToEmit,
        nonce: signerNonce,
        stored: false,
        signature: {
          v: splitSig.v,
          r: splitSig.r,
          s: splitSig.s,
        },
      };

      signerNonce++;
      tokenIdToEmit++;

      return withdrawRequest;
    });

    await WorldStakingERC721.withdrawERC721(withdrawRequests);

    expect(await ERC721Consumer.balanceOf(owner.address)).to.equal(40)
  });
});
