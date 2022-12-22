const { ethers, waffle } = require("hardhat");
const { expect } = require("chai");
const Promise = require("bluebird");

const ids = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
];

before(async function () {
  _NFTConsumer = await ethers.getContractFactory("NFTConsumer");
  NFTConsumer = await _NFTConsumer.deploy();

  _WorldStakingERC721 = await ethers.getContractFactory("WorldStakingERC721");
  WorldStakingERC721 = await _WorldStakingERC721.deploy();

  [owner, signer1] = await ethers.getSigners();

  await NFTConsumer.setAdmin(signer1.address, true);
  await NFTConsumer.setWorldAddress(WorldStakingERC721.address);

  await NFTConsumer.mintArbitrary(owner.address, 20);
});

var signerNonce = 1;
var tokenIdToEmit = 100000;

describe("Tests", function () {
  it("deposits and withdraws 20 tokens from world", async function () {
    await NFTConsumer.setApprovalForAll(WorldStakingERC721.address, true);
    await WorldStakingERC721.depositNFTs(NFTConsumer.address, ids);

    const wrs = ids.map((a) => {
      return {
        collectionAddress: NFTConsumer.address,
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

    expect(await NFTConsumer.balanceOf(owner.address)).to.equal(0)

    await WorldStakingERC721.withdrawNFTs(wrs);

    expect(await NFTConsumer.balanceOf(owner.address)).to.equal(20)
  });

  it("Withdraw 10 tokens that the signer allows it to", async function () {
    const signedMessages = await Promise.mapSeries(ids, async (id, index) => {
      const message = ethers.utils.solidityPack(
        ["uint", "address", "uint", "address"],
        [signerNonce, NFTConsumer.address, tokenIdToEmit, owner.address]
      );

      const messageHash = ethers.utils.keccak256(message);


      let messageHashBytes = ethers.utils.arrayify(messageHash);

      const flatSig = await signer1.signMessage(messageHashBytes);

      const splitSig = ethers.utils.splitSignature(flatSig);

      const obj = {
        collectionAddress: NFTConsumer.address,
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

      return obj;
    });


    await WorldStakingERC721.withdrawNFTs(signedMessages);

    expect(await NFTConsumer.balanceOf(owner.address)).to.equal(40)

  });
});
