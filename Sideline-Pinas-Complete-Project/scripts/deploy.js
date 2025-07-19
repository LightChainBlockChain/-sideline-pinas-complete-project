const { ethers } = require("hardhat");

async function main() {
    console.log("🚀 Starting deployment of Sideline Pinas Token Ecosystem...\n");
    
    // Get the deployer account
    const [deployer] = await ethers.getSigners();
    console.log("💼 Deploying contracts with account:", deployer.address);
    console.log("💰 Account balance:", ethers.utils.formatEther(await deployer.getBalance()), "ETH\n");

    // Deploy VeriToken (VERI)
    console.log("📋 Deploying VeriToken (VERI)...");
    const VeriToken = await ethers.getContractFactory("VeriToken");
    const veriToken = await VeriToken.deploy();
    await veriToken.deployed();
    
    console.log("✅ VeriToken deployed to:", veriToken.address);
    console.log("🏷️  Token Symbol: VERI");
    console.log("🪙 Initial Supply: 200,000,000 VERI (founder allocation)");
    console.log("🔥 Max Supply: 5,000,000,000 VERI");
    console.log("🛡️  Min Supply: 100,000,000 VERI\n");

    // Deploy LightGovernanceToken (LIGHT)
    console.log("📋 Deploying LightGovernanceToken (LIGHT)...");
    const LightGovernanceToken = await ethers.getContractFactory("LightGovernanceToken");
    const lightToken = await LightGovernanceToken.deploy();
    await lightToken.deployed();
    
    console.log("✅ LightGovernanceToken deployed to:", lightToken.address);
    console.log("🏷️  Token Symbol: LIGHT");
    console.log("🪙 Initial Supply: 100,000,000 LIGHT");
    console.log("🗳️  Governance Features: Voting, Proposals, Delegation\n");

    // Get token statistics
    console.log("📊 Getting initial token statistics...\n");
    
    // VeriToken stats
    const veriStats = await veriToken.getTokenStatistics();
    console.log("🔸 VERI Token Statistics:");
    console.log("  - Total Supply:", ethers.utils.formatEther(veriStats[0]), "VERI");
    console.log("  - Max Supply:", ethers.utils.formatEther(veriStats[1]), "VERI");
    console.log("  - Min Supply:", ethers.utils.formatEther(veriStats[2]), "VERI");
    console.log("  - Total Burned:", ethers.utils.formatEther(veriStats[3]), "VERI");
    console.log("  - Total Minted:", ethers.utils.formatEther(veriStats[4]), "VERI");
    console.log("  - Health Score:", await veriToken.calculateHealthScore(), "/100\n");

    // LIGHT token stats
    const lightSupply = await lightToken.totalSupply();
    console.log("🔸 LIGHT Token Statistics:");
    console.log("  - Total Supply:", ethers.utils.formatEther(lightSupply), "LIGHT");
    console.log("  - Voting Delay:", await lightToken.votingDelay(), "blocks");
    console.log("  - Voting Period:", await lightToken.votingPeriod(), "blocks");
    console.log("  - Proposal Threshold:", ethers.utils.formatEther(await lightToken.proposalThreshold()), "LIGHT\n");

    // Verification costs
    console.log("🛡️  Identity Verification Costs (VERI):");
    console.log("  - Basic Identity:", ethers.utils.formatEther(await veriToken.getVerificationCost("basic_identity")), "VERI");
    console.log("  - KYC Level 1:", ethers.utils.formatEther(await veriToken.getVerificationCost("kyc_level_1")), "VERI");
    console.log("  - KYC Level 2:", ethers.utils.formatEther(await veriToken.getVerificationCost("kyc_level_2")), "VERI");
    console.log("  - KYC Level 3:", ethers.utils.formatEther(await veriToken.getVerificationCost("kyc_level_3")), "VERI");
    console.log("  - Business Verification:", ethers.utils.formatEther(await veriToken.getVerificationCost("business_verification")), "VERI");
    console.log("  - Product Authenticity:", ethers.utils.formatEther(await veriToken.getVerificationCost("product_authenticity")), "VERI");
    console.log("  - ZKP Verification:", ethers.utils.formatEther(await veriToken.getVerificationCost("zkp_verification")), "VERI\n");

    // Create contract deployment summary
    console.log("📄 DEPLOYMENT SUMMARY");
    console.log("=====================");
    console.log("Network:", network.name);
    console.log("Deployer:", deployer.address);
    console.log("Gas Price:", ethers.utils.formatUnits(await deployer.provider.getGasPrice(), "gwei"), "gwei");
    console.log("\n📋 CONTRACT ADDRESSES:");
    console.log("VeriToken (VERI):", veriToken.address);
    console.log("LightGovernanceToken (LIGHT):", lightToken.address);

    // Create MetaMask integration guide
    console.log("\n🦊 METAMASK INTEGRATION");
    console.log("========================");
    console.log("To add these tokens to MetaMask:");
    console.log("\n1. VeriToken (VERI)");
    console.log("   - Contract Address:", veriToken.address);
    console.log("   - Token Symbol: VERI");
    console.log("   - Decimals: 18");
    console.log("\n2. LightGovernanceToken (LIGHT)");
    console.log("   - Contract Address:", lightToken.address);
    console.log("   - Token Symbol: LIGHT");
    console.log("   - Decimals: 18");

    // Save deployment info to file
    const deploymentInfo = {
        network: network.name,
        deployer: deployer.address,
        deploymentDate: new Date().toISOString(),
        contracts: {
            VeriToken: {
                address: veriToken.address,
                symbol: "VERI",
                name: "VeriToken",
                decimals: 18,
                initialSupply: ethers.utils.formatEther(veriStats[4]),
                maxSupply: ethers.utils.formatEther(veriStats[1])
            },
            LightGovernanceToken: {
                address: lightToken.address,
                symbol: "LIGHT",
                name: "LightGovernanceToken",
                decimals: 18,
                totalSupply: ethers.utils.formatEther(lightSupply)
            }
        },
        verificationCosts: {
            basic_identity: ethers.utils.formatEther(await veriToken.getVerificationCost("basic_identity")),
            kyc_level_1: ethers.utils.formatEther(await veriToken.getVerificationCost("kyc_level_1")),
            kyc_level_2: ethers.utils.formatEther(await veriToken.getVerificationCost("kyc_level_2")),
            kyc_level_3: ethers.utils.formatEther(await veriToken.getVerificationCost("kyc_level_3")),
            business_verification: ethers.utils.formatEther(await veriToken.getVerificationCost("business_verification")),
            product_authenticity: ethers.utils.formatEther(await veriToken.getVerificationCost("product_authenticity")),
            zkp_verification: ethers.utils.formatEther(await veriToken.getVerificationCost("zkp_verification"))
        }
    };

    // Write deployment info to JSON file
    const fs = require('fs');
    const path = require('path');
    
    const deploymentPath = path.join(__dirname, '..', 'deployments', `deployment-${network.name}-${Date.now()}.json`);
    
    // Create deployments directory if it doesn't exist
    const deploymentsDir = path.dirname(deploymentPath);
    if (!fs.existsSync(deploymentsDir)) {
        fs.mkdirSync(deploymentsDir, { recursive: true });
    }
    
    fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));
    console.log("\n💾 Deployment info saved to:", deploymentPath);

    console.log("\n🎉 Deployment completed successfully!");
    console.log("🔗 Your tokens are now ready for MetaMask integration!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
