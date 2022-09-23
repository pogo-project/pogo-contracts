// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./RewardToken.sol";

contract Staking {
    using SafeERC20 for IERC20; // Wrappers around ERC20 operations that throw on failure

    RewardToken public rewardToken; // Token to be payed as reward

    uint256 private constant STAKER_SHARE_PRECISION = 1e12; // A big number to perform mul and div operations

    // Staking pool
    struct Pool {
        IERC20 stakeToken; // Token to be staked
        string  poolName;
        uint256 tokensStaked; // Total tokens staked
        uint256 lockPeriod; // lockPeriod
        uint256 rewardTokensPerBlock;
        address[] stakers; // Stakers in this pool
    }

    // Staking user for a pool
    struct PoolStaker {
        uint256 amount; // The tokens quantity the user has staked.
        uint256 rewards; // The reward tokens quantity the user can harvest
        uint256 lastRewardedBlock; // Last block number the user had their rewards calculated
    }

    Pool[] public pools; // Staking pools

    // Mapping poolId => staker address => PoolStaker
    mapping(uint256 => mapping(address => PoolStaker)) public poolStakers;

    // Events
    event Deposit(address indexed user, uint256 indexed poolId, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed poolId, uint256 amount);
    event HarvestRewards(address indexed user, uint256 indexed poolId, uint256 amount);
    event PoolCreated(uint256 poolId);

    function createPool() external {}
    function addStakerToPoolIfInexistent() external {}
    function stake() external {}
    function withdraw() external {}
    function earned() public view returns (uint) {}

}
