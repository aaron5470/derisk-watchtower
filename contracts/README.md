# DeRisk Watchtower - Smart Contracts

This directory contains the Foundry-based smart contracts for the DeRisk Watchtower project.

## Prerequisites

### Install Foundry

Foundry is required to build, test, and deploy the smart contracts.

**On Linux/macOS:**
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

**On Windows:**
1. Install WSL (Windows Subsystem for Linux)
2. Run the Linux installation commands in WSL, OR
3. Download precompiled binaries from [Foundry Releases](https://github.com/foundry-rs/foundry/releases)

Verify installation:
```bash
forge --version
cast --version
anvil --version
```

## Project Structure

```
contracts/
├── src/                    # Smart contract source files
│   ├── interfaces/         # Contract interfaces
│   ├── mocks/             # Mock contracts for testing
│   ├── PositionVault.sol  # Main position management contract
│   ├── Protector.sol      # Protection execution contract
│   └── DemoEscrow.sol     # Demo escrow for collateral
├── test/                   # Foundry tests (.t.sol files)
├── script/                 # Deployment and seed scripts
├── lib/                    # Dependencies (managed by forge)
├── out/                    # Compiled artifacts (gitignored)
└── deployments/           # Deployment addresses and configs
```

## Setup

### 1. Install Dependencies

Install OpenZeppelin contracts and Forge Standard Library:

```bash
cd contracts
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install foundry-rs/forge-std --no-commit
```

### 2. Configure Environment

Create a `.env` file in the contracts directory:

```bash
# RPC URLs
BASE_SEPOLIA_RPC=https://sepolia.base.org
MAINNET_RPC=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY

# Private key for deployment (DO NOT commit this!)
DEPLOYER_PRIVATE_KEY=your_private_key_here

# Etherscan API key for contract verification
BASESCAN_API_KEY=your_basescan_api_key
```

**IMPORTANT:** Never commit your `.env` file. It's already in `.gitignore`.

### 3. Build Contracts

```bash
cd contracts
forge build
```

### 4. Run Tests

```bash
# Run all tests
forge test

# Run tests with verbose output
forge test -vv

# Run specific test file
forge test --match-path test/PositionVault.t.sol

# Run with gas reporting
forge test --gas-report
```

### 5. Run Local Node (Anvil)

```bash
# Start local Ethereum node
anvil
```

## Deployment

### Deploy to Local Network (Anvil)

```bash
# In one terminal, start anvil
anvil

# In another terminal, deploy
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Deploy to Base Sepolia Testnet

```bash
forge script script/Deploy.s.sol \
  --rpc-url $BASE_SEPOLIA_RPC \
  --broadcast \
  --verify
```

### Seed Demo Data

After deployment, seed the contracts with demo data:

```bash
forge script script/Seed.s.sol \
  --rpc-url $BASE_SEPOLIA_RPC \
  --broadcast
```

## Contract Architecture

### PositionVault
- Manages DeFi lending positions
- Tracks collateral, debt, and health factors
- Emits events for position state changes
- Uses OpenZeppelin's ReentrancyGuard and Pausable

### Protector
- Executes protection strategies for at-risk positions
- Adds collateral from escrow to improve health factors
- Validates health factor improvements
- Integrates with PositionVault for position updates

### DemoEscrow
- Holds collateral for protection operations
- Authorizes Protector contract to withdraw funds
- Simple implementation for testnet demonstration

## Key Features

- **Security:** ReentrancyGuard, Pausable, and Ownable patterns
- **Gas Optimized:** Efficient storage layouts and operations
- **Well Tested:** Comprehensive unit, integration, and security tests
- **Documented:** NatSpec comments for all public functions
- **Chainlink Ready:** Compatible with Chainlink price feeds and automation

## Testing Strategy

The test suite includes:
- **Unit Tests:** Individual contract function testing
- **Integration Tests:** Full workflow testing (create → protect)
- **Gas Tests:** Gas cost benchmarking
- **Security Tests:** Reentrancy, access control, edge cases
- **Fuzz Tests:** Property-based testing with random inputs

## Verification

After deployment, contracts are automatically verified on BaseScan if you provide `BASESCAN_API_KEY`.

Manual verification:
```bash
forge verify-contract \
  --chain-id 84532 \
  --compiler-version v0.8.20 \
  ADDRESS \
  src/PositionVault.sol:PositionVault \
  --etherscan-api-key $BASESCAN_API_KEY
```

## Useful Commands

```bash
# Format code
forge fmt

# Create gas snapshot
forge snapshot

# Generate documentation
forge doc

# Check contract size
forge build --sizes

# Flatten contract for verification
forge flatten src/PositionVault.sol
```

## Troubleshooting

### "forge: command not found"
- Ensure Foundry is installed and in your PATH
- Run `foundryup` to update to the latest version

### Build fails with "version mismatch"
- Check solc_version in foundry.toml matches pragma in contracts
- Run `forge clean` and rebuild

### Tests fail with "could not find artifact"
- Run `forge build` before `forge test`
- Check that imports in test files are correct

### Out of gas errors
- Increase gas limits in foundry.toml
- Check for infinite loops or heavy computations

## Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet)
- [BaseScan (Sepolia)](https://sepolia.basescan.org/)

## License

MIT
