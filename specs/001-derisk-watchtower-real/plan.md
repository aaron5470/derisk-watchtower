# Implementation Plan: DeRisk Watchtower
# 实施计划：DeRisk 瞭望塔

**Branch**: `001-derisk-watchtower-real` | **Date**: 2025-10-14 | **Spec**: [spec.md](./spec.md)
**分支**：`001-derisk-watchtower-real` | **日期**：2025-10-14 | **规格**：[spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-derisk-watchtower-real/spec.md`
**输入**：来自 `/specs/001-derisk-watchtower-real/spec.md` 的功能规格书

## Summary / 概要

**[EN]** DeRisk Watchtower is a real-time DeFi position monitoring and protection system for ETHOnline 2025. The system monitors user lending positions on Base Sepolia, detects liquidation risk via Health Factor (HF) calculation, sends real-time alerts via WebSocket, and provides one-click protection through automated contract execution. The technical approach combines Foundry smart contracts (PositionVault + Protector), The Graph subgraph indexing, Chainlink Automation for trigger execution, a Go-based API with WebSocket support, Next.js + wagmi/viem frontend, and Prometheus + Grafana observability stack.

**[ZH]** DeRisk 瞭望塔是 ETHOnline 2025 的实时 DeFi 头寸监控与保护系统。系统在 Base Sepolia 上监控用户借贷头寸，通过健康系数（HF）计算检测清算风险，经 WebSocket 发送实时警报，并通过自动化合约执行提供一键保护。技术方案结合 Foundry 智能合约（PositionVault + Protector）、The Graph 子图索引、Chainlink Automation 触发执行、基于 Go 的 API（含 WebSocket 支持）、Next.js + wagmi/viem 前端及 Prometheus + Grafana 可观测性栈。

**Core User Flow** / **核心用户流程**:
1. User connects wallet → View HF & position dashboard (≤3 clicks)
1. 用户连接钱包 → 查看 HF 与头寸仪表盘（≤3 次点击）
2. Backend monitors HF every 5s; alerts trigger when HF ≤ 1.3 (P95 ≤ 10s)
2. 后端每 5 秒监控 HF；HF ≤ 1.3 时触发警报（P95 ≤ 10 秒）
3. User clicks "Protect Position" → Protector contract adds collateral from demo escrow (5s execution)
3. 用户点击"保护头寸" → Protector 合约从演示托管添加抵押（5 秒执行）
4. UI displays before/after comparison within 5s of transaction confirmation
4. 交易确认后 5 秒内 UI 展示前后对比
5. Chainlink Automation (CRON 5 min) provides automatic protection fallback
5. Chainlink Automation（CRON 5 分钟）提供自动保护回退
6. Judges/reviewers can reproduce via subgraph queries, /metrics endpoint, and ?replay=1 offline mode
6. 评委/审查者可通过子图查询、/metrics 端点与 ?replay=1 离线模式复现

## Technical Context / 技术上下文

**Language/Version** / **语言/版本**:
- **[EN]** Solidity 0.8.20+ (Foundry), Go 1.21+, TypeScript 5.x (Next.js 14)
- **[ZH]** Solidity 0.8.20+（Foundry）、Go 1.21+、TypeScript 5.x（Next.js 14）

**Primary Dependencies** / **主要依赖**:
- **[EN]** Smart Contracts: Foundry (forge/anvil/cast), OpenZeppelin Contracts (ReentrancyGuard, Pausable)
- **[ZH]** 智能合约：Foundry（forge/anvil/cast）、OpenZeppelin Contracts（ReentrancyGuard、Pausable）
- **[EN]** Indexing: The Graph (Graph Node / hosted alternative like Alchemy Subgraphs)
- **[ZH]** 索引：The Graph（Graph 节点 / Alchemy Subgraphs 等托管替代）
- **[EN]** Automation: Chainlink Automation (CRON + conditional triggers on Base Sepolia)
- **[ZH]** 自动化：Chainlink Automation（CRON + Base Sepolia 条件触发）
- **[EN]** Backend: Go (chi router, gorilla/websocket, prometheus/client_golang, viem-go or go-ethereum)
- **[ZH]** 后端：Go（chi 路由、gorilla/websocket、prometheus/client_golang、viem-go 或 go-ethereum）
- **[EN]** Frontend: Next.js 14 (App Router), wagmi 2.x, viem 2.x, TanStack Query, shadcn/ui (optional)
- **[ZH]** 前端：Next.js 14（App Router）、wagmi 2.x、viem 2.x、TanStack Query、shadcn/ui（可选）
- **[EN]** Observability: Prometheus (scrape /metrics), Grafana (dashboards as JSON)
- **[ZH]** 可观测性：Prometheus（抓取 /metrics）、Grafana（仪表板为 JSON）

**Storage** / **存储**:
- **[EN]** On-chain: Base Sepolia blockchain (Position & RiskEvent state in contracts + events)
- **[ZH]** 链上：Base Sepolia 区块链（Position 与 RiskEvent 状态存于合约 + 事件）
- **[EN]** Indexed: The Graph subgraph (Position, RiskEvent entities queryable via GraphQL)
- **[ZH]** 索引：The Graph 子图（Position、RiskEvent 实体可通过 GraphQL 查询）
- **[EN]** Ephemeral: Go backend in-memory cache for recent events (60s window for WebSocket replay)
- **[ZH]** 临时：Go 后端内存缓存近期事件（60 秒窗口用于 WebSocket 回放）
- **[EN]** Static: docs/fixtures/*.json for offline replay mode (?replay=1)
- **[ZH]** 静态：docs/fixtures/*.json 用于离线回放模式（?replay=1）

**Testing** / **测试**:
- **[EN]** Smart Contracts: Foundry test suite (forge test), unit + integration tests with mock price feeds
- **[ZH]** 智能合约：Foundry 测试套件（forge test），单元 + 集成测试（含模拟价格预言机）
- **[EN]** Backend: Go testing package (go test), table-driven tests for HF calculation, WebSocket replay logic
- **[ZH]** 后端：Go testing 包（go test），表驱动测试用于 HF 计算、WebSocket 回放逻辑
- **[EN]** Frontend: Vitest (unit), Playwright (E2E critical flows: connect → alert → protect)
- **[ZH]** 前端：Vitest（单元）、Playwright（E2E 关键流程：连接 → 警报 → 保护）
- **[EN]** Subgraph: Graph CLI test helpers, manual query validation against deployed contracts
- **[ZH]** 子图：Graph CLI 测试辅助工具，对已部署合约手动查询验证

**Target Platform** / **目标平台**:
- **[EN]** Blockchain: Base Sepolia testnet (ChainID 84532)
- **[ZH]** 区块链：Base Sepolia 测试网（ChainID 84532）
- **[EN]** Backend: Linux server (Docker container), Vercel Serverless Functions (if API split), or single VPS
- **[ZH]** 后端：Linux 服务器（Docker 容器）、Vercel Serverless Functions（如 API 拆分）或单一 VPS
- **[EN]** Frontend: Vercel/Netlify deployment, desktop browsers (Chrome, Firefox, Safari)
- **[ZH]** 前端：Vercel/Netlify 部署，桌面浏览器（Chrome、Firefox、Safari）
- **[EN]** Observability: Local Docker Compose (Prometheus + Grafana) for dev/demo
- **[ZH]** 可观测性：本地 Docker Compose（Prometheus + Grafana）用于开发/演示

**Project Type** / **项目类型**: **Web application** (backend + frontend + contracts)
**项目类型**：**Web 应用**（后端 + 前端 + 合约）

**Performance Goals** / **性能目标**:
- **[EN]** Alert Latency (P95): Detection → UI display ≤ 10 seconds
- **[ZH]** 警报延迟（P95）：检测 → UI 展示 ≤ 10 秒
- **[EN]** Protection Execution: User click → transaction confirmation ≤ 5 seconds
- **[ZH]** 保护执行：用户点击 → 交易确认 ≤ 5 秒
- **[EN]** HF Calculation: Backend recalculation every 5s, UI refresh every 3s
- **[ZH]** HF 计算：后端每 5 秒重算，UI 每 3 秒刷新
- **[EN]** WebSocket Push: Server-side event → client receive ≤ 2 seconds
- **[ZH]** WebSocket 推送：服务器事件 → 客户端接收 ≤ 2 秒
- **[EN]** API Response (non-blockchain): ≤ 2 seconds under normal conditions
- **[ZH]** API 响应（非区块链）：正常条件下 ≤ 2 秒
- **[EN]** Concurrent Monitoring: Support 10+ positions without degradation (demo scope: ~30 positions total)
- **[ZH]** 并发监控：支持 10 个以上头寸无性能下降（演示范围：共约 30 个头寸）

**Constraints** / **约束**:
- **[EN]** Demo Duration: Complete flow must be demonstrable in 2-4 minutes, ≤8 clicks
- **[ZH]** 演示时长：完整流程必须可在 2–4 分钟、≤8 次点击内演示
- **[EN]** Network: Base Sepolia only (no mainnet, no multi-chain)
- **[ZH]** 网络：仅 Base Sepolia（无主网、无多链）
- **[EN]** Data Freshness: Display "Stale" indicator if data >60s old; disable protection if >10s stale
- **[ZH]** 数据新鲜度：数据 >60 秒时显示"陈旧"指示器；>10 秒陈旧时禁用保护
- **[EN]** Security: Testnet-only, least-privilege, .env secrets, OpenZeppelin patterns (ReentrancyGuard, Pausable)
- **[ZH]** 安全：仅测试网、最小权限、.env 机密、OpenZeppelin 模式（ReentrancyGuard、Pausable）
- **[EN]** Partner Prizes: Maximum 3 integrations (Base, Chainlink, The Graph)
- **[ZH]** 合作伙伴奖励：最多 3 个集成（Base、Chainlink、The Graph）
- **[EN]** Observability: /metrics endpoint required, Grafana JSON export in configs/grafana/
- **[ZH]** 可观测性：/metrics 端点必需，Grafana JSON 导出置于 configs/grafana/

**Scale/Scope** / **规模/范围**:
- **[EN]** Positions: Max 8 per user, ~30 total across all demo users
- **[ZH]** 头寸：每用户最多 8 个，所有演示用户共约 30 个
- **[EN]** Codebase: Estimated 3k-5k LoC (contracts 500, backend 1.5k, frontend 1.5k, subgraph 300, tests 1k)
- **[ZH]** 代码库：估计 3k–5k 行代码（合约 500、后端 1.5k、前端 1.5k、子图 300、测试 1k）
- **[EN]** Demo Scenarios: 3 offline replay fixtures (healthy→safe, near-liquidation alert, protection executed)
- **[ZH]** 演示场景：3 个离线回放数据（健康→安全、临近清算警报、保护已执行）
- **[EN]** AI Risk Explanations: 120-160 words (EN+ZH bilingual), structure: Signal, Reasoning, Confidence, Next Step
- **[ZH]** AI 风险解释：120–160 字（英中双语），结构：信号、推理、置信度、下一步

## Constitution Check / 宪法检查

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*
*门禁：Phase 0 研究前必须通过。Phase 1 设计后重新检查。*

| Principle / 原则 | Status / 状态 | Notes / 备注 |
|------------------|----------------|---------------|
| **I. Hackathon Development Integrity** / **I. 黑客松开发完整性** | ✅ **PASS** / **通过** | All code developed from scratch during hackathon. External libraries (OpenZeppelin, wagmi, chi) permitted with clear attribution in README. No private pre-hackathon code reuse. / 所有代码在黑客松期间从零开发。允许外部库（OpenZeppelin、wagmi、chi），README 明确归属。无黑客松前私有代码复用。 |
| **II. AI Transparency & Human Oversight** / **II. AI 透明度与人类监督** | ✅ **PASS** / **通过** | AI_USAGE.md will log all AI-assisted contributions (file/commit granularity). Critical logic (HF calculation, Protector contract, WebSocket replay) will be explicitly reviewed and annotated. / AI_USAGE.md 将记录所有 AI 协助贡献（文件/提交粒度）。关键逻辑（HF 计算、Protector 合约、WebSocket 回放）将明确审查并标注。 |
| **III. Version Control Discipline** / **III. 版本控制纪律** | ✅ **PASS** / **通过** | Trunk-based development on `main`. Feature branch `001-derisk-watchtower-real` short-lived, merged frequently. Conventional Commits format enforced. Min 3 commits/day. CHANGELOG.md updated daily. / 基于 `main` 的主干开发。功能分支 `001-derisk-watchtower-real` 短生命周期，频繁合并。强制 Conventional Commits 格式。每日至少 3 次提交。CHANGELOG.md 每日更新。 |
| **IV. Security & Compliance Standards** / **IV. 安全与合规标准** | ✅ **PASS** / **通过** | Base Sepolia only. Least-privilege design. .env secrets never committed, .env.example provided. OpenZeppelin ReentrancyGuard & Pausable used. SPDX headers in contracts. Chainlink Automation failure modes documented with manual override. / 仅 Base Sepolia。最小权限设计。.env 机密永不提交，提供 .env.example。使用 OpenZeppelin ReentrancyGuard 与 Pausable。合约含 SPDX 头。Chainlink Automation 失败模式记录，含手动覆盖。 |
| **V. Observability & Metrics** / **V. 可观测性与指标** | ✅ **PASS** / **通过** | /metrics endpoint exposes Prometheus-compatible metrics: `risk_event_trigger_total`, `protect_success_total`, `protect_failure_total`, `alert_latency_seconds`, `positions_monitored`. Grafana dashboard JSON in `configs/grafana/`. README includes one-command Docker Compose startup + export instructions. / /metrics 端点暴露 Prometheus 兼容指标：`risk_event_trigger_total`、`protect_success_total`、`protect_failure_total`、`alert_latency_seconds`、`positions_monitored`。Grafana 仪表板 JSON 置于 `configs/grafana/`。README 包含一键 Docker Compose 启动 + 导出说明。 |
| **Deliverables & Documentation** / **交付物与文档** | ✅ **PASS** / **通过** | README.md (one-command startup + demo walkthrough), AI_USAGE.md, CHANGELOG.md, docs/PROOF.md (Hacker Dashboard link), LICENSE (MIT), SPDX headers, community health files (CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md). Demo video 2-4 min. Deployed frontend URL. Partner integrations (≤3): Base, Chainlink, The Graph with documented usage & feedback in PROOF.md. / README.md（一键启动 + 演示步骤）、AI_USAGE.md、CHANGELOG.md、docs/PROOF.md（黑客仪表板链接）、LICENSE（MIT）、SPDX 头、社区健康文件（CODE_OF_CONDUCT.md、CONTRIBUTING.md、SECURITY.md）。演示视频 2–4 分钟。已部署前端 URL。合作伙伴集成（≤3）：Base、Chainlink、The Graph，PROOF.md 记录使用与反馈。 |

**Constitution Gate Result** / **宪法门禁结果**: ✅ **GREEN** / **绿灯** - All principles satisfied. Proceed to Phase 0 research. / 所有原则满足。继续 Phase 0 研究。

## Project Structure / 项目结构

### Documentation (this feature) / 文档（本功能）

```
specs/001-derisk-watchtower-real/
├── spec.md              # Feature specification (already complete)
│                        # 功能规格书（已完成）
├── plan.md              # This file (/speckit.plan output)
│                        # 本文件（/speckit.plan 输出）
├── research.md          # Phase 0 output (technology decisions, patterns, best practices)
│                        # Phase 0 输出（技术决策、模式、最佳实践）
├── data-model.md        # Phase 1 output (entities, schema, relationships)
│                        # Phase 1 输出（实体、模式、关系）
├── quickstart.md        # Phase 1 output (one-command setup guide for developers)
│                        # Phase 1 输出（开发者一键设置指南）
├── contracts/           # Phase 1 output (OpenAPI/GraphQL contracts)
│   ├── api.openapi.yaml # REST API contract for Go backend
│   │                    # Go 后端 REST API 契约
│   └── subgraph.schema.graphql # The Graph schema (also copied to subgraph/)
│                        # The Graph 模式（同时复制到 subgraph/）
└── tasks.md             # Phase 2 output (/speckit.tasks - NOT created by /speckit.plan)
                         # Phase 2 输出（/speckit.tasks - 非 /speckit.plan 创建）
```

### Source Code (repository root) / 源代码（仓库根目录）

**Structure Decision** / **结构决策**: **Web application** (backend + frontend + contracts) due to distinct Go API server, Next.js frontend, and Solidity smart contracts. Subgraph treated as separate service.
**结构决策**：**Web 应用**（后端 + 前端 + 合约），因有独立 Go API 服务器、Next.js 前端与 Solidity 智能合约。子图视为独立服务。

```
derisk-watchtower/
├── contracts/                     # Smart contracts (Foundry project)
│   │                              # 智能合约（Foundry 项目）
│   ├── src/
│   │   ├── PositionVault.sol      # User position state & HF tracking
│   │   │                          # 用户头寸状态与 HF 跟踪
│   │   ├── Protector.sol          # Protection executor (adds collateral from escrow)
│   │   │                          # 保护执行器（从托管添加抵押）
│   │   ├── DemoEscrow.sol         # Pre-funded test token escrow for demos
│   │   │                          # 预充测试代币托管，用于演示
│   │   └── interfaces/
│   │       ├── IChainlinkPriceFeed.sol # Chainlink price feed interface
│   │       │                          # Chainlink 价格预言机接口
│   │       └── IProtector.sol         # Protector interface for automation
│   │                                  # 自动化用 Protector 接口
│   ├── test/
│   │   ├── PositionVault.t.sol    # Unit + integration tests
│   │   │                          # 单元 + 集成测试
│   │   ├── Protector.t.sol
│   │   └── mocks/                 # Mock price feeds, tokens
│   │                              # 模拟价格预言机、代币
│   ├── script/
│   │   ├── Deploy.s.sol           # Deployment script for Base Sepolia
│   │   │                          # Base Sepolia 部署脚本
│   │   └── Seed.s.sol             # Seed demo positions & escrow
│   │                              # 种子演示头寸与托管
│   └── foundry.toml               # Foundry config (Base Sepolia RPC, etc.)
│                                  # Foundry 配置（Base Sepolia RPC 等）
│
├── subgraph/                      # The Graph indexing
│   │                              # The Graph 索引
│   ├── schema.graphql             # GraphQL schema (Position, RiskEvent entities)
│   │                              # GraphQL 模式（Position、RiskEvent 实体）
│   ├── subgraph.yaml              # Subgraph manifest (contract addresses, events)
│   │                              # 子图清单（合约地址、事件）
│   ├── src/
│   │   └── mapping.ts             # Event handler mappings (AssemblyScript)
│   │                              # 事件处理器映射（AssemblyScript）
│   └── tests/                     # Subgraph unit tests (Graph CLI)
│                                  # 子图单元测试（Graph CLI）
│
├── backend/                       # Go API server + WebSocket
│   │                              # Go API 服务器 + WebSocket
│   ├── cmd/
│   │   └── server/
│   │       └── main.go            # Entry point: HTTP + WS server
│   │                              # 入口点：HTTP + WS 服务器
│   ├── internal/
│   │   ├── api/
│   │   │   ├── router.go          # chi router setup
│   │   │   │                      # chi 路由设置
│   │   │   ├── handlers/
│   │   │   │   ├── positions.go   # GET /api/positions?owner=...
│   │   │   │   ├── hf.go          # GET /api/hf/{address}
│   │   │   │   ├── health.go      # GET /healthz
│   │   │   │   ├── metrics.go     # GET /metrics (Prometheus)
│   │   │   │   └── ws.go          # WS /ws/risk-stream
│   │   │   └── middleware/
│   │   │       ├── cors.go
│   │   │       ├── logging.go
│   │   │       └── ratelimit.go   # Rate limiting + circuit breaker
│   │   │                          # 限流 + 熔断器
│   │   ├── services/
│   │   │   ├── monitor.go         # HF monitoring loop (every 5s)
│   │   │   │                      # HF 监控循环（每 5 秒）
│   │   │   ├── alerter.go         # Alert generation & WS broadcast
│   │   │   │                      # 警报生成与 WS 广播
│   │   │   ├── rpclient.go        # RPC client with retry/backoff
│   │   │   │                      # RPC 客户端含重试/退避
│   │   │   ├── subgraph.go        # GraphQL client for subgraph
│   │   │   │                      # 子图 GraphQL 客户端
│   │   │   └── replay.go          # Offline replay logic (?replay=1)
│   │   │                          # 离线回放逻辑（?replay=1）
│   │   ├── models/
│   │   │   ├── position.go        # Position struct
│   │   │   └── riskevent.go       # RiskEvent struct
│   │   └── config/
│   │       └── config.go          # Load .env, validate settings
│   │                              # 加载 .env，验证设置
│   ├── tests/
│   │   ├── monitor_test.go        # Table-driven tests for HF calc
│   │   │                          # HF 计算的表驱动测试
│   │   ├── websocket_test.go      # WS reconnect + replay tests
│   │   │                          # WS 重连 + 回放测试
│   │   └── integration/           # Integration tests with mock RPC
│   │                              # 与模拟 RPC 的集成测试
│   └── go.mod

│
├── frontend/                      # Next.js 14 App Router
│   │                              # Next.js 14 App Router
│   ├── app/
│   │   ├── layout.tsx             # Root layout (wagmi/viem providers)
│   │   │                          # 根布局（wagmi/viem 提供者）
│   │   ├── page.tsx               # Home: wallet connect prompt
│   │   │                          # 主页：钱包连接提示
│   │   └── dashboard/
│   │       └── page.tsx           # Position dashboard with HF display
│   │                              # 头寸仪表盘及 HF 显示
│   ├── components/
│   │   ├── wallet/
│   │   │   └── ConnectButton.tsx  # Wallet connection button (wagmi)
│   │   │                          # 钱包连接按钮（wagmi）
│   │   ├── positions/
│   │   │   ├── PositionCard.tsx   # Position card with HF indicator
│   │   │   │                      # 头寸卡片及 HF 指示器
│   │   │   ├── ProtectButton.tsx  # One-click protect action
│   │   │   │                      # 一键保护操作
│   │   │   └── Timeline.tsx       # RiskEvent timeline visualization
│   │   │                          # RiskEvent 时间线可视化
│   │   ├── alerts/
│   │   │   ├── RiskAlert.tsx      # Real-time alert banner (WS-driven)
│   │   │   │                      # 实时警报横幅（WS 驱动）
│   │   │   └── AlertToast.tsx     # Toast notifications
│   │   │                          # Toast 通知
│   │   └── ui/                    # shadcn/ui components (optional)
│   │                              # shadcn/ui 组件（可选）
│   ├── hooks/
│   │   ├── useWebSocket.ts        # WebSocket hook with auto-reconnect
│   │   │                          # WebSocket 钩子含自动重连
│   │   ├── usePositions.ts        # TanStack Query hook for positions
│   │   │                          # TanStack Query 钩子用于头寸
│   │   └── useProtect.ts          # Hook for Protector contract write
│   │                              # Protector 合约写入钩子
│   ├── lib/
│   │   ├── wagmi.ts               # wagmi config (Base Sepolia, connectors)
│   │   │                          # wagmi 配置（Base Sepolia、连接器）
│   │   ├── viem.ts                # viem public/wallet clients
│   │   │                          # viem 公共/钱包客户端
│   │   └── api.ts                 # Axios/fetch wrapper for backend API
│   │                              # 后端 API 的 Axios/fetch 包装
│   ├── tests/
│   │   ├── unit/                  # Vitest unit tests (hooks, utils)
│   │   │                          # Vitest 单元测试（钩子、工具）
│   │   └── e2e/                   # Playwright E2E tests (critical flows)
│   │                              # Playwright E2E 测试（关键流程）
│   ├── public/
│   │   └── fixtures/              # Offline replay JSON (S1, S2, S3)
│   │                              # 离线回放 JSON（S1、S2、S3）
│   └── package.json
│
├── configs/                       # Configuration files
│   │                              # 配置文件
│   ├── grafana/
│   │   └── watchtower-dashboard.json # Grafana dashboard export
│   │                                 # Grafana 仪表板导出
│   └── prometheus/
│       └── prometheus.yml         # Prometheus scrape config
│                                  # Prometheus 抓取配置
│
├── docs/                          # Documentation
│   │                              # 文档
│   ├── PROOF.md                   # Hacker Dashboard submission link + evidence
│   │                              # 黑客仪表板提交链接 + 证据
│   ├── fixtures/                  # Offline replay data (3 scenarios)
│   │   │                          # 离线回放数据（3 个场景）
│   │   ├── scenario-1-healthy.json
│   │   ├── scenario-2-alert.json
│   │   └── scenario-3-protected.json
│   └── architecture.png           # Optional: architecture diagram
│                                  # 可选：架构图
│
├── .github/                       # GitHub workflows & templates
│   │                              # GitHub 工作流与模板
│   ├── workflows/
│   │   ├── ci.yml                 # CI: test contracts, backend, frontend
│   │   │                          # CI：测试合约、后端、前端
│   │   └── deploy.yml             # Deploy subgraph + frontend (optional)
│   │                              # 部署子图 + 前端（可选）
│   ├── CODE_OF_CONDUCT.md
│   ├── CONTRIBUTING.md
│   └── SECURITY.md
│
├── docker-compose.yml             # Local dev stack: Prometheus + Grafana
│                                  # 本地开发栈：Prometheus + Grafana
├── .env.example                   # Env var placeholders (RPC, private keys, etc.)
│                                  # 环境变量占位符（RPC、私钥等）
├── README.md                      # One-command startup + demo walkthrough
│                                  # 一键启动 + 演示步骤
├── LICENSE                        # MIT License
│                                  # MIT 许可证
├── AI_USAGE.md                    # AI assistance log (file/commit granularity)
│                                  # AI 协助日志（文件/提交粒度）
└── CHANGELOG.md                   # Daily development log
                                   # 每日开发日志
```

## Complexity Tracking / 复杂度跟踪

*This section is intentionally empty as Constitution Check PASSED without violations requiring justification.*
*本节故意留空，因宪法检查通过，无需证明违规。*

| Violation / 违规 | Why Needed / 为何需要 | Simpler Alternative Rejected Because / 拒绝更简单替代方案的原因 |
|-------------------|------------------------|----------------------------------------------------------------|
| N/A               | N/A                    | N/A                                                            |

---

## Phase 0: Research & Technology Decisions / Phase 0：研究与技术决策

**[EN]** Phase 0 will produce `research.md` documenting all technology decisions, best practices, and integration patterns. The following unknowns must be resolved through targeted research:

**[ZH]** Phase 0 将产生 `research.md`，记录所有技术决策、最佳实践与集成模式。以下未知项必须通过针对性研究解决：

### Research Tasks / 研究任务

1. **Chainlink Price Feed Integration on Base Sepolia** / **Base Sepolia 上 Chainlink 价格预言机集成**
   - **[EN]** Research: Available price feed addresses for collateral/debt tokens on Base Sepolia, update frequency, staleness detection patterns
   - **[ZH]** 研究：Base Sepolia 上抵押/债务代币可用价格预言机地址、更新频率、陈旧检测模式
   - **[EN]** Output: Feed addresses, AggregatorV3Interface usage pattern, fallback strategies
   - **[ZH]** 输出：预言机地址、AggregatorV3Interface 使用模式、回退策略

2. **The Graph Subgraph Deployment Strategy** / **The Graph 子图部署策略**
   - **[EN]** Research: The Graph Network vs. hosted alternatives (Alchemy Subgraphs, Goldsky), deployment steps, latency expectations
   - **[ZH]** 研究：The Graph Network vs. 托管替代（Alchemy Subgraphs、Goldsky）、部署步骤、延迟预期
   - **[EN]** Output: Selected deployment target, CLI commands, staleness detection (lastSync tracking)
   - **[ZH]** 输出：选定部署目标、CLI 命令、陈旧检测（lastSync 跟踪）

3. **Chainlink Automation Configuration on Base Sepolia** / **Base Sepolia 上 Chainlink Automation 配置**
   - **[EN]** Research: Upkeep registration process, CRON trigger vs. conditional trigger, gas pricing, manual override patterns
   - **[ZH]** 研究：Upkeep 注册流程、CRON 触发 vs. 条件触发、Gas 定价、手动覆盖模式
   - **[EN]** Output: Upkeep ID registration steps, performUpkeep() interface implementation, fallback CLI script
   - **[ZH]** 输出：Upkeep ID 注册步骤、performUpkeep() 接口实现、回退 CLI 脚本

4. **Go WebSocket Best Practices** / **Go WebSocket 最佳实践**
   - **[EN]** Research: gorilla/websocket patterns, reconnect logic, backpressure handling, event replay with timestamps
   - **[ZH]** 研究：gorilla/websocket 模式、重连逻辑、背压处理、带时间戳事件回放
   - **[EN]** Output: WS server setup, client reconnect flow (serverEventTs), 60s in-memory event cache design
   - **[ZH]** 输出：WS 服务器设置、客户端重连流程（serverEventTs）、60 秒内存事件缓存设计

5. **Exponential Backoff + Circuit Breaker Implementation in Go** / **Go 中指数退避 + 熔断器实现**
   - **[EN]** Research: Libraries (e.g., cenkalti/backoff, sony/gobreaker) or custom implementation, jitter patterns
   - **[ZH]** 研究：库（如 cenkalti/backoff、sony/gobreaker）或自定义实现、抖动模式
   - **[EN]** Output: Retry logic with parameters (initial=500ms, multiplier=2.0, jitter=±20%, max_attempts=5, max_delay=8s), circuit breaker config (5 failures/30s → open; half-open after 60s)
   - **[ZH]** 输出：重试逻辑及参数（初始 500ms、倍数 2.0、抖动 ±20%、最多 5 次、最大 8s）、熔断器配置（30 秒内 5 次失败 → 断开；60 秒后半开）

6. **wagmi/viem Contract Interaction Patterns** / **wagmi/viem 合约交互模式**
   - **[EN]** Research: useWriteContract hook, transaction confirmation patterns, error handling, gas estimation
   - **[ZH]** 研究：useWriteContract 钩子、交易确认模式、错误处理、Gas 估算
   - **[EN]** Output: Hook implementation for Protector.protect(), transaction status UI feedback
   - **[ZH]** 输出：Protector.protect() 钩子实现、交易状态 UI 反馈

7. **Prometheus Metrics Best Practices for DeFi** / **DeFi Prometheus 指标最佳实践**
   - **[EN]** Research: Metric naming conventions (_total, _seconds), histogram bucket recommendations, label cardinality limits
   - **[ZH]** 研究：指标命名约定（_total、_seconds）、直方图桶建议、标签基数限制
   - **[EN]** Output: Metric definitions (risk_event_trigger_total, protect_success_total, protect_failure_total, alert_latency_seconds with buckets 0.5/1/2/5/10, positions_monitored), promhttp integration
   - **[ZH]** 输出：指标定义（risk_event_trigger_total、protect_success_total、protect_failure_total、alert_latency_seconds 桶 0.5/1/2/5/10、positions_monitored）、promhttp 集成

8. **AI Risk Explanation Generation (LLM API Integration)** / **AI 风险解释生成（LLM API 集成）**
   - **[EN]** Research: Provider selection (OpenAI GPT-4, Anthropic Claude), structured output format (JSON schema), rate limits, fallback static templates
   - **[ZH]** 研究：供应商选择（OpenAI GPT-4、Anthropic Claude）、结构化输出格式（JSON 模式）、限流、回退静态模板
   - **[EN]** Output: API client setup, prompt template for risk explanation (Signal, Reasoning, Confidence 0-1, Next Step, optional formula), 10-min in-memory cache, fallback mechanism
   - **[ZH]** 输出：API 客户端设置、风险解释提示模板（信号、推理、置信度 0–1、下一步、可选公式）、10 分钟内存缓存、回退机制

9. **Offline Replay Mode Implementation** / **离线回放模式实现**
   - **[EN]** Research: Query param detection (?replay=1), JSON fixture loading, time-based event sequencing for UI
   - **[ZH]** 研究：查询参数检测（?replay=1）、JSON 数据加载、UI 时间序列事件
   - **[EN]** Output: Replay service in Go backend, 3 scenario JSON fixtures (S1: healthy→safe, S2: near-liquidation alert, S3: protection executed), frontend replay integration
   - **[ZH]** 输出：Go 后端回放服务、3 个场景 JSON 数据（S1：健康→安全、S2：临近清算警报、S3：保护已执行）、前端回放集成

10. **Grafana Dashboard JSON Export** / **Grafana 仪表板 JSON 导出**
    - **[EN]** Research: Dashboard creation workflow, PromQL query examples (rate(), histogram_quantile()), Export as JSON procedure
    - **[ZH]** 研究：仪表板创建工作流、PromQL 查询示例（rate()、histogram_quantile()）、导出为 JSON 流程
    - **[EN]** Output: watchtower-dashboard.json with 3 panels (triggers/failures counter, latency P95, positions gauge), README instructions for import
    - **[ZH]** 输出：watchtower-dashboard.json 含 3 个面板（触发/失败计数器、延迟 P95、头寸仪表盘）、README 导入说明

**Research Output** / **研究输出**: `research.md` with 10 decision records, each containing:
**研究输出**：`research.md` 含 10 个决策记录，每个包含：
- **[EN]** Decision: What was chosen (e.g., "Use Alchemy Subgraphs for deployment")
- **[ZH]** 决策：选择了什么（如"使用 Alchemy Subgraphs 部署"）
- **[EN]** Rationale: Why chosen (e.g., "Faster sync, lower setup friction for demo")
- **[ZH]** 理由：为何选择（如"更快同步，演示设置摩擦更小"）
- **[EN]** Alternatives considered: What else was evaluated (e.g., "Self-hosted Graph Node - rejected due to time constraints")
- **[ZH]** 考虑的替代方案：评估了什么（如"自托管 Graph 节点 - 因时间限制拒绝"）

---

## Phase 1: Design & Contracts / Phase 1：设计与契约

**Prerequisites** / **前提条件**: `research.md` complete / `research.md` 完成

**[EN]** Phase 1 will generate three artifacts: `data-model.md` (entity design), `contracts/` (API contracts), and `quickstart.md` (developer setup guide). The agent context will be updated post-generation.

**[ZH]** Phase 1 将生成三个产物：`data-model.md`（实体设计）、`contracts/`（API 契约）、`quickstart.md`（开发者设置指南）。生成后将更新代理上下文。

### Data Model (`data-model.md`) / 数据模型（`data-model.md`）

**[EN]** Extract entities from feature spec and formalize schema, relationships, validation rules, state transitions.

**[ZH]** 从功能规格提取实体，形式化模式、关系、验证规则、状态转换。

**Core Entities** / **核心实体**:

1. **Position** / **头寸**
   - **[EN]** Fields: `id` (bytes32), `owner` (address), `collateralAmount` (uint256), `collateralToken` (address), `debtAmount` (uint256), `debtToken` (address), `healthFactor` (uint256, 4 decimals fixed-point), `lastUpdateTimestamp` (uint256)
   - **[ZH]** 字段：`id`（bytes32）、`owner`（address）、`collateralAmount`（uint256）、`collateralToken`（address）、`debtAmount`（uint256）、`debtToken`（address）、`healthFactor`（uint256，4 位小数定点）、`lastUpdateTimestamp`（uint256）
   - **[EN]** Relationships: One-to-many RiskEvents
   - **[ZH]** 关系：一对多 RiskEvents
   - **[EN]** Validation: `healthFactor` recalculated on-chain via Chainlink price feeds; off-chain validation in backend
   - **[ZH]** 验证：`healthFactor` 经 Chainlink 价格预言机链上重算；后端链下验证
   - **[EN]** State: Mutable (collateral/debt changes via deposit/borrow/protect operations)
   - **[ZH]** 状态：可变（抵押/债务通过存款/借款/保护操作变化）

2. **RiskEvent** / **风险事件**
   - **[EN]** Fields: `id` (bytes32), `positionId` (bytes32), `eventType` (enum: ThresholdBreach, ProtectionTriggered, ManualAction), `previousHF` (uint256), `newHF` (uint256), `deltaHF` (int256), `txHash` (bytes32), `timestamp` (uint256)
   - **[ZH]** 字段：`id`（bytes32）、`positionId`（bytes32）、`eventType`（枚举：ThresholdBreach、ProtectionTriggered、ManualAction）、`previousHF`（uint256）、`newHF`（uint256）、`deltaHF`（int256）、`txHash`（bytes32）、`timestamp`（uint256）
   - **[EN]** Relationships: Many-to-one Position
   - **[ZH]** 关系：多对一 Position
   - **[EN]** Validation: `eventType` must be valid enum value; `deltaHF = newHF - previousHF`
   - **[ZH]** 验证：`eventType` 必须为有效枚举值；`deltaHF = newHF - previousHF`
   - **[EN]** State: Immutable (append-only log)
   - **[ZH]** 状态：不可变（仅追加日志）

3. **AlertThreshold** / **警报阈值**
   - **[EN]** Fields: `value` (uint256, default 1.3e4 for 4-decimal fixed-point 1.30), `enabled` (bool)
   - **[ZH]** 字段：`value`（uint256，默认 1.3e4 表示 4 位小数定点 1.30）、`enabled`（bool）
   - **[EN]** Relationships: None (global config)
   - **[ZH]** 关系：无（全局配置）
   - **[EN]** Validation: `value > 1.0e4` (HF must be > 1.0 to trigger alert meaningfully)
   - **[ZH]** 验证：`value > 1.0e4`（HF 必须 > 1.0 才有意义触发警报）
   - **[EN]** State: Mutable (admin-only setter)
   - **[ZH]** 状态：可变（仅管理员设置）

4. **ProtectionAction** / **保护操作**
   - **[EN]** Fields: `id` (bytes32), `positionId` (bytes32), `actionType` (enum: AddCollateral, RepayDebt), `beforeHF` (uint256), `afterHF` (uint256), `collateralDelta` (uint256), `debtDelta` (uint256), `txHash` (bytes32), `timestamp` (uint256)
   - **[ZH]** 字段：`id`（bytes32）、`positionId`（bytes32）、`actionType`（枚举：AddCollateral、RepayDebt）、`beforeHF`（uint256）、`afterHF`（uint256）、`collateralDelta`（uint256）、`debtDelta`（uint256）、`txHash`（bytes32）、`timestamp`（uint256）
   - **[EN]** Relationships: Many-to-one Position
   - **[ZH]** 关系：多对一 Position
   - **[EN]** Validation: `afterHF > beforeHF` (protection must improve HF); `collateralDelta > 0` OR `debtDelta > 0`
   - **[ZH]** 验证：`afterHF > beforeHF`（保护必须改善 HF）；`collateralDelta > 0` 或 `debtDelta > 0`
   - **[EN]** State: Immutable (historical record)
   - **[ZH]** 状态：不可变（历史记录）

5. **ScenarioPrediction** (Off-chain only, not indexed) / **场景预测**（仅链下，不索引）
   - **[EN]** Fields: `positionId` (string), `scenarioType` (enum: PriceUp8, PriceDown8), `predictedHF` (float), `contributingFactors` (array of strings), `confidence` (float 0-1), `timestamp` (int64)
   - **[ZH]** 字段：`positionId`（字符串）、`scenarioType`（枚举：PriceUp8、PriceDown8）、`predictedHF`（浮点）、`contributingFactors`（字符串数组）、`confidence`（浮点 0–1）、`timestamp`（int64）
   - **[EN]** Relationships: Conceptually linked to Position (not enforced on-chain)
   - **[ZH]** 关系：概念上关联 Position（链上不强制）
   - **[EN]** Validation: `predictedHF >= 0`; `confidence` in [0, 1]
   - **[ZH]** 验证：`predictedHF >= 0`；`confidence` 在 [0, 1]
   - **[EN]** State: Ephemeral (calculated on demand, not persisted)
   - **[ZH]** 状态：临时（按需计算，不持久化）

**State Transition Diagram** / **状态转换图** (for Position.healthFactor):
**状态转换图**（Position.healthFactor）：

```
[中] Safe (HF > 1.5) ←→ Warning (1.3 < HF ≤ 1.5) ←→ Critical (HF ≤ 1.3)
[EN] Safe (HF > 1.5) ←→ Warning (1.3 < HF ≤ 1.5) ←→ Critical (HF ≤ 1.3)

Transitions triggered by:
[中] 触发转换的原因：
[EN] Transitions triggered by:
- Price oracle updates (Chainlink feeds)
- User actions (deposit collateral, borrow debt, repay debt)
- Protection actions (Protector.protect() adds collateral)

[中] - 价格预言机更新（Chainlink 预言机）
[EN] - Price oracle updates (Chainlink feeds)
[中] - 用户操作（存入抵押、借款、偿还）
[EN] - User actions (deposit collateral, borrow debt, repay debt)
[中] - 保护操作（Protector.protect() 添加抵押）
[EN] - Protection actions (Protector.protect() adds collateral)
```

### API Contracts (`contracts/`) / API 契约（`contracts/`）

**[EN]** Generate OpenAPI 3.0 spec for Go backend REST API and GraphQL schema for The Graph subgraph.

**[ZH]** 为 Go 后端 REST API 生成 OpenAPI 3.0 规格，为 The Graph 子图生成 GraphQL 模式。

#### REST API Contract (`contracts/api.openapi.yaml`)

**[EN]** Key endpoints extracted from functional requirements:

**[ZH]** 从功能需求提取的关键端点：

```yaml
openapi: 3.0.0
info:
  title: DeRisk Watchtower API
  version: 1.0.0
  description: Real-time DeFi position monitoring and protection API

servers:
  - url: http://localhost:8080
    description: Local development
  - url: https://api.derisk-watchtower.example.com
    description: Production (Base Sepolia)

paths:
  /healthz:
    get:
      summary: Health check
      responses:
        '200':
          description: Service healthy
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: "ok"
                  version:
                    type: string
                    example: "1.0.0"
                  now:
                    type: integer
                    format: int64
                    example: 1699999999

  /metrics:
    get:
      summary: Prometheus metrics
      responses:
        '200':
          description: Metrics in Prometheus text format
          content:
            text/plain:
              schema:
                type: string

  /api/positions:
    get:
      summary: Get positions by owner
      parameters:
        - name: owner
          in: query
          required: true
          schema:
            type: string
            pattern: '^0x[a-fA-F0-9]{40}$'
            example: "0x1234567890123456789012345678901234567890"
      responses:
        '200':
          description: List of positions
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Position'
        '400':
          description: Invalid owner address
        '500':
          description: Internal server error

  /api/hf/{address}:
    get:
      summary: Get Health Factor for position
      parameters:
        - name: address
          in: path
          required: true
          schema:
            type: string
            pattern: '^0x[a-fA-F0-9]{40}$'
      responses:
        '200':
          description: Health Factor data
          content:
            application/json:
              schema:
                type: object
                properties:
                  hf:
                    type: number
                    format: float
                    example: 1.4523
                    description: Health Factor (4 decimal precision)
                  lastUpdateAt:
                    type: integer
                    format: int64
                    example: 1699999999
                    description: Unix timestamp of last update
                  isStale:
                    type: boolean
                    example: false
                    description: True if data is >60s old
        '404':
          description: Position not found
        '500':
          description: Internal server error

  /ws/risk-stream:
    get:
      summary: WebSocket for real-time risk alerts
      description: |
        Upgrade to WebSocket connection. Client sends `serverEventTs` on reconnect
        for event replay (last 60s). Server sends RiskAlert messages.
      responses:
        '101':
          description: Switching Protocols to WebSocket

components:
  schemas:
    Position:
      type: object
      properties:
        id:
          type: string
          example: "0xabc..."
        owner:
          type: string
          example: "0x1234..."
        collateralAmount:
          type: string
          example: "1000000000000000000"
          description: Wei/smallest unit
        collateralToken:
          type: string
          example: "0x5678..."
        debtAmount:
          type: string
          example: "500000000000000000"
        debtToken:
          type: string
          example: "0x9abc..."
        healthFactor:
          type: number
          format: float
          example: 1.4523
        lastUpdateAt:
          type: integer
          format: int64
          example: 1699999999

    RiskAlert:
      type: object
      description: WebSocket message payload
      properties:
        type:
          type: string
          enum: [RiskAlert]
          example: "RiskAlert"
        positionId:
          type: string
          example: "0xabc..."
        hf:
          type: number
          format: float
          example: 0.85
        threshold:
          type: number
          format: float
          example: 1.30
        txHash:
          type: string
          nullable: true
          example: "0xdef..."
        timestamp:
          type: integer
          format: int64
          example: 1699999999
        replayed:
          type: boolean
          example: false
          description: True if event is from replay (reconnect)
```

#### GraphQL Schema (`contracts/subgraph.schema.graphql`)

**[EN]** The Graph subgraph schema for Position and RiskEvent indexing:

**[ZH]** The Graph 子图模式，用于 Position 与 RiskEvent 索引：

```graphql
type Position @entity {
  id: ID!                               # Position ID (bytes32)
  owner: Bytes!                         # Owner address
  collateralAmount: BigInt!             # Collateral amount in wei
  collateralToken: Bytes!               # Collateral token address
  debtAmount: BigInt!                   # Debt amount in wei
  debtToken: Bytes!                     # Debt token address
  healthFactor: BigInt!                 # Health Factor (4-decimal fixed-point, e.g., 13000 = 1.3000)
  lastUpdateTimestamp: BigInt!          # Last update timestamp (Unix)
  riskEvents: [RiskEvent!]! @derivedFrom(field: "position")  # Related risk events
  protectionActions: [ProtectionAction!]! @derivedFrom(field: "position")  # Related protection actions
}

type RiskEvent @entity {
  id: ID!                               # Event ID (txHash-logIndex)
  position: Position!                   # Related position
  eventType: RiskEventType!             # Enum: ThresholdBreach, ProtectionTriggered, ManualAction
  previousHF: BigInt!                   # Previous HF (4-decimal fixed-point)
  newHF: BigInt!                        # New HF (4-decimal fixed-point)
  deltaHF: BigInt!                      # HF delta (signed, 4-decimal fixed-point)
  txHash: Bytes!                        # Transaction hash
  timestamp: BigInt!                    # Event timestamp (Unix)
}

enum RiskEventType {
  ThresholdBreach
  ProtectionTriggered
  ManualAction
}

type ProtectionAction @entity {
  id: ID!                               # Action ID (txHash-logIndex)
  position: Position!                   # Related position
  actionType: ProtectionActionType!     # Enum: AddCollateral, RepayDebt
  beforeHF: BigInt!                     # HF before action (4-decimal fixed-point)
  afterHF: BigInt!                      # HF after action (4-decimal fixed-point)
  collateralDelta: BigInt!              # Collateral added (wei, 0 if RepayDebt)
  debtDelta: BigInt!                    # Debt repaid (wei, 0 if AddCollateral)
  txHash: Bytes!                        # Transaction hash
  timestamp: BigInt!                    # Action timestamp (Unix)
}

enum ProtectionActionType {
  AddCollateral
  RepayDebt
}
```

### Developer Quickstart (`quickstart.md`) / 开发者快速开始（`quickstart.md`）

**[EN]** One-command setup guide for local development, testing, and demo deployment.

**[ZH]** 一键设置指南，用于本地开发、测试与演示部署。

**[EN]** Structure:
1. Prerequisites (Node.js, Go, Foundry, Docker, Base Sepolia RPC URL, faucet ETH)
2. Repository clone & env setup (`.env` from `.env.example`)
3. One-command startup: `docker-compose up -d` (Prometheus + Grafana)
4. Contract deployment: `cd contracts && forge script script/Deploy.s.sol --broadcast --rpc-url $BASE_SEPOLIA_RPC`
5. Subgraph deployment: `cd subgraph && graph deploy --studio derisk-watchtower`
6. Backend startup: `cd backend && go run cmd/server/main.go`
7. Frontend startup: `cd frontend && npm run dev`
8. Accessing services: Frontend (localhost:3000), Backend API (localhost:8080), Grafana (localhost:3001), Prometheus (localhost:9090)
9. Demo walkthrough: Connect wallet → View positions → Trigger alert (via Foundry script) → Click "Protect Position" → View before/after comparison
10. Offline replay mode: `http://localhost:3000?replay=1`

**[ZH]** 结构：
1. 前提（Node.js、Go、Foundry、Docker、Base Sepolia RPC URL、水龙头 ETH）
2. 仓库克隆与环境设置（从 `.env.example` 创建 `.env`）
3. 一键启动：`docker-compose up -d`（Prometheus + Grafana）
4. 合约部署：`cd contracts && forge script script/Deploy.s.sol --broadcast --rpc-url $BASE_SEPOLIA_RPC`
5. 子图部署：`cd subgraph && graph deploy --studio derisk-watchtower`
6. 后端启动：`cd backend && go run cmd/server/main.go`
7. 前端启动：`cd frontend && npm run dev`
8. 访问服务：前端（localhost:3000）、后端 API（localhost:8080）、Grafana（localhost:3001）、Prometheus（localhost:9090）
9. 演示步骤：连接钱包 → 查看头寸 → 触发警报（通过 Foundry 脚本）→ 点击"保护头寸" → 查看前后对比
10. 离线回放模式：`http://localhost:3000?replay=1`

### Agent Context Update / 代理上下文更新

**[EN]** After Phase 1 artifacts are generated, run:

**[ZH]** Phase 1 产物生成后，运行：

```bash
# 中文说明（English explanation）
# 运行代理上下文更新脚本，仅添加新技术到 CLAUDE.md
# Run agent context update script to add new technologies to CLAUDE.md only
.specify/scripts/bash/update-agent-context.sh claude
```

**[EN]** This script detects Claude Code agent usage and updates `CLAUDE.md` with:
- Active Technologies: Foundry, Go, Next.js, The Graph, Chainlink Automation, Prometheus, Grafana
- Project Structure: backend/, frontend/, contracts/, subgraph/, configs/, docs/
- Commands: `forge build`, `go run cmd/server/main.go`, `npm run dev`, `graph deploy`, `docker-compose up -d`

**[ZH]** 此脚本检测 Claude Code 代理使用并更新 `CLAUDE.md`，添加：
- Active Technologies：Foundry、Go、Next.js、The Graph、Chainlink Automation、Prometheus、Grafana
- Project Structure：backend/、frontend/、contracts/、subgraph/、configs/、docs/
- Commands：`forge build`、`go run cmd/server/main.go`、`npm run dev`、`graph deploy`、`docker-compose up -d`

---

## Phase 2: Task Generation (Not Part of /speckit.plan) / Phase 2：任务生成（非 /speckit.plan 部分）

**[EN]** Phase 2 generates `tasks.md` via the `/speckit.tasks` command. This command is NOT executed by `/speckit.plan`. It will be run separately by the user after reviewing this plan and Phase 1 outputs.

**[ZH]** Phase 2 通过 `/speckit.tasks` 命令生成 `tasks.md`。此命令**不由** `/speckit.plan` 执行。用户审查本计划与 Phase 1 输出后将单独运行。

**[EN]** Task generation will decompose this plan into dependency-ordered, atomic implementation tasks with acceptance criteria mapped to spec requirements.

**[ZH]** 任务生成将把本计划分解为依赖顺序的原子实现任务，验收标准映射到规格需求。

**[EN]** To generate tasks after reviewing this plan, run:

**[ZH]** 审查本计划后生成任务，运行：

```bash
# 中文说明（English explanation）
# 生成实现任务清单
# Generate implementation task list
/speckit.tasks
```

---

## Summary & Next Steps / 概要与下一步

**[EN]** This implementation plan establishes:
1. ✅ **Technical Context**: Complete tech stack (Foundry, Go, Next.js, The Graph, Chainlink, Prometheus, Grafana)
2. ✅ **Constitution Compliance**: All 5 principles satisfied (integrity, AI transparency, version control, security, observability)
3. ✅ **Project Structure**: Web application with backend/, frontend/, contracts/, subgraph/, configs/, docs/
4. ✅ **Phase 0 Research Tasks**: 10 targeted research items to resolve unknowns (Chainlink feeds, subgraph deployment, WebSocket patterns, etc.)
5. ✅ **Phase 1 Design Outputs**: data-model.md (5 entities), contracts/ (OpenAPI + GraphQL), quickstart.md (one-command setup)

**[ZH]** 本实施计划确立：
1. ✅ **技术上下文**：完整技术栈（Foundry、Go、Next.js、The Graph、Chainlink、Prometheus、Grafana）
2. ✅ **宪法合规**：所有 5 项原则满足（完整性、AI 透明度、版本控制、安全、可观测性）
3. ✅ **项目结构**：Web 应用，含 backend/、frontend/、contracts/、subgraph/、configs/、docs/
4. ✅ **Phase 0 研究任务**：10 个针对性研究项，解决未知（Chainlink 预言机、子图部署、WebSocket 模式等）
5. ✅ **Phase 1 设计输出**：data-model.md（5 个实体）、contracts/（OpenAPI + GraphQL）、quickstart.md（一键设置）

**[EN]** **Next Steps**:
1. Review this plan for accuracy and alignment with spec.md
2. Approve Phase 0 research tasks
3. Execute Phase 0: Generate `research.md` with 10 decision records
4. Execute Phase 1: Generate `data-model.md`, `contracts/`, `quickstart.md`
5. Re-validate Constitution Check post-design
6. Run `/speckit.tasks` to generate dependency-ordered implementation tasks

**[ZH]** **下一步**：
1. 审查本计划准确性及与 spec.md 一致性
2. 批准 Phase 0 研究任务
3. 执行 Phase 0：生成 `research.md`，含 10 个决策记录
4. 执行 Phase 1：生成 `data-model.md`、`contracts/`、`quickstart.md`
5. 设计后重新验证宪法检查
6. 运行 `/speckit.tasks` 生成依赖顺序的实现任务

**[EN]** **Branch**: `001-derisk-watchtower-real`
**[EN]** **Plan Path**: `C:/Users/wk547/Desktop/EthGlobal2025/derisk-watchtower/specs/001-derisk-watchtower-real/plan.md`
**[EN]** **Spec Path**: `C:/Users/wk547/Desktop/EthGlobal2025/derisk-watchtower/specs/001-derisk-watchtower-real/spec.md`

**[ZH]** **分支**：`001-derisk-watchtower-real`
**[ZH]** **计划路径**：`C:/Users/wk547/Desktop/EthGlobal2025/derisk-watchtower/specs/001-derisk-watchtower-real/plan.md`
**[ZH]** **规格路径**：`C:/Users/wk547/Desktop/EthGlobal2025/derisk-watchtower/specs/001-derisk-watchtower-real/spec.md`

---

*Generated by `/speckit.plan` on 2025-10-14 | 由 `/speckit.plan` 生成于 2025-10-14*
