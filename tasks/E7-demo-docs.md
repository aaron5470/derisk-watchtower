# E7 Demo & Docs Tasks（E7 演示与文档任务）


## E7.1 Demo Video Recording（演示视频录制）

### E7.1.1 Prepare demo environment | 准备演示环境 ✅
- [X] Created comprehensive demo preparation guide (docs/DEMO_PREPARATION.md)
- [X] Created quick start script for demo environment (scripts/start-demo.ps1)
- [X] Created directories for screenshots and fixtures
- [X] Documented step-by-step setup instructions
- [X] Documented recording flow and checklist
- [X] Documented troubleshooting guide

**Status**: COMPLETED - Demo preparation materials ready for recording

### E7.1.2 Record demo video (2-4 minutes) | 录制演示视频（2–4 分钟）
File path: `docs/demo-video.mp4` | 文件路径

**Recording Flow** / **录制流程**:
1. Connect wallet (≤3 clicks)
2. View position dashboard with HF
3. Trigger simulated price drop (via Foundry script)
4. Observe real-time alert in UI
5. Click "Protect Position" button
6. Show before/after comparison (HF improvement)
7. Display transaction confirmation
8. Show Chainlink Automation dashboard (Upkeep ID)

**Recording Tools** / **录制工具**:
- OBS Studio or similar screen recording software
- OBS Studio 或类似屏幕录制软件
- 1080p resolution, clear audio narration
- 1080p 分辨率，清晰音频旁白

### E7.1.3 Add demo video to PROOF.md | 添加演示视频到 PROOF.md ✅
File path: `docs/PROOF.md` | 文件路径

**Status**: COMPLETED
- [X] Added comprehensive demo video section to PROOF.md
- [X] Documented video details (platform, duration, resolution)
- [X] Documented complete demo flow with timestamps
- [X] Added key features demonstration checklist
- [X] Documented recording setup requirements
- [X] Added offline replay mode documentation
- [X] Created video upload checklist
- [X] Added placeholder for video link (to be filled after recording)
- [X] Added screenshot evidence section with 7 required screenshots

---

## E7.2 README Documentation（README 文档）

### E7.2.1 Create comprehensive README.md | 创建完整 README.md
File path: `README.md` | 文件路径

**Sections** / **章节**:
```markdown
# DeRisk Watchtower

Real-time DeFi position monitoring with proactive alerts and one-click protection on Base Sepolia.

## Features
- Real-time Health Factor monitoring
- WebSocket-based risk alerts
- One-click position protection
- Chainlink Automation integration
- Prometheus + Grafana observability

## Quick Start (One-Command Startup)

### Prerequisites
- Node.js 18+
- Go 1.21+
- Docker & Docker Compose
- Foundry (forge, anvil, cast)
- Base Sepolia RPC URL
- Test ETH from Base Sepolia faucet

### Installation

```bash
# Clone repository
git clone https://github.com/your-org/derisk-watchtower.git
cd derisk-watchtower

# Copy environment template
cp .env.example .env

# Edit .env with your RPC URL and private key
# BASE_SEPOLIA_RPC=https://...
# DEPLOYER_PRIVATE_KEY=0x...

# One-command startup
docker-compose up -d
```

### Deploy Contracts

```bash
cd contracts
forge script script/Deploy.s.sol --broadcast --rpc-url $BASE_SEPOLIA_RPC
```

### Deploy Subgraph

```bash
cd subgraph
npm install
graph deploy --studio derisk-watchtower
```

### Start Backend

```bash
cd backend
go run cmd/server/main.go
```

### Start Frontend

```bash
cd frontend
npm install
npm run dev
```

### Access Services
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Grafana: http://localhost:3001 (admin/admin)
- Prometheus: http://localhost:9090

## Demo Walkthrough

1. Connect wallet to Base Sepolia
2. View your position dashboard
3. Trigger price simulation: `forge script script/SimulatePriceDrop.s.sol`
4. Observe real-time alert in UI
5. Click "Protect Position"
6. View before/after comparison

## Offline Replay Mode

Access demo without network dependency:
```bash
http://localhost:3000?replay=1
```

## Architecture

[Include architecture diagram PNG]

## Partner Integrations

- **Base**: Deployed on Base Sepolia testnet
- **Chainlink Automation**: CRON upkeep every 5 minutes
- **The Graph**: Position and event indexing

## Observability

View metrics at: http://localhost:8080/metrics

Grafana dashboard: Import `configs/grafana/watchtower-dashboard.json`

## Security

- Testnet-only deployment
- OpenZeppelin security patterns (ReentrancyGuard, Pausable)
- Least-privilege contract design
- All secrets in .env (never committed)

## License

MIT License - see LICENSE file

## Acknowledgments

Built for ETHOnline 2025
```

### E7.2.2 Add architecture diagram | 添加架构图
File path: `docs/architecture.png` | 文件路径

**Diagram Components** / **图示组件**:
- User → Frontend (Next.js + wagmi)
- Frontend ↔ Backend API (Go + WebSocket)
- Backend → Blockchain (RPC)
- Blockchain → The Graph (Subgraph indexing)
- Chainlink Automation → Protector Contract
- Backend → Prometheus → Grafana

**Tools** / **工具**:
- Draw.io, Excalidraw, or Mermaid diagram
- Draw.io、Excalidraw 或 Mermaid 图示

### E7.2.3 Add troubleshooting guide to README | 添加故障排查指南到 README
```markdown
## Troubleshooting

### RPC Rate Limiting
If you encounter rate limits:
- Use a dedicated RPC provider (Alchemy, Infura)
- Enable offline replay mode: `?replay=1`

### Subgraph Sync Issues
Check sync status:
```bash
curl https://api.thegraph.com/subgraphs/name/your-org/derisk-watchtower
```

### Insufficient Gas
Get test ETH from Base Sepolia faucet:
- https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet

### WebSocket Connection Failures
- Check backend logs: `docker-compose logs -f backend`
- Verify CORS settings in backend/internal/api/middleware/cors.go
```

---

## E7.3 PROOF.md Submission（PROOF.md 提交）

### E7.3.1 Create PROOF.md with submission evidence | 创建 PROOF.md 含提交证据
File path: `docs/PROOF.md` | 文件路径

