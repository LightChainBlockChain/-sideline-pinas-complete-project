// Test suite for VeriToken (VERI) tokenomics
const assert = require('assert');
const VeriToken = require('./veri-token');

// Utility function for BigInt comparisons
function assertBigIntEqual(a, b, message) {
  assert.strictEqual(a.toString(), b.toString(), message);
}

// Test cases
function runTests() {
  const token = new VeriToken();
  
  // Test initialization
  describe('Initialization', () => {
    it('should initialize with correct total supply', () => {
      const expectedSupply = BigInt(1000000000) * BigInt(10 ** 18);
      assertBigIntEqual(token.totalSupply, expectedSupply, 'Total supply mismatch');
    });

    it('should allocate 20% of total supply to founder', () => {
      const founderAddress = 'veri_founder_address';
      const expectedFounderAllocation = token.totalSupply / BigInt(5);
      assertBigIntEqual(token.balanceOf(founderAddress), expectedFounderAllocation, 'Founder allocation mismatch');
    });
  });

  // Test transfers
  describe('Transfers', () => {
    it('should transfer tokens and burn the correct amount', () => {
      const sender = 'veri_founder_address';
      const recipient = 'recipient_address';
      const amountToTransfer = BigInt(1000) * BigInt(10 ** 18);
      const senderBalanceBefore = token.balanceOf(sender);

      token.transfer(sender, recipient, amountToTransfer);

      const burnAmount = token.calculateTransactionBurn(amountToTransfer);
      const expectedSenderBalance = senderBalanceBefore - amountToTransfer;
      const expectedRecipientBalance = amountToTransfer - burnAmount;

      assertBigIntEqual(token.balanceOf(sender), expectedSenderBalance, 'Sender balance after transfer mismatch');
      assertBigIntEqual(token.balanceOf(recipient), expectedRecipientBalance, 'Recipient balance after transfer mismatch');
    });
  });

  // Test minting
  describe('Minting', () => {
    it('should mint tokens and increase total supply', () => {
      const recipient = 'mint_recipient';
      const mintAmount = BigInt(5000) * BigInt(10 ** 18);
      const totalSupplyBefore = token.totalSupply;

      token.mint(recipient, mintAmount);

      const expectedTotalSupply = totalSupplyBefore + mintAmount;

      assertBigIntEqual(token.totalSupply, expectedTotalSupply, 'Total supply after mint mismatch');
      assertBigIntEqual(token.balanceOf(recipient), mintAmount, 'Recipient balance after mint mismatch');
    });
  });

  // Test burning
  describe('Burning', () => {
    it('should burn tokens and decrease total supply', () => {
      const burnAmount = BigInt(1000) * BigInt(10 ** 18);
      const totalSupplyBefore = token.totalSupply;
      const burnedEvent = token.burn(burnAmount);

      const expectedTotalSupply = totalSupplyBefore - burnAmount;

      assertBigIntEqual(token.totalSupply, expectedTotalSupply, 'Total supply after burn mismatch');
      assert.strictEqual(burnedEvent.amount.toString(), burnAmount.toString(), 'Burn event amount mismatch');
    });
  });
}

runTests();
