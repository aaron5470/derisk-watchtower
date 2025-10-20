# DeRisk Watchtower Subgraph - Quick Start Guide

Get the subgraph running in under 10 minutes!

## Prerequisites Checklist

- [ ] Node.js 18+ installed (`node --version`)
- [ ] Docker & Docker Compose installed (`docker --version`)
- [ ] E1 smart contracts deployed to Base Sepolia
- [ ] Have contract addresses from deployment

## Step 1: Install Dependencies (2 minutes)

```bash
cd subgraph
npm install

# Install Graph CLI globally
npm install -g @graphprotocol/graph-cli
```

Verify installation:
```bash
graph --version
# Should show: @graphprotocol/graph-cli/0.56.0 (or similar)
```

## Step 2: Configure Contract Addresses (2 minutes)

### Option A: Automatic (Recommended)

If you have the Foundry deployment JSON:

```bash
npm run update-addresses
```

This automatically updates `subgraph.yaml` and `.env` with deployed addresses.

### Option B: Manual

1. Copy environment template:
```bash
cp .env.example .env
```

2. Edit `.env` with your deployed addresses:
```bash
POSITION_VAULT_ADDRESS=0xYourPositionVaultAddress
PROTECTOR_ADDRESS=0xYourProtectorAddress
DEMO_ESCROW_ADDRESS=0xYourDemoEscrowAddress

POSITION_VAULT_START_BLOCK=12345678
PROTECTOR_START_BLOCK=12345678
DEMO_ESCROW_START_BLOCK=12345678
```

3. Manually edit `subgraph.yaml` and replace placeholder addresses with your deployed addresses.

## Step 3: Prepare Contract ABIs (1 minute)

```bash
# Make sure contracts are built first
cd ../contracts
forge build

# Return to subgraph directory
cd ../subgraph

# Copy ABIs
npm run prepare-abis
```

Expected output:
```
✅ Copied ABI for PositionVault
✅ Copied ABI for Protector
✅ Copied ABI for DemoEscrow
```

## Step 4: Generate Code (1 minute)

```bash
npm run codegen
```

This generates TypeScript types in `generated/` directory.

Expected output:
```
  Skip migration: Bump mapping apiVersion from 0.0.1 to 0.0.2
  Skip migration: Bump mapping apiVersion from 0.0.2 to 0.0.3
  ...
✔ Generate types for data source templates
✔ Load GraphQL schema from schema.graphql
✔ Generate types for templates
✔ Load ABI from abis/PositionVault.json
  ...
✔ Generate types for data source: PositionVault
✔ Generate types for data source: Protector
✔ Generate types for data source: DemoEscrow

Types generated successfully
```

## Step 5: Build Subgraph (1 minute)

```bash
npm run build
```

Expected output:
```
  Compile data source: PositionVault => build/PositionVault/PositionVault.wasm
  Compile data source: Protector => build/Protector/Protector.wasm
  Compile data source: DemoEscrow => build/DemoEscrow/DemoEscrow.wasm
✔ Compile subgraph
✔ Write compiled subgraph to build/

Build completed: build/subgraph.yaml
```

## Step 6: Deploy Subgraph

### Option A: Local Testing (Recommended for Development)

#### 6.1. Start Local Graph Node

In a **separate terminal**:

```bash
cd subgraph
docker-compose -f docker-compose-graph.yml up
```

Wait for services to start (takes 1-2 minutes). You'll see:
```
graph-node_1  | Apr 17 00:00:00.000 INFO Starting JSON-RPC admin server at: http://0.0.0.0:8020
graph-node_1  | Apr 17 00:00:00.000 INFO Starting GraphQL HTTP server at: http://0.0.0.0:8000
```

#### 6.2. Create and Deploy Subgraph

In your **original terminal**:

```bash
# Create subgraph (only needed once)
npm run create-local

# Deploy subgraph
npm run deploy-local
```

Expected output:
```
✔ Upload subgraph to IPFS

Build completed: QmHashOfYourSubgraph

Deployed to http://localhost:8000/subgraphs/name/derisk-watchtower/graphql

Subgraph endpoints:
Queries (HTTP):     http://localhost:8000/subgraphs/name/derisk-watchtower
```

### Option B: The Graph Studio (Production)

