// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title VeriToken
 * @dev VeriToken (VERI) - ERC-20 Compatible Token with Marketplace Tokenomics
 * @notice Implements burning, minting, staking, and verification mechanisms for healthy token economy
 */
contract VeriToken is ERC20, ERC20Burnable, Ownable, Pausable, ReentrancyGuard {
    
    // Token Properties
    string private constant TOKEN_NAME = "VeriToken";
    string private constant TOKEN_SYMBOL = "VERI";
    uint256 public constant MAX_SUPPLY = 5_000_000_000 * 10**18; // 5 billion max
    uint256 public constant MIN_SUPPLY = 100_000_000 * 10**18; // 100 million min
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 10**18; // 1 billion initial
    
    // Tokenomics Parameters
    struct TokenomicsConfig {
        uint256 transactionBurnRate; // 0.1% = 100 (basis points)
        uint256 verificationBurnRate; // 0.05% = 50
        uint256 stakingBurnRate; // 0.01% = 10
        uint256 validatorRewardRate; // 0.02% = 20
        uint256 loyaltyRewardRate; // 0.01% = 10
        uint256 developmentFundRate; // 0.01% = 10
        uint256 maxBurnPerBlock; // 1M tokens
        uint256 maxMintPerBlock; // 500K tokens
        uint256 burnToMintRatio; // 200 = 2.0 ratio
        uint256 stakingAPY; // 500 = 5%
        uint256 minStakingAmount; // 1000 VERI minimum
        uint256 stakingLockPeriod; // 30 days in seconds
        uint256 proposalCost; // 10,000 VERI to create proposal
        uint256 votingPower; // 100 VERI = 1 vote
    }
    
    TokenomicsConfig public tokenomics;
    
    // Statistics
    struct TokenStats {
        uint256 totalBurned;
        uint256 totalMinted;
        uint256 totalStaked;
        uint256 totalTransactions;
        uint256 totalVerifications;
        uint256 activeStakers;
        uint256 blockNumber;
    }
    
    TokenStats public stats;
    
    // Staking
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 apy;
        bool active;
    }
    
    mapping(address => Stake[]) public userStakes;
    mapping(address => uint256) public stakedBalances;
    
    // Verification costs
    mapping(string => uint256) public verificationCosts;
    
    // Events
    event TokensBurned(address indexed from, uint256 amount, string reason);
    event TokensMinted(address indexed to, uint256 amount, string reason);
    event TokensStaked(address indexed staker, uint256 amount, uint256 duration);
    event TokensUnstaked(address indexed staker, uint256 amount, uint256 rewards, uint256 penalty);
    event VerificationProcessed(address indexed verifier, address indexed subject, string credentialType, uint256 cost, uint256 reward);
    event TokenomicsUpdated(string parameter, uint256 oldValue, uint256 newValue);
    
    constructor() ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
        // Initialize tokenomics
        tokenomics = TokenomicsConfig({
            transactionBurnRate: 100, // 0.1%
            verificationBurnRate: 50, // 0.05%
            stakingBurnRate: 10, // 0.01%
            validatorRewardRate: 20, // 0.02%
            loyaltyRewardRate: 10, // 0.01%
            developmentFundRate: 10, // 0.01%
            maxBurnPerBlock: 1_000_000 * 10**18, // 1M tokens
            maxMintPerBlock: 500_000 * 10**18, // 500K tokens
            burnToMintRatio: 200, // 2.0 ratio
            stakingAPY: 500, // 5%
            minStakingAmount: 1000 * 10**18, // 1000 VERI
            stakingLockPeriod: 30 days,
            proposalCost: 10_000 * 10**18, // 10,000 VERI
            votingPower: 100 * 10**18 // 100 VERI = 1 vote
        });
        
        // Initialize verification costs
        verificationCosts["basic_identity"] = 100 * 10**18;
        verificationCosts["kyc_level_1"] = 500 * 10**18;
        verificationCosts["kyc_level_2"] = 1000 * 10**18;
        verificationCosts["kyc_level_3"] = 2000 * 10**18;
        verificationCosts["business_verification"] = 1500 * 10**18;
        verificationCosts["product_authenticity"] = 300 * 10**18;
        verificationCosts["zkp_verification"] = 200 * 10**18;
        
        // Mint initial supply to deployer (founder allocation 20%)
        uint256 founderAllocation = INITIAL_SUPPLY / 5; // 20%
        _mint(msg.sender, founderAllocation);
        stats.totalMinted = founderAllocation;
        
        emit TokensMinted(msg.sender, founderAllocation, "founder_allocation");
    }
    
    /**
     * @dev Override transfer to include burn mechanism
     */
    function transfer(address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
        return _transferWithBurn(msg.sender, to, amount);
    }
    
    /**
     * @dev Override transferFrom to include burn mechanism
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        return _transferWithBurn(from, to, amount);
    }
    
    /**
     * @dev Internal transfer with burn mechanism
     */
    function _transferWithBurn(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        uint256 burnAmount = (amount * tokenomics.transactionBurnRate) / 10000;
        uint256 transferAmount = amount - burnAmount;
        
        // Burn tokens
        if (burnAmount > 0 && totalSupply() - burnAmount >= MIN_SUPPLY) {
            _burn(from, burnAmount);
            stats.totalBurned += burnAmount;
            emit TokensBurned(from, burnAmount, "transaction_burn");
        } else {
            transferAmount = amount; // No burn if would go below min supply
        }
        
        // Transfer remaining amount
        _transfer(from, to, transferAmount);
        stats.totalTransactions++;
        
        return true;
    }
    
    /**
     * @dev Mint new tokens (controlled inflation)
     */
    function mint(address to, uint256 amount, string memory reason) external onlyOwner whenNotPaused {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds maximum supply");
        require(amount <= tokenomics.maxMintPerBlock, "Exceeds per-block mint limit");
        
        // Check burn-to-mint ratio for non-initial minting
        if (keccak256(bytes(reason)) != keccak256(bytes("initial_distribution")) && 
            keccak256(bytes(reason)) != keccak256(bytes("founder_allocation"))) {
            uint256 recentBurns = getRecentBurnAmount();
            uint256 maxMintAllowed = (recentBurns * 10000) / tokenomics.burnToMintRatio;
            require(amount <= maxMintAllowed || recentBurns == 0, "Exceeds burn-to-mint ratio");
        }
        
        _mint(to, amount);
        stats.totalMinted += amount;
        
        emit TokensMinted(to, amount, reason);
    }
    
    /**
     * @dev Burn tokens with reason tracking
     */
    function burnWithReason(uint256 amount, string memory reason) external whenNotPaused {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(totalSupply() - amount >= MIN_SUPPLY, "Cannot burn below minimum supply");
        require(amount <= tokenomics.maxBurnPerBlock, "Exceeds per-block burn limit");
        
        _burn(msg.sender, amount);
        stats.totalBurned += amount;
        
        emit TokensBurned(msg.sender, amount, reason);
    }
    
    /**
     * @dev Stake tokens for rewards
     */
    function stake(uint256 amount, uint256 duration) external nonReentrant whenNotPaused {
        require(amount >= tokenomics.minStakingAmount, "Below minimum staking amount");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(duration >= tokenomics.stakingLockPeriod, "Duration below minimum lock period");
        
        // Transfer tokens to contract
        _transfer(msg.sender, address(this), amount);
        
        // Create stake record
        Stake memory newStake = Stake({
            amount: amount,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            apy: tokenomics.stakingAPY,
            active: true
        });
        
        userStakes[msg.sender].push(newStake);
        stakedBalances[msg.sender] += amount;
        stats.totalStaked += amount;
        
        if (userStakes[msg.sender].length == 1) {
            stats.activeStakers++;
        }
        
        emit TokensStaked(msg.sender, amount, duration);
    }
    
    /**
     * @dev Unstake tokens and claim rewards
     */
    function unstake(uint256 stakeIndex) external nonReentrant whenNotPaused {
        require(stakeIndex < userStakes[msg.sender].length, "Invalid stake index");
        
        Stake storage userStake = userStakes[msg.sender][stakeIndex];
        require(userStake.active, "Stake not active");
        
        uint256 amount = userStake.amount;
        bool isLockPeriodOver = block.timestamp >= userStake.endTime;
        
        // Calculate rewards
        uint256 stakingDuration = block.timestamp > userStake.endTime ? 
            userStake.endTime - userStake.startTime : 
            block.timestamp - userStake.startTime;
        uint256 rewardAmount = calculateStakingReward(amount, stakingDuration, userStake.apy);
        
        // Calculate penalty for early unstaking
        uint256 penalty = 0;
        if (!isLockPeriodOver) {
            penalty = amount / 20; // 5% penalty
        }
        
        uint256 finalAmount = amount - penalty;
        
        // Update records
        userStake.active = false;
        stakedBalances[msg.sender] -= amount;
        stats.totalStaked -= amount;
        
        // Transfer stake back
        _transfer(address(this), msg.sender, finalAmount);
        
        // Mint rewards if any
        if (rewardAmount > 0 && totalSupply() + rewardAmount <= MAX_SUPPLY) {
            _mint(msg.sender, rewardAmount);
            stats.totalMinted += rewardAmount;
        }
        
        // Burn penalty if any
        if (penalty > 0) {
            _burn(address(this), penalty);
            stats.totalBurned += penalty;
            emit TokensBurned(address(this), penalty, "early_unstaking_penalty");
        }
        
        emit TokensUnstaked(msg.sender, finalAmount, rewardAmount, penalty);
    }
    
    /**
     * @dev Process identity verification
     */
    function processVerification(
        address verifier,
        address subject,
        string memory credentialType
    ) external onlyOwner whenNotPaused {
        uint256 cost = getVerificationCost(credentialType);
        require(balanceOf(verifier) >= cost, "Insufficient balance for verification");
        
        // Burn verification cost
        _burn(verifier, cost);
        stats.totalBurned += cost;
        
        // Mint validator reward
        uint256 reward = (cost * tokenomics.validatorRewardRate) / 10000;
        if (totalSupply() + reward <= MAX_SUPPLY) {
            _mint(verifier, reward);
            stats.totalMinted += reward;
        }
        
        stats.totalVerifications++;
        
        emit VerificationProcessed(verifier, subject, credentialType, cost, reward);
        emit TokensBurned(verifier, cost, "verification_burn");
        emit TokensMinted(verifier, reward, "validator_reward");
    }
    
    /**
     * @dev Calculate staking reward
     */
    function calculateStakingReward(uint256 amount, uint256 duration, uint256 apy) public pure returns (uint256) {
        uint256 annualReward = (amount * apy) / 10000;
        uint256 reward = (annualReward * duration) / (365 days);
        return reward;
    }
    
    /**
     * @dev Get verification cost for credential type
     */
    function getVerificationCost(string memory credentialType) public view returns (uint256) {
        uint256 cost = verificationCosts[credentialType];
        return cost > 0 ? cost : 100 * 10**18; // Default cost
    }
    
    /**
     * @dev Get user's staking information
     */
    function getUserStakes(address user) external view returns (Stake[] memory) {
        return userStakes[user];
    }
    
    /**
     * @dev Get recent burn amount (last 24 hours)
     */
    function getRecentBurnAmount() public view returns (uint256) {
        // Simplified implementation - in production, you'd track burns by block/timestamp
        return stats.totalBurned; // For now, return total burns
    }
    
    /**
     * @dev Get comprehensive token statistics
     */
    function getTokenStatistics() external view returns (
        uint256 _totalSupply,
        uint256 _maxSupply,
        uint256 _minSupply,
        uint256 _totalBurned,
        uint256 _totalMinted,
        uint256 _totalStaked,
        uint256 _totalTransactions,
        uint256 _totalVerifications,
        uint256 _activeStakers
    ) {
        return (
            totalSupply(),
            MAX_SUPPLY,
            MIN_SUPPLY,
            stats.totalBurned,
            stats.totalMinted,
            stats.totalStaked,
            stats.totalTransactions,
            stats.totalVerifications,
            stats.activeStakers
        );
    }
    
    /**
     * @dev Get voting power (balance + staked tokens)
     */
    function getVotingPower(address account) external view returns (uint256) {
        return (balanceOf(account) + stakedBalances[account]) / tokenomics.votingPower;
    }
    
    /**
     * @dev Calculate health score (0-100)
     */
    function calculateHealthScore() external view returns (uint256) {
        if (stats.totalMinted == 0) return 50; // Neutral score for new token
        
        uint256 burnToMintRatio = (stats.totalBurned * 100) / stats.totalMinted;
        uint256 stakingRatio = (stats.totalStaked * 100) / totalSupply();
        uint256 supplyRatio = (totalSupply() * 100) / MAX_SUPPLY;
        
        // Ideal ranges: 150% burn-to-mint, 30% staked, 50% of max supply
        uint256 burnScore = burnToMintRatio > 150 ? 100 : (burnToMintRatio * 100) / 150;
        uint256 stakingScore = stakingRatio > 30 ? 100 : (stakingRatio * 100) / 30;
        uint256 supplyScore = supplyRatio < 50 ? 100 : (100 - supplyRatio);
        
        return (burnScore * 40 + stakingScore * 30 + supplyScore * 30) / 100;
    }
    
    /**
     * @dev Update tokenomics parameters (owner only)
     */
    function updateTokenomics(
        string memory parameter,
        uint256 newValue
    ) external onlyOwner {
        uint256 oldValue;
        
        if (keccak256(bytes(parameter)) == keccak256(bytes("transactionBurnRate"))) {
            oldValue = tokenomics.transactionBurnRate;
            tokenomics.transactionBurnRate = newValue;
        } else if (keccak256(bytes(parameter)) == keccak256(bytes("stakingAPY"))) {
            oldValue = tokenomics.stakingAPY;
            tokenomics.stakingAPY = newValue;
        } else if (keccak256(bytes(parameter)) == keccak256(bytes("governanceThreshold"))) {
            oldValue = tokenomics.proposalCost;
            tokenomics.proposalCost = newValue;
        } else {
            revert("Invalid parameter");
        }
        
        emit TokenomicsUpdated(parameter, oldValue, newValue);
    }
    
    /**
     * @dev Update verification cost
     */
    function updateVerificationCost(string memory credentialType, uint256 newCost) external onlyOwner {
        require(newCost > 0, "Cost must be greater than zero");
        verificationCosts[credentialType] = newCost;
    }
    
    /**
     * @dev Pause contract functions (emergency only)
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause contract functions
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Process daily maintenance rewards
     */
    function processDailyRewards() external onlyOwner {
        stats.blockNumber += 1440; // Assuming 1440 blocks per day
        
        // Process staking rewards for all active stakers
        // This is a simplified version - in production, you'd implement more sophisticated logic
    }
    
    /**
     * @dev Emergency withdraw staked tokens (owner only, for emergencies)
     */
    function emergencyWithdrawStake(address user, uint256 stakeIndex) external onlyOwner {
        require(stakeIndex < userStakes[user].length, "Invalid stake index");
        
        Stake storage userStake = userStakes[user][stakeIndex];
        require(userStake.active, "Stake not active");
        
        uint256 amount = userStake.amount;
        userStake.active = false;
        stakedBalances[user] -= amount;
        stats.totalStaked -= amount;
        
        _transfer(address(this), user, amount);
    }
}
