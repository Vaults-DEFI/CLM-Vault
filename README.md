# RacineFi Vault - README

## **Description**
RacineFi is a decentralized, automated vault platform that maximizes returns for users by dynamically managing liquidity across decentralized exchanges (DEXs) and yield farms. The platform automates liquidity rebalancing, reward harvesting, and reinvestment to ensure users grow their investments with zero platform fees.

### **Key Features**
- **Automated Deposits & Withdrawals**: Users deposit assets (WRBTC, RUSDT, or RIF) and receive shares representing their vault stake. Withdrawals burn the shares and return the equivalent value of the deposited asset.
- **Dynamic Liquidity Rebalancing**: Every 6 hours, the rebalancer triggers the `moveticks` function, allowing the smart contract to automatically adjust liquidity positions for optimal returns and manage impermanent loss.
- **Automated Rewards Management**: Earned rewards are harvested and reinvested into the vault for compounding growth.

### **Ideal For**
- **Passive Investors**: No need for active management—RacineFi handles everything automatically.
- **Cost-Conscious Users**: Zero platform fees, allowing users to keep 100% of their earnings.

---

## **Testing Locally**

To test the RacineFi vault locally, follow the steps below:

### **1. Install Dependencies**
```bash
forge install
```

### **2. Build the Project**
```bash
forge build
```

### **3. Start a Local Anvil Node**
```bash
anvil --fork-url <FORK_URL>
```
- **FORK_URL**: Use any RPC URL of your preferred network from Alchemy or any other node provider.

### **4. Run Tests**
In another terminal, run the tests:
```bash
forge test --match-path test/LendingManager.t.sol --rpc-url $RPC_URL -vv
```
- **RPC_URL**: Use `http://127.0.0.1:8545`.

---

### **Useful Links**
- **Alchemy**: https://www.alchemy.com
- **Forge Documentation**: https://book.getfoundry.sh/

