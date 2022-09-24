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
        uint256 totalTokensStaked; // Total tokens staked
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
    /// @param _lockPeriod Minimum time the user's tokens will be locked.
    /// @param _rewardTokensPerBlock Base Annual Percentage Rate the user will received after staked his tokens.
    function createPool(
        uint256 _lockPeriod,
        uint256 _rewardTokensPerBlock
    ) external onlyOwner {
        require(_lockPeriod > 0, "Pool: Lock Period should be greater than 0");
        uint256 poolId = _poolIdCounter.current();

        address[] memory stakers;
        Pool memory pool = Pool(poolId, 0, _lockPeriod, _rewardTokensPerBlock,  stakers);
        pools.push(pool);

        _poolIdCounter.increment();
        emit PoolCreated(poolId);
    }

    function addStakerToPoolIfInexistent() external {}
    function stake() external {}
    function withdraw() external {}

}
