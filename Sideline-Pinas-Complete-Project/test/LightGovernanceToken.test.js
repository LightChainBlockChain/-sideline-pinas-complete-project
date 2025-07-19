const { expect } = require("chai");
const { ethers } = require("hardhat");

// Unit tests for LightGovernanceToken

/* Test Features:
 *  - Governance proposals
 *  - Voting
 *  - Delegation
 *  - Governance staking
 */
describe("LightGovernanceToken", function () {
    let LightToken, lightToken, owner, addr1, addr2;

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        LightToken = await ethers.getContractFactory("LightGovernanceToken");
        [owner, addr1, addr2, _] = await ethers.getSigners();

        // Deploy a new LightGovernanceToken contract for each test
        lightToken = await LightToken.deploy();
        await lightToken.deployed();

        // Transfer some tokens to addr1 for testing
        await lightToken.transfer(addr1.address, ethers.utils.parseEther("10000000"));
    });

    it("Should mint the total supply to the deployer", async function () {
        const totalSupply = await lightToken.totalSupply();
        const deployerBalance = await lightToken.balanceOf(owner.address);
        const addr1Balance = await lightToken.balanceOf(addr1.address);
        
        expect(totalSupply).to.equal(ethers.utils.parseEther("100000000")); // 100M LIGHT
        expect(deployerBalance.add(addr1Balance)).to.equal(totalSupply);
    });

    it("Should allow creating governance proposals", async function () {
        const proposalTitle = "Test Proposal";
        const proposalDescription = "This is a test proposal";
        
        await lightToken.connect(addr1).propose(proposalTitle, proposalDescription);
        
        const proposalCount = await lightToken.proposalCount();
        expect(proposalCount).to.equal(1);
        
        const proposal = await lightToken.getProposal(1);
        expect(proposal.proposer).to.equal(addr1.address);
        expect(proposal.title).to.equal(proposalTitle);
        expect(proposal.description).to.equal(proposalDescription);
    });

    it("Should allow governance staking for enhanced voting power", async function () {
        const stakeAmount = ethers.utils.parseEther("1000");
        const lockPeriod = 90 * 24 * 60 * 60; // 90 days
        
        await lightToken.connect(addr1).stakeForGovernance(stakeAmount, lockPeriod);
        
        const totalStaked = await lightToken.totalGovernanceStaked(addr1.address);
        expect(totalStaked).to.equal(stakeAmount);
        
        // Check voting power includes multiplier
        const votingPower = await lightToken.getVotingPower(addr1.address);
        const actualBalance = await lightToken.balanceOf(addr1.address);
        const stakingPower = stakeAmount.mul(150).div(100);
        const expectedPower = actualBalance.add(stakingPower);
        expect(votingPower).to.equal(expectedPower);
    });

    it("Should allow voting on proposals", async function () {
        // Create a proposal
        await lightToken.connect(addr1).propose("Test Vote", "Vote test");
        
        // Fast forward time to voting period
        await network.provider.send("evm_increaseTime", [24 * 60 * 60]); // 1 day
        await network.provider.send("evm_mine");
        
        // Vote on the proposal
        await lightToken.connect(addr1).castVote(1, 1, "Voting for this proposal"); // VoteChoice.For = 1
        
        const proposal = await lightToken.getProposal(1);
        expect(proposal.forVotes).to.be.gt(0);
    });

    it("Should enforce minimum voting power for proposals", async function () {
        // addr2 has no tokens, should not be able to propose
        await expect(
            lightToken.connect(addr2).propose("Failed Proposal", "Should fail")
        ).to.be.revertedWith("Insufficient voting power");
    });

    it("Should allow proposal cancellation", async function () {
        await lightToken.connect(addr1).propose("Cancel Test", "Will be cancelled");
        
        await lightToken.connect(addr1).cancelProposal(1);
        
        const proposal = await lightToken.getProposal(1);
        expect(proposal.cancelled).to.be.true;
    });
});