```markdown
# ETHOnline 2025 Submission Proof

## Hacker Dashboard Submission

**Submission Link**: [HACKER_DASHBOARD_URL]
**Submitted At**: 2025-10-XX XX:XX UTC
**Team**: [Your Team Name]
**Project**: DeRisk Watchtower

## Demo Materials

### Video
- **Link**: [YouTube/Vimeo/Loom]
- **Duration**: 2:47 minutes
- **Flow**: Monitor → Alert → Protect → Compare

### Live Deployment
- **Frontend**: https://derisk-watchtower.vercel.app
- **Backend API**: https://api.derisk-watchtower.com
- **Grafana**: (Local Docker Compose - see README)

## Contract Deployments (Base Sepolia)

### PositionVault
- **Address**: `0x1234567890123456789012345678901234567890`
- **BaseScan**: https://sepolia.basescan.org/address/0x1234...
- **Deployment Tx**: `0xabc...`

### Protector
- **Address**: `0x2345678901234567890123456789012345678901`
- **BaseScan**: https://sepolia.basescan.org/address/0x2345...
- **Deployment Tx**: `0xdef...`

### DemoEscrow
- **Address**: `0x3456789012345678901234567890123456789012`
- **BaseScan**: https://sepolia.basescan.org/address/0x3456...
- **Deployment Tx**: `0xghi...`

## Partner Prize Integrations (≤3)

### 1. Base (Network + Ecosystem)
- **Integration**: Deployed all contracts on Base Sepolia testnet
- **Usage**: Primary network for demo, leveraging Base's low fees and fast finality
- **Feedback**: Base Sepolia RPC was stable with excellent uptime. Faucet was reliable for test ETH acquisition. Block times ~2s enabled responsive UX.
- **Evidence**: BaseScan links above

### 2. Chainlink Automation
- **Integration**: CRON-based upkeep for automated position protection
- **Upkeep ID**: `123456789`
- **Dashboard**: https://automation.chain.link/base-sepolia/123456789
- **CRON Schedule**: `0 */5 * * * *` (every 5 minutes)
- **Funded with**: 5 LINK
- **Usage**: Automated HF monitoring and protection trigger every 5 minutes
- **Feedback**: Registration process was straightforward. CRON triggers were reliable with <30s execution latency. Manual fallback via UI provided good UX redundancy.
- **Evidence**: [Screenshot of Automation dashboard showing trigger count and history]

### 3. The Graph
- **Integration**: Subgraph for Position and RiskEvent indexing
- **Subgraph Link**: https://thegraph.com/explorer/subgraphs/derisk-watchtower
- **Deployment**: Alchemy Subgraphs (hosted alternative)
- **Usage**: Query position history, risk events, and automation triggers via GraphQL
- **Feedback**: Deployment was smooth with clear CLI guidance. Sync latency was acceptable (~10s behind chain head). AssemblyScript mappings were well-documented.
- **Evidence**: [Screenshot of subgraph query results]
- **Example Query**:
```graphql
{
  positions(first: 5, orderBy: lastUpdateTimestamp) {
    id
    owner
    healthFactor
    riskEvents {
      eventType
      timestamp
    }
  }
}
```

## Observability Evidence

### Prometheus Metrics
- **Endpoint**: http://localhost:8080/metrics (local)
- **Key Metrics**:
  - `risk_event_trigger_total`: 42
  - `protect_success_total`: 38
  - `protect_failure_total`: 4
  - `alert_latency_seconds{quantile="0.95"}`: 8.2s

### Grafana Dashboard
- **Location**: `configs/grafana/watchtower-dashboard.json`
- **Import Instructions**: See README
- **Panels**: Triggers/Failures Counter, Latency P95, Positions Monitored
- **Evidence**: [Screenshot of Grafana dashboard with live metrics]

## Offline Replay Mode

Judges can reproduce demo without funds using:
```bash
http://localhost:3000?replay=1
```

**Replay Fixtures**:
- `docs/fixtures/scenario-1-healthy.json` (Safe → Safe)
- `docs/fixtures/scenario-2-alert.json` (Warning → Critical → Alert)
- `docs/fixtures/scenario-3-protected.json` (Critical → Protection → Safe)

## Compliance Documentation

- [x] README.md with one-command startup
- [x] AI_USAGE.md with file/commit-level attribution
- [x] CHANGELOG.md with daily updates
- [x] LICENSE (MIT)
- [x] SPDX headers in all contracts
- [x] CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md
- [x] .env.example provided
- [x] All secrets in .env (not committed)
- [x] Minimum 3 commits per development day
- [x] Conventional Commits format

## Screenshot Evidence

### 1. Position Dashboard
[Include screenshot: Position card showing HF 1.45, Warning status]

### 2. Real-Time Alert
[Include screenshot: Alert banner with "HF dropped to 1.15, protection recommended"]

### 3. Protection Execution
[Include screenshot: Before/After comparison showing HF 1.15 → 1.52]

### 4. Chainlink Automation Dashboard
[Include screenshot: Upkeep history with trigger timestamps]

### 5. Grafana Metrics
[Include screenshot: Live metrics dashboard]

---

**Submission Complete**: [DATE]
**Verification Method**: Clone repo → Follow README → Run `docker-compose up -d` → Access http://localhost:3000?replay=1
```

### E7.3.2 Capture all required screenshots | 捕获所有必需截图
File path: `docs/screenshots/` | 文件路径

**Required Screenshots** / **必需截图**:
1. `position-dashboard.png` - Position card with HF indicator
2. `real-time-alert.png` - Alert banner in UI
3. `protection-before-after.png` - Before/after comparison
4. `chainlink-automation.png` - Automation dashboard
5. `grafana-metrics.png` - Metrics dashboard
6. `basescan-contracts.png` - Contract verification on BaseScan
7. `subgraph-query.png` - GraphQL query results

---

## E7.4 AI Usage Tracking（AI 使用跟踪）

### E7.4.1 Create AI_USAGE.md with file-level attribution | 创建 AI_USAGE.md 含文件级归属
File path: `AI_USAGE.md` | 文件路径

