# Quickstart Guide: DeRisk Watchtower

**Feature**: DeRisk Watchtower
**Target**: Developers setting up the project for the first time
**Time to Complete**: 15-30 minutes

## Prerequisites

Before starting, ensure you have the following installed:

- **Node.js** 18+ and npm
- **Go** 1.21+
- **Foundry** (forge, anvil, cast)
- **Docker** and Docker Compose
- **Git**
- **MetaMask** or compatible Web3 wallet
- **Code Editor** (VS Code recommended)

### Quick Install Commands

```bash
# Node.js (via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18

# Go
# Visit: https://go.dev/dl/

# Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Docker
# Visit: https://docs.docker.com/get-docker/

# Verify installations
node --version    # Should be v18.x or higher
npm --version
go version        # Should be go1.21.x or higher
forge --version   # Should show foundry version
docker --version
docker-compose --version
```

---

## Project Structure Overview

```
derisk-watchtower/
├── contracts/          # Solidity smart contracts (Foundry project)
│   ├── src/
│   ├── test/
│   ├── script/
│   └── foundry.toml
├── subgraph/           # The Graph subgraph
│   ├── schema.graphql
│   ├── subgraph.yaml
│   └── src/mapping.ts
├── api/                # Go backend API
│   ├── cmd/api/main.go
│   ├── internal/
│   └── go.mod
├── web/                # Next.js frontend
│   ├── app/
│   ├── components/
│   ├── lib/
│   └── package.json
├── configs/            # Configuration files
│   ├── prometheus/
│   └── grafana/
├── scripts/            # Deployment and utility scripts
├── docs/               # Documentation
├── docker-compose.yml  # Docker services (Prometheus, Grafana)
├── .env.example        # Environment variable template
└── README.md
```

---

## Step 1: Clone and Setup Repository

```bash
# Clone the repository
git clone <repository-url>
cd derisk-watchtower

# Create environment file from template
cp .env.example .env

# Edit .env with your values
nano .env  # or use your preferred editor
```

### Environment Variables (`.env`)

```bash
# Network Configuration
NETWORK=base-sepolia
CHAIN_ID=84532
RPC_URL=https://sepolia.base.org
# Alternative RPC providers:
# RPC_URL=https://base-sepolia.g.alchemy.com/v2/YOUR_API_KEY
# RPC_URL=https://base-sepolia.infura.io/v3/YOUR_PROJECT_ID

# Contract Deployment
DEPLOYER_PRIVATE_KEY=0xyour_private_key_here_DO_NOT_COMMIT
# Get test ETH from: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet

# The Graph
SUBGRAPH_ENDPOINT=https://api.studio.thegraph.com/query/<your-subgraph>/derisk-watchtower/v1.0.0

# Chainlink Automation
CHAINLINK_UPKEEP_ID=your_upkeep_id_here
LINK_TOKEN_ADDRESS=0xE4aB69C077896252FAFBD49EFD26B5D171A32410  # Base Sepolia LINK

# Backend API
API_PORT=8080
CACHE_TTL_SECONDS=30

# AI Service (Optional)
OPENAI_API_KEY=your_openai_api_key_here
# Or use Anthropic:
# ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Observability
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_WS_URL=ws://localhost:8080/ws/risk-stream
NEXT_PUBLIC_SUBGRAPH_URL=https://api.studio.thegraph.com/query/<your-subgraph>/derisk-watchtower/v1.0.0
```

**Security Note**: Never commit `.env` file with real private keys. Use test accounts only.

---

## Step 2: Smart Contract Setup & Deployment

### Install Dependencies

```bash
cd contracts
forge install
```

### Compile Contracts

```bash
forge build
```

Expected output:
```
[⠊] Compiling...
[⠒] Compiling 15 files with 0.8.24
[⠢] Solc 0.8.24 finished in 2.34s
Compiler run successful!
```

### Run Tests

```bash
forge test
```

Expected output:
```
Running 12 tests for test/PositionVault.t.sol:PositionVaultTest
[PASS] testAddCollateral() (gas: 45123)
[PASS] testRepayDebt() (gas: 42567)
[PASS] testProtection() (gas: 67890)
...
Test result: ok. 12 passed; 0 failed; finished in 1.23s
```

### Deploy to Base Sepolia

