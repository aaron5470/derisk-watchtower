# DeRisk Watchtower Contracts - Quick Start Guide

Get up and running with the DeRisk Watchtower smart contracts in under 5 minutes!

## Prerequisites

- Git
- A terminal (bash, WSL, or Git Bash on Windows)
- Basic understanding of Ethereum/Solidity

## Step 1: Install Foundry (2 minutes)

### On Linux/macOS:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### On Windows:
Use WSL (Windows Subsystem for Linux) and run the Linux commands above, OR download precompiled binaries from [Foundry Releases](https://github.com/foundry-rs/foundry/releases).

### Verify Installation:
```bash
forge --version
# Should show: forge 0.2.0 (or similar)
```

## Step 2: Install Dependencies (1 minute)

```bash
cd contracts
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install foundry-rs/forge-std --no-commit
```

## Step 3: Build Contracts (30 seconds)

```bash
forge build
```

Expected output:
```
[⠊] Compiling...
[⠒] Compiling 10 files with 0.8.20
[⠢] Solc 0.8.20 finished in 3.45s
Compiler run successful!
```

## Step 4: Run Tests (30 seconds)

```bash
forge test
```

Expected output:
```
Running 30+ tests...

Test results: OK. 30 passed; 0 failed; finished in 1.23s
```

### Run with detailed output:
```bash
forge test -vv
```

### Run with gas reporting:
```bash
forge test --gas-report
```

## Step 5: Deploy Locally (1 minute)

### Terminal 1 - Start Local Node:
```bash
anvil
```

Leave this running. You'll see accounts with ETH balances.

### Terminal 2 - Deploy Contracts:
```bash
# Use one of the private keys from Anvil output
export DEPLOYER_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Deploy
forge script script/Deploy.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  -vvv
```

You'll see contract addresses printed:
```
PositionVault deployed at: 0x5FbDB2315678afecb367f032d93F642f64180aa3
DemoEscrow deployed at: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Protector deployed at: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
```

## Step 6: Seed Demo Data (Optional)

```bash
# Set deployed addresses
export POSITION_VAULT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
export DEMO_ESCROW_ADDRESS=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
export PROTECTOR_ADDRESS=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0

# Run seed script
forge script script/Seed.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  -vvv
```

## What's Next?

### Interact with Contracts

Use `cast` to interact with deployed contracts:

```bash
# Get position count
cast call $POSITION_VAULT_ADDRESS "positionCount()(uint256)" --rpc-url http://localhost:8545

# Get a position
cast call $POSITION_VAULT_ADDRESS "getPosition(bytes32)((bytes32,address,uint256,address,uint256,address,uint256,uint256))" 0x... --rpc-url http://localhost:8545

# Check if position needs protection
cast call $PROTECTOR_ADDRESS "checkUpkeep(bytes32)(bool)" 0x... --rpc-url http://localhost:8545
```

### Run Specific Tests

```bash
# Test a specific contract
forge test --match-path test/PositionVault.t.sol

# Test a specific function
forge test --match-test testCreatePosition -vv

# Watch tests (re-run on file changes)
forge test --watch
```

### Generate Documentation

```bash
forge doc
```

Open `docs/index.html` in your browser to view contract documentation.

### Create Gas Snapshot

```bash
forge snapshot
```

This creates `.gas-snapshot` with gas costs for all tests.

### Format Code

```bash
forge fmt
```

## Deploy to Base Sepolia Testnet

### 1. Get Base Sepolia ETH

Visit [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet) and request test ETH.

### 2. Setup Environment

Create `.env` file:
```bash
cp .env.example .env
```

Edit `.env`:
```bash
BASE_SEPOLIA_RPC=https://sepolia.base.org
DEPLOYER_PRIVATE_KEY=your_actual_private_key_here
BASESCAN_API_KEY=your_basescan_api_key_here
```

**⚠️ NEVER commit your .env file!**

### 3. Deploy

```bash
source .env

forge script script/Deploy.s.sol \
  --rpc-url $BASE_SEPOLIA_RPC \
  --broadcast \
  --verify \
  -vvv
```

### 4. Verify Contracts (if auto-verify failed)

```bash
forge verify-contract \
  --chain-id 84532 \
  --compiler-version v0.8.20 \
  <CONTRACT_ADDRESS> \
  src/PositionVault.sol:PositionVault \
  --etherscan-api-key $BASESCAN_API_KEY
```

## Troubleshooting

### Error: "forge: command not found"
- Run `foundryup` to install/update Foundry
- Restart your terminal
- Check if `~/.foundry/bin` is in your PATH

### Error: "Failed to resolve import"
- Run `forge install` commands from Step 2
- Check that `lib/` directory exists with `openzeppelin-contracts/` and `forge-std/`

### Error: "Compiler error"
- Check Solidity version in `foundry.toml` matches pragma in contracts (0.8.20)
- Run `forge clean && forge build`

### Tests failing
- Make sure you ran `forge build` first
- Check if all dependencies are installed
- Run `forge test -vvv` for detailed error messages

## Useful Commands Cheat Sheet

```bash
# Build
forge build                    # Compile contracts
forge build --sizes            # Show contract sizes
forge clean                    # Clean build artifacts

# Test
forge test                     # Run all tests
forge test -vv                 # Verbose output
forge test -vvv                # Very verbose (shows stack traces)
forge test --gas-report        # Show gas usage
forge test --match-test X      # Run tests matching pattern X
forge test --match-path Y      # Run tests in file Y
forge snapshot                 # Create gas snapshot

# Deploy & Interact
anvil                          # Start local node
forge script <script> --broadcast  # Run deployment script
cast call <addr> <sig>         # Call view function
cast send <addr> <sig>         # Send transaction
cast balance <addr>            # Get ETH balance

# Utils
forge fmt                      # Format code
forge doc                      # Generate docs
forge tree                     # Show dependency tree
forge inspect <contract> abi   # Get contract ABI
```

## Contract Addresses (After Deployment)

Keep track of your deployed contract addresses:

### Local (Anvil)
- PositionVault: `_______________`
- DemoEscrow: `_______________`
- Protector: `_______________`

### Base Sepolia
- PositionVault: `_______________`
- DemoEscrow: `_______________`
- Protector: `_______________`

## Learn More

- 📖 [Full README](./README.md) - Comprehensive documentation
- ✅ [Implementation Complete](./IMPLEMENTATION_COMPLETE.md) - What was built
- 📚 [Foundry Book](https://book.getfoundry.sh/) - Official Foundry guide
- 🔐 [OpenZeppelin Docs](https://docs.openzeppelin.com/contracts/) - Security patterns
- 🌐 [Base Docs](https://docs.base.org/) - Base network documentation

## Getting Help

1. Check the error message carefully
2. Review relevant test files for examples
3. Consult [Foundry Book](https://book.getfoundry.sh/)
4. Check [Foundry GitHub Issues](https://github.com/foundry-rs/foundry/issues)

---

**Happy Building! 🚀**
