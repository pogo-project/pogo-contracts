const { expect } = require("chai");
const hre = require("hardhat");
const { BigNumber } = require("ethers");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("POGO Contracts", function () {

  const STAKER_SHARE_PRECISION = 1e18;
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
    it("Should transfer X tokens.", async function () {
      const amountOfTokens = 1000;

      await rewardToken.transfer(addr1.address, amountOfTokens);

      const balance = await rewardToken.balanceOf(addr1.address);
      expect(balance).to.equal(amountOfTokens);
    });
  });

  describe("StakingRewards", function () {
    it("Should return the created pool.", async function () {
      const poolId = 0;
      const maxPoolSupply = 42_000_000;
      const stakingDuration = 7_889_400; // 3 month
      const minAPR = 20; // 20 %
      const minTokensAmount = 100;

      await stakingRewards.createPool(
        maxPoolSupply, 
        stakingDuration,
        minAPR,
        minTokensAmount
      );

      const pool = await stakingRewards.pools(0);
      console.log(pool)
      expect(pool.poolId).to.equal(poolId);
    });

    /*it("Should stake tokens for the first time.", async function () {
      // const THREE_MONTHS_IN_SECS = 7_889_400;
      // const unlockTime = (await time.latest()) + THREE_MONTHS_IN_SECS;
      const poolId = 0;
      const amount = 100;

      await rewardToken
        .connect(addr1)
        .approve(stakingRewards.address, amount);

      await stakingRewards
        .connect(addr1)
        .stake(
          poolId,
          amount
        );

      const pool = await stakingRewards.pools(0);
      expect(pool.totalTokensStaked).to.equal(100);
      // expect(pool.stakers(0)).to.equal(addr1.address);

      const isStaker = await stakingRewards.stakerAddressList(addr1.address);
      expect(isStaker).to.equal(true);
      
      const staker = await stakingRewards.poolStakers(poolId, addr1.address);
      expect(staker.stakedTokens).to.equal(BigNumber.from(100));
    });

    it("Should stake tokens for the second time.", async function () {
      const poolId = 0;
      const amount = 100;

      await rewardToken
        .connect(addr1)
        .approve(stakingRewards.address, amount);

      await stakingRewards
        .connect(addr1)
        .stake(
          poolId,
          amount
        );

      const pool = await stakingRewards.pools(0);
      expect(pool.totalTokensStaked).to.equal(200);
      // expect(pool.stakers[0]).to.equal(addr1.address);

      const isStaker = await stakingRewards.stakerAddressList(addr1.address);
      expect(isStaker).to.equal(true);
      
      const staker = await stakingRewards.poolStakers(poolId, addr1.address);
      expect(staker.stakedTokens).to.equal(BigNumber.from(200));
    });*/
    
  });

});