**Prerequisites**:
- Private key in `.env` has test ETH (get from faucet)
- RPC URL is configured

```bash
# Deploy contracts
forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --broadcast --verify

# Save deployed addresses
# The script will output contract addresses - copy them to your .env
```

**Example output**:
```
== Logs ==
Deploying PositionVault...
PositionVault deployed at: 0x1234567890abcdef1234567890abcdef12345678

Deploying Protector...
Protector deployed at: 0xabcdef1234567890abcdef1234567890abcdef12

Deploying Mock Tokens...
MockUSDC deployed at: 0x234567890abcdef1234567890abcdef123456789
MockWETH deployed at: 0x34567890abcdef1234567890abcdef1234567890
```

**Add to `.env`**:
```bash
# Deployed Contracts (Base Sepolia)
POSITION_VAULT_ADDRESS=0x1234567890abcdef1234567890abcdef12345678
PROTECTOR_ADDRESS=0xabcdef1234567890abcdef1234567890abcdef12
MOCK_USDC_ADDRESS=0x234567890abcdef1234567890abcdef123456789
MOCK_WETH_ADDRESS=0x34567890abcdef1234567890abcdef1234567890
```

### Verify Contracts on BaseScan

```bash
forge verify-contract \
  --chain base-sepolia \
  --compiler-version v0.8.24 \
  $POSITION_VAULT_ADDRESS \
  src/PositionVault.sol:PositionVault
```

**View on BaseScan**: `https://sepolia.basescan.org/address/<contract-address>`

---

## Step 3: Subgraph Setup & Deployment

### Install Graph CLI

```bash
npm install -g @graphprotocol/graph-cli
```

### Initialize Subgraph Project

```bash
cd ../subgraph

# Initialize (if not already done)
graph init --studio derisk-watchtower
```

### Configure Subgraph

Edit `subgraph.yaml`:

```yaml
specVersion: 0.0.5
schema:
  file: ./schema.graphql
dataSources:
  - kind: ethereum
    name: PositionVault
    network: base-sepolia
    source:
      address: "0x1234567890abcdef1234567890abcdef12345678"  # YOUR_POSITION_VAULT_ADDRESS
      abi: PositionVault
      startBlock: 10000000  # Block number where contract was deployed
    mapping:
      kind: ethereum/events
      apiVersion: 0.0.7
      language: wasm/assemblyscript
      entities:
        - Position
        - RiskEvent
        - ProtectionAction
      abis:
        - name: PositionVault
          file: ./abis/PositionVault.json
      eventHandlers:
        - event: PositionCreated(indexed uint256,indexed address,uint256,uint256)
          handler: handlePositionCreated
        - event: PositionUpdated(indexed uint256,uint256,uint256,uint256)
          handler: handlePositionUpdated
        - event: RiskThresholdBreached(indexed uint256,uint256,uint256)
          handler: handleRiskThresholdBreached
        - event: ProtectionExecuted(indexed uint256,uint8,uint256,uint256,int256,int256,indexed address)
          handler: handleProtectionExecuted
      file: ./src/mapping.ts
```

### Deploy Subgraph

```bash
# Authenticate with The Graph Studio
graph auth --studio <YOUR_DEPLOY_KEY>

# Build subgraph
graph codegen && graph build

# Deploy to hosted service
graph deploy --studio derisk-watchtower
```

**Subgraph URL** (after deployment):
```
https://api.studio.thegraph.com/query/<your-workspace>/derisk-watchtower/v1.0.0
```

**Test subgraph query**:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query": "{ positions(first: 5) { id owner healthFactor } }"}' \
  https://api.studio.thegraph.com/query/<your-workspace>/derisk-watchtower/v1.0.0
```

---

## Step 4: Backend API Setup

### Install Dependencies

```bash
cd ../api
go mod download
```

### Build and Run

```bash
# Build
go build -o bin/api cmd/api/main.go

# Run
./bin/api
```

**Or run directly**:
```bash
go run cmd/api/main.go
```

Expected output:
```
2025/10/13 12:00:00 Starting DeRisk Watchtower API...
2025/10/13 12:00:00 Connecting to RPC: https://sepolia.base.org
2025/10/13 12:00:00 Connecting to subgraph: https://api.studio.thegraph.com/...
2025/10/13 12:00:00 Server listening on :8080
2025/10/13 12:00:00 Health check: http://localhost:8080/health
2025/10/13 12:00:00 Metrics: http://localhost:8080/metrics
2025/10/13 12:00:00 WebSocket: ws://localhost:8080/ws/risk-stream
```

### Test API Endpoints

```bash
# Health check
curl http://localhost:8080/health

