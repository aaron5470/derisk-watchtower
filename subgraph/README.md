# DeRisk Watchtower Subgraph

A [Graph Protocol](https://thegraph.com/) subgraph for indexing and querying DeRisk Watchtower smart contract events on Base Sepolia testnet.

## Overview

This subgraph indexes position management, protection actions, and risk events from the DeRisk Watchtower smart contracts, providing a powerful GraphQL API for querying historical and real-time data.

### Features

- **Position Tracking**: Index all DeFi lending positions with health factor monitoring
- **Risk Event Detection**: Track health factor breaches and warning events
- **Protection Analytics**: Monitor protection actions and their effectiveness
- **User Statistics**: Aggregate per-user position and protection data
- **Time-Series Data**: Daily statistics for trend analysis
- **Token Metrics**: Track token usage across positions

## Architecture

```
┌─────────────────────────────────────────────────────┐
│           Smart Contracts (Base Sepolia)            │
│  ┌─────────────┐  ┌──────────┐  ┌──────────────┐  │
│  │ Position    │  │ Protector│  │ Demo Escrow  │  │
│  │ Vault       │  │          │  │              │  │
│  └──────┬──────┘  └─────┬────┘  └──────┬───────┘  │
└─────────┼───────────────┼───────────────┼──────────┘
          │               │               │
          │ Events        │ Events        │ Events
          │               │               │
┌─────────▼───────────────▼───────────────▼──────────┐
│              Graph Node (Indexer)                   │
│  ┌──────────────────────────────────────────────┐  │
│  │           Event Handlers (mapping.ts)        │  │
│  └──────────────────┬───────────────────────────┘  │
│                     │                               │
│  ┌──────────────────▼───────────────────────────┐  │
│  │         GraphQL Schema (schema.graphql)      │  │
│  └──────────────────┬───────────────────────────┘  │
└─────────────────────┼──────────────────────────────┘
                      │
┌─────────────────────▼──────────────────────────────┐
│               PostgreSQL Database                   │
│  - Positions  - Users  - RiskEvents                │
│  - ProtectionActions  - GlobalStats  - DailyStats  │
└─────────────────────┬──────────────────────────────┘
                      │
                      │ GraphQL API
                      │
┌─────────────────────▼──────────────────────────────┐
│             Frontend / Backend Queries              │
└─────────────────────────────────────────────────────┘
```

## Prerequisites

- Node.js >= 18.x
- npm or yarn
- Graph CLI: `npm install -g @graphprotocol/graph-cli`
- Docker & Docker Compose (for local testing)
- Deployed E1 smart contracts (see `../contracts/`)

## Quick Start

### 1. Install Dependencies

```bash
cd subgraph
npm install
```

### 2. Prepare Contract ABIs

```bash
# First, ensure contracts are built
cd ../contracts
forge build

# Then copy ABIs to subgraph
cd ../subgraph
npm run prepare-abis
```

### 3. Update Contract Addresses

After deploying E1 contracts:

```bash
# Automatically update from deployment JSON
npm run update-addresses

# Or manually edit subgraph.yaml and .env
```

### 4. Generate Code

```bash
npm run codegen
```

This generates TypeScript types from your schema and ABIs in the `generated/` directory.

### 5. Build Subgraph

```bash
npm run build
```

### 6. Deploy

**Local Testing:**

```bash
# Start local Graph node
docker-compose -f docker-compose-graph.yml up -d

# Create subgraph
npm run create-local

# Deploy to local node
npm run deploy-local
```

**The Graph Studio (Production):**

```bash
# Authenticate
graph auth --studio <DEPLOY_KEY>

# Deploy
npm run deploy
```

## Configuration

### Environment Variables

Create `.env` from `.env.example`:

```bash
cp .env.example .env
```

Required variables:

```bash
# Contract addresses (Base Sepolia)
POSITION_VAULT_ADDRESS=0x...
PROTECTOR_ADDRESS=0x...
DEMO_ESCROW_ADDRESS=0x...

# Start blocks (for optimization)
POSITION_VAULT_START_BLOCK=12345678
PROTECTOR_START_BLOCK=12345678
DEMO_ESCROW_START_BLOCK=12345678

# The Graph access token
GRAPH_ACCESS_TOKEN=your_token_here
```

## Schema Overview

### Core Entities

#### Position
Tracks individual DeFi lending positions.

```graphql
type Position @entity {
  id: ID! # positionId
  user: Bytes!
  collateralToken: Bytes!
  collateralAmount: BigInt!
  debtToken: Bytes!
  debtAmount: BigInt!
  healthFactor: BigInt! # 4 decimal precision
  createdAt: BigInt!
  isActive: Boolean!
  totalProtections: BigInt!
  # ... more fields
}
```

#### RiskEvent
Records health factor breaches and warnings.

```graphql
type RiskEvent @entity {
  id: ID!
  position: Position!
  eventType: RiskEventType! # CRITICAL, WARNING, RECOVERED
  healthFactor: BigInt!
  timestamp: BigInt!
  # ... more fields
}
```

#### ProtectionAction
Tracks executed protections.

```graphql
type ProtectionAction @entity {
  id: ID!
  position: Position!
  actionType: ProtectionActionType!
  collateralAdded: BigInt!
  healthFactorBefore: BigInt!
  healthFactorAfter: BigInt!
  # ... more fields
}
```

#### GlobalStats
Singleton entity with aggregated statistics.

```graphql
type GlobalStats @entity {
  id: ID! # Always "1"
  totalPositions: BigInt!
  activePositions: BigInt!
  criticalPositions: BigInt!
  totalProtections: BigInt!
  # ... more fields
}
```

See [schema.graphql](./schema.graphql) for complete schema.

## Example Queries

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

### Get User Details

```graphql
query GetUser($address: ID!) {
  user(id: $address) {
    totalPositions
    activePositions
    totalProtectionsReceived
    currentCriticalPositions
    positions {
      id
      healthFactor
      totalProtections
    }
  }
}
```

### Get Global Statistics

```graphql
query GetGlobalStats {
  globalStats(id: "1") {
    totalPositions
    activePositions
    criticalPositions
    totalProtections
    successfulProtections
  }
}
```

See [queries/example-queries.graphql](./queries/example-queries.graphql) for more examples.

## Local Development

### Start Local Graph Node

```bash
docker-compose -f docker-compose-graph.yml up -d
```

This starts:
- **Graph Node**: Port 8000 (GraphQL), 8020 (JSON-RPC)
- **IPFS**: Port 5001 (API)
- **PostgreSQL**: Port 5432

### Access GraphQL Playground

Open [http://localhost:8000/subgraphs/name/derisk-watchtower](http://localhost:8000/subgraphs/name/derisk-watchtower)

### View Logs

```bash
docker-compose -f docker-compose-graph.yml logs -f graph-node
```

### Stop Services

```bash
docker-compose -f docker-compose-graph.yml down
```

## Testing

### Query Testing

Use the GraphQL Playground to test queries:

```bash
# After deploying locally
open http://localhost:8000/subgraphs/name/derisk-watchtower/graphql
```

### Matchstick Unit Tests

```bash
npm run test
```

Create tests in `tests/` directory using Matchstick framework.

## Deployment Workflow

### 1. Deploy Smart Contracts

```bash
cd ../contracts
forge script script/Deploy.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast
```

### 2. Update Subgraph Configuration

```bash
cd ../subgraph
npm run update-addresses
```

This automatically:
- Updates `subgraph.yaml` with contract addresses
- Updates `.env` with addresses and start blocks

### 3. Prepare ABIs

```bash
npm run prepare-abis
```

### 4. Generate and Build

```bash
npm run codegen
npm run build
```

### 5. Deploy

**Local:**
```bash
npm run create-local
npm run deploy-local
```

**The Graph Studio:**
```bash
graph auth --studio <DEPLOY_KEY>
npm run deploy
```

## Monitoring

### Indexing Status

Check indexing status:

```bash
# Local
curl http://localhost:8030/graphql \
  -X POST \
  -d '{"query":"{ indexingStatusForCurrentVersion(subgraphName: \"derisk-watchtower\") { synced health fatalError { message } chains { latestBlock { number } chainHeadBlock { number } } } }"}'

# Hosted Service
curl https://api.thegraph.com/index-node/graphql \
  -X POST \
  -d '{"query":"{ indexingStatusForCurrentVersion(subgraphName: \"<username>/derisk-watchtower\") { synced health } }"}'
```

### GraphQL Metrics

Query metrics endpoint:

```bash
curl http://localhost:8040/metrics
```

## Troubleshooting

### Issue: "Failed to resolve import"

**Solution**: Run `npm run prepare-abis` to copy contract ABIs.

### Issue: "Contracts not deployed"

**Solution**:
1. Deploy E1 contracts first: `cd ../contracts && forge script script/Deploy.s.sol --broadcast`
2. Update addresses: `npm run update-addresses`

### Issue: "Subgraph failed with fatal error"

**Solution**: Check Graph Node logs:
```bash
docker-compose -f docker-compose-graph.yml logs graph-node
```

Common causes:
- Incorrect contract addresses in `subgraph.yaml`
- Wrong start block (set too early)
- ABI mismatch between contracts and subgraph

### Issue: "No data returned from queries"

**Solution**:
1. Check indexing status (see Monitoring section)
2. Ensure contracts have emitted events
3. Verify start block is correct
4. Check Graph Node is connected to correct RPC

## Scripts Reference

```bash
# Code generation
npm run codegen          # Generate types from schema

# Building
npm run build            # Build subgraph

# Local deployment
npm run create-local     # Create subgraph on local node
npm run remove-local     # Remove subgraph from local node
npm run deploy-local     # Deploy to local node

# Production deployment
npm run deploy           # Deploy to The Graph Studio

# Utilities
npm run update-addresses # Update contract addresses from deployment
npm run prepare-abis     # Copy ABIs from contracts

# Testing
npm run test             # Run Matchstick tests
```

## File Structure

```
subgraph/
├── schema.graphql              # GraphQL schema definitions
├── subgraph.yaml               # Subgraph manifest
├── package.json                # Dependencies and scripts
├── docker-compose-graph.yml    # Local Graph node setup
├── .env.example                # Environment template
│
├── src/
│   └── mapping.ts              # Event handler implementations
│
├── abis/                       # Contract ABIs (generated)
│   ├── PositionVault.json
│   ├── Protector.json
│   └── DemoEscrow.json
│
├── generated/                  # Generated TypeScript types (auto-created)
│
├── scripts/
│   ├── update-addresses.js     # Update configuration with deployed addresses
│   └── prepare-abis.js         # Copy ABIs from contract builds
│
├── queries/
│   └── example-queries.graphql # Example GraphQL queries
│
├── tests/                      # Unit tests (optional)
│
└── build/                      # Build output (auto-created)
```

## Health Factor Thresholds

The subgraph uses the following health factor thresholds (4 decimal precision):

- **Critical**: HF < 13000 (1.3) - Immediate risk
- **Warning**: 13000 <= HF < 15000 (1.3 - 1.5) - At risk
- **Safe**: HF >= 15000 (1.5) - Healthy

Example: `healthFactor: "15000"` = 1.5

## Performance Optimization

### Start Block Optimization

Set `startBlock` in `subgraph.yaml` to deployment block to avoid indexing unnecessary blocks:

```yaml
source:
  address: "0x..."
  abi: PositionVault
  startBlock: 12345678  # Use actual deployment block
```

### Query Pagination

Always use pagination for large result sets:

```graphql
query GetPositions($first: Int!, $skip: Int!) {
  positions(first: $first, skip: $skip) {
    # fields...
  }
}
```

### Indexed Fields

Schema uses `@derivedFrom` for efficient relationship queries:

```graphql
type Position @entity {
  riskEvents: [RiskEvent!]! @derivedFrom(field: "position")
}
```

## Resources

- [The Graph Documentation](https://thegraph.com/docs/)
- [Graph CLI Documentation](https://thegraph.com/docs/en/developer/graph-cli/)
- [AssemblyScript Documentation](https://www.assemblyscript.org/)
- [GraphQL Documentation](https://graphql.org/learn/)
- [Base Sepolia Network Info](https://docs.base.org/network-information)

## Support

For issues related to:
- **Subgraph Implementation**: Check this README and Graph docs
- **Smart Contracts**: See `../contracts/README.md`
- **The Graph Protocol**: Visit [The Graph Discord](https://thegraph.com/discord)

## License

MIT

---

**Status**: Ready for deployment pending E1 contract deployment

**Last Updated**: 2025-10-17