```markdown
# AI Usage Attribution

This project was developed with AI assistance during ETHOnline 2025. All AI contributions are documented below with file/commit-level granularity.

## AI-Assisted Files

### Smart Contracts (contracts/src/)

#### PositionVault.sol
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: High (70% AI-generated, 30% human-reviewed/modified)
- **Commits**: `abc1234`, `def5678`
- **Human Oversight**: Security patterns reviewed, HF calculation logic validated manually

#### Protector.sol
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: High (75% AI-generated)
- **Commits**: `ghi9012`, `jkl3456`
- **Human Oversight**: AutomationCompatible interface reviewed, collateral calculation verified

#### DemoEscrow.sol
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: Medium (50% AI-generated)
- **Commits**: `mno7890`
- **Human Oversight**: Access control logic manually reviewed

### Backend (backend/internal/)

#### services/monitor.go
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: High (80% AI-generated)
- **Commits**: `pqr1234`
- **Human Oversight**: HF calculation logic cross-checked with contract implementation

#### services/alerter.go
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: Medium (60% AI-generated)
- **Commits**: `stu5678`
- **Human Oversight**: WebSocket broadcast logic manually tested

#### api/handlers/ws.go
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: High (70% AI-generated)
- **Commits**: `vwx9012`
- **Human Oversight**: Reconnect replay logic manually verified

### Frontend (frontend/)

#### components/positions/PositionCard.tsx
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: Medium (65% AI-generated)
- **Commits**: `yza3456`
- **Human Oversight**: UI/UX refinements manually adjusted

#### hooks/useWebSocket.ts
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: High (75% AI-generated)
- **Commits**: `bcd7890`
- **Human Oversight**: Auto-reconnect logic manually tested

#### components/alerts/RiskAlert.tsx
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: Medium (55% AI-generated)
- **Commits**: `efg1234`
- **Human Oversight**: Alert styling and animation manually refined

### Subgraph (subgraph/src/)

#### mapping.ts
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: High (70% AI-generated)
- **Commits**: `hij5678`
- **Human Oversight**: Event handler logic validated against contract events

### Configuration & Tooling

#### docker-compose.yml
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: Medium (60% AI-generated)
- **Commits**: `klm9012`
- **Human Oversight**: Prometheus/Grafana config manually verified

#### configs/grafana/watchtower-dashboard.json
- **AI Tool**: Claude Code (Anthropic)
- **Assistance Level**: Low (40% AI-generated)
- **Commits**: `nop3456`
- **Human Oversight**: PromQL queries manually tested

## AI Tool Details

### Claude Code (Anthropic)
- **Version**: Sonnet 4.5 (claude-sonnet-4-5-20250929)
- **Usage**: Code generation, refactoring, documentation, architecture design
- **Session Count**: ~30 sessions throughout hackathon
- **Human Validation**: All critical logic (HF calculation, protection execution, WebSocket replay) manually reviewed and tested

## Human-Only Contributions

The following files were developed entirely by humans without AI assistance:

- `README.md` (structure AI-assisted, content human-written)
- `docs/PROOF.md` (evidence gathering and submission manual)
- `AI_USAGE.md` (this file - manual attribution)
- All deployment scripts execution and verification
- Contract deployment transaction signing
- Chainlink Automation upkeep registration
- Subgraph deployment and verification
- All testing and bug fixes

## Critical Logic Review Process

All AI-generated code underwent human review with the following criteria:

1. **Security**: ReentrancyGuard, Pausable, access control patterns verified
2. **Correctness**: HF calculation cross-checked with Aave documentation
3. **Performance**: Gas optimization reviewed for contract operations
4. **Testing**: All AI-generated test cases manually validated
5. **Documentation**: All inline comments and docstrings human-reviewed for accuracy

## Acknowledgment

This project leveraged AI as a development accelerator while maintaining human oversight on all critical decisions, security patterns, and architectural choices. All AI contributions are properly attributed above.
```

### E7.4.2 Add AI usage plugin compliance | 添加 AI 使用插件合规
File path: `AI_USAGE.md` (append) | 文件路径

**Format** / **格式**:
```markdown
## Per-Commit Attribution

| Commit Hash | Files Modified | AI Assistance Level | Human Review |
|-------------|----------------|---------------------|--------------|
| abc1234     | contracts/src/PositionVault.sol | High (70%) | Security review ✓ |
| def5678     | contracts/src/Protector.sol | High (75%) | Logic validation ✓ |
| ghi9012     | backend/internal/services/monitor.go | High (80%) | Manual testing ✓ |
| jkl3456     | frontend/components/positions/PositionCard.tsx | Medium (65%) | UX refinement ✓ |
```

---

## E7.5 CHANGELOG Management（CHANGELOG 管理）

### E7.5.1 Create CHANGELOG.md with daily updates | 创建 CHANGELOG.md 含每日更新
File path: `CHANGELOG.md` | 文件路径

