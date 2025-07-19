# 🧪 Sideline Pinas Testing Checklist

## **🎯 Pre-Testing Setup**

### **Prerequisites**
- [ ] Hardhat local node is running (`npx hardhat node`)
- [ ] MetaMask extension installed
- [ ] Test account imported with 10,000 ETH
- [ ] Connected to Sideline Pinas Local network (Chain ID: 1337)
- [ ] VERI and LIGHT tokens added to MetaMask

### **Test Account Details**
```
Address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
Starting Balance: 10,000 ETH + 200M VERI + 100M LIGHT
```

---

## **🌐 Website Functionality Tests**

### **1. Basic Website Loading**
- [ ] Website loads without errors
- [ ] All images and styles load correctly
- [ ] Navigation works properly
- [ ] Responsive design on mobile/tablet
- [ ] No console errors in browser dev tools

### **2. MetaMask Connection**
- [ ] "Connect Wallet" button appears
- [ ] Clicking connects to MetaMask
- [ ] Wallet address displays correctly
- [ ] Connection status shows "Connected"
- [ ] Network detection works correctly

---

## **📊 Dashboard Display Tests**

### **3. Token Balance Display**
- [ ] VERI balance shows correctly (~200,000,000)
- [ ] LIGHT balance shows correctly (~100,000,000)
- [ ] Balances update in real-time
- [ ] Health score displays (should be 30/100 initially)
- [ ] Total supply information accurate

### **4. Network Status**
- [ ] Network name shows "Hardhat Local" or similar
- [ ] Block number displays and updates
- [ ] Connection indicator shows green/connected
- [ ] Gas price information accurate

---

## **💰 VERI Token Tests**

### **5. VERI Token Staking**
- [ ] Staking form accepts valid amounts
- [ ] Duration dropdown works (30/90/180/365 days)
- [ ] Stake button triggers MetaMask transaction
- [ ] Transaction completes successfully
- [ ] Staked amount reflects in balance
- [ ] Staking rewards calculation correct

**Test Scenario:**
```
1. Enter amount: 1000 VERI
2. Select duration: 90 days (1.5x APY)
3. Click "Stake Tokens"
4. Confirm in MetaMask
5. Verify staking successful
```

### **6. VERI Token Burning**
- [ ] Burn amount input accepts numbers
- [ ] Burn reason field accepts text
- [ ] Burn button triggers transaction
- [ ] Tokens actually burned from total supply
- [ ] Health score improves after burning
- [ ] Transaction receipt shows burn event

**Test Scenario:**
```
1. Enter amount: 100 VERI
2. Reason: "Testing burn functionality"
3. Click "Burn Tokens"
4. Confirm transaction
5. Check total supply decreased
```

### **7. VERI Token Transfer**
- [ ] Recipient address field validates format
- [ ] Transfer amount input works
- [ ] Transfer button triggers MetaMask
- [ ] Transaction completes successfully
- [ ] Balances update correctly
- [ ] Transaction appears in history

**Test Scenario:**
```
From: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
To: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
Amount: 500 VERI
```

---

## **🗳️ LIGHT Token Tests**

### **8. Governance Staking**
- [ ] LIGHT governance staking form works
- [ ] Duration options affect voting power multiplier
- [ ] Staking transaction successful
- [ ] Voting power calculation correct
- [ ] Staked LIGHT locks properly

**Test Scenario:**
```
1. Amount: 10,000 LIGHT
2. Duration: 180 days (2x voting power)
3. Expected voting power: 20,000
4. Verify lock period set correctly
```

### **9. LIGHT Token Transfer**
- [ ] LIGHT transfer form functional
- [ ] Address validation works
- [ ] Amount validation proper
- [ ] Transaction successful
- [ ] Balance updates correctly

**Test Scenario:**
```
Transfer: 1,000 LIGHT to second test account
Verify: Balance reduces by 1,000 LIGHT + gas
```

---

## **🏛️ Governance System Tests**

### **10. Proposal Creation**
- [ ] Proposal title field works
- [ ] Description textarea functional
- [ ] "Create Proposal" button active
- [ ] Transaction triggers correctly
- [ ] Proposal appears in active list
- [ ] Proposal threshold respected (1M LIGHT)

**Test Scenario:**
```
Title: "Test Proposal for Platform Improvement"
Description: "This is a test proposal to verify governance functionality"
Expected: Should require 1,000,000 LIGHT to create
```

