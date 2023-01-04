const { ethers, waffle } = require("hardhat");
const { expect } = require("chai");
const Promise = require("bluebird");

var signer1;
var owner;

before(async function () {
  _ERC1155Consumer = await ethers.getContractFactory("ERC1155Consumer");
  ERC1155Consumer = await _ERC1155Consumer.deploy();

  _WorldStakingERC1155 = await ethers.getContractFactory("WorldStakingERC1155");
  WorldStakingERC1155 = await _WorldStakingERC1155.deploy();

  [owner, signer1] = await ethers.getSigners();

  await ERC1155Consumer.setAdmin(signer1.address, true);
  await ERC1155Consumer.setWorldAddress(WorldStakingERC1155.address);

  await ERC1155Consumer.mintArbitrary(owner.address, 2, 2);
});

var signerNonce = 1;

describe("Tests", function () {
  it("deposits and withdraws 2 tokens from world", async function () {
    await ERC1155Consumer.setApprovalForAll(WorldStakingERC1155.address, true);

    await WorldStakingERC1155.depositERC1155(
      ERC1155Consumer.address,
      owner.address,
      [2],
      [2]
    );

    expect(await ERC1155Consumer.balanceOf(owner.address, 2)).to.equal(0);

    const withdrawRequest = {
      tokenAddress: ERC1155Consumer.address,
      reciever: owner.address,
      tokenId: 2,
      amount: 2,
      nonce: 0,
      stored: true,
      signature: {
        v: 0,
        r: "0x0000000000000000000000000000000000000000000000000000000000000000",
        s: "0x0000000000000000000000000000000000000000000000000000000000000000",
      },
    };

    await WorldStakingERC1155.withdrawERC1155([withdrawRequest]);

    expect(await ERC1155Consumer.balanceOf(owner.address, 2)).to.equal(2);
  });

  it("Withdraw 10 tokens that the signer allows it to", async function () {
    const withdrawRequests = await Promise.mapSeries(
      [[2, 20]],
      async (item, index) => {
        const message = ethers.utils.solidityPack(
          ["uint", "address", "uint", "uint", "address"],
          [
            signerNonce,
            ERC1155Consumer.address,
            item[0],
            item[1],
            owner.address,
          ]
        );

        const messageHash = ethers.utils.keccak256(message);

        let messageHashBytes = ethers.utils.arrayify(messageHash);

        const flatSig = await signer1.signMessage(messageHashBytes);

        const splitSig = ethers.utils.splitSignature(flatSig);

        const withdrawRequest = {
          tokenAddress: ERC1155Consumer.address,
          reciever: owner.address,
          tokenId: item[0],
          amount: item[1],
          nonce: signerNonce,
          stored: false,
          signature: {
            v: splitSig.v,
            r: splitSig.r,
            s: splitSig.s,
          },
        };

        signerNonce++;

        return withdrawRequest;
      }
    );

    await WorldStakingERC1155.withdrawERC1155(withdrawRequests);

    expect(await ERC1155Consumer.balanceOf(owner.address, 2)).to.equal(22);
  });
});