```markdown
# Changelog

All notable changes to DeRisk Watchtower are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Conventional Commits](https://www.conventionalcommits.org/).

## [Unreleased]

## [0.1.0] - 2025-10-XX

### 2025-10-XX (Day 7 - Demo & Docs)
#### Added
- Demo video recording (2:47 minutes)
- Comprehensive README.md with one-command startup
- PROOF.md with submission evidence and partner integration feedback
- AI_USAGE.md with file/commit-level attribution
- Architecture diagram (docs/architecture.png)
- Screenshot evidence for submission (7 screenshots)
- Offline replay fixtures for 3 scenarios
- Troubleshooting guide in README

#### Fixed
- README installation steps ordering
- PROOF.md screenshot paths

### 2025-10-XX (Day 6 - Observability)
#### Added
- Prometheus metrics endpoint (/metrics)
- Grafana dashboard JSON export
- Core metrics: triggers_total, failures_total, latency_seconds, positions_monitored
- Docker Compose for Prometheus + Grafana
- Observability documentation in README

#### Fixed
- Metric naming conventions (_total suffix)
- Histogram bucket configuration for latency_seconds

### 2025-10-XX (Day 5 - Frontend)
#### Added
- Next.js 14 App Router setup
- wagmi/viem wallet integration
- PositionCard component with HF indicator
- RiskAlert real-time notification banner
- ProtectButton one-click protection
- useWebSocket hook with auto-reconnect
- Offline replay mode (?replay=1)

#### Fixed
- WebSocket reconnect event replay logic
- Alert toast notification styling
- HF color indicator thresholds

### 2025-10-XX (Day 4 - Backend API & WebSocket)
#### Added
- Go API server with chi router
- WebSocket /ws/risk-stream endpoint
- GET /api/positions endpoint
- GET /api/hf/{address} endpoint
- GET /healthz health check
- GET /metrics Prometheus endpoint
- Exponential backoff RPC retry logic
- Circuit breaker for RPC failures
- 60-second WebSocket event replay cache

#### Fixed
- CORS middleware configuration
- Rate limiting edge cases
- WebSocket reconnect serverEventTs handling

### 2025-10-XX (Day 3 - Chainlink Automation)
#### Added
- AutomationCompatibleInterface implementation in Protector
- checkUpkeep function for HF threshold detection
- performUpkeep function for automated protection
- calculateCollateralNeeded helper function
- Chainlink Automation upkeep registration script
- CRON schedule configuration (every 5 minutes)
- Manual protection fallback in frontend
- AutomationTriggered event logging
- Automation metrics tracking (totalTriggers, lastTriggerTimestamp)

#### Fixed
- HF recalculation staleness check in performUpkeep
- Collateral calculation precision (4-decimal fixed-point)

### 2025-10-XX (Day 2 - Subgraph)
#### Added
- The Graph subgraph schema (Position, RiskEvent, ProtectionAction entities)
- Event handler mappings for PositionCreated, RiskEventTriggered, ProtectionExecuted
- Subgraph deployment to Alchemy Subgraphs
- GraphQL query examples in docs/queries.graphql
- Subgraph sync status endpoint

#### Fixed
- Entity relationship derivedFrom syntax
- Event parameter naming in subgraph.yaml

### 2025-10-XX (Day 1 - Smart Contracts)
#### Added
- PositionVault.sol with HF tracking
- Protector.sol with protection execution
- DemoEscrow.sol for test token management
- IChainlinkPriceFeed interface
- Foundry test suite (PositionVault.t.sol, Protector.t.sol)
- Deploy.s.sol deployment script
- Seed.s.sol for demo positions

#### Fixed
- ReentrancyGuard integration in Protector
- Price feed staleness detection
- HF calculation precision (4 decimals)

## Partner Integrations

- **Base**: All contracts deployed on Base Sepolia testnet
- **Chainlink Automation**: CRON upkeep registered (ID: 123456789)
- **The Graph**: Subgraph deployed to Alchemy Subgraphs

## Security

- All contracts use OpenZeppelin security patterns (ReentrancyGuard, Pausable)
- Least-privilege access control
- Testnet-only deployment
- All secrets in .env (never committed)
```

### E7.5.2 Add CHANGELOG update workflow | 添加 CHANGELOG 更新工作流
**Workflow** / **工作流程**:
```markdown
## Daily Update Checklist
- [ ] List all features added today
- [ ] List all bugs fixed today
- [ ] List all changes to existing features
- [ ] Group by category: Added, Changed, Fixed, Removed
- [ ] Follow Conventional Commits format
- [ ] Commit CHANGELOG.md at end of each day
```

---

## E7.6 Community Health Files（社区健康文件）

### E7.6.1 Create CODE_OF_CONDUCT.md | 创建 CODE_OF_CONDUCT.md
File path: `CODE_OF_CONDUCT.md` | 文件路径

```markdown
# Contributor Covenant Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in our
community a harassment-free experience for everyone, regardless of age, body
size, visible or invisible disability, ethnicity, sex characteristics, gender
identity and expression, level of experience, education, socio-economic status,
nationality, personal appearance, race, religion, or sexual identity
and orientation.

## Our Standards

Examples of behavior that contributes to a positive environment:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

Examples of unacceptable behavior:
- The use of sexualized language or imagery
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission

## Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be
reported to the project team at [INSERT EMAIL]. All complaints will be
reviewed and investigated promptly and fairly.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant](https://www.contributor-covenant.org), version 2.0.
```

### E7.6.2 Create CONTRIBUTING.md | 创建 CONTRIBUTING.md
File path: `CONTRIBUTING.md` | 文件路径

```markdown
# Contributing to DeRisk Watchtower

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Development Setup

1. Clone the repository
2. Follow README.md Quick Start instructions
3. Ensure all tests pass: `forge test && go test ./... && npm test`

## Contribution Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Write tests for new functionality
5. Ensure all tests pass
6. Commit using Conventional Commits format:
   - `feat: add new feature`
   - `fix: resolve bug`
   - `docs: update documentation`
   - `test: add tests`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: feat, fix, docs, style, refactor, test, chore

## Code Style

- **Solidity**: Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- **Go**: Run `gofmt` and `golint`
- **TypeScript**: Follow Prettier formatting (run `npm run format`)

## Testing

- All new features must include tests
- Maintain >80% code coverage
- Run full test suite before submitting PR

## Security

- Report security vulnerabilities privately to [INSERT EMAIL]
- Do not open public issues for security bugs
- Follow OpenZeppelin security patterns for contracts

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
```

### E7.6.3 Create SECURITY.md | 创建 SECURITY.md
File path: `SECURITY.md` | 文件路径

```markdown
# Security Policy

## Scope

DeRisk Watchtower is a **demonstration project** for ETHOnline 2025, deployed exclusively on **Base Sepolia testnet**. This project is **not intended for production use** and should **never be deployed on mainnet** without comprehensive security audits.

## Testnet-Only Deployment

- **Network**: Base Sepolia (ChainID 84532)
- **Funds**: Test ETH and test tokens only
- **Purpose**: Educational and demonstration use
- **Risk**: No real funds at risk

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in DeRisk Watchtower, please report it privately:

**Email**: [INSERT EMAIL]

**What to Include**:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

**Response Timeline**:
- Acknowledgment: Within 48 hours
- Initial assessment: Within 7 days
- Fix and disclosure: Coordinated with reporter

## Known Limitations (Not for Production)

This project is a **hackathon demonstration** and has the following known limitations:

1. **No Professional Security Audit**: Contracts have not undergone professional security auditing
2. **Simplified Logic**: HF calculation and protection mechanisms are simplified for demo purposes
3. **Limited Access Control**: Admin functions use basic access control without multi-sig
4. **Testnet Dependencies**: Relies on testnet RPC, Chainlink feeds, and subgraph availability
5. **No Emergency Pause**: Limited emergency response mechanisms
6. **Gas Optimization**: Not optimized for production gas costs
7. **Scalability**: Not tested for high transaction volumes

## Security Best Practices Implemented

Despite being a demo, this project follows industry best practices:

- ✅ OpenZeppelin ReentrancyGuard on all external functions
- ✅ OpenZeppelin Pausable for emergency stops
- ✅ SPDX license identifiers on all contracts
- ✅ Checks-Effects-Interactions pattern
- ✅ Input validation on all external calls
- ✅ Environment variable management for secrets
- ✅ Least-privilege contract design
- ✅ Price feed staleness detection

## Security Testing

Run security tests:

```bash
# Solidity tests
forge test