### **11. Voting System**
- [ ] Proposals display correctly
- [ ] Vote buttons functional (For/Against)
- [ ] Voting power considered correctly
- [ ] Vote delegation works
- [ ] Voting period respected
- [ ] Results calculated properly

---

## **🔧 Technical Tests**

### **12. Transaction Handling**
- [ ] Transaction status shows "Processing"
- [ ] Success/failure notifications work
- [ ] Gas estimation accurate
- [ ] Transaction receipts complete
- [ ] Error handling works properly
- [ ] Retry mechanism functional

### **13. Error Scenarios**
- [ ] Insufficient balance handled gracefully
- [ ] Invalid addresses rejected
- [ ] Network disconnection managed
- [ ] MetaMask rejection handled
- [ ] Contract interaction errors caught
- [ ] User-friendly error messages

### **14. Edge Cases**
- [ ] Zero amount transactions blocked
- [ ] Maximum amount limits respected
- [ ] Decimal precision handled correctly
- [ ] Overflow/underflow protection
- [ ] Reentrancy protection working

---

## **📱 Mobile/Responsive Tests**

### **15. Mobile Compatibility**
- [ ] Website renders properly on mobile
- [ ] Touch interactions work
- [ ] MetaMask mobile app integration
- [ ] Forms usable on small screens
- [ ] Navigation accessible
- [ ] No horizontal scrolling issues

---

## **🔒 Security Tests**

### **16. Smart Contract Security**
- [ ] Only authorized addresses can mint
- [ ] Burning actually reduces supply
- [ ] Transfer restrictions work
- [ ] Staking locks tokens properly
- [ ] Governance controls functional
- [ ] Emergency pause mechanisms

### **17. Frontend Security**
- [ ] XSS protection active
- [ ] Input sanitization working
- [ ] HTTPS connections only
- [ ] No sensitive data in console
- [ ] Contract addresses verified
- [ ] API endpoints secured

---

## **⚡ Performance Tests**

### **18. Load Performance**
- [ ] Website loads under 3 seconds
- [ ] Token balance queries fast
- [ ] Transaction processing reasonable
- [ ] No memory leaks detected
- [ ] Smooth user interactions
- [ ] Efficient contract calls

---

## **🚀 End-to-End Scenarios**

### **19. Complete User Journey**
```
Scenario: New User Complete Flow
1. [ ] Install MetaMask
2. [ ] Add Sideline Pinas network
3. [ ] Import test account
4. [ ] Add VERI and LIGHT tokens
5. [ ] Connect wallet to website
6. [ ] View initial balances
7. [ ] Stake 1000 VERI for 90 days
8. [ ] Transfer 500 LIGHT to another account
9. [ ] Create a governance proposal
10. [ ] Vote on the proposal
11. [ ] Burn 100 VERI tokens
12. [ ] Check updated balances and health score
```

### **20. Multi-User Scenario**
```
Scenario: Multiple Users Interacting
1. [ ] User A stakes VERI tokens
2. [ ] User B creates governance proposal
3. [ ] User A votes on proposal
4. [ ] User B transfers LIGHT to User A
5. [ ] Both users' balances update correctly
6. [ ] Voting results accurate
7. [ ] All transactions recorded properly
```

---

## **✅ Testing Checklist Summary**

**Before Going Live:**
- [ ] All basic functionality tests pass
- [ ] No critical security vulnerabilities
- [ ] Mobile compatibility confirmed
- [ ] Performance meets standards
- [ ] Error handling robust
- [ ] Documentation complete
- [ ] User guides available
- [ ] Support channels ready

**Post-Launch Monitoring:**
- [ ] Monitor transaction success rates
- [ ] Track user adoption metrics
- [ ] Watch for security incidents
- [ ] Collect user feedback
- [ ] Monitor contract health
- [ ] Track token economics metrics

---

## **🐛 Bug Reporting Template**

```
Bug Title: [Brief description]

Steps to Reproduce:
1. 
2. 
3. 

Expected Behavior:
[What should happen]

Actual Behavior:
[What actually happened]

Environment:
- Browser: 
- MetaMask Version: 
- Network: 
- Account Address: 
- Transaction Hash (if applicable): 

Additional Notes:
[Screenshots, error messages, etc.]
```

---

**Remember:** This is a test environment. Never use real funds or production private keys during testing!

## **📞 Support Information**
- GitHub Repository: `https://github.com/LightChainBlockChain/-sideline-pinas-complete-project`
- Test Network: Hardhat Local (Chain ID: 1337)
- Contract Verification: Check deployment logs for addresses
