# 🦊 MetaMask Setup Guide for Sideline Pinas

## Quick Setup Instructions

### **Step 1: Install MetaMask**
1. Visit [metamask.io](https://metamask.io)
2. Download the browser extension
3. Create a new wallet or import existing one
4. **IMPORTANT**: Save your seed phrase safely!

### **Step 2: Add Hardhat Local Network**

#### **Automatic Setup (Recommended)**
Click this link when MetaMask is installed:
```
ethereum:add?address=0x5FbDB2315678afecb367f032d93F642f64180aa3&symbol=VERI&decimals=18&image=
```

#### **Manual Setup**
1. Open MetaMask
2. Click the network dropdown (usually shows "Ethereum Mainnet")
3. Select "Add Network" → "Add network manually"
4. Enter these details:

```
Network Name: Sideline Pinas Local
RPC URL: http://127.0.0.1:8545
Chain ID: 1337
Currency Symbol: ETH
Block Explorer URL: (leave empty)
```

5. Click "Save"

### **Step 3: Import Test Account**
For testing purposes, import this account:
```
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
Address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Balance: 10,000 ETH (for testing)
```

⚠️ **WARNING**: This is a test account. Never use this private key on mainnet!

### **Step 4: Add VERI Token**
1. In MetaMask, click "Import tokens"
2. Select "Custom token"
3. Enter:
```
Token Contract Address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Token Symbol: VERI
Decimals: 18
```
4. Click "Add Custom Token"

### **Step 5: Add LIGHT Token**
1. Click "Import tokens" again
2. Select "Custom token"
3. Enter:
```
Token Contract Address: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Token Symbol: LIGHT
Decimals: 18
```
4. Click "Add Custom Token"

## **🎯 One-Click Setup Script**

Copy and paste this into your browser console when on the Sideline Pinas website:

```javascript
// Add network and tokens automatically
async function setupSidelinePinas() {
  if (typeof window.ethereum !== 'undefined') {
    try {
      // Add network
      await window.ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [{
          chainId: '0x539', // 1337 in hex
          chainName: 'Sideline Pinas Local',
          rpcUrls: ['http://127.0.0.1:8545'],
          nativeCurrency: {
            name: 'ETH',
            symbol: 'ETH',
            decimals: 18
          }
        }]
      });
      
      // Add VERI token
      await window.ethereum.request({
        method: 'wallet_watchAsset',
        params: {
          type: 'ERC20',
          options: {
            address: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
            symbol: 'VERI',
            decimals: 18
          }
        }
      });
      
      // Add LIGHT token
      await window.ethereum.request({
        method: 'wallet_watchAsset',
        params: {
          type: 'ERC20',
          options: {
            address: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
            symbol: 'LIGHT',
            decimals: 18
          }
        }
      });
      
      alert('✅ Sideline Pinas setup complete!');
    } catch (error) {
      console.error('Setup failed:', error);
    }
  } else {
    alert('❌ MetaMask not found. Please install MetaMask first.');
  }
}

// Run setup
setupSidelinePinas();
```

## **🔧 Troubleshooting**

### **MetaMask Not Connecting**
1. Refresh the page
2. Click "Connect Wallet" again
3. Make sure you're on the correct network
4. Check if the Hardhat node is running

### **Tokens Not Appearing**
1. Make sure you're on the Sideline Pinas Local network
2. Try refreshing MetaMask
3. Manually add tokens using contract addresses
4. Check if you have any balance

### **Transaction Failing**
1. Make sure you have enough ETH for gas
2. Check if the smart contracts are deployed
3. Try increasing gas limit
4. Verify you're connected to the right network

## **📱 Mobile Setup**

### **MetaMask Mobile**
1. Download MetaMask mobile app
2. Open browser within MetaMask
3. Navigate to your Sideline Pinas website
4. Follow the same setup steps

### **WalletConnect (Alternative)**
If you prefer other wallets:
1. Use WalletConnect compatible wallets
2. Scan QR code to connect
3. Follow same token import steps

## **🛡️ Security Tips**

### **For Testing**
- Only use test accounts with test ETH
- Never send real ETH to test networks
- Keep test and real wallets separate

### **For Production**
- Use hardware wallets for large amounts
- Double-check all addresses before sending
- Start with small test transactions
- Keep your seed phrase offline and secure

## **📊 Monitoring Your Assets**

### **In MetaMask**
- View token balances in Assets tab
- Check transaction history in Activity
- Monitor network status

### **On Sideline Pinas Dashboard**
- Real-time balance updates
- Health score monitoring
- Staking rewards tracking
- Governance participation status

## **🚀 Advanced Features**

### **Custom RPC Settings**
For better performance, you might want to adjust:
- Gas price: 20 gwei (default)
- Gas limit: 21,000 (for transfers)
- Custom nonce: For stuck transactions

### **Multiple Accounts**
- Create separate accounts for different purposes
- Use different accounts for testing vs production
- Label accounts clearly

---

## **🆘 Need Help?**

If you encounter issues:
1. Check the troubleshooting section above
2. Make sure Hardhat local node is running
3. Verify all contract addresses
4. Clear browser cache and try again
5. Contact support if problems persist

**Test Account Details (For Development Only):**
- Address: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`
- Private Key: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`
- Initial Balance: 10,000 ETH

⚠️ **Never use this account on mainnet - it's publicly known!**
