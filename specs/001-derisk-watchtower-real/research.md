# Research & Technology Decisions: DeRisk Watchtower

**Feature**: DeRisk Watchtower
**Date**: 2025-10-13
**Status**: Complete

## Executive Summary

This document captures all technology decisions, best practices research, and architectural patterns for implementing the DeRisk Watchtower system on Base Sepolia for ETHOnline 2025.

## Technology Stack Decisions

### 1. Blockchain Network: Base Sepolia

**Decision**: Deploy exclusively on Base Sepolia testnet

**Rationale**:
- **Well-documented ecosystem**: Comprehensive documentation for developers
- **Explorer support**: BaseScan provides reliable block exploration for debugging and verification
- **Faucet availability**: Easy access to test ETH and LINK tokens
- **Active community**: Strong support ecosystem for troubleshooting
- **L2 benefits**: Lower gas costs and faster transaction times compared to Ethereum mainnet
- **Chainlink integration**: Native support for Chainlink services (Automation, Price Feeds)

**Alternatives Considered**:
- Ethereum Sepolia: Rejected due to higher gas costs and slower block times
- Optimism Sepolia: Rejected due to less mature tooling and documentation
- Arbitrum Sepolia: Rejected for consistency with sponsor ecosystem

**Implementation Notes**:
- Chain ID: 84532
- RPC endpoints: Multiple providers (Alchemy, Infura, public RPCs) for redundancy
- Faucets: Base Sepolia faucet, Chainlink faucet for LINK tokens

---

### 2. Smart Contract Framework: Foundry

**Decision**: Use Foundry (forge, anvil, cast) for all smart contract development

**Rationale**:
- **Performance**: Rust-based toolchain significantly faster than Hardhat
- **Testing**: Built-in fuzzing and advanced testing capabilities
- **Deployment scripts**: Solidity-based scripts for type-safe deployments
- **Gas optimization**: Detailed gas reports and optimization tools
- **Developer experience**: Fast compilation, hot reload, and better error messages

**Alternatives Considered**:
- Hardhat: Rejected due to slower compilation and JavaScript-based configuration
- Truffle: Rejected as legacy tooling with declining community support
- Remix: Rejected for lack of CLI/automation capabilities

**Best Practices**:
- Use `forge test` with invariant testing for critical contract logic
- Implement `forge script` for idempotent, reproducible deployments
- Enable gas snapshots with `forge snapshot` for regression testing
- Use `anvil` for local testing with forked Base Sepolia state

**Dependencies**:
- Foundry v0.2.0+
- OpenZeppelin Contracts v5.0.0 (ReentrancyGuard, Pausable, Ownable)
- Solidity 0.8.24

---

### 3. Smart Contract Security: OpenZeppelin Patterns

**Decision**: Follow OpenZeppelin security baseline patterns for all contracts

**Rationale**:
- **Battle-tested**: Industry-standard security patterns used by major protocols
- **Audited**: OpenZeppelin contracts have undergone multiple security audits
- **Modular**: Inherit only needed functionality (ReentrancyGuard, Pausable, Ownable)
- **Upgradeable patterns**: Proxy patterns available if needed (not required for demo)
- **Events**: Comprehensive event emission for observability

**Key Patterns to Implement**:
1. **ReentrancyGuard**: Protect all state-changing functions with `nonReentrant` modifier
2. **Pausable**: Emergency stop mechanism for critical issues
3. **Ownable/AccessControl**: Role-based access for admin functions
4. **Checks-Effects-Interactions**: Always validate inputs, update state, then make external calls
5. **SafeERC20**: Use safe transfer methods for token operations

**Implementation Checklist**:
- [ ] All external state-changing functions have `nonReentrant`
- [ ] Input validation on all user-supplied parameters
- [ ] Event emission for all state changes
- [ ] SPDX license identifiers on all files
- [ ] NatSpec comments for all public/external functions
- [ ] Explicit visibility modifiers (public/external/internal/private)
- [ ] No floating pragma versions (use exact version: `pragma solidity 0.8.24;`)

---

### 4. Indexing Layer: The Graph

**Decision**: Use The Graph Protocol for blockchain data indexing

**Rationale**:
- **Real-time indexing**: Near real-time event processing (typically <30s latency)
- **GraphQL API**: Powerful query language for complex data retrieval
- **Declarative mappings**: TypeScript-based event handlers
- **Reorg handling**: Built-in protection against chain reorganizations
- **Hosted service**: Free tier available for testnet deployments

**Alternatives Considered**:
- Direct RPC polling: Rejected due to rate limits and complexity
- Ponder: Rejected as newer, less mature tooling
- Custom indexer: Rejected due to development time constraints

