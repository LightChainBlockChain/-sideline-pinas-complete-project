// Contract Addresses for Sideline Pinas
// Deployed on Hardhat local network

const CONTRACT_ADDRESSES = {
  VERI_TOKEN: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
  LIGHT_TOKEN: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
  NETWORK_ID: 1337, // Hardhat local network
  RPC_URL: "http://127.0.0.1:8545"
};

// Export for use in frontend
if (typeof module !== 'undefined' && module.exports) {
  module.exports = CONTRACT_ADDRESSES;
}
