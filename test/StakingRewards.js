const { expect } = require("chai");
const hre = require("hardhat");
const { BigNumber } = require("ethers");

describe("POGO Contracts", function () {

  let rewardToken, stakingRewards;
  let owner, addr1, addr2, addrs;

  before(async function () {
    [owner, addr1, addr2, ...addrs] = await hre.ethers.getSigners();

    const RewardToken = await ethers.getContractFactory("RewardToken");
    rewardToken = await RewardToken.deploy("POGO", "POGO", 1_000_000);
    await rewardToken.deployed();

    const StakingRewards = await ethers.getContractFactory("StakingRewards");
    stakingRewards = await StakingRewards.deploy(rewardToken.address);
    await stakingRewards.deployed();
  });

  describe("RewardToken", function () {

  });

  describe("StakingRewards", function () {
    it("Should return the created pool", async function () {
      const poolId = 0;
      const maxPoolSupply = 42_000_000;
      const stakingDuration = 131_400; // 3 month
      const minAPR = 20; // 20 %
      const minTokensAmount = 500;

      await stakingRewards.createPool(
        maxPoolSupply, 
        stakingDuration,
        minAPR,
        minTokensAmount
      );
      const pool = await stakingRewards.pools(0);
      expect(pool.poolId).to.equal(poolId);
    });
  });

});