**Subgraph Architecture**:
```
schema.graphql → Define entities (Position, RiskEvent, ProtectionAction)
subgraph.yaml → Configure data sources (contracts, start blocks, handlers)
src/mapping.ts → Event handlers (PositionCreated, RiskThresholdBreached, ProtectionExecuted)
```

**Best Practices**:
- Use derived fields for calculated values (e.g., Health Factor)
- Implement time-travel queries for historical state
- Add pagination support to all list queries
- Use BigInt/BigDecimal for financial calculations
- Include block number and timestamp in all entities

**Key Queries to Support**:
- `positionsByOwner(owner: String!, first: Int, skip: Int): [Position]`
- `riskEventsByPosition(positionId: ID!, first: Int, orderBy: String): [RiskEvent]`
- `protectionActionsByPosition(positionId: ID!): [ProtectionAction]`
- `positionsAtRisk(threshold: BigDecimal!): [Position]`

---

### 5. Automation: Chainlink Automation

**Decision**: Use Chainlink Automation (formerly Keepers) for automated position monitoring and protection triggers

**Rationale**:
- **Decentralized**: Network of nodes for reliable execution
- **Gas efficient**: Optimized for cost-effective automation
- **Flexible triggers**: Time-based (CRON) and custom logic (conditional) upkeeps
- **Base Sepolia support**: Native integration with Base L2
- **Monitoring dashboard**: Web UI for managing and debugging upkeeps

**Automation Strategy**:
1. **Primary**: Chainlink Custom Logic Upkeep
   - Check Health Factor of monitored positions every block
   - Trigger protection when HF < threshold
   - Gas limit: 500k per execution

2. **Fallback**: Backend CRON job (every 5 minutes)
   - Queries subgraph for at-risk positions
   - Submits manual protection transactions if Automation is delayed
   - Logs delays as Prometheus metrics

**Best Practices**:
- Implement `checkUpkeep` with gas-efficient checks (view function)
- Keep `performUpkeep` logic minimal and idempotent
- Emit events for all upkeep executions
- Include circuit breakers for maximum execution frequency
- Document gas requirements and LINK funding needs

**Implementation Checklist**:
- [ ] Register Upkeep on Chainlink Automation UI
- [ ] Fund with sufficient LINK tokens (estimate: 5 LINK for testing)
- [ ] Document Upkeep ID in README and PROOF.md
- [ ] Implement manual override endpoint in API
- [ ] Log automation delays as Prometheus metric

---

### 6. Backend API: Go + chi Router

**Decision**: Build backend API service in Go using chi HTTP router

**Rationale**:
- **Performance**: Compiled language, excellent concurrency via goroutines
- **WebSocket support**: Native support for bi-directional communication
- **Type safety**: Strong typing prevents runtime errors
- **Standard library**: Comprehensive stdlib reduces external dependencies
- **Deployment**: Single binary, easy containerization

**Alternatives Considered**:
- Node.js/Express: Rejected due to performance and memory concerns
- Python/FastAPI: Rejected due to slower execution for WebSocket streams
- Rust/Actix: Rejected due to steeper learning curve and time constraints

**API Architecture**:
```
cmd/api/main.go → Entry point, server initialization
internal/
  ├── handlers/ → HTTP/WebSocket handlers
  ├── services/ → Business logic (HF calculation, risk detection)
  ├── rpc/ → Blockchain RPC clients with retry logic
  ├── cache/ → Redis/in-memory caching layer
  ├── metrics/ → Prometheus instrumentation
  └── ws/ → WebSocket connection management
```

**Key Features**:
1. **RPC Client with Retry Logic**: Exponential backoff for rate limit handling
2. **Caching Layer**: In-memory TTL cache (30s) for position data
3. **WebSocket Hub**: Pub/sub pattern for real-time event broadcasting
4. **Prometheus Metrics**: Middleware for request duration, error rates
5. **Graceful Shutdown**: Drain connections on SIGTERM

**Dependencies**:
- `github.com/go-chi/chi/v5`: HTTP router
- `github.com/gorilla/websocket`: WebSocket implementation
- `github.com/prometheus/client_golang`: Metrics collection
- `github.com/ethereum/go-ethereum`: Ethereum client libraries

---

### 7. Frontend: Next.js + wagmi + viem

**Decision**: Build frontend with Next.js App Router, wagmi for wallet integration, viem for Ethereum interactions

**Rationale**:
- **Next.js 14 App Router**: Server components, streaming, improved performance
- **wagmi**: React hooks for wallet connection (MetaMask, WalletConnect)
- **viem**: Modern, typed Ethereum library (replacement for ethers.js)
- **TypeScript**: Type safety for contract interactions
- **Vercel deployment**: One-click deployment with Edge Network CDN

