# Implementation Tasks Index
# 实施任务索引

**Feature**: DeRisk Watchtower
**功能**: DeRisk 瞭望塔
**Branch**: `001-derisk-watchtower-real`
**分支**: `001-derisk-watchtower-real`

---

## Task Organization
## 任务组织

This feature's implementation tasks are organized into executable phases (E0-E8). Each phase contains detailed, bilingual task breakdowns with specific file paths, code examples, and completion checklists.

本功能的实施任务组织为可执行阶段（E0–E8）。每个阶段包含详细的双语任务分解，含具体文件路径、代码示例与完成清单。

---

## Phase Index
## 阶段索引

### [E0 - Project Initialization](../../tasks/E0-init.md)
### [E0 - 项目初始化](../../tasks/E0-init.md)

**Scope**: Repository setup, directory structure, tooling installation, environment configuration
**范围**: 仓库设置、目录结构、工具安装、环境配置

**Key Tasks**:
- Initialize Git repository and branching strategy
- 初始化 Git 仓库与分支策略
- Set up Foundry, Go, Node.js toolchains
- 设置 Foundry、Go、Node.js 工具链
- Create `.env.example` templates
- 创建 `.env.example` 模板
- Configure Docker Compose for observability stack
- 配置 Docker Compose 用于可观测栈

---

### [E1 - Smart Contracts](../../tasks/E1-contracts.md)
### [E1 - 智能合约](../../tasks/E1-contracts.md)

**Scope**: Solidity contracts, Foundry tests, deployment scripts
**范围**: Solidity 合约、Foundry 测试、部署脚本

**Key Contracts**:
- `PositionVault.sol` - Position state & HF tracking
- `PositionVault.sol` - 头寸状态与 HF 跟踪
- `Protector.sol` - Protection execution logic
- `Protector.sol` - 保护执行逻辑
- `DemoEscrow.sol` - Test token escrow
- `DemoEscrow.sol` - 测试代币托管

**Dependencies**: E0 complete
**依赖**: E0 完成

---

### [E2 - The Graph Subgraph](../../tasks/E2-subgraph.md)
### [E2 - The Graph 子图](../../tasks/E2-subgraph.md)

**Scope**: Subgraph schema, event mappings, deployment
**范围**: 子图模式、事件映射、部署

**Key Entities**:
- `Position` - User lending positions
- `Position` - 用户借贷头寸
- `RiskEvent` - Risk threshold breaches
- `RiskEvent` - 风险阈值突破
- `ProtectionAction` - Protection executions
- `ProtectionAction` - 保护执行

**Dependencies**: E1 complete (contracts deployed)
**依赖**: E1 完成（合约已部署）

---

### [E3 - Chainlink Automation](../../tasks/E3-automation.md)
### [E3 - Chainlink Automation](../../tasks/E3-automation.md)

**Scope**: Automation-compatible Protector, Upkeep registration, CRON triggers
**范围**: 自动化兼容 Protector、Upkeep 注册、CRON 触发

**Key Features**:
- `checkUpkeep()` - HF threshold detection
- `checkUpkeep()` - HF 阈值检测
- `performUpkeep()` - Automated protection execution
- `performUpkeep()` - 自动化保护执行
- CRON schedule: every 5 minutes
- CRON 调度: 每 5 分钟
- Manual fallback via frontend
- 前端手动回退

**Dependencies**: E1 complete
**依赖**: E1 完成

---

### [E4 - Backend API & WebSocket](../../tasks/E4-api-ws.md)
### [E4 - 后端 API 与 WebSocket](../../tasks/E4-api-ws.md)

**Scope**: Go API server, WebSocket real-time alerts, RPC client with retry logic
**范围**: Go API 服务器、WebSocket 实时警报、含重试逻辑的 RPC 客户端

**Key Endpoints**:
- `GET /api/positions` - Query positions by owner
- `GET /api/positions` - 按所有者查询头寸
- `GET /api/hf/{address}` - Fetch Health Factor
- `GET /api/hf/{address}` - 获取健康系数
- `WS /ws/risk-stream` - Real-time alerts with reconnect replay
- `WS /ws/risk-stream` - 实时警报含重连回放
- `GET /metrics` - Prometheus metrics
- `GET /metrics` - Prometheus 指标

**Dependencies**: E1 (contracts), E2 (subgraph)
**依赖**: E1（合约）、E2（子图）

---

### [E5 - Frontend](../../tasks/E5-frontend.md)
### [E5 - 前端](../../tasks/E5-frontend.md)

**Scope**: Next.js 14 App Router, wagmi/viem wallet integration, UI components
**范围**: Next.js 14 App Router、wagmi/viem 钱包集成、UI 组件

