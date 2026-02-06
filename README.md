# Solidity-Projects
Solidity or Smart Contract Based Project
# EtherBay - Decentralized Marketplace 🛒

A secure, gas-optimized decentralized marketplace smart contract built on Ethereum. This dApp allows users to list items for sale, purchase goods using ETH, and withdraw earnings securely.

## 🚀 Key Features (Technical Highlights)

This project demonstrates advanced Solidity patterns suitable for production-grade environments:

* 🛡️ Pull-Payment Pattern: Implements the "Pull" over "Push" payment pattern for seller withdrawals. This prevents Denial of Service (DoS) attacks and protects the contract against Re-entrancy vulnerabilities during fund transfers.
* ⛽ Gas Optimization: Utilizes Solidity 0.8.4+ Custom Errors (error NotEnoughEther()) instead of expensive string require messages, significantly reducing gas costs for deployment and execution.
* 💰 Platform Economy: Includes a business model where the contract owner collects a Listing Fee (revenue generation) while Sellers keep 100% of the sales price.
* 🔒 Role-Based Access Control: Uses custom modifiers to restrict administrative functions (like fee updates and profit withdrawals) to the contract owner.
* 📦 State Management: Leverages Enums to manage the lifecycle of an item (Listed -> Sold) to prevent double-spending or purchasing unavailable items.

## 🛠️ Tech Stack

* Language: Solidity (v0.8.18)
* Environment: Remix IDE / Hardhat
* Network: Ethereum Testnet (Sepolia/Goerli)

## 📜 Contract Workflow

1.  Listing: A Seller calls listItem(name, price) and pays a small listingFee.
2.  Buying: A Buyer calls buyItem(id) and sends ETH covering the price.
3.  Holding: The contract holds the funds in a "Pending Withdrawal" mapping (Virtual Bank).
4.  Withdrawing: The Seller calls withdrawEarnings() to "pull" their funds to their wallet.
5.  Revenue: The Admin calls withdrawPlatformProfit() to collect accumulated listing fees.

## 💻 How to Run (Remix)

1.  Open [Remix IDE](https://remix.ethereum.org).
2.  Create a new file EtherBay.sol and paste the contract code.
3.  Compile using the Solidity Compiler tab (Ctrl+S).
4.  Navigate to the Deploy tab.
5.  Deploying:
    * Select Injected Provider (MetaMask) or Remix VM.
    * Click Deploy.
6.  Interacting:
    * List Item: Enter "Watch", Price in Wei (e.g., 5000000000000000000). Important: In the "Value" field at the top left, enter 1000000000000000 (0.001 ETH) to cover the listing fee.
    * Buy Item: Enter the Item ID. In the "Value" field, enter the exact Item Price.

## 🔍 Security Considerations

* Checks-Effects-Interactions: The withdrawEarnings function strictly follows this pattern. We update the user's balance to 0 *before* performing the external transfer call to prevent re-entrancy.
* Validation: Strict checks on msg.value ensure no under-payments for listing fees or item purchases.

