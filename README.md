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

## **Integration with Rootstock**
We have deployed our smart contracts for CLM and the vault on the Rootstock blockchain, leveraging its secure and efficient infrastructure to ensure seamless vault operations.

- **Vault Contract Address**: `0x9eC3104E33A234040C865F90860d95e9d98711b9` 
- **Strategy Contract Address**: `0x1CDd9fe9E02eb4CeE23121c32cC9303dB4D30D46` 
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

### **4. Set Up Environment Variables**

Create a `.env` file in the root directory of your project and add the following environment variables:

```env
RPC_URL=http://127.0.0.1:8545
WRBTC=0x542FDA317318eBf1d3DeAF76E0B632741a7e677d
RUSDT=0xEf213441a85DF4d7acBdAe0Cf78004E1e486BB96
POOL_RBTC_RUSDT=0xc0b92ac272d427633c36fd03dc104a2042b3a425
USER=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
USER2=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
USER3=0x90F79bf6EB2c4f870365E785982E1f101E93b906
WETH=0x82aF49447D8a07e3bd95BD0d56f35241523fBab1
USDC=0xaf88d065e77c8cC2239327C5EDb3A432268e5831
```

### **5. Run Tests**
In another terminal, run the tests:
```bash
forge test --match-path test/LendingManager.t.sol --rpc-url $RPC_URL -vv
```
- **RPC_URL**: Use `http://127.0.0.1:8545`.

---

## **Building on Rootstock**
Building on Rootstock has been smooth and straightforward, offering high security and compatibility with Ethereum tools, making it easier to deploy and manage our vault contracts. We found the infrastructure reliable, with fast transaction finality and low costs.

---

## **Team**
- **Bhumi Sadariya**: Senior Smart Contract Developer, leading the development of secure and efficient smart contracts that power the vault's core functionality.
- **Jay Sojitra**: Full Stack Developer, responsible for building and maintaining the platform’s frontend and backend services, ensuring a seamless user experience.


---

### **Useful Links**
- **Demo**:https://ethglobal.com/showcase/racinefi-h66ht
- **Alchemy**: https://www.alchemy.com
- **Forge Documentation**: https://book.getfoundry.sh/

