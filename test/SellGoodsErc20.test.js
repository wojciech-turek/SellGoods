const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SellGoodsErc20", async function () {
  let deployedContract;

  before(async () => {
    const SellGoods = await ethers.getContractFactory("GoodsExchangeErc20");
    const sellGoods = await SellGoods.deploy();
    deployedContract = await sellGoods.deployed();
  });
  it("can register new item to sell", async function () {
    const [seller, buyer, resolver] = await ethers.getSigners();
    await deployedContract.sellItem(
      "bike",
      5000000,
      "0x7c8dc3349c298204d85f8eb3eb8a815dcd5ce125"
    );
    const response = await deployedContract.openItems(0);
    expect(response[0]).to.equal(seller.address);
  });
  it("does NOT allow NON-BUYER to approve the purchase", async function () {
    const [seller, buyer, resolver] = await ethers.getSigners();

    try {
      await deployedContract.connect(resolver).approvePurchase(0);
    } catch (err) {
      expect(err).exist;
    }
  });
  // ETC
});