**Key Components**:
- `PositionCard` - HF display with color indicators
- `PositionCard` - 含颜色指示器的 HF 显示
- `RiskAlert` - Real-time alert banners
- `RiskAlert` - 实时警报横幅
- `ProtectButton` - One-click protection
- `ProtectButton` - 一键保护
- `useWebSocket` - Auto-reconnect hook
- `useWebSocket` - 自动重连钩子

**Dependencies**: E4 (backend API)
**依赖**: E4（后端 API）

---

### [E6 - Observability](../../tasks/E6-observability.md)
### [E6 - 可观测性](../../tasks/E6-observability.md)

**Scope**: Prometheus metrics, Grafana dashboards, Docker Compose setup
**范围**: Prometheus 指标、Grafana 仪表盘、Docker Compose 设置

**Key Metrics**:
- `risk_event_trigger_total` - Alert trigger count
- `risk_event_trigger_total` - 警报触发计数
- `protect_success_total` / `protect_failure_total` - Protection outcomes
- `protect_success_total` / `protect_failure_total` - 保护结果
- `alert_latency_seconds` - P95 latency tracking
- `alert_latency_seconds` - P95 延迟跟踪
- `positions_monitored` - Active position gauge
- `positions_monitored` - 活跃头寸仪表

**Dependencies**: E4 (backend metrics endpoint)
**依赖**: E4（后端指标端点）

---

### [E7 - Demo & Documentation](../../tasks/E7-demo-docs.md)
### [E7 - 演示与文档](../../tasks/E7-demo-docs.md)

**Scope**: Demo video, README, PROOF.md, AI_USAGE.md, community health files, offline replay fixtures
**范围**: 演示视频、README、PROOF.md、AI_USAGE.md、社区健康文件、离线重放数据

**Key Deliverables**:
- Demo video (2-4 minutes)
- 演示视频（2–4 分钟）
- README.md with one-command startup
- README.md 含一键启动
- PROOF.md with submission evidence
- PROOF.md 含提交证据
- AI_USAGE.md with file/commit attribution
- AI_USAGE.md 含文件/提交归属
- Offline replay fixtures (3 scenarios)
- 离线重放数据（3 个场景）
- Partner integration documentation (≤3)
- 合作伙伴集成文档（≤3）

**Dependencies**: E1-E6 complete
**依赖**: E1–E6 完成

---

### [E8 - Testing & Security](../../tasks/E8-testing-security.md)
### [E8 - 测试与安全](../../tasks/E8-testing-security.md)

**Scope**: Contract tests, backend tests, frontend E2E tests, security audits, fuzz testing, load testing
**范围**: 合约测试、后端测试、前端 E2E 测试、安全审计、模糊测试、负载测试

**Key Testing Areas**:
- Foundry unit & integration tests (38 test cases)
- Foundry 单元与集成测试（38 个测试用例）
- Go backend tests with table-driven patterns
- Go 后端测试含表驱动模式
- Playwright E2E critical flow tests
- Playwright E2E 关键流程测试
- Slither static analysis
- Slither 静态分析
- Fuzz testing (10,000 iterations)
- 模糊测试（10,000 次迭代）
- k6 load testing (50+ req/s throughput)
- k6 负载测试（50+ req/s 吞吐量）

**Dependencies**: E1-E7 (all phases for comprehensive testing)
**依赖**: E1–E7（所有阶段以进行全面测试）

---

## Execution Strategy
## 执行策略

### Sequential Dependencies
### 顺序依赖

```
E0 → E1 → E2
       ↓
       E3
       ↓
E4 → E5
↓
E6
↓
E7 (after E1-E6 complete)
↓
E8 (comprehensive testing after all implementation)
```

### Parallel Opportunities
### 并行机会

After E1 completes:
- **E2 (Subgraph)** and **E3 (Automation)** can proceed in parallel
- **E2（子图）** 与 **E3（Automation）** 可并行进行

After E4 completes:
- **E5 (Frontend)** and **E6 (Observability)** can proceed in parallel
- **E5（前端）** 与 **E6（可观测性）** 可并行进行

---

## Summary
## 概要

**Total Phases**: 9 (E0-E8)
**总阶段数**: 9（E0–E8）

**Estimated Tasks**: ~150-200 granular tasks across all phases
**预估任务**: 所有阶段共约 150–200 个细粒度任务

**MVP Scope**: E0 + E1 + E2 + E4 + E5 (User Story 1: View Position Health)
**MVP 范围**: E0 + E1 + E2 + E4 + E5（用户故事 1：查看头寸健康度）

**Full Demo**: E0-E7 (all features + documentation)
**完整演示**: E0–E7（所有功能 + 文档）

**Production-Ready**: E0-E8 (with comprehensive testing & security)
**生产就绪**: E0–E8（含全面测试与安全）

---

**Implementation Plan Generated**: 2025-10-14
**实施计划生成**: 2025-10-14

**Next Step**: Execute `/speckit.implement` to begin task-by-task implementation
**下一步**: 执行 `/speckit.implement` 开始逐任务实施