**Alternatives Considered**:
- React + Vite: Rejected for lack of SSR/streaming capabilities
- ethers.js: Replaced by viem for better TypeScript support and tree-shaking
- web3.js: Rejected as legacy library with larger bundle size

**Frontend Architecture**:
```
app/
  ├── page.tsx → Landing/dashboard page
  ├── layout.tsx → Root layout with wagmi/viem providers
  ├── positions/
  │   └── [address]/page.tsx → Position detail view
  └── api/
      └── health/route.ts → Health check endpoint
components/
  ├── PositionCard.tsx → Display HF, status badges
  ├── RiskTimeline.tsx → Event timeline visualization
  ├── ProtectButton.tsx → One-click protection trigger
  └── AIExplanation.tsx → Risk explanation display
hooks/
  ├── usePositions.ts → Fetch positions via subgraph
  ├── useWebSocket.ts → Real-time event subscription
  └── useProtection.ts → Execute protection transaction
lib/
  ├── contracts.ts → Contract ABIs and addresses
  ├── wagmiConfig.ts → wagmi configuration
  └── graphql.ts → GraphQL client for subgraph
```

**Best Practices**:
- Use Server Components for initial data fetching
- Client Components only for interactivity (wallet, transactions)
- Implement optimistic UI updates with `useMutation`
- Cache subgraph queries with React Query/SWR
- Handle wallet connection errors with user-friendly messages
- Show loading states, empty states, error states

**Dependencies**:
- `next`: 14.x (App Router)
- `wagmi`: 2.x (wallet hooks)
- `viem`: 2.x (Ethereum client)
- `@tanstack/react-query`: 5.x (data fetching)
- `urql` or `@apollo/client`: GraphQL client for subgraph

---

### 8. Observability: Prometheus + Grafana

**Decision**: Use Prometheus for metrics collection and Grafana for visualization

**Rationale**:
- **Industry standard**: De facto standard for monitoring cloud-native applications
- **Pull-based**: Scrape metrics from `/metrics` endpoint
- **Time-series database**: Optimized for time-series data
- **PromQL**: Powerful query language for aggregations and alerts
- **Grafana integration**: Pre-built dashboards and alerting

**Metrics to Track**:
```go
// Counters
watchtower_triggers_total{type="manual|automatic",status="success|failure"}
watchtower_api_requests_total{endpoint="/api/positions",method="GET",status="200"}

// Histograms
watchtower_latency_seconds{operation="fetch_hf|execute_protection"}
watchtower_rpc_latency_seconds{method="eth_call|eth_sendTransaction"}

// Gauges
watchtower_positions_monitored{network="base_sepolia"}
watchtower_websocket_connections
```

**Grafana Dashboard Panels**:
1. Protection Triggers Rate (last 1h, 6h, 24h)
2. API Request Latency (P50, P95, P99)
3. Error Rate by Type
4. Active WebSocket Connections
5. Positions at Risk (gauge)
6. RPC Call Success Rate
7. Subgraph Sync Lag

**Deployment**:
- Docker Compose for local development
- Prometheus scrapes backend `/metrics` every 15s
- Grafana dashboard JSON exported to `configs/grafana/watchtower-dashboard.json`
- README includes import instructions

**Configuration Files**:
```
configs/
  ├── prometheus/prometheus.yml → Scrape configuration
  └── grafana/
      ├── dashboard.json → Dashboard definition
      └── datasources.yml → Prometheus datasource
docker-compose.yml → Services: prometheus, grafana, api
```

---

### 9. AI Risk Explanation: LLM API Integration

**Decision**: Use external LLM API (OpenAI or Anthropic Claude) for risk explanations

**Rationale**:
- **Quality**: State-of-the-art language models for clear explanations
- **Speed**: Fast inference times (<5s target)
- **API availability**: Both providers have generous free tiers for testing
- **Structured outputs**: Support for JSON mode for predictable responses

**Implementation Strategy**:
1. **Primary**: OpenAI GPT-4o-mini (cost-effective, fast)
2. **Fallback**: Static templated explanations if quota exceeded
3. **Caching**: Cache explanations by position state hash (HF range + collateral ratio)

**API Request Format**:
```json
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are a DeFi risk analyst. Explain liquidation risks clearly and concisely."
    },
    {
      "role": "user",
      "content": "Position: HF=1.15, collateral=1000 USDC, debt=850 USDC. Explain risk and predict HF if collateral drops 8%."
    }
  ],
  "temperature": 0.7,
  "max_tokens": 300
}
```

