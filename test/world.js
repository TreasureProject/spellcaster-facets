const { ethers, waffle } = require("hardhat");
const { expect } = require("chai");
const Promise = require("bluebird");
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");

before(async function () {
  _NFTConsumer = await ethers.getContractFactory("NFTConsumer");
  NFTConsumer = await _NFTConsumer.deploy();

  _WorldStakingERC721 = await ethers.getContractFactory("WorldStakingERC721");
  WorldStakingERC721 = await _WorldStakingERC721.deploy();

  [owner] = await ethers.getSigners();

  await NFTConsumer.setAdmin(owner.address, true);
  await NFTConsumer.setWorldAddress(WorldStakingERC721.address);

  await NFTConsumer.mintArbitrary(owner.address, 20);
});



describe("Tests", function () {
    it("deposits and withdraws 20 tokens from world", async function(){
        await NFTConsumer.setApprovalForAll(WorldStakingERC721.address, true);
        await WorldStakingERC721.depositNFTs(NFTConsumer.address, [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]);
    });
})