# TT Token - ERC20

TT is a custom ERC-20 token deployed using the Foundry development framework on Ethereum-compatible blockchains.

## 🚀 Project Overview

This project implements a basic ERC-20 token named **TT (Test Token)** using Solidity. It demonstrates smart contract development, testing, and deployment with Foundry.

- **Token Name:** TT  
- **Token Symbol:** TT  
- **Token Standard:** ERC-20  
- **Development Framework:** Foundry

## 🧱 Features

- ERC-20 compliance (transfer, approve, transferFrom, balanceOf, allowance)  
- Mintable total supply (optional)  
- Tested using Foundry's Forge tool

## 📁 Project Structure

```
TT-ERC20/
├── src/                # Smart contracts
│   └── TTToken.sol     # Main ERC-20 token contract
├── script/             # Deployment scripts
│   └── Deploy.s.sol    # Script to deploy contract
├── test/               # Unit tests
│   └── TTToken.t.sol   # Test cases
├── foundry.toml        # Foundry config file
```

## 🛠️ Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)  
- Git  
- Node.js (optional, for frontend or scripts)

### Installation

```bash
# Clone the repo
git clone https://github.com/sahilsan95/TT-ERC20.git
cd TT-ERC20

# Install Foundry dependencies
forge install
```

### Compilation

```bash
forge build
```

### Run Tests

```bash
forge test
```

### Deployment

```bash
forge script script/Deploy.s.sol --broadcast --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY>
```

> Replace `<YOUR_RPC_URL>` and `<YOUR_PRIVATE_KEY>` with your actual values.

## 🧪 Example Usage

```solidity
TTToken token = new TTToken();
token.transfer(0xRecipientAddress, 1000);
```

## 📜 License

This project is licensed under the MIT License.

---

Created with 💻 using [Foundry](https://github.com/foundry-rs/foundry)