**Response Structure**:
```json
{
  "explanation": "Your position has a Health Factor of 1.15, which is in the Warning zone...",
  "scenarios": {
    "price_down_8": {
      "new_hf": 1.06,
      "risk_level": "Critical",
      "recommendation": "Add collateral or repay debt immediately"
    },
    "price_up_8": {
      "new_hf": 1.24,
      "risk_level": "Warning",
      "recommendation": "Monitor closely, consider adding buffer"
    }
  }
}
```

**Best Practices**:
- Set API timeout to 5s (fail fast)
- Implement exponential backoff for rate limits
- Log all API calls for cost tracking
- Use environment variables for API keys
- Include fallback static explanations

---

### 10. Demo Replay Mode: Offline Data Strategy

**Decision**: Implement offline replay mode with cached/simulated data

**Rationale**:
- **Demo reliability**: Eliminates dependency on network conditions during presentations
- **Judge experience**: Allows judges to run demo without test funds or RPC access
- **Testing**: Enables consistent E2E testing without blockchain interactions

**Implementation Approach**:
```
1. Record Mode:
   - Capture real blockchain interactions (RPC calls, events, transactions)
   - Serialize responses to JSON fixtures in `fixtures/demo-session-1.json`
   - Include timestamps, block numbers, transaction hashes

2. Replay Mode (env: REPLAY_MODE=true):
   - Replace RPC client with mock client reading from fixtures
   - WebSocket server sends pre-recorded events with simulated delays
   - UI shows "Demo Mode" badge

3. Fixture Structure:
{
  "positions": [...],
  "events": [
    { "type": "threshold_breach", "timestamp": 1697... , "data": {...} }
  ],
  "transactions": [...]
}
```

**Activation**:
- Environment variable: `REPLAY_MODE=true`
- UI toggle: "Enable Demo Mode" in settings
- README section: "Running in Offline Demo Mode"

---

## Cross-Cutting Concerns

### Error Handling Strategy

**Contract Errors**:
- Use custom errors (Solidity 0.8.4+) for gas efficiency
- Provide descriptive error messages for troubleshooting
- Emit events before reverting for observability

**API Errors**:
- Standardized error responses: `{ "error": "...", "code": "ERR_RPC_TIMEOUT", "details": {...} }`
- HTTP status codes: 400 (client error), 500 (server error), 503 (RPC unavailable)
- Include retry guidance in error messages

**Frontend Errors**:
- Toast notifications for transient errors
- Modal dialogs for actionable errors (e.g., "Insufficient gas, visit faucet")
- Sentry/error tracking for production monitoring

### Caching Strategy

**Levels**:
1. **Frontend**: React Query cache (5min stale time)
2. **Backend**: In-memory LRU cache (30s TTL) for position data
3. **Subgraph**: Built-in caching (configurable)

**Invalidation**:
- On new block events (WebSocket)
- Manual refresh button
- After successful transactions

### Security Considerations

**API Security**:
- Rate limiting: 100 req/min per IP
- CORS configuration: Allow only frontend origin
- API key authentication for admin endpoints (optional)

**Contract Security**:
- Reentrancy protection on all state-changing functions
- Input validation (address non-zero, amounts > 0)
- Access control for admin functions (Ownable)
- Pausable pattern for emergency stops

**Frontend Security**:
- Sanitize user inputs
- Verify contract addresses before transactions
- Show transaction preview before signing
- Warn on high gas fees

---

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        User Browser                          │
│  Next.js Frontend (Vercel) + MetaMask Wallet Integration    │
└────────────┬──────────────────────────────┬─────────────────┘
             │                               │
             │ HTTP/WS                       │ RPC
             │                               │
             ▼                               ▼
┌────────────────────────┐        ┌────────────────────────────┐
│   Go API Server        │        │  Base Sepolia Testnet      │
│  (VPS/Cloud Run)       │        │  - PositionVault Contract  │
│  - REST API            │◄───────┤  - Protector Contract      │
│  - WebSocket Hub       │  Events │  - Mock Token Contracts    │
│  - Prometheus /metrics │        └────────────┬───────────────┘
└────────┬───────────────┘                     │
         │                                     │ Events
         │ GraphQL                             │
         ▼                                     ▼
┌────────────────────────┐        ┌────────────────────────────┐
│  The Graph (Hosted)    │        │  Chainlink Automation      │
│  - Subgraph API        │        │  - Upkeep Monitor          │
│  - Position indexing   │        │  - Auto-trigger protection │
└────────────────────────┘        └────────────────────────────┘
         │
         │ Metrics
         ▼
