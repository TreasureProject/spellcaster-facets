const { ethers, waffle } = require("hardhat");
const { expect } = require("chai");
const Promise = require("bluebird");


before(async function () {
  _ERC20Consumer = await ethers.getContractFactory("ERC20Consumer");
  ERC20Consumer = await _ERC20Consumer.deploy();

  _WorldStakingERC20 = await ethers.getContractFactory("WorldStakingERC20");
  WorldStakingERC20 = await _WorldStakingERC20.deploy();

  [owner, signer1] = await ethers.getSigners();

  await ERC20Consumer.setAdmin(signer1.address, true);
  await ERC20Consumer.setWorldAddress(WorldStakingERC20.address);

  await ERC20Consumer.mintArbitrary(owner.address, "20000000000000000");
});

var signerNonce = 1;

describe("Tests", function () {
  it("deposits and withdraws 2000 tokens from world", async function () {
    await ERC20Consumer.setApprovalForAll(WorldStakingERC20.address, true);

    await WorldStakingERC20.depositERC20(ERC20Consumer.address, owner.address, "20000000000000000");

    const withdrawRequest = {
        tokenAddress: ERC20Consumer.address,
        reciever: owner.address,
        quantity: "20000000000000000",
        nonce: 0,
        stored: true,
        signature: {
          v: 0,
          r: "0x0000000000000000000000000000000000000000000000000000000000000000",
          s: "0x0000000000000000000000000000000000000000000000000000000000000000",
        },
      }

    expect(await ERC20Consumer.balanceOf(owner.address)).to.equal(0)

    await WorldStakingERC20.withdrawERC20(withdrawRequests);

    expect(await ERC20Consumer.balanceOf(owner.address)).to.equal("20000000000000000")
  });

  /*

  it("Withdraw 10 tokens that the signer allows it to", async function () {
    const withdrawRequests = await Promise.mapSeries(ids, async (id, index) => {
      const message = ethers.utils.solidityPack(
        ["uint", "address", "uint", "address"],
        [signerNonce, ERC20Consumer.address, tokenIdToEmit, owner.address]
      );

      const messageHash = ethers.utils.keccak256(message);


      let messageHashBytes = ethers.utils.arrayify(messageHash);

      const flatSig = await signer1.signMessage(messageHashBytes);

      const splitSig = ethers.utils.splitSignature(flatSig);

      const withdrawRequest = {
        tokenAddress: ERC20Consumer.address,
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

    await WorldStakingERC20.withdrawERC20s(withdrawRequests);

    expect(await ERC20Consumer.balanceOf(owner.address)).to.equal(40)
  });
  */
});