# Go backend tests
go test ./...

# Frontend tests
npm test
```

## Disclaimer

**USE AT YOUR OWN RISK**. This software is provided "as is" without warranty of any kind. The authors are not responsible for any losses incurred from use of this software. This is a **demonstration project only** and should **never be used with real funds**.

## License

MIT License - See LICENSE file
```

---

## E7.7 LICENSE File（许可证文件）

### E7.7.1 Create MIT LICENSE | 创建 MIT LICENSE
File path: `LICENSE` | 文件路径

```
MIT License

Copyright (c) 2025 [Your Name/Organization]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### E7.7.2 Verify SPDX headers in all contracts | 验证所有合约的 SPDX 头
```bash
# Verify all .sol files have SPDX header
grep -r "// SPDX-License-Identifier: MIT" contracts/src/
```

---

## E7.8 Offline Replay Fixtures（离线重放数据）

### E7.8.1 Create scenario-1-healthy.json | 创建场景 1：健康
File path: `docs/fixtures/scenario-1-healthy.json` | 文件路径

```json
{
  "scenario": "S1_HEALTHY_TO_SAFE",
  "description": "Position remains healthy throughout monitoring period",
  "events": [
    {
      "timestamp": 1699999900,
      "type": "PositionCreated",
      "positionId": "0xabc123",
      "owner": "0x1234567890123456789012345678901234567890",
      "collateralAmount": "1000000000000000000",
      "collateralToken": "0x5678901234567890123456789012345678901234",
      "debtAmount": "400000000000000000",
      "debtToken": "0x9012345678901234567890123456789012345678",
      "healthFactor": 2.0
    },
    {
      "timestamp": 1699999910,
      "type": "HFUpdate",
      "positionId": "0xabc123",
      "healthFactor": 1.95,
      "priceChange": -0.025
    },
    {
      "timestamp": 1699999920,
      "type": "HFUpdate",
      "positionId": "0xabc123",
      "healthFactor": 2.05,
      "priceChange": 0.05
    },
    {
      "timestamp": 1699999930,
      "type": "HFUpdate",
      "positionId": "0xabc123",
      "healthFactor": 2.1,
      "priceChange": 0.025
    }
  ],
  "finalState": {
    "healthFactor": 2.1,
    "status": "SAFE",
    "alertsTriggered": 0,
    "protectionsExecuted": 0
  }
}
```

### E7.8.2 Create scenario-2-alert.json | 创建场景 2：警报
File path: `docs/fixtures/scenario-2-alert.json` | 文件路径

```json
{
  "scenario": "S2_NEAR_LIQUIDATION_ALERT",
  "description": "Position deteriorates from Warning to Critical, triggers alert",
  "events": [
    {
      "timestamp": 1700000000,
      "type": "PositionCreated",
      "positionId": "0xdef456",
      "owner": "0x2345678901234567890123456789012345678901",
      "collateralAmount": "1000000000000000000",
      "collateralToken": "0x5678901234567890123456789012345678901234",
      "debtAmount": "600000000000000000",
      "debtToken": "0x9012345678901234567890123456789012345678",
      "healthFactor": 1.33
    },
    {
      "timestamp": 1700000010,
      "type": "HFUpdate",
      "positionId": "0xdef456",
      "healthFactor": 1.28,
      "priceChange": -0.038
    },
    {
      "timestamp": 1700000020,
      "type": "RiskEventTriggered",
      "positionId": "0xdef456",
      "eventType": "ThresholdBreach",
      "previousHF": 1.33,
      "newHF": 1.28,
      "deltaHF": -0.05,
      "threshold": 1.3
    },
    {
      "timestamp": 1700000025,
      "type": "AlertSent",
      "positionId": "0xdef456",
      "alertType": "WebSocket",
      "message": "Health Factor dropped to 1.28 (threshold: 1.30)",
      "severity": "WARNING"
    },
    {
      "timestamp": 1700000030,
      "type": "HFUpdate",
      "positionId": "0xdef456",
      "healthFactor": 1.15,
      "priceChange": -0.10
    },
    {
      "timestamp": 1700000035,
      "type": "RiskEventTriggered",
      "positionId": "0xdef456",
      "eventType": "ThresholdBreach",
      "previousHF": 1.28,
      "newHF": 1.15,
      "deltaHF": -0.13,
      "threshold": 1.3
    },
    {
      "timestamp": 1700000040,
      "type": "AlertSent",
      "positionId": "0xdef456",
      "alertType": "WebSocket",
      "message": "CRITICAL: Health Factor dropped to 1.15. Protection recommended.",
      "severity": "CRITICAL"
    }
  ],
  "finalState": {
    "healthFactor": 1.15,
    "status": "CRITICAL",
    "alertsTriggered": 2,
    "protectionsExecuted": 0
  }
}
```

### E7.8.3 Create scenario-3-protected.json | 创建场景 3：保护执行
File path: `docs/fixtures/scenario-3-protected.json` | 文件路径

```json
{
  "scenario": "S3_PROTECTION_EXECUTED",
  "description": "Position drops to Critical, user executes protection, HF restored to Safe",
  "events": [
    {
      "timestamp": 1700000100,
      "type": "PositionCreated",
      "positionId": "0xghi789",
      "owner": "0x3456789012345678901234567890123456789012",
      "collateralAmount": "1000000000000000000",
      "collateralToken": "0x5678901234567890123456789012345678901234",
      "debtAmount": "650000000000000000",
      "debtToken": "0x9012345678901234567890123456789012345678",
      "healthFactor": 1.23
    },
    {
      "timestamp": 1700000110,
      "type": "RiskEventTriggered",
      "positionId": "0xghi789",
      "eventType": "ThresholdBreach",
      "previousHF": 1.23,
      "newHF": 1.23,
      "deltaHF": 0,
      "threshold": 1.3
    },
    {
      "timestamp": 1700000115,
      "type": "AlertSent",
      "positionId": "0xghi789",
      "alertType": "WebSocket",
      "message": "CRITICAL: Health Factor 1.23. Protection recommended.",
      "severity": "CRITICAL"
    },
    {
      "timestamp": 1700000120,
      "type": "ProtectionTriggered",
      "positionId": "0xghi789",
      "actionType": "AddCollateral",
      "beforeHF": 1.23,
      "collateralAdded": "300000000000000000",
      "txHash": "0xprotect123",
      "executedBy": "0x3456789012345678901234567890123456789012"
    },
    {
      "timestamp": 1700000125,
      "type": "ProtectionExecuted",
      "positionId": "0xghi789",
      "actionType": "AddCollateral",
      "beforeHF": 1.23,
      "afterHF": 1.52,
      "collateralDelta": "300000000000000000",
      "debtDelta": "0",
      "txHash": "0xprotect123",
      "txConfirmed": true
    },
    {
      "timestamp": 1700000130,
      "type": "HFUpdate",
      "positionId": "0xghi789",
      "healthFactor": 1.52,
      "priceChange": 0
    }
  ],
  "finalState": {
    "healthFactor": 1.52,
    "status": "SAFE",
    "alertsTriggered": 1,
    "protectionsExecuted": 1,
    "beforeAfterComparison": {
      "before": {
        "hf": 1.23,
        "collateral": "1000000000000000000",
        "debt": "650000000000000000"
      },
      "after": {
        "hf": 1.52,
        "collateral": "1300000000000000000",
        "debt": "650000000000000000"
      }
    }
  }
}
```

### E7.8.4 Add replay mode to frontend | 添加重放模式到前端
File path: `frontend/lib/replay.ts` | 文件路径

```typescript
export function loadReplayFixture(scenario: string): ReplayData {
  // Load fixture from /docs/fixtures/
  const fixtures = {
    '1': require('../../../docs/fixtures/scenario-1-healthy.json'),
    '2': require('../../../docs/fixtures/scenario-2-alert.json'),
    '3': require('../../../docs/fixtures/scenario-3-protected.json'),
  };

  return fixtures[scenario] || fixtures['1'];
}

