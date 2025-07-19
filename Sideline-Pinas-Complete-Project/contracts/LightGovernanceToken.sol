// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title LightGovernanceToken
 * @dev LIGHT - Governance Token for Sideline Pinas Ecosystem
 * @notice Implements comprehensive governance features including voting, delegation, and proposals
 */
contract LightGovernanceToken is ERC20, ERC20Burnable, Ownable, Pausable, ReentrancyGuard {
    
    // Token Properties
    string private constant TOKEN_NAME = "LightGovernanceToken";
    string private constant TOKEN_SYMBOL = "LIGHT";
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10**18; // 100 million tokens
    uint256 public constant MIN_PROPOSAL_THRESHOLD = 1_000_000 * 10**18; // 1M LIGHT minimum
    
    // Governance Parameters
    struct GovernanceConfig {
        uint256 votingDelay; // 1 day in blocks
        uint256 votingPeriod; // 7 days in blocks
        uint256 proposalThreshold; // Minimum tokens to create proposal
        uint256 quorumThreshold; // Minimum participation for valid vote
        uint256 executionDelay; // Time delay before execution
        uint256 gracePeriod; // Grace period for proposal execution
    }
    
    GovernanceConfig public governance;
    
    // Proposal System
    struct Proposal {
        uint256 id;
        address proposer;
        string title;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        bool executed;
        bool cancelled;
        mapping(address => bool) hasVoted;
        mapping(address => VoteChoice) votes;
    }
    
    enum VoteChoice { Against, For, Abstain }
    enum ProposalState { Pending, Active, Cancelled, Defeated, Succeeded, Queued, Expired, Executed }
    
    // Storage
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    mapping(address => uint256) public proposalCounts; // Proposals per address
    
    // Delegation tracking
    mapping(address => address) private _delegates;
    mapping(address => uint256) private _delegatedVotes;
    
    // Staking for governance power
    struct GovernanceStake {
        uint256 amount;
        uint256 startTime;
        uint256 lockPeriod;
        uint256 multiplier; // Voting power multiplier (100 = 1x)
        bool active;
    }
    
    mapping(address => GovernanceStake[]) public governanceStakes;
    mapping(address => uint256) public totalGovernanceStaked;
    uint256 public totalStaked;
    
    // Events
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string title);
    event VoteCast(address indexed voter, uint256 indexed proposalId, VoteChoice choice, uint256 weight, string reason);
    event ProposalExecuted(uint256 indexed proposalId, bool success);
    event ProposalCancelled(uint256 indexed proposalId);
    event GovernanceStaked(address indexed user, uint256 amount, uint256 lockPeriod, uint256 multiplier);
    event GovernanceUnstaked(address indexed user, uint256 amount, uint256 penalty);
    // Events for governance staking (delegation events inherited from ERC20Votes)
    
    constructor() 
        ERC20(TOKEN_NAME, TOKEN_SYMBOL)
    {
        // Initialize governance parameters
        governance = GovernanceConfig({
            votingDelay: 1 days / 12 seconds, // ~7200 blocks (assuming 12 second blocks)
            votingPeriod: 7 days / 12 seconds, // ~50400 blocks
            proposalThreshold: MIN_PROPOSAL_THRESHOLD,
            quorumThreshold: 4_000_000 * 10**18, // 4M LIGHT (4% of supply)
            executionDelay: 2 days,
            gracePeriod: 14 days
        });
        
        // Mint total supply to deployer
        _mint(msg.sender, TOTAL_SUPPLY);
    }
    
    /**
     * @dev Create a new governance proposal
     */
    function propose(
        string memory title,
        string memory description
    ) external whenNotPaused returns (uint256) {
        require(getVotingPower(msg.sender) >= governance.proposalThreshold, "Insufficient voting power");
        require(bytes(title).length > 0 && bytes(description).length > 0, "Title and description required");
        
        uint256 proposalId = ++proposalCount;
        Proposal storage newProposal = proposals[proposalId];
        
        newProposal.id = proposalId;
        newProposal.proposer = msg.sender;
        newProposal.title = title;
        newProposal.description = description;
        newProposal.startTime = block.timestamp + (governance.votingDelay * 12); // Convert blocks to seconds
        newProposal.endTime = newProposal.startTime + (governance.votingPeriod * 12);
        
        proposalCounts[msg.sender]++;
        
        emit ProposalCreated(proposalId, msg.sender, title);
        return proposalId;
    }
    
    /**
     * @dev Cast a vote on a proposal
     */
    function castVote(
        uint256 proposalId,
        VoteChoice choice,
        string memory reason
    ) external whenNotPaused {
        require(proposalId > 0 && proposalId <= proposalCount, "Invalid proposal");
        Proposal storage proposal = proposals[proposalId];
        
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        require(!proposal.executed && !proposal.cancelled, "Proposal not active");
        
        uint256 weight = getVotingPower(msg.sender);
        require(weight > 0, "No voting power");
        
        proposal.hasVoted[msg.sender] = true;
        proposal.votes[msg.sender] = choice;
        
        if (choice == VoteChoice.For) {
            proposal.forVotes += weight;
        } else if (choice == VoteChoice.Against) {
            proposal.againstVotes += weight;
        } else {
            proposal.abstainVotes += weight;
        }
        
        emit VoteCast(msg.sender, proposalId, choice, weight, reason);
    }
    
    /**
     * @dev Execute a successful proposal
     */
    function executeProposal(uint256 proposalId) external whenNotPaused {
        require(proposalId > 0 && proposalId <= proposalCount, "Invalid proposal");
        Proposal storage proposal = proposals[proposalId];
        
        require(!proposal.executed, "Already executed");
        require(!proposal.cancelled, "Proposal cancelled");
        require(block.timestamp > proposal.endTime, "Voting still active");
        
        ProposalState state = getProposalState(proposalId);
        require(state == ProposalState.Succeeded, "Proposal not successful");
        
        proposal.executed = true;
        
        // Here you would implement actual proposal execution logic
        // For now, we just mark it as executed
        
        emit ProposalExecuted(proposalId, true);
    }
    
    /**
     * @dev Cancel a proposal (only proposer or owner)
     */
    function cancelProposal(uint256 proposalId) external {
        require(proposalId > 0 && proposalId <= proposalCount, "Invalid proposal");
        Proposal storage proposal = proposals[proposalId];
        
        require(msg.sender == proposal.proposer || msg.sender == owner(), "Not authorized");
        require(!proposal.executed, "Cannot cancel executed proposal");
        require(!proposal.cancelled, "Already cancelled");
        
        proposal.cancelled = true;
        
        emit ProposalCancelled(proposalId);
    }
    
    /**
     * @dev Stake tokens for enhanced governance power
     */
    function stakeForGovernance(uint256 amount, uint256 lockPeriod) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount must be greater than zero");
        require(lockPeriod >= 30 days, "Minimum 30 day lock period");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        // Calculate multiplier based on lock period
        uint256 multiplier = 100; // Base 1x
        if (lockPeriod >= 365 days) {
            multiplier = 300; // 3x for 1 year+
        } else if (lockPeriod >= 180 days) {
            multiplier = 200; // 2x for 6 months+
        } else if (lockPeriod >= 90 days) {
            multiplier = 150; // 1.5x for 3 months+
        }
        
        // Transfer tokens to contract
        _transfer(msg.sender, address(this), amount);
        
        // Create stake
        GovernanceStake memory newStake = GovernanceStake({
            amount: amount,
            startTime: block.timestamp,
            lockPeriod: lockPeriod,
            multiplier: multiplier,
            active: true
        });
        
        governanceStakes[msg.sender].push(newStake);
        totalGovernanceStaked[msg.sender] += amount;
        totalStaked += amount;
        
        emit GovernanceStaked(msg.sender, amount, lockPeriod, multiplier);
    }
    
    /**
     * @dev Unstake governance tokens
     */
    function unstakeFromGovernance(uint256 stakeIndex) external nonReentrant whenNotPaused {
        require(stakeIndex < governanceStakes[msg.sender].length, "Invalid stake index");
        
        GovernanceStake storage stake = governanceStakes[msg.sender][stakeIndex];
        require(stake.active, "Stake not active");
        
        uint256 amount = stake.amount;
        bool isLockExpired = block.timestamp >= stake.startTime + stake.lockPeriod;
        
        // Calculate penalty for early unstaking
        uint256 penalty = 0;
        if (!isLockExpired) {
            penalty = amount / 10; // 10% penalty for early unstaking
        }
        
        uint256 returnAmount = amount - penalty;
        
        // Update records
        stake.active = false;
        totalGovernanceStaked[msg.sender] -= amount;
        totalStaked -= amount;
        
        // Transfer tokens back
        _transfer(address(this), msg.sender, returnAmount);
        
        // Burn penalty if any
        if (penalty > 0) {
            _burn(address(this), penalty);
        }
        
        emit GovernanceUnstaked(msg.sender, returnAmount, penalty);
    }
    
    /**
     * @dev Get voting power (balance + staked with multipliers)
     */
    function getVotingPower(address account) public view returns (uint256) {
        uint256 power = balanceOf(account);
        
        // Add staked tokens with multipliers
        GovernanceStake[] storage stakes = governanceStakes[account];
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].active) {
                power += (stakes[i].amount * stakes[i].multiplier) / 100;
            }
        }
        
        return power;
    }
    
    /**
     * @dev Get proposal state
     */
    function getProposalState(uint256 proposalId) public view returns (ProposalState) {
        require(proposalId > 0 && proposalId <= proposalCount, "Invalid proposal");
        Proposal storage proposal = proposals[proposalId];
        
        if (proposal.cancelled) {
            return ProposalState.Cancelled;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.timestamp < proposal.startTime) {
            return ProposalState.Pending;
        } else if (block.timestamp <= proposal.endTime) {
            return ProposalState.Active;
        } else {
            uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
            
            if (totalVotes < governance.quorumThreshold) {
                return ProposalState.Defeated;
            } else if (proposal.forVotes > proposal.againstVotes) {
                return ProposalState.Succeeded;
            } else {
                return ProposalState.Defeated;
            }
        }
    }
    
    /**
     * @dev Get proposal details
     */
    function getProposal(uint256 proposalId) external view returns (
        address proposer,
        string memory title,
        string memory description,
        uint256 startTime,
        uint256 endTime,
        uint256 forVotes,
        uint256 againstVotes,
        uint256 abstainVotes,
        bool executed,
        bool cancelled
    ) {
        require(proposalId > 0 && proposalId <= proposalCount, "Invalid proposal");
        Proposal storage proposal = proposals[proposalId];
        
        return (
            proposal.proposer,
            proposal.title,
            proposal.description,
            proposal.startTime,
            proposal.endTime,
            proposal.forVotes,
            proposal.againstVotes,
            proposal.abstainVotes,
            proposal.executed,
            proposal.cancelled
        );
    }
    
    /**
     * @dev Get user's governance stakes
     */
    function getUserGovernanceStakes(address user) external view returns (GovernanceStake[] memory) {
        return governanceStakes[user];
    }
    
    /**
     * @dev Update governance parameters (owner only)
     */
    function updateGovernanceConfig(
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalThreshold,
        uint256 _quorumThreshold
    ) external onlyOwner {
        require(_proposalThreshold >= MIN_PROPOSAL_THRESHOLD, "Threshold too low");
        
        governance.votingDelay = _votingDelay;
        governance.votingPeriod = _votingPeriod;
        governance.proposalThreshold = _proposalThreshold;
        governance.quorumThreshold = _quorumThreshold;
    }
    
    /**
     * @dev Emergency pause (owner only)
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause (owner only)
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // Required overrides for multiple inheritance
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
    
    // Standard ERC20 functions - no need to override
    
    // Governance interface compatibility
    function votingDelay() public view returns (uint256) {
        return governance.votingDelay;
    }
    
    function votingPeriod() public view returns (uint256) {
        return governance.votingPeriod;
    }
    
    function proposalThreshold() public view returns (uint256) {
        return governance.proposalThreshold;
    }
}