# Metrics
curl http://localhost:8080/metrics

# Get positions (replace with your address)
curl "http://localhost:8080/api/positions?owner=0x742d35Cc6634C0532925a3b844Bc454e4438f44e"

# Get Health Factor
curl http://localhost:8080/api/hf/0x742d35Cc6634C0532925a3b844Bc454e4438f44e
```

---

## Step 5: Frontend Setup

### Install Dependencies

```bash
cd ../web
npm install
```

### Configure Environment

Create `web/.env.local`:

```bash
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_WS_URL=ws://localhost:8080/ws/risk-stream
NEXT_PUBLIC_SUBGRAPH_URL=https://api.studio.thegraph.com/query/<your-workspace>/derisk-watchtower/v1.0.0
NEXT_PUBLIC_CHAIN_ID=84532
NEXT_PUBLIC_POSITION_VAULT_ADDRESS=0x1234567890abcdef1234567890abcdef12345678
NEXT_PUBLIC_PROTECTOR_ADDRESS=0xabcdef1234567890abcdef1234567890abcdef12
```

### Run Development Server

```bash
npm run dev
```

Expected output:
```
   ▲ Next.js 14.0.0
   - Local:        http://localhost:3000
   - Network:      http://192.168.1.100:3000

 ✓ Ready in 2.3s
```

### Open in Browser

Navigate to: `http://localhost:3000`

**Expected UI**:
- Connect Wallet button
- Empty state message (if no positions)
- Position cards (if wallet has positions)
- Risk timeline
- Protect button

---

## Step 6: Chainlink Automation Setup

### Register Upkeep

1. Visit: https://automation.chain.link/base-sepolia
2. Click "Register New Upkeep"
3. Choose "Custom logic" trigger
4. Enter your Protector contract address
5. Fund with LINK tokens (5 LINK recommended for testing)
6. Save the Upkeep ID to `.env`

**Get LINK tokens**:
- Faucet: https://faucets.chain.link/base-sepolia

**Manual Override** (if Automation is delayed):
```bash
curl -X POST http://localhost:8080/api/protection/trigger \
  -H "Content-Type: application/json" \
  -d '{
    "positionId": "0x742d35Cc...-1",
    "actionType": "MANUAL_PROTECT",
    "amount": "1000000000000000000"
  }'
```

---

## Step 7: Observability Stack

### Start Prometheus + Grafana

```bash
cd ..
docker-compose up -d prometheus grafana
```

Expected output:
```
Creating network "derisk-watchtower_default" ...
Creating derisk-watchtower_prometheus_1 ... done
Creating derisk-watchtower_grafana_1    ... done
```

### Access Dashboards

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001
  - Default credentials: admin / admin (change on first login)

### Import Grafana Dashboard

1. Open Grafana: http://localhost:3001
2. Login (admin/admin)
3. Go to Dashboards → Import
4. Upload `configs/grafana/watchtower-dashboard.json`
5. Select Prometheus datasource
6. Click "Import"

**View Metrics**:
- Protection triggers count
- API request latency
- WebSocket connections
- Positions monitored

---

## Step 8: Create a Test Position

### Using Frontend

1. Connect MetaMask to Base Sepolia
2. Get test ETH from faucet
3. Navigate to "Create Position"
4. Deposit collateral (Mock USDC)
5. Borrow debt (Mock WETH)
6. Confirm transaction
7. View position on dashboard

### Using Foundry Script

```bash
cd contracts
forge script script/CreateTestPosition.s.sol:CreateTestPositionScript \
  --rpc-url $RPC_URL \
  --broadcast
```

---

## Step 9: Trigger a Risk Alert (Demo Mode)

### Option 1: Simulate Price Drop

```bash
# Update mock oracle price (reduce collateral value)
cast send $MOCK_ORACLE_ADDRESS \
  "setPrice(uint256)" \
  920000000000000000 \
  --rpc-url $RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY
```

Expected:
- HF drops below threshold
- Risk alert appears in UI
- WebSocket notification sent
- Chainlink Automation triggers protection (or manual override)