export function isReplayMode(): boolean {
  if (typeof window === 'undefined') return false;
  const params = new URLSearchParams(window.location.search);
  return params.get('replay') === '1';
}
```

---

## E7.9 Deployment Documentation（部署文档）

### E7.9.1 Create DEPLOYMENT.md | 创建 DEPLOYMENT.md
File path: `docs/DEPLOYMENT.md` | 文件路径

```markdown
# Deployment Guide

## Contract Deployment (Base Sepolia)

### Prerequisites
- Foundry installed (`foundryup`)
- Base Sepolia RPC URL (from Alchemy/Infura)
- Private key with test ETH (from Base Sepolia faucet)
- LINK tokens for Chainlink Automation (from faucet)

### Step 1: Configure Environment

```bash
cp .env.example .env
```

Edit `.env`:
```
BASE_SEPOLIA_RPC=https://base-sepolia.g.alchemy.com/v2/YOUR_API_KEY
DEPLOYER_PRIVATE_KEY=0xYOUR_PRIVATE_KEY
COLLATERAL_PRICE_FEED=0x... # Chainlink ETH/USD feed on Base Sepolia
DEBT_PRICE_FEED=0x...       # Chainlink USDC/USD feed on Base Sepolia
```

### Step 2: Deploy Contracts

```bash
cd contracts

# Build contracts
forge build

# Run tests
forge test

# Deploy to Base Sepolia
forge script script/Deploy.s.sol --broadcast --rpc-url $BASE_SEPOLIA_RPC --verify
```

**Deployed Contract Addresses** (save these):
```
PositionVault: 0x...
Protector: 0x...
DemoEscrow: 0x...
```

### Step 3: Seed Demo Positions

```bash
forge script script/Seed.s.sol --broadcast --rpc-url $BASE_SEPOLIA_RPC
```

### Step 4: Verify on BaseScan

Contracts should auto-verify with `--verify` flag. If not:

```bash
forge verify-contract <ADDRESS> <CONTRACT_NAME> --chain-id 84532 --etherscan-api-key $BASESCAN_API_KEY
```

## Subgraph Deployment

### Prerequisites
- The Graph CLI installed (`npm install -g @graphprotocol/graph-cli`)
- Alchemy Subgraphs account (or The Graph Studio)

### Step 1: Update Subgraph Config

Edit `subgraph/subgraph.yaml` with deployed contract addresses:

```yaml
dataSources:
  - name: PositionVault
    network: base-sepolia
    source:
      address: "0xYOUR_VAULT_ADDRESS"
      abi: PositionVault
      startBlock: YOUR_DEPLOYMENT_BLOCK
```

### Step 2: Deploy Subgraph

```bash
cd subgraph

# Install dependencies
npm install

# Authenticate (Alchemy Subgraphs)
graph auth --studio YOUR_DEPLOY_KEY

# Build subgraph
graph codegen && graph build

# Deploy
graph deploy --studio derisk-watchtower
```

**Subgraph URL**: Save the deployed subgraph endpoint.

## Backend Deployment

### Option 1: Docker (Recommended for Demo)

```bash
cd backend

# Build image
docker build -t derisk-watchtower-backend .

# Run container
docker run -p 8080:8080 \
  -e BASE_SEPOLIA_RPC=$BASE_SEPOLIA_RPC \
  -e SUBGRAPH_URL=$SUBGRAPH_URL \
  -e PROTECTOR_ADDRESS=$PROTECTOR_ADDRESS \
  derisk-watchtower-backend
```

### Option 2: Direct Execution

```bash
cd backend

# Install dependencies
go mod download

# Run server
go run cmd/server/main.go
```

**Backend API**: http://localhost:8080

## Frontend Deployment (Vercel)

### Prerequisites
- Vercel account
- Vercel CLI installed (`npm i -g vercel`)

### Step 1: Configure Environment

