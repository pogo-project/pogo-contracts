// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./RewardToken.sol";

contract StakingRewards is Ownable {
    using SafeERC20 for RewardToken; // Wrappers around RewardToken operations that throw on failure
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    /* ========== STATE VARIABLES ========== */

    RewardToken public immutable rewardToken; // Token to be payed as reward
    Counters.Counter private _poolIdCounter;

    uint256 private constant STAKER_SHARE_PRECISION = 1e12; // A big number to perform mul and div operations
    
    uint256 public constant PERIOD_1 = 91.25 days;  // 3 months
    uint256 public constant PERIOD_2 = 182.5 days;  // 6 months
    uint256 public constant PERIOD_3 = 365 days;    // 12 months
    
    uint256 public constant APR_1 = 20; // 20 %
    uint256 public constant APR_2 = 25; // 25 %
    uint256 public constant APR_3 = 30; // 30 %

    // Staking pool
    struct Pool {
        uint256 poolId;
        uint256 maxPoolSupply; // Total supply available
        uint256 stakingDuration; // 3 months / 6 months / 12 months
        uint256 totalTokensStaked; // Total tokens staked
        uint256 minAPR; // 20 % / 25 % / 30 %
        uint256 minTokensAmount; // Minimum tokens required
        uint256 lastUpdatePoolSizePercent;
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
    mapping(address => bool) private stakerAddressList;

    /* ========== EVENTS ========== */

    event Deposit(address indexed user, uint256 indexed poolId, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed poolId, uint256 amount);
    event HarvestRewards(address indexed user, uint256 indexed poolId, uint256 amount);
    event PoolCreated(uint256 poolId);

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rewardToken) public {
        rewardToken = RewardToken(_rewardToken);
    }

    /* ========== VIEWS ========== */

    function earned() public view returns (uint256) {}

    /* ========== EXTERNAL FUNCTIONS ========== */

    /// @notice Create a new staking Pool
    /// @param _maxPoolSupply Total supply available.
    /// @param _stakingDuration Minimum time the user's tokens will be locked.
    /// @param _minAPR Base Annual Percentage Rate the user will received after staked his tokens.
    /// @param _minTokensAmount Minimum tokens amount to stake in the pool.
    function createPool(
        uint256 _maxPoolSupply,
        uint256 _stakingDuration,
        uint256 _minAPR,
        uint256 _minTokensAmount
    ) external onlyOwner {
        require(_stakingDuration > 0, "Pool: Staking Duration should be greater than 0");
        uint256 poolId = _poolIdCounter.current();

        address[] memory stakers;
        Pool memory pool = Pool(
            poolId, 
            _maxPoolSupply, 
            _stakingDuration, 
            0, 
            _minAPR, 
            _minTokensAmount, 
            0, 
            stakers
        );
        pools.push(pool);

        _poolIdCounter.increment();
        emit PoolCreated(poolId);
    }

    function stake() external {}
    function withdraw() external {}

    /* ========== INTERNAL FUNCTIONS ========== */

    /// @notice Add staker to the pool.
    /// @param _poolId Pool indentifier.
    /// @param _depositingStaker Staker address.
    function _addStakerToPoolIfInexistent(
        uint256 _poolId, 
        address _depositingStaker
    ) private {
        Pool storage pool = pools[_poolId];
        for (uint256 i; i < pool.stakers.length; i++) {
            address existingStaker = pool.stakers[i];
            if (existingStaker == _depositingStaker) return;
        }
        pool.stakers.push(_depositingStaker);
    }

}
