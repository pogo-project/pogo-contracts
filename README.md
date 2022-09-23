# **Staking contract :**

The staking contract allows the user to stake the platform's native tokens in different staking pools. The choice of staking pool depends on how long the user wants to lock their tokens and the annual percentage rate of tokens they will receive.
At any time after the vesting time the user can unstake and harvest his tokens.

## Use case : 

### State initiale : 
- Staker A stake **100 tokens**.
- Staker B stake **100 tokens**.

The total staked tokens in the pool is **200 tokens**.

### 1 day after :
- Staker A unstake **100 tokens**.
- Staker A harvest **RewardsMintedPerSeconds * (StarkerAStakedTokens / TotalStakedTokens) * 1 day * 3600 seconds**.
- Staker A harvest **R * (100 / 200) * 24 * 3600**.

### 1 day more after :
- Staker B unstake **$100**.

Rewards on day 1

- Staker B harvest **RewardsMintedPerSeconds * (StarkerBStakedTokens / TotalStakedTokens) * 1 day * 3600 seconds**. 
- Staker B harvest **R * (100 / 200) * 24 * 3600**. 

Rewards on day 2

- Staker B harvest **RewardsMintedPerSeconds * (StarkerBStakedTokens / TotalStakedTokens) * 1 day * 3600 seconds**.
- Staker B harvest **R * (100 / 100) * 24 * 3600**. 

Rewards total 
- Staker B harvest **(R * (100 / 200) * 24 * 3600) + (R * (100 / 100) * 24 * 3600)**.