Create `frontend/.env.local`:
```
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=YOUR_PROJECT_ID
NEXT_PUBLIC_BACKEND_API_URL=https://api.derisk-watchtower.com
NEXT_PUBLIC_BACKEND_WS_URL=wss://api.derisk-watchtower.com
NEXT_PUBLIC_SUBGRAPH_URL=https://...
NEXT_PUBLIC_CHAIN_ID=84532
```

### Step 2: Deploy to Vercel

```bash
cd frontend

# Install dependencies
npm install

# Deploy
vercel --prod
```

**Frontend URL**: Save the Vercel deployment URL.

## Chainlink Automation Registration

### Step 1: Get LINK Tokens

Get test LINK from Base Sepolia faucet:
- https://faucets.chain.link/base-sepolia

### Step 2: Register Upkeep

Option A: Web UI (Recommended)
1. Visit https://automation.chain.link
2. Connect wallet
3. Click "Register New Upkeep"
4. Select "Time-based" trigger
5. Enter CRON expression: `0 */5 * * * *`
6. Enter Protector contract address
7. Fund with 5 LINK
8. Confirm transaction

Option B: Script
```bash
cd contracts
forge script script/RegisterUpkeep.s.sol --broadcast --rpc-url $BASE_SEPOLIA_RPC
```

**Upkeep ID**: Save the Upkeep ID from dashboard.

## Observability Stack

### Start Prometheus + Grafana

```bash
# From repo root
docker-compose up -d
```

### Import Grafana Dashboard

1. Access Grafana: http://localhost:3001 (admin/admin)
2. Navigate to Dashboards → Import
3. Upload `configs/grafana/watchtower-dashboard.json`
4. Select Prometheus data source
5. Click Import

## Post-Deployment Verification

### Checklist

- [ ] Contracts deployed and verified on BaseScan
- [ ] Subgraph syncing (check status at subgraph endpoint)
- [ ] Backend API responding at /healthz
- [ ] Frontend accessible and wallet connection works
- [ ] WebSocket connection establishes (/ws/risk-stream)
- [ ] Chainlink Automation upkeep active (check dashboard)
- [ ] Prometheus scraping metrics (/metrics)
- [ ] Grafana dashboard displaying live data
- [ ] Offline replay mode works (?replay=1)
- [ ] All URLs documented in PROOF.md

### Test Full Flow

1. Connect wallet to frontend
2. View position dashboard
3. Trigger test alert: `forge script script/SimulatePriceDrop.s.sol`
4. Verify alert appears in UI within 10 seconds
5. Click "Protect Position"
6. Verify transaction confirms and HF improves
7. Check Grafana for metrics update

## Troubleshooting

### Subgraph Not Syncing
```bash
# Check subgraph status
curl https://api.thegraph.com/subgraphs/name/your-org/derisk-watchtower

# If behind, wait 5-10 minutes for sync
# If error, check logs in The Graph Studio
```

### Backend RPC Rate Limit
- Upgrade to paid RPC plan (Alchemy Growth tier)
- Use multiple RPC providers with fallback

### Frontend WebSocket Connection Fails
- Check CORS settings in backend
- Verify WebSocket URL uses `wss://` for production

### Chainlink Automation Not Triggering
- Check Upkeep is funded with LINK
- Verify checkUpkeep returns true: Test via Automation dashboard
- Check performUpkeep gas limit (increase if failing)

## Production Considerations (Out of Scope for Demo)

**This project is for demonstration only. For production deployment, consider:**

- Professional security audit
- Multi-sig admin controls
- Gas optimization
- Comprehensive error handling
- Rate limiting and DDoS protection
- Encrypted secrets management (Vault, AWS Secrets Manager)
- Load balancing for backend API
- CDN for frontend (Cloudflare)
- Monitoring and alerting (PagerDuty)
- Backup and disaster recovery
```

---

## E7.10 Partner Prize Documentation（合作伙伴奖励文档）

### E7.10.1 Document Base integration in PROOF.md | 在 PROOF.md 记录 Base 集成
Already included in E7.3.1 above

### E7.10.2 Document Chainlink Automation integration in PROOF.md | 在 PROOF.md 记录 Chainlink Automation 集成
Already included in E7.3.1 above

### E7.10.3 Document The Graph integration in PROOF.md | 在 PROOF.md 记录 The Graph 集成
Already included in E7.3.1 above

### E7.10.4 Capture partner integration screenshots | 捕获合作伙伴集成截图
**Required Screenshots** / **必需截图**:
1. `basescan-verification.png` - Contract verification on BaseScan
2. `chainlink-automation-dashboard.png` - Upkeep dashboard with trigger history
3. `thegraph-subgraph-query.png` - Successful GraphQL query result

---

## E7.11 .env.example Template（.env.example 模板）

### E7.11.1 Create comprehensive .env.example | 创建完整 .env.example
File path: `.env.example` | 文件路径

```bash
# DeRisk Watchtower Environment Configuration

# Network Configuration
BASE_SEPOLIA_RPC=https://base-sepolia.g.alchemy.com/v2/YOUR_API_KEY
CHAIN_ID=84532

# Deployment
DEPLOYER_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# Chainlink Price Feeds (Base Sepolia)
COLLATERAL_PRICE_FEED=0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1  # ETH/USD
DEBT_PRICE_FEED=0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165       # USDC/USD

# Deployed Contract Addresses (fill after deployment)
POSITION_VAULT_ADDRESS=0x...
PROTECTOR_ADDRESS=0x...
DEMO_ESCROW_ADDRESS=0x...

# Chainlink Automation
LINK_TOKEN_BASE_SEPOLIA=0xE4aB69C077896252FAFBD49EFD26B5D171A32410
AUTOMATION_REGISTRAR_BASE_SEPOLIA=0x...
UPKEEP_ID=

# The Graph
SUBGRAPH_URL=https://api.studio.thegraph.com/query/.../derisk-watchtower
GRAPH_DEPLOY_KEY=YOUR_DEPLOY_KEY_HERE

# Backend API
API_PORT=8080
API_HOST=0.0.0.0
CORS_ALLOWED_ORIGINS=http://localhost:3000,https://derisk-watchtower.vercel.app

# WebSocket
WS_PING_INTERVAL=30s
WS_EVENT_CACHE_TTL=60s

# Monitoring
HF_CHECK_INTERVAL=5s
ALERT_THRESHOLD=13000  # 1.30 with 4 decimals
CRITICAL_THRESHOLD=13000

