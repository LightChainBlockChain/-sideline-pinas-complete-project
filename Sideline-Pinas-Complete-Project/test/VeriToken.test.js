const { expect } = require("chai");
const { ethers } = require("hardhat");

// Unit tests for VeriToken

/* Test Features:
 *  - Minting
 *  - Burning
 *  - Staking
 *  - Verification
 */
describe("VeriToken", function () {
    let VeriToken, veriToken, owner, addr1, addr2;

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        VeriToken = await ethers.getContractFactory("VeriToken");
        [owner, addr1, addr2, _] = await ethers.getSigners();

        // Deploy a new VeriToken contract for each test
        veriToken = await VeriToken.deploy();
        await veriToken.deployed();
    });

    it("Should mint the initial supply to the founder", async function () {
        const founderBalance = await veriToken.balanceOf(owner.address);
        const stats = await veriToken.stats();
        expect(stats.totalMinted).to.equal(founderBalance);
    });

    it("Should allow burning of tokens", async function () {
        await veriToken.connect(owner).burnWithReason(ethers.utils.parseEther("50"), "test_burn");
        const stats = await veriToken.stats();
        expect(stats.totalBurned).to.equal(ethers.utils.parseEther("50"));
    });

    it("Should allow staking of tokens", async function () {
        const stakeAmount = ethers.utils.parseEther("1000");
        await veriToken.connect(owner).stake(stakeAmount, 60 * 60 * 24 * 30);

        const balances = await veriToken.stakedBalances(owner.address);
        expect(balances).to.equal(stakeAmount);
    });

    it("Should perform identity verification", async function () {
        // First transfer some tokens to addr1 so they can pay for verification
        await veriToken.transfer(addr1.address, ethers.utils.parseEther("1000"));
        
        const balanceBefore = await veriToken.balanceOf(addr1.address);

        await veriToken.processVerification(addr1.address, addr2.address, "basic_identity");
        const balanceAfter = await veriToken.balanceOf(addr1.address);

        expect(balanceAfter.lt(balanceBefore)).to.be.true;
    });
});

