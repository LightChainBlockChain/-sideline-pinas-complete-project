// Load contract addresses and ABIs
const CONTRACT_ADDRESSES = {
    VERI_TOKEN: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    LIGHT_TOKEN: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
    NETWORK_ID: 1337,
    RPC_URL: "http://127.0.0.1:8545"
};

document.addEventListener("DOMContentLoaded", function() {
    let ethersProvider;
    let signer;
    let veriTokenContract;
    let lightTokenContract;

    async function initiate() {
        try {
            // Check if MetaMask is installed
            if (!window.ethereum) {
                console.error("MetaMask is not installed!");
                alert("Please install MetaMask to use this application.");
                return;
            }

            // Initialize provider and signer
            ethersProvider = new ethers.providers.Web3Provider(window.ethereum);
            signer = ethersProvider.getSigner();

            // Request account access if needed
            await ethersProvider.send("eth_requestAccounts", []);

            // Check if connected to correct network
            const network = await ethersProvider.getNetwork();
            if (network.chainId !== CONTRACT_ADDRESSES.NETWORK_ID) {
                alert(`Please switch to Hardhat local network (Chain ID: ${CONTRACT_ADDRESSES.NETWORK_ID})`);
                return;
            }

            // Get user's account
            const accounts = await ethersProvider.listAccounts();
            const userAddress = accounts[0];

            document.getElementById("walletAddress").textContent = `${userAddress.slice(0, 6)}...${userAddress.slice(-4)}`;
            document.getElementById("walletAddress").classList.remove("hidden");
            document.getElementById("connectWallet").classList.add("hidden");

            // Update network status
            document.getElementById("networkStatus").innerHTML = `<span class="text-green-500">●</span> Connected`;
            document.getElementById("networkName").textContent = network.name || "Hardhat";
            document.getElementById("blockNumber").textContent = await ethersProvider.getBlockNumber();

            await connectContracts();

        } catch (error) {
            console.error(error);
            alert("Failed to connect to wallet. Please try again.");
        }
    }

    async function connectContracts() {
        try {
            // Load ABIs from JSON files
            const veriTokenABI = await fetch('./contracts/VeriToken.json').then(r => r.json()).then(data => data.abi);
            const lightTokenABI = await fetch('./contracts/LightGovernanceToken.json').then(r => r.json()).then(data => data.abi);

            // Create contract instances
            veriTokenContract = new ethers.Contract(CONTRACT_ADDRESSES.VERI_TOKEN, veriTokenABI, signer);
            lightTokenContract = new ethers.Contract(CONTRACT_ADDRESSES.LIGHT_TOKEN, lightTokenABI, signer);

            // Retrieve data from contracts
            await getVeriData(veriTokenContract);
            await getLightData(lightTokenContract);

            // Set action listeners
            setActionListeners(veriTokenContract, lightTokenContract);
            
        } catch (error) {
            console.error('Failed to connect to contracts:', error);
            alert('Failed to load smart contracts. Make sure the local blockchain is running.');
        }
    }

    function setActionListeners(veriToken, lightToken) {
        // Stake VERI Tokens
        document.getElementById("stakeBtn").onclick = async function() {
            const amount = document.getElementById("stakeAmount").value;
            const duration = document.getElementById("stakeDuration").value;

            try {
                const tx = await veriToken.stake(
                    ethers.utils.parseEther(amount),
                    duration
                );
                displayTransactionStatus();
                await tx.wait();
                hideTransactionStatus();
                alert("Stake transaction successful!");
            } catch (error) {
                console.error(error);
                alert("Failed to stake tokens.");
            }
        };

        // Burn VERI Tokens
        document.getElementById("burnBtn").onclick = async function() {
            const amount = document.getElementById("burnAmount").value;
            const reason = document.getElementById("burnReason").value;
            try {
                const tx = await veriToken.burnWithReason(
                    ethers.utils.parseEther(amount),
                    reason
                );
                displayTransactionStatus();
                await tx.wait();
                hideTransactionStatus();
                alert("Burn transaction successful!");
            } catch (error) {
                console.error(error);
                alert("Failed to burn tokens.");
            }
        };

        // Transfer VERI Tokens
        document.getElementById("transferBtn").onclick = async function() {
            const to = document.getElementById("transferTo").value;
            const amount = document.getElementById("transferAmount").value;

            try {
                const tx = await veriToken.transfer(
                    to,
                    ethers.utils.parseEther(amount)
                );
                displayTransactionStatus();
                await tx.wait();
                hideTransactionStatus();
                alert("Transfer successful!");
            } catch (error) {
                console.error(error);
                alert("Failed to transfer tokens.");
            }
        };

        // Stake for Governance
        document.getElementById("govStakeBtn").onclick = async function() {
            const amount = document.getElementById("govStakeAmount").value;
            const lockPeriod = document.getElementById("govStakeDuration").value;

            try {
                const tx = await lightToken.stakeForGovernance(
                    ethers.utils.parseEther(amount),
                    lockPeriod
                );
                displayTransactionStatus();
                await tx.wait();
                hideTransactionStatus();
                alert("Governance staking successful!");
            } catch (error) {
                console.error(error);
                alert("Failed to stake for governance.");
            }
        };

        // Transfer LIGHT Tokens
        document.getElementById("lightTransferBtn").onclick = async function() {
            const to = document.getElementById("lightTransferTo").value;
            const amount = document.getElementById("lightTransferAmount").value;

            try {
                const tx = await lightToken.transfer(
                    to,
                    ethers.utils.parseEther(amount)
                );
                displayTransactionStatus();
                await tx.wait();
                hideTransactionStatus();
                alert("Transfer successful!");
            } catch (error) {
                console.error(error);
                alert("Failed to transfer LIGHT tokens.");
            }
        };

        // Proposal submission
        document.getElementById("createProposalBtn").onclick = async function() {
            const title = document.getElementById("proposalTitle").value;
            const description = document.getElementById("proposalDescription").value;

            try {
                const tx = await lightToken.propose(title, description);
                displayTransactionStatus();
                await tx.wait();
                hideTransactionStatus();
                alert("Proposal created successfully!");
            } catch (error) {
                console.error(error);
                alert("Failed to create proposal.");
            }
        };
    }

    function displayTransactionStatus() {
        document.getElementById("transactionStatus").classList.remove("hidden");
    }

    function hideTransactionStatus() {
        document.getElementById("transactionStatus").classList.add("hidden");
    }

    async function getVeriData(contract) {
        const userAddress = await signer.getAddress();
        
        try {
            // User balance
            const balance = await contract.balanceOf(userAddress);
            document.getElementById("veriBalance").textContent = ethers.utils.formatEther(balance) + " VERI";

            // Token statistics
            const stats = await contract.getTokenStatistics();
            document.getElementById("veriSupply").textContent = ethers.utils.formatEther(stats._totalSupply) + " VERI";
            document.getElementById("veriHealth").textContent = await contract.calculateHealthScore();
        } catch (error) {
            console.error(error);
        }
    }

    async function getLightData(contract) {
        const userAddress = await signer.getAddress();
        
        try {
            // User balance
            const balance = await contract.balanceOf(userAddress);
            document.getElementById("lightBalance").textContent = ethers.utils.formatEther(balance) + " LIGHT";

            // Voting power
            const votingPower = await contract.getVotingPower(userAddress);
            document.getElementById("lightVoting").textContent = ethers.utils.formatEther(votingPower);

            // Total supply
            const totalSupply = await contract.totalSupply();
            document.getElementById("lightSupply").textContent = ethers.utils.formatEther(totalSupply) + " LIGHT";
        } catch (error) {
            console.error(error);
        }
    }

    // Tab functionality
    document.querySelectorAll('.tab-button').forEach(button => {
        button.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            
            // Remove active class from all buttons and content
            document.querySelectorAll('.tab-button').forEach(btn => {
                btn.classList.remove('text-blue-600', 'border-b-2', 'border-blue-600');
                btn.classList.add('text-gray-500');
            });
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.add('hidden');
            });
            
            // Add active class to clicked button and show content
            this.classList.remove('text-gray-500');
            this.classList.add('text-blue-600', 'border-b-2', 'border-blue-600');
            document.getElementById(`${tabName}-tab`).classList.remove('hidden');
        });
    });

    document.getElementById("connectWallet").onclick = initiate;
});

