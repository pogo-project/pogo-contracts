# **Staking contract :**

The staking contract allows the user to stake the platform's native tokens in different staking pools. The choice of staking pool depends on how long the user wants to lock their tokens and the annual percentage rate of tokens they will receive.
At any time after the vesting time the user can unstake and harvest his tokens.

## Formula : 

### **r(u, k, n) = Si / Ti * R**
- **r(u, k, n)** =  rewards earned by user **u** from **k** to **n** seconds.
- Si = amount staked by user u at time = i
- Ti = total staked at time = i (Assum Ti > 0)
- R = reward rate per second (total rewards / duration)

## Use case : 

Alice stakes 100 tokens for 7 889 400 seconds (3 months)