### Option 2: Use Replay Mode

```bash
# Set environment variable for offline demo
export REPLAY_MODE=true

# Restart backend
cd api
go run cmd/api/main.go
```

**Frontend shows**:
- "Demo Mode" badge
- Pre-recorded events from `fixtures/demo-session-1.json`
- Simulated WebSocket notifications

---

## Step 10: Run Complete End-to-End Test

### Automated Test Script

```bash
# Run E2E test suite
cd ..
./scripts/e2e-test.sh
```

**Test steps**:
1. ✓ Health check API
2. ✓ Create test position
3. ✓ Query position via subgraph
4. ✓ Simulate price drop
5. ✓ Verify risk alert
6. ✓ Trigger protection
7. ✓ Verify HF improvement
8. ✓ Check Prometheus metrics

---

## Quick Commands Reference

```bash
# Smart Contracts
cd contracts
forge build                    # Compile
forge test                     # Run tests
forge script script/Deploy.s.sol --broadcast --rpc-url $RPC_URL  # Deploy

# Subgraph
cd subgraph
graph codegen && graph build  # Build
graph deploy --studio derisk-watchtower  # Deploy

# Backend API
cd api
go run cmd/api/main.go        # Run
go test ./...                 # Test

# Frontend
cd web
npm run dev                   # Development server
npm run build                 # Production build
npm run lint                  # Lint code

# Observability
docker-compose up -d          # Start Prometheus + Grafana
docker-compose down           # Stop services
docker-compose logs -f        # View logs

# One-Command Startup (All services)
./scripts/start-all.sh
```

---

## Troubleshooting

### Issue: RPC Connection Fails

**Error**: `Failed to connect to RPC`

**Solution**:
- Check RPC URL in `.env` is correct
- Try alternative RPC provider (Alchemy, Infura)
- Verify network (Base Sepolia, Chain ID 84532)

### Issue: Subgraph Not Syncing

**Error**: `Subgraph sync lag > 60s`

**Solution**:
- Check subgraph deployment status in The Graph Studio
- Verify contract address and start block in `subgraph.yaml`
- Redeploy subgraph with correct configuration

### Issue: Insufficient Gas

**Error**: `Transaction failed: out of gas`

**Solution**:
- Get more test ETH from faucet: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet
- Increase gas limit in transaction
- Check wallet balance

### Issue: WebSocket Disconnects

**Error**: `WebSocket connection closed`

**Solution**:
- Enable auto-reconnect in client (see `useWebSocket` hook)
- Check firewall/proxy settings
- Verify backend is running on correct port

### Issue: Grafana Dashboard Empty

**Error**: `No data in Grafana`

**Solution**:
- Verify Prometheus is scraping `/metrics` endpoint
- Check `prometheus.yml` configuration
- Ensure backend API is running and generating metrics
- Wait 15-30 seconds for first scrape

---

## Next Steps

✅ **You've completed the quickstart!**

**Now you can**:
1. Review the [Implementation Plan](plan.md) for detailed architecture
2. Read the [Data Model](data-model.md) for entity definitions
3. Explore [API Contracts](contracts/) for API specifications
4. Start implementing user stories from [Specification](spec.md)

**Daily Workflow**:
1. Update `CHANGELOG.md` with progress
2. Log AI assistance in `AI_USAGE.md`
3. Commit frequently (min 3x/day)
4. Test locally before pushing
5. Update `docs/PROOF.md` with milestones

**Before Demo**:
- [ ] Record demo video (2-4 minutes)
- [ ] Deploy frontend to Vercel
- [ ] Document all contract addresses in README
- [ ] Export Grafana dashboard JSON
- [ ] Submit via Hacker Dashboard

---

## Support & Resources

- **Base Sepolia Faucet**: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet
- **Base Sepolia Explorer**: https://sepolia.basescan.org
- **Chainlink Faucet**: https://faucets.chain.link/base-sepolia
- **The Graph Studio**: https://thegraph.com/studio
- **Foundry Documentation**: https://book.getfoundry.sh
- **Next.js Documentation**: https://nextjs.org/docs
- **wagmi Documentation**: https://wagmi.sh

**Need Help?**
- Check `docs/` directory for detailed guides
- Review Constitution for compliance requirements
- Open an issue in the repository
