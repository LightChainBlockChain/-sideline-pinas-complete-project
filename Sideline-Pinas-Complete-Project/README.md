# Sideline Pinas - Complete Token Ecosystem

A comprehensive blockchain ecosystem featuring two interconnected tokens: **VeriToken (VERI)** for marketplace transactions and identity verification, and **LightGovernanceToken (LIGHT)** for decentralized governance.

## 🏗️ Architecture

### VeriToken (VERI) 
- **Purpose**: Marketplace currency and identity verification
- **Features**: 
  - Deflationary tokenomics with burn mechanisms
  - Staking with APY rewards
  - Identity verification system with different KYC levels
  - Health scoring system
  - Supply controls (min/max supply limits)
- **Initial Supply**: 200M VERI (founder allocation)
- **Max Supply**: 5B VERI
- **Min Supply**: 100M VERI

### LightGovernanceToken (LIGHT)
- **Purpose**: Decentralized governance and voting
- **Features**:
  - Proposal creation and voting system
  - Governance staking with voting power multipliers
  - Delegation capabilities
  - Configurable voting parameters
  - Penalty system for early unstaking
- **Total Supply**: 100M LIGHT (fixed)

## 🚀 Quick Start

### Prerequisites
- Node.js (v14+)
- MetaMask browser extension
- Git

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd Sideline-Pinas-Complete-Project
```

2. **Install dependencies**
```bash
npm install
```

3. **Setup environment**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Compile contracts**
```bash
npx hardhat compile
```

5. **Run tests**
```bash
npx hardhat test
```

### Deployment

#### Local Development Network

1. **Start Hardhat Network** (Terminal 1)
```bash
npx hardhat node
```

2. **Deploy Contracts** (Terminal 2)
```bash
npx hardhat run scripts/deploy.js --network localhost
```

3. **Start Frontend Server** (Terminal 3)
```bash
npm start
# or
node server.js
```

4. **Access Dashboard**
Open browser to `http://localhost:3000`

#### TestNet Deployment
```bash
# Goerli Testnet
npx hardhat run scripts/deploy.js --network goerli

# Polygon Mumbai
npx hardhat run scripts/deploy.js --network mumbai
```

## 🦊 MetaMask Setup

### Add Hardhat Local Network

1. Open MetaMask
2. Networks > Add Network
3. Fill in details:
   - **Network Name**: Hardhat Local
   - **RPC URL**: `http://127.0.0.1:8545`
   - **Chain ID**: `1337`
   - **Currency Symbol**: `ETH`

### Import Test Account
Use any of the test accounts provided by Hardhat:
```
Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### Add Tokens to MetaMask

After deployment, add the token contracts:

**VeriToken (VERI)**
- Contract: `0x5FbDB2315678afecb367f032d93F642f64180aa3`
- Symbol: `VERI`
- Decimals: `18`

**LightGovernanceToken (LIGHT)**
- Contract: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`
- Symbol: `LIGHT` 
- Decimals: `18`

## 💡 Usage Guide

### VERI Token Operations

#### Staking
- **Minimum**: 1,000 VERI
- **Lock Periods**: 30 days minimum
- **APY**: 5% base rate
- **Early Withdrawal**: 5% penalty

#### Verification Costs
- Basic Identity: 100 VERI
- KYC Level 1: 500 VERI
- KYC Level 2: 1,000 VERI
- KYC Level 3: 2,000 VERI
- Business Verification: 1,500 VERI
- Product Authenticity: 300 VERI
- ZKP Verification: 200 VERI

### LIGHT Token Operations

#### Governance Staking
- **Minimum**: 30 days lock period
- **Multipliers**:
  - 30-89 days: 1x voting power
  - 90-179 days: 1.5x voting power
  - 180-364 days: 2x voting power
  - 365+ days: 3x voting power

#### Proposals
- **Minimum Tokens**: 1M LIGHT to create proposals
- **Voting Delay**: 1 day
- **Voting Period**: 7 days
- **Quorum**: 4M LIGHT (4% of supply)

## 📁 Project Structure

```
Sideline-Pinas-Complete-Project/
├── contracts/                 # Smart contracts
│   ├── VeriToken.sol         # VERI token contract
│   └── LightGovernanceToken.sol # LIGHT governance contract
├── scripts/                  # Deployment scripts
│   └── deploy.js            # Main deployment script
├── test/                    # Contract tests
│   ├── VeriToken.test.js    # VERI token tests
│   └── LightGovernanceToken.test.js # LIGHT token tests
├── frontend/                # Web interface
│   ├── index.html          # Main dashboard
│   ├── app.js             # Frontend logic
│   └── contracts/         # Contract artifacts
├── deployments/           # Deployment records
├── hardhat.config.js     # Hardhat configuration
├── package.json          # Dependencies
└── server.js            # Frontend server
```

## 🧪 Testing

Run comprehensive test suite:
```bash
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/VeriToken.test.js

# Run with gas reporting
REPORT_GAS=true npx hardhat test

# Run with coverage
npx hardhat coverage
```

## 🔐 Security Features

### VeriToken Security
- **Burn Protection**: Cannot burn below minimum supply
- **Reentrancy Guards**: Protection against reentrancy attacks
- **Pausable**: Emergency pause functionality
- **Access Control**: Owner-only functions for critical operations

### LightGovernanceToken Security
- **Proposal Validation**: Comprehensive proposal state validation
- **Vote Protection**: Cannot vote twice on same proposal
- **Time Controls**: Proper timing controls for proposals
- **Stake Protection**: Early unstaking penalties

## 🔧 Configuration

### Environment Variables
```env
# Blockchain Network Configuration
PRIVATE_KEY=your_private_key_here
INFURA_PROJECT_ID=your_infura_project_id
ETHERSCAN_API_KEY=your_etherscan_api_key

# Network URLs
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
GOERLI_RPC_URL=https://goerli.infura.io/v3/YOUR_PROJECT_ID
POLYGON_RPC_URL=https://polygon-mainnet.infura.io/v3/YOUR_PROJECT_ID

# Server Configuration
PORT=3000
NODE_ENV=development
```

### Hardhat Configuration
- **Solidity**: 0.8.19
- **Optimizer**: Enabled (200 runs)
- **Gas Reporter**: Available
- **Contract Sizer**: Enabled
- **Coverage**: Available

## 📊 Contract Sizes

| Contract | Size (KiB) | Optimization |
|----------|------------|--------------|
| VeriToken | 10.885 | ✅ Optimized |
| LightGovernanceToken | 10.313 | ✅ Optimized |

## 🚨 Important Notes

### Development Network
- Use only for development and testing
- All accounts have publicly known private keys
- **NEVER** send real funds to test accounts

### Production Deployment
- Update all private keys and API keys
- Conduct thorough security audit
- Test on testnets before mainnet
- Verify contracts on block explorers

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📞 Support

For questions and support:
- Create an issue on GitHub
- Check existing documentation
- Review test files for usage examples

---

**⚠️ Disclaimer**: This is a development project. Use at your own risk. Always conduct proper security audits before deploying to production networks.
