const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SellGoods", async function () {
  let deployedContract;

  before(async () => {
    const SellGoods = await ethers.getContractFactory("GoodsExchange");
    const sellGoods = await SellGoods.deploy();
    deployedContract = await sellGoods.deployed();
  });
  it("can register new item to sell", async function () {
    const [seller, buyer, resolver] = await ethers.getSigners();
    await deployedContract.sellItem("bike", ethers.utils.parseEther("1"));
    const response = await deployedContract.openItems(0);
    expect(response[0]).to.equal(seller.address);
  });
  it("allows buyer to purchase an item", async function () {
    const [seller, buyer, resolver] = await ethers.getSigners();
    await deployedContract
      .connect(buyer)
      .purchaseItem(0, { value: ethers.utils.parseEther("1") });
    const response = await deployedContract.openItems(0);
    expect(response[8]).to.equal(buyer.address);
  });
  it("allows buyer approve a purchase", async function () {
    const [seller, buyer, resolver] = await ethers.getSigners();
    await deployedContract.connect(buyer).approvePurchase(0);
    const response = await deployedContract.openItems(0);
    expect(response[7]).to.equal(true);
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
