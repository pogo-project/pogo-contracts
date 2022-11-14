// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./RewardToken.sol";

contract StakingRewards is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20; // Wrappers around RewardToken operations that throw on failure
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    /* ========== STATE VARIABLES ========== */

    IERC20 public immutable rewardToken; // Token to be payed as reward
    Counters.Counter private _poolIdCounter;

    uint256 private constant STAKER_SHARE_PRECISION = 1e18; // A big number to perform mul and div operations

    // Staking pool
    struct Pool {
        uint256 poolId; // Pool identifier
        uint256 maxPoolSupply; // Total supply available
        uint256 stakingDuration; // 3 months / 6 months / 12 months
        uint256 totalTokensStaked; // Total tokens amount staked
        uint256 minAPR; // 20 % / 25 % / 30 %
        uint256 currentAPR;
        uint256 rewardPerTokenStored; // Sum of (minAPR * stakingDuration * STAKER_SHARE_PRECISION / total supply)
        uint256 minTokensAmount; // Minimum tokens required
        uint256 lastUpdatedTime;
        address[] stakers; // Stakers in this pool
    }

    // Staking user for a pool
    struct PoolStaker {
        uint256 stakedTokens; // The tokens quantity the user has staked.
        uint256 rewardsPending; // The reward tokens quantity the user can harvest
        uint256 rewardPerTokenPaid;
        uint256 lastClaimedTime; // Last claim of tokens
        uint256 lastUpdatedTime;
        uint256 endDate; // Date from which the staker may claim his tokens
    }

    Pool[] public pools; // Staking pools

    mapping(uint256 => mapping(address => PoolStaker)) public poolStakers; // Staker infos from specific pool
    mapping(address => bool) public stakerAddressList; // List of all stakers

    /* ========== EVENTS ========== */

    event Stake(uint256 poolId, address indexed staker, uint256 amount);
    event Withdraw(uint256 indexed poolId, address indexed staker, uint256 amount);
    event Claimed(uint256 indexed poolId, address indexed staker, uint256 amount);
    event HarvestRewards(address indexed staker, uint256 indexed poolId, uint256 amount);
    event PoolCreated(uint256 poolId);

    /* ========== MODIFIERS ========== */

    modifier updateReward(
        uint256 _poolId,
        address _staker 
    ) {
        Pool memory pool = pools[_poolId];
        PoolStaker memory staker = poolStakers[_poolId][_staker];

        pool.lastUpdatedTime = block.timestamp;
        staker.lastUpdatedTime = block.timestamp;

        uint256 rewardPerTokenStored = rewardPerToken(_poolId, _staker);
        if(_staker != address(0)) {
            staker.rewardsPending = earned(_poolId, _staker);
            staker.rewardPerTokenPaid = rewardPerTokenStored;
        }

        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rewardToken) public {
        rewardToken = IERC20(_rewardToken);
    }

    /* ========== VIEWS ========== */

    function isStakerAddress(address check) public view returns(bool isIndeed) {
        return stakerAddressList[check];
    }

    /// @notice Calculate amount of rewards per token
    /// @param _poolId Pool indentifier.
    /// @param _staker Staker address.
    function rewardPerToken(
        uint256 _poolId,
        address _staker
    ) public view returns (uint256) {
        Pool memory pool = pools[_poolId];
        PoolStaker memory staker = poolStakers[_poolId][_staker];
        if (pool.maxPoolSupply == 0) {
            return pool.rewardPerTokenStored;
        }

        // r += R / totalSupply * (current time - last updated time)
        // Where R is reward rate per second (total rewards / duration) 
        return 
            pool.rewardPerTokenStored + 
            (pool.currentAPR * ( block.timestamp - staker.lastUpdatedTime ) * STAKER_SHARE_PRECISION) /
            pool.maxPoolSupply;
    }

    /// @notice Get earned tokens for specify pool staker
    /// @param _poolId Pool indentifier.
    /// @param _staker Staker address.
    function earned(
        uint256 _poolId,
        address _staker
    ) public view returns (uint256) {
        PoolStaker memory staker = poolStakers[_poolId][_staker];
        return 
        ((staker.stakedTokens *
            (rewardPerToken(_poolId, _staker) - staker.rewardPerTokenPaid)) / STAKER_SHARE_PRECISION) +
        staker.rewardsPending;
    }

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
        require(_stakingDuration > 0, "Staking Duration should be greater than 0.");
        uint256 poolId = _poolIdCounter.current();

        address[] memory stakers;
        // Create pool object
        Pool memory pool;
        pool.poolId = poolId;
        pool.maxPoolSupply = _maxPoolSupply;
        pool.stakingDuration = _stakingDuration;
        pool.minAPR = _minAPR;
        pool.currentAPR = _minAPR;
        pool.minTokensAmount = _minTokensAmount;
        pool.stakers = stakers;

        pools.push(pool);

        _poolIdCounter.increment();

        emit PoolCreated(poolId);
    }

    /// @notice Stake tokens in a specify pool.
    /// @param _poolId Pool indentifier.
    /// @param _amount Amount to stake.
    function stake(
        uint256 _poolId,
        uint256 _amount
    ) external nonReentrant updateReward(_poolId, msg.sender) {
        _stake(_poolId, _amount, msg.sender);
    } 

    /// @notice Unstake tokens in a specify pool.
    /// @param _poolId Pool indentifier.
    /// @param _amount Amount to stake.
    function withdraw(
        uint256 _poolId, 
        uint256 _amount
    ) external nonReentrant updateReward(_poolId, msg.sender) {
        _withdraw(_poolId, _amount, msg.sender);
    }

    function claim(
        uint256 _poolId
    ) external nonReentrant updateReward(_poolId, msg.sender) {
        _claim(_poolId, msg.sender);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    /// @notice Stake tokens in a specify pool.
    /// @param _poolId Pool indentifier.
    /// @param _amount Amount to stake.
    /// @param _staker Staker address.
    function _stake(
        uint256 _poolId,
        uint256 _amount,
        address _staker
    ) internal {
        Pool storage pool = pools[_poolId];

        require(_amount >= pool.minTokensAmount , "Insuficient stake amount.");
        require(pool.totalTokensStaked + _amount <= pool.maxPoolSupply, "Pool capacity exceeded.");
        require(_amount <= rewardToken.balanceOf(_staker), "You don't have enough tokens.");

        PoolStaker memory staker;
        if(stakerAddressList[_staker] == false) {
            staker.stakedTokens = _amount;
            staker.endDate = block.timestamp + pool.stakingDuration; // Lock tokens for a specific duration
            poolStakers[_poolId][_staker] = staker;

            pool.stakers.push(_staker); // Add staker to specific pool
            stakerAddressList[_staker] = true;
        } else {
            staker = poolStakers[_poolId][_staker]; // Get staker info
            staker.stakedTokens += _amount;// Add amount to current staked tokens
        }
        pool.totalTokensStaked += _amount; // Add amount to pool total staked tokens

        rewardToken.safeTransferFrom(_staker, address(this), _amount);

        // Update currentAPR

        emit Stake(_poolId, _staker, _amount);
    }

    /// @notice Withdraw tokens in a specify pool.
    /// @param _poolId Pool indentifier.
    /// @param _amount Amount to stake.
    /// @param _staker Staker address.
    function _withdraw(
        uint256 _poolId,
        uint256 _amount,
        address _staker
    ) internal {
        Pool storage pool = pools[_poolId];

        // Get claimable amount

        require(_amount > 0, "Nothing to withdraw");
        require(rewardToken.balanceOf(address(this)) > _amount /* + claimableAmount */, "Insuficient contract balance");
        require(stakerAddressList[_staker] == false, "You're currently not staking tokens");

        pool.totalTokensStaked -= _amount; // Remove amount to pool total staked tokens
        PoolStaker memory staker = poolStakers[_poolId][msg.sender];
        staker.stakedTokens -= _amount;

        rewardToken.safeTransfer(_staker, _amount);

        if(staker.stakedTokens == 0) {
            stakerAddressList[msg.sender] = false;
        }

        emit Withdraw(_poolId, _staker, _amount);
        /*
        if claimableAmount > 0 : emit Claimed(_poolId, _staker, _amount);
         */ 
    }

    /// @notice Claim tokens
    /// @param _poolId Pool indentifier.
    /// @param _staker Staker address.
    function _claim(
        uint256 _poolId,
        address _staker
    ) internal {
        PoolStaker memory staker = poolStakers[_poolId][_staker];
        uint256 rewardsPending = staker.rewardsPending;
        if(rewardsPending > 0 ) {
            staker.rewardsPending = 0; // reset rewards pending
            rewardToken.safeTransfer(_staker, rewardsPending);

            emit Claimed(_poolId, _staker, rewardsPending);
        }
    }
}