1. **Create Subgraph on The Graph Studio**
   - Visit [https://thegraph.com/studio/](https://thegraph.com/studio/)
   - Click "Create a Subgraph"
   - Name it "derisk-watchtower"
   - Select "Base Sepolia" network

2. **Get Your Deploy Key**
   - Copy the deploy key from the Studio dashboard

3. **Authenticate**
   ```bash
   graph auth --studio <YOUR_DEPLOY_KEY>
   ```

4. **Deploy**
   ```bash
   npm run deploy
   ```

## Step 7: Query Your Subgraph (1 minute)

### Local Playground

Open [http://localhost:8000/subgraphs/name/derisk-watchtower/graphql](http://localhost:8000/subgraphs/name/derisk-watchtower/graphql)

### Test Query

Try this query in the GraphQL Playground:

```graphql
query GetGlobalStats {
  globalStats(id: "1") {
    totalPositions
    activePositions
    criticalPositions
    warningPositions
    safePositions
    totalProtections
  }
}
```

### Get All Positions

```graphql
query GetPositions {
  positions(first: 10, orderBy: createdAt, orderDirection: desc) {
    id
    user
    collateralAmount
    debtAmount
    healthFactor
    createdAt
  }
}
```

### Get Critical Positions

```graphql
query GetCriticalPositions {
  positions(
    where: { healthFactor_lt: "13000", isActive: true }
    orderBy: healthFactor
    orderDirection: asc
  ) {
    id
    user
    healthFactor
    collateralAmount
    debtAmount
  }
}
```

## Step 8: Verify Indexing (1 minute)

Check if your subgraph is syncing:

```bash
curl http://localhost:8030/graphql \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ indexingStatusForCurrentVersion(subgraphName: \"derisk-watchtower\") { synced health chains { latestBlock { number } chainHeadBlock { number } } } }"}'
```

Healthy response:
```json
{
  "data": {
    "indexingStatusForCurrentVersion": {
      "synced": true,
      "health": "healthy",
      "chains": [...]
    }
  }
}
```

## What's Next?

### Explore Example Queries

Check out [queries/example-queries.graphql](./queries/example-queries.graphql) for more query examples:
- User position tracking
- Risk event monitoring
- Protection analytics
- Daily statistics

### Create Some Test Data

Run the seed script to create demo positions:

```bash
cd ../contracts
forge script script/Seed.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast
```

Then query them in the subgraph!

### Monitor Subgraph

View logs:
```bash
docker-compose -f docker-compose-graph.yml logs -f graph-node
```

### Integrate with Frontend

Use the GraphQL endpoint in your app:
```javascript
const SUBGRAPH_URL = 'http://localhost:8000/subgraphs/name/derisk-watchtower';

const query = `
  query GetPositions {
    positions(first: 10) {
      id
      healthFactor
    }
  }
`;

const response = await fetch(SUBGRAPH_URL, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ query })
});

const data = await response.json();
```

## Common Commands

```bash
# Development
npm run codegen          # Regenerate types after schema changes
npm run build            # Rebuild subgraph
npm run deploy-local     # Redeploy to local node

# Local Graph Node
docker-compose -f docker-compose-graph.yml up    # Start services
docker-compose -f docker-compose-graph.yml down  # Stop services
docker-compose -f docker-compose-graph.yml logs  # View logs

# Production
npm run deploy           # Deploy to The Graph Studio

# Utilities
npm run update-addresses # Update contract addresses
npm run prepare-abis     # Copy ABIs from contracts
```

## Troubleshooting

### Error: "Failed to fetch ABIs"

**Solution**: Build contracts first
```bash
cd ../contracts && forge build && cd ../subgraph && npm run prepare-abis
```

### Error: "Cannot connect to Graph Node"

**Solution**: Ensure Docker services are running
```bash
docker-compose -f docker-compose-graph.yml up
```

### Error: "No data in queries"

**Possible causes**:
1. **Contracts not deployed**: Deploy E1 contracts first
2. **Wrong addresses**: Check `subgraph.yaml` has correct addresses
3. **No events emitted**: Create test positions using Seed script
4. **Still indexing**: Check indexing status (see Step 8)

### Error: "Subgraph failed with fatal error"

**Solution**: Check Graph Node logs
```bash
docker-compose -f docker-compose-graph.yml logs graph-node | grep ERROR
```

Common issues:
- Incorrect ABI
- Wrong start block (set too early)
- Invalid contract address

## Complete Workflow Example

```bash
# 1. Install
cd subgraph
npm install
npm install -g @graphprotocol/graph-cli

# 2. Configure (assuming contracts deployed)
npm run prepare-abis
npm run update-addresses

# 3. Build
npm run codegen
npm run build

# 4. Deploy locally
docker-compose -f docker-compose-graph.yml up -d
npm run create-local
npm run deploy-local

# 5. Test
open http://localhost:8000/subgraphs/name/derisk-watchtower/graphql

# 6. Create test data
cd ../contracts
forge script script/Seed.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast

# 7. Query test data
# Use GraphQL Playground to query positions
```

## Resources

- [Full README](./README.md) - Comprehensive documentation
- [Example Queries](./queries/example-queries.graphql) - Query examples
- [The Graph Docs](https://thegraph.com/docs/) - Official documentation
- [Contract Docs](../contracts/README.md) - Smart contract setup

## Support

- **Subgraph Issues**: Check [README.md](./README.md) troubleshooting section
- **Contract Issues**: See [../contracts/README.md](../contracts/README.md)
- **The Graph Help**: Visit [The Graph Discord](https://thegraph.com/discord)

---

**Ready?** Start with Step 1 and you'll have a working subgraph in 10 minutes!

**Status**: All code complete, ready for deployment pending E1 contracts