┌────────────────────────┐
│  Prometheus + Grafana  │
│  (Docker Compose)      │
│  - Metrics storage     │
│  - Dashboard UI        │
└────────────────────────┘
```

---

## Development Timeline Estimates

**Phase 1: Smart Contracts (2-3 days)**
- PositionVault.sol: 1 day
- Protector.sol: 1 day
- Mock tokens + deployment scripts: 0.5 day
- Tests + deployment to Base Sepolia: 0.5 day

**Phase 2: Subgraph (1 day)**
- Schema definition: 0.25 day
- Event handlers: 0.5 day
- Deployment + testing: 0.25 day

**Phase 3: Backend API (2 days)**
- RPC client + caching: 0.5 day
- REST API endpoints: 0.5 day
- WebSocket hub: 0.5 day
- Prometheus metrics: 0.5 day

**Phase 4: Frontend (2-3 days)**
- Position dashboard: 1 day
- Wallet integration + transactions: 1 day
- Timeline + AI explanation: 0.5 day
- Error handling + polish: 0.5 day

**Phase 5: Automation (1 day)**
- Chainlink Upkeep setup: 0.5 day
- Fallback CRON job: 0.5 day

**Phase 6: Observability (1 day)**
- Grafana dashboard: 0.5 day
- Docker Compose setup: 0.25 day
- Documentation: 0.25 day

**Phase 7: Compliance & Documentation (1-2 days)**
- Community health files: 0.5 day
- AI_USAGE + CHANGELOG setup: 0.5 day
- README + PROOF documentation: 0.5 day
- Demo video recording: 0.5 day

**Total**: 10-13 days (estimated)

---

## Risk Mitigation Implementation

| Risk | Technical Solution | Verification Method |
|------|-------------------|---------------------|
| RPC rate limiting | Multi-provider fallback (Alchemy→Infura→Public) + exponential backoff | Load test with 100 req/s |
| Subgraph sync lag | Cache last-known state + display staleness indicator | Monitor sync lag metric |
| Automation delays | Backend fallback CRON job + manual override API | Simulate Chainlink downtime |
| Insufficient gas | Gas estimation API + link to faucet in error message | Test with empty wallet |
| WebSocket disconnect | Auto-reconnect with exponential backoff + polling fallback | Simulate network interruptions |
| AI API quota | Static fallback explanations + response caching | Exceed rate limit intentionally |

---

## Definition of Done (Technical Checklist)

### Smart Contracts
- [ ] All contracts deployed to Base Sepolia with verified source code
- [ ] SPDX headers present in all .sol files
- [ ] OpenZeppelin patterns implemented (ReentrancyGuard, Pausable)
- [ ] All public functions have NatSpec comments
- [ ] Forge tests achieve >80% code coverage
- [ ] Gas snapshots committed to repo

### Backend API
- [ ] `/metrics` endpoint returns Prometheus-formatted metrics
- [ ] `/health` endpoint returns 200 OK with version info
- [ ] WebSocket reconnection tested and functional
- [ ] RPC retry logic handles rate limits gracefully
- [ ] Caching reduces RPC calls by >50%
- [ ] API documentation (OpenAPI spec) generated

### Frontend
- [ ] Wallet connection works with MetaMask and WalletConnect
- [ ] All user flows tested: view position → receive alert → execute protection
- [ ] Empty states, loading states, error states implemented
- [ ] Responsive design works on desktop (Chrome, Firefox, Safari)
- [ ] Demo mode toggle functional with offline data
- [ ] Deployed to Vercel with custom domain

### Subgraph
- [ ] Schema matches entity definitions in data-model.md
- [ ] All contract events have corresponding handlers
- [ ] Queries return data within <2s for 100 positions
- [ ] Subgraph deployed to hosted service with public endpoint
- [ ] README documents example queries

### Observability
- [ ] Grafana dashboard displays all key metrics
- [ ] `docker-compose up` starts Prometheus + Grafana successfully
- [ ] Dashboard JSON exported and committed to repo
- [ ] README "Observability" section includes import instructions
- [ ] Example PromQL queries documented

### Compliance
- [ ] AI_USAGE.md has at least one entry per development day
- [ ] CHANGELOG.md updated daily with summaries
- [ ] docs/PROOF.md includes Hacker Dashboard submission link + screenshots
- [ ] CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md present
- [ ] README has one-command startup instructions
- [ ] Demo video (2-4 minutes) uploaded and linked

---

## Conclusion

All technology decisions are finalized and research is complete. The architecture leverages proven technologies optimized for a hackathon timeline while maintaining production-grade quality standards. No further clarifications needed - ready to proceed with Phase 1 (Design & Contracts).