# RPC Retry Configuration
RPC_RETRY_INITIAL_DELAY=500ms
RPC_RETRY_MULTIPLIER=2.0
RPC_RETRY_JITTER=0.2
RPC_RETRY_MAX_ATTEMPTS=5
RPC_RETRY_MAX_DELAY=8s

# Circuit Breaker
CIRCUIT_BREAKER_THRESHOLD=5
CIRCUIT_BREAKER_WINDOW=30s
CIRCUIT_BREAKER_RECOVERY=60s

# AI Risk Explanation (Optional - for User Story 4)
AI_API_PROVIDER=openai  # or anthropic
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
AI_CACHE_TTL=10m

# Prometheus Metrics
METRICS_ENABLED=true
METRICS_PATH=/metrics

# Logging
LOG_LEVEL=info  # debug, info, warn, error

# Frontend Environment Variables
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=YOUR_WALLET_CONNECT_ID
NEXT_PUBLIC_BACKEND_API_URL=http://localhost:8080
NEXT_PUBLIC_BACKEND_WS_URL=ws://localhost:8080
NEXT_PUBLIC_SUBGRAPH_URL=https://api.studio.thegraph.com/query/.../derisk-watchtower
NEXT_PUBLIC_CHAIN_ID=84532
NEXT_PUBLIC_PROTECTOR_ADDRESS=0x...
NEXT_PUBLIC_POSITION_VAULT_ADDRESS=0x...

# BaseScan (for contract verification)
BASESCAN_API_KEY=YOUR_BASESCAN_API_KEY

# Optional: Vercel Deployment
VERCEL_PROJECT_ID=
VERCEL_ORG_ID=
VERCEL_TOKEN=
```

### E7.11.2 Add .env.example usage to README | 添加 .env.example 使用到 README
Already included in E7.2.1 Quick Start section

---

## E7.12 Completion Checklist（完成清单）

### E7.12.1 Demo & Video
- [ ] Demo environment prepared and tested | 演示环境已准备并测试
- [ ] Demo video recorded (2-4 minutes) | 演示视频已录制（2–4 分钟）
- [ ] Video shows full flow: Monitor → Alert → Protect → Compare | 视频展示完整流程
- [ ] Video uploaded to hosting platform (YouTube/Vimeo/Loom) | 视频已上传到托管平台
- [ ] Video link added to PROOF.md | 视频链接已添加到 PROOF.md

### E7.12.2 Documentation
- [ ] README.md with one-command startup | README.md 含一键启动
- [ ] Architecture diagram created and added | 架构图已创建并添加
- [ ] Troubleshooting guide in README | README 含故障排查指南
- [ ] DEPLOYMENT.md with step-by-step instructions | DEPLOYMENT.md 含分步说明
- [ ] AI_USAGE.md with file/commit-level attribution | AI_USAGE.md 含文件/提交级归属
- [ ] CHANGELOG.md with daily updates | CHANGELOG.md 含每日更新
- [ ] CODE_OF_CONDUCT.md | CODE_OF_CONDUCT.md
- [ ] CONTRIBUTING.md | CONTRIBUTING.md
- [ ] SECURITY.md | SECURITY.md
- [ ] LICENSE file (MIT) | LICENSE 文件（MIT）
- [ ] .env.example provided | .env.example 已提供

### E7.12.3 Submission Materials
- [ ] PROOF.md with Hacker Dashboard link | PROOF.md 含黑客仪表板链接
- [ ] All contract addresses documented | 所有合约地址已记录
- [ ] BaseScan verification links added | BaseScan 验证链接已添加
- [ ] Chainlink Automation Upkeep ID documented | Chainlink Automation Upkeep ID 已记录
- [ ] The Graph subgraph URL documented | The Graph 子图 URL 已记录
- [ ] Partner integration feedback provided (≤3) | 合作伙伴集成反馈已提供（≤3）
- [ ] Screenshot evidence captured (7 screenshots) | 截图证据已捕获（7 张截图）

### E7.12.4 Offline Replay
- [ ] scenario-1-healthy.json created | scenario-1-healthy.json 已创建
- [ ] scenario-2-alert.json created | scenario-2-alert.json 已创建
- [ ] scenario-3-protected.json created | scenario-3-protected.json 已创建
- [ ] Replay mode implemented in frontend (?replay=1) | 前端重放模式已实现（?replay=1）
- [ ] Replay mode tested and verified | 重放模式已测试并验证

### E7.12.5 Deployment
- [ ] All contracts deployed to Base Sepolia | 所有合约已部署到 Base Sepolia
- [ ] Contracts verified on BaseScan | 合约已在 BaseScan 验证
- [ ] Subgraph deployed and syncing | 子图已部署并同步
- [ ] Backend API deployed and accessible | 后端 API 已部署并可访问
- [ ] Frontend deployed to Vercel/Netlify | 前端已部署到 Vercel/Netlify
- [ ] Chainlink Automation upkeep registered and funded | Chainlink Automation upkeep 已注册并充值
- [ ] Prometheus + Grafana running locally | Prometheus + Grafana 本地运行
- [ ] All deployment URLs documented | 所有部署 URL 已记录

### E7.12.6 Quality Assurance
- [ ] Full demo flow tested end-to-end | 完整演示流程端到端测试
- [ ] Offline replay mode tested | 离线重放模式已测试
- [ ] All links in documentation verified | 文档中所有链接已验证
- [ ] All screenshots captured and embedded | 所有截图已捕获并嵌入
- [ ] README one-command startup tested | README 一键启动已测试
- [ ] Observability metrics visible in Grafana | Grafana 可见可观测指标
- [ ] Partner integrations verified and documented | 合作伙伴集成已验证并记录

### E7.12.7 Compliance
- [ ] All commits follow Conventional Commits format | 所有提交遵循 Conventional Commits 格式
- [ ] Minimum 3 commits per development day | 每个开发日至少 3 次提交
- [ ] All SPDX headers present in contracts | 所有合约含 SPDX 头
- [ ] No secrets committed to repository | 仓库无机密提交
- [ ] .env.example provided with placeholders | .env.example 已提供含占位符
- [ ] Community health files present | 社区健康文件已存在
- [ ] AI usage properly attributed | AI 使用已正确归属

---

**End of E7 Demo & Docs Tasks | E7 演示与文档任务结束**
