# Feature Specification: DeRisk Watchtower
# 功能规格书：DeRisk 瞭望塔

**Feature Branch**: `001-derisk-watchtower-real`
**功能分支**：`001-derisk-watchtower-real`
**Created**: 2025-10-13
**创建时间**：2025-10-13
**Status**: Draft
**状态**：草案
**Input**: User description: "DeRisk Watchtower - Real-time DeFi position monitoring with alerts and one-click protection on Base Sepolia"
**输入**：用户描述：“DeRisk 瞭望塔 - 在 Base Sepolia 上实时监控 DeFi 头寸、发送警报并支持一键保护”

## Background & Context
## 背景与上下文

DeRisk Watchtower is a demonstration project for ETHOnline 2025 that showcases real-time DeFi position risk monitoring with proactive alerts and automated protection mechanisms on Base Sepolia testnet.
DeRisk 瞭望塔是 ETHOnline 2025 的演示项目，展示在 Base Sepolia 测试网上对 DeFi 头寸进行实时风险监控、主动警报与自动保护机制。

**Demo Constraints**:
**演示约束**：
- Demo duration: 2-4 minutes showing "monitor → alert → protect → compare" flow
- 演示时长：2–4 分钟，展示“监控 → 警报 → 保护 → 对比”流程
- Submission: Via Hacker Dashboard with proof link in `docs/PROOF.md`
- 提交方式：通过 Hacker Dashboard，并在 `docs/PROOF.md` 附上证明链接
- Partner prizes: Maximum 3 partner awards with documented tool usage and feedback
- 合作伙伴奖励：最多 3 个，需记录工具使用与反馈

**Target Audience**:
**目标受众**：
- **Borrowers**: Users with DeFi lending positions who need liquidation protection
- **借款人**：持有 DeFi 借贷头寸、需要清算保护的用户
- **Judges/Observers**: Reviewers who can reproduce the demo without funds using subgraph queries, automation logs, and observability metrics
- **评委/观察者**：无需资金即可通过子图查询、自动化日志与可观测指标复现演示的评审者

## User Scenarios & Testing
## 用户场景与测试

### User Story 1 - View Position Health (Priority: P1) 🎯 MVP
### 用户故事 1 – 查看头寸健康度（优先级：P1）🎯 MVP

A borrower connects their wallet and immediately sees their current Health Factor (HF) and liquidation risk status, enabling them to understand their position safety at a glance.
借款人连接钱包后立即看到当前健康系数（HF）与清算风险状态，一眼了解头寸安全。

**Why this priority**: This is the foundational capability - users cannot take protective action without first understanding their risk level. It delivers immediate value by surfacing critical information.
**为何此优先级**：这是基础能力——用户若不了解风险水平便无法采取保护措施，它通过呈现关键信息带来即时价值。

**Independent Test**: Can be fully tested by connecting a wallet with an active lending position and verifying HF display appears within 3 steps. Delivers standalone value even without alerts or protection features.
**独立测试**：连接带有活跃借贷头寸的钱包，验证 HF 是否在 3 步内展示，即可完整测试；即使没有警报或保护功能也能独立提供价值。

**Acceptance Scenarios**:
**验收场景**：

1. **Given** a user with an active lending position, **When** they connect their wallet, **Then** their current Health Factor is displayed within 3 clicks/steps
1. **假设**用户有活跃借贷头寸，**当**其连接钱包，**则**当前健康系数在 3 次点击/步骤内展示
2. **Given** a user with multiple positions, **When** they view the dashboard, **Then** all positions are listed with individual HF values and update timestamps
2. **假设**用户有多重头寸，**当**其查看仪表盘，**则**列出所有头寸及各自 HF 值与更新时间戳
3. **Given** a user with no active positions, **When** they connect their wallet, **Then** a clear empty state message is shown with guidance on what positions would be monitored
3. **假设**用户无活跃头寸，**当**其连接钱包，**则**展示清晰空状态提示及可监控头寸指引
4. **Given** the system cannot fetch HF data (RPC failure), **When** the user views their position, **Then** a clear error message is displayed with a retry option
4. **假设**系统无法获取 HF 数据（RPC 故障），**当**用户查看头寸，**则**展示清晰错误信息及重试选项

---

### User Story 2 - Receive Risk Alerts (Priority: P2)
### 用户故事 2 – 接收风险警报（优先级：P2）

A borrower is automatically notified when their Health Factor drops below the risk threshold, giving them advance warning before liquidation becomes imminent.
当健康系数跌破风险阈值时，借款人自动收到通知，在清算来临前获得预警。

**Why this priority**: Proactive alerts are the core value proposition - they enable users to react before it's too late. However, alerts are only useful once users can view their positions (depends on P1).
**为何此优先级**：主动警报是核心价值主张——让用户来得及反应；但警报仅在用户能查看头寸（依赖 P1）后才有意义。

**Independent Test**: Can be tested by simulating or triggering a drop in HF below threshold and verifying alert appears in UI and via WebSocket within 10 seconds. Delivers value as a standalone monitoring/notification system.
**独立测试**：模拟或触发 HF 跌破阈值，验证 UI 与 WebSocket 是否在 10 秒内出现警报；可作为独立监控/通知系统提供价值。

**Acceptance Scenarios**:
**验收场景**：

1. **Given** a user's Health Factor drops below the configured threshold, **When** the system detects this change, **Then** an alert appears in the UI within 10 seconds
1. **假设**用户健康系数跌破设定阈值，**当**系统检测到变化，**则**UI 在 10 秒内出现警报
2. **Given** a user has WebSocket connection active, **When** a risk event occurs, **Then** they receive a real-time notification via WebSocket with position details and timestamp
2. **假设**用户 WebSocket 连接活跃，**当**风险事件产生，**则**其通过 WebSocket 收到实时通知，含头寸详情与时间戳
3. **Given** multiple risk events occur in succession, **When** the system processes them, **Then** each event is recorded in the risk timeline with timestamps and HF delta values
3. **假设**连续发生多笔风险事件，**当**系统处理，**则**每笔事件记录在风险时间线，含时间戳与 HF 差值
4. **Given** a risk alert is triggered, **When** the user views the timeline, **Then** they can see the event type, previous HF, current HF, and transaction hash (if applicable)
4. **假设**风险警报被触发，**当**用户查看时间线，**则**其能看到事件类型、前值 HF、当前 HF 及交易哈希（如适用）

---

### User Story 3 - One-Click Position Protection (Priority: P3)
### 用户故事 3 – 一键头寸保护（优先级：P3）

A borrower can execute a protection action with a single click, automatically adjusting their position to restore a healthy Health Factor and avoid liquidation.
借款人可一键执行保护操作，自动调整头寸以恢复健康系数、避免清算。

**Why this priority**: This is the ultimate value delivery - automated protection that saves users from liquidation. However, it requires both position visibility (P1) and risk detection (P2) to function meaningfully in context.
**为何此优先级**：这是终极价值交付——自动保护用户免于清算；但需头寸可见（P1）与风险检测（P2）才能有意义地运行。

**Independent Test**: Can be tested by calling the Protector contract directly and verifying HF improvement and position changes within 5 seconds of transaction confirmation. Delivers value as a standalone protection mechanism.
**独立测试**：直接调用 Protector 合约，验证交易确认后 5 秒内 HF 改善及头寸变化；可作为独立保护机制提供价值。

**Acceptance Scenarios**:
**验收场景**：

1. **Given** a user has a position at risk (HF below threshold), **When** they click the "Protect Position" button, **Then** the Protector contract is called and executes within 5 seconds
1. **假设**用户头寸处于风险（HF 低于阈值），**当**其点击“保护头寸”按钮，**则**调用 Protector 合约并在 5 秒内执行
2. **Given** the protection action succeeds, **When** the transaction confirms, **Then** the UI displays before/after HF comparison and position changes (collateral, debt)
2. **假设**保护操作成功，**当**交易确认，**则**UI 展示前后 HF 对比及头寸变化（抵押品、债务）
3. **Given** the protection action fails (insufficient gas, contract error), **When** the user attempts protection, **Then** a clear error message is shown with suggested remediation steps
3. **假设**保护操作失败（Gas 不足、合约错误），**当**用户尝试保护，**则**展示清晰错误信息及建议补救步骤
4. **Given** a protection action is executed, **When** viewing the timeline, **Then** the protection event is recorded with transaction hash, HF improvement, and timestamp
4. **假设**保护操作已执行，**当**查看时间线，**则**记录保护事件，含交易哈希、HF 改善值与时间戳

---

### User Story 4 - AI Risk Explanation & Scenario Prediction (Priority: P4)
### 用户故事 4 – AI 风险解释与场景预测（优先级：P4）

A borrower can request an AI-generated explanation of their risk status and see predicted Health Factor values under hypothetical price movement scenarios (±8% collateral price change).
借款人可请求 AI 生成的风险状态解释，并查看抵押品价格假设变动 ±8% 下的预测健康系数。

**Why this priority**: This adds educational value and helps users understand risk dynamics, but is not essential for the core monitoring/protection flow. It enhances user experience but is not blocking for demo functionality.
**为何此优先级**：增加教育价值，帮助用户理解风险动态，但并非核心监控/保护流程必需；提升体验，不阻塞演示功能。

**Independent Test**: Can be tested by requesting explanation for any position and verifying structured response includes current risk summary plus two scenario predictions within reasonable response time. Delivers value as a standalone educational/analysis tool.
**独立测试**：请求任意头寸解释，验证结构化响应在合理时间内包含当前风险摘要及两个场景预测；可作为独立教育/分析工具提供价值。

**Acceptance Scenarios**:
**验收场景**：

1. **Given** a user views their position, **When** they click "Explain Risk", **Then** an AI-generated explanation is returned in structured format within 5 seconds
1. **假设**用户查看头寸，**当**其点击“解释风险”，**则**5 秒内返回结构化格式的 AI 生成解释
2. **Given** an AI explanation is requested, **When** the response is displayed, **Then** it includes current risk status, contributing factors, and plain-language summary
2. **假设**请求 AI 解释，**当**响应展示，**则**包含当前风险状态、促成因素及通俗摘要
3. **Given** scenario prediction is requested, **When** the system calculates, **Then** two scenarios are shown: HF if collateral price drops 8%, and HF if collateral price rises 8%
3. **假设**请求场景预测，**当**系统计算，**则**展示两个场景：抵押品价格下跌 8% 时的 HF 与上涨 8% 时的 HF
4. **Given** the AI service is unavailable, **When** explanation is requested, **Then** a fallback message is shown indicating the feature is temporarily unavailable
4. **假设**AI 服务不可用，**当**请求解释，**则**展示回退提示，说明该功能暂时不可用

---

### Edge Cases
### 边缘场景

- **What happens when RPC provider is down or slow?**: System should use cached data with staleness indicator, or provide manual refresh option with clear error messaging
- **RPC 提供商宕机或缓慢时如何？**：系统应使用带陈旧指示的缓存数据，或提供带清晰错误提示的手动刷新选项
- **What happens when user has insufficient gas for protection transaction?**: Display clear error with estimated gas requirement and link to testnet faucet
- **用户保护交易 Gas 不足时如何？**：展示清晰错误，含预估 Gas 需求及测试网水龙头链接
- **What happens when Health Factor is borderline (near threshold)?**: System should show "warning" state distinct from "critical" and "safe" states
- **健康系数处于边界（接近阈值）时如何？**：系统应展示区别于“严重”与“安全”的“警告”状态
- **What happens when Chainlink Automation is delayed?**: Manual protection button serves as fallback mechanism; delay is logged as observability metric
- **Chainlink Automation 延迟时如何？**：手动保护按钮作为回退；延迟记录为可观测指标
- **What happens when subgraph is out of sync?**: Display last sync timestamp and warning if data is stale (>60 seconds old)
- **子图不同步时如何？**：展示最后同步时间戳，若数据陈旧（>60 秒）则警告
- **What happens when WebSocket connection drops?**: Client should automatically reconnect and refetch missed events; show connection status indicator
- **WebSocket 连接断开时如何？**：客户端应自动重连并补拉遗漏事件；显示连接状态指示器
- **What happens during demo if real-time events don't occur?**: Provide replay mode with cached/simulated data to ensure consistent demo experience
- **演示期间无实时事件时如何？**：提供缓存/模拟数据的重放模式，确保演示体验一致

## Requirements
## 需求

### Functional Requirements
### 功能需求

- **FR-001**: System MUST display current Health Factor for connected wallet address within 3 user actions (connect wallet + navigate)
- **FR-001**：系统必须在 3 个用户操作（连接钱包 + 导航）内展示已连接钱包地址的当前健康系数
- **FR-002**: System MUST show clear visual indicators for position health status: Safe (HF > 1.5), Warning (1.2 < HF ≤ 1.5), Critical (HF ≤ 1.2)
- **FR-002**：系统必须清晰展示头寸健康状态指示：安全（HF > 1.5）、警告（1.2 < HF ≤ 1.5）、严重（HF ≤ 1.2）
- **FR-003**: System MUST display empty state with helpful guidance when user has no monitored positions
- **FR-003**：用户无监控头寸时，系统必须展示带帮助指引的空状态
- **FR-004**: System MUST trigger UI alert within 10 seconds when Health Factor drops below threshold
- **FR-004**：健康系数跌破阈值时，系统必须在 10 秒内触发 UI 警报
- **FR-005**: System MUST send real-time notifications via WebSocket when risk events occur
- **FR-005**：风险事件发生时，系统必须经 WebSocket 发送实时通知
- **FR-006**: System MUST record all risk events in a timeline with: timestamp, event type, HF delta, transaction hash
- **FR-006**：系统必须将所有风险事件记录到时间线，含：时间戳、事件类型、HF 差值、交易哈希
- **FR-007**: System MUST provide "One-Click Protect" button that calls Protector contract
- **FR-007**：系统必须提供“一键保护”按钮以调用 Protector 合约
- **FR-008**: System MUST display before/after comparison after protection action: previous HF, new HF, collateral change, debt change
- **FR-008**：保护操作后，系统必须展示前后对比：前值 HF、新 HF、抵押品变化、债务变化
- **FR-009**: System MUST show operation status and progress during protection execution
- **FR-009**：保护执行期间，系统必须展示操作状态与进度
- **FR-010**: System MUST display clear error messages with remediation guidance for failed operations
- **FR-010**：操作失败时，系统必须展示清晰错误信息及补救指引
- **FR-011**: System MUST provide AI-generated risk explanation on user request (120-160 words EN+ZH, structure: Signal, Reasoning, Confidence 0-1, Next Step, optional formula)
- **FR-011**：用户请求时，系统必须提供 AI 生成的风险解释（120–160 字英中对照，结构：信号、推理、置信度 0–1、下一步、可选公式）
- **FR-012**: System MUST calculate and display ±8% collateral price scenario predictions for Health Factor
- **FR-012**：系统必须计算并展示抵押品价格 ±8% 场景下的健康系数预测
- **FR-013**: System MUST expose Prometheus metrics at `/metrics` endpoint including: triggers_total, failures_total, latency_seconds, positions_monitored
- **FR-013**：系统必须在 `/metrics` 端点暴露 Prometheus 指标，含：triggers_total、failures_total、latency_seconds、positions_monitored
- **FR-014**: System MUST provide manual refresh/retry capability when automated systems are delayed or unavailable
- **FR-014**：自动化系统延迟或不可用时，系统必须提供手动刷新/重试能力
- **FR-015**: System MUST indicate data staleness when subgraph or RPC data is >60 seconds old
- **FR-015**：子图或 RPC 数据 >60 秒时，系统必须指示数据陈旧
- **FR-016**: System MUST log all operations and events for observability and debugging
- **FR-016**：系统必须记录所有操作与事件，用于可观测与调试

### Non-Functional Requirements
### 非功能需求

- **NFR-001**: Demo flow must be completable in 2-4 minutes
- **NFR-001**：演示流程必须可在 2–4 分钟内完成
- **NFR-002**: Demo flow must require ≤8 clicks from wallet connection to protection completion
- **NFR-002**：从连接钱包到保护完成，演示流程必须 ≤8 次点击
- **NFR-003**: System must support offline replay mode with cached/simulated data for consistent demos
- **NFR-003**：系统必须支持离线重放模式，使用缓存/模拟数据确保演示一致
- **NFR-004**: UI must be responsive and work on desktop browsers (Chrome, Firefox, Safari)
- **NFR-004**：UI 必须响应式，兼容桌面浏览器（Chrome、Firefox、Safari）
- **NFR-005**: System must handle RPC rate limits gracefully with exponential backoff (initial=500ms, multiplier=2.0, jitter=±20%, max_attempts=5, max_delay=8s) and circuit breaker (5 failures/30s → open; half-open after 60s)
- **NFR-005**：系统必须优雅处理 RPC 限流，采用指数退避（初始 500ms，倍数 2.0，抖动 ±20%，最多 5 次重试，最大间隔 8s）与熔断器（30 秒内 5 次失败即断开；60 秒后半开试探）
- **NFR-006**: API responses for non-blockchain operations must complete within 2 seconds under normal conditions
- **NFR-006**：正常条件下，非区块链操作的 API 响应必须在 2 秒内完成
- **NFR-007**: WebSocket connection must auto-reconnect with exponential backoff on disconnect
- **NFR-007**：WebSocket 断开后必须自动重连，采用指数退避
- **NFR-008**: System must operate on Base Sepolia testnet only
- **NFR-008**：系统必须仅运行于 Base Sepolia 测试网
- **NFR-009**: All sensitive data (private keys, API keys) must be managed via environment variables
- **NFR-009**：所有敏感数据（私钥、API 密钥）必须通过环境变量管理
- **NFR-010**: System must provide one-command startup script for local development
- **NFR-010**：系统必须提供一键启动脚本，用于本地开发
- **NFR-011**: System must include Grafana dashboard JSON export in `configs/grafana/`
- **NFR-011**：系统必须在 `configs/grafana/` 包含 Grafana 仪表盘 JSON 导出
- **NFR-012**: All smart contracts must include SPDX license identifiers
- **NFR-012**：所有智能合约必须包含 SPDX 许可证标识符
- **NFR-013**: Codebase must follow OpenZeppelin security patterns for contract operations
- **NFR-013**：代码库必须遵循 OpenZeppelin 安全模式进行合约操作
- **NFR-014**: System must support up to 8 positions per user and ~30 total positions across all demo users
- **NFR-014**：系统必须支持每用户最多 8 个头寸，演示期间所有用户共约 30 个头寸
- **NFR-015**: Offline replay mode must include 3 scenarios: (S1) healthy→safe, (S2) near-liquidation alert, (S3) protection executed, stored in fixtures/replay/*.json
- **NFR-015**：离线重放模式必须包含 3 个场景：(S1) 健康→安全，(S2) 临近清算预警，(S3) 保护已执行，存储于 fixtures/replay/*.json
- **NFR-016**: AI risk explanations must be 120-160 words (EN + ZH bilingual) with structure: Signal, Reasoning, Confidence (0-1), Next Step, and optional formula snippet
- **NFR-016**：AI 风险解释必须为 120–160 英文字（配中文对照），结构：信号、推理、置信度（0–1）、下一步，可选公式示例
- **NFR-017**: Partner integrations must be limited to ≤3: Base (network), Chainlink (Automation), The Graph (subgraph), each with documented usage and feedback in PROOF.md
- **NFR-017**：合作伙伴集成必须不超过 3 个：Base（网络）、Chainlink（Automation）、The Graph（子图），每个在 PROOF.md 记录使用与反馈

### Key Entities
### 核心实体

- **Position**: Represents a user's lending position with attributes: id, owner address, collateral amount, debt amount, Health Factor, last update timestamp
- **Position（头寸）**：代表用户借贷头寸，属性含：id、所有者地址、抵押数量、债务数量、健康系数、最后更新时间戳
- **RiskEvent**: Represents a risk-related event with attributes: id, position reference, event type (threshold_breach, protection_triggered, manual_action), HF delta, transaction hash, timestamp
- **RiskEvent（风险事件）**：代表风险相关事件，属性含：id、头寸引用、事件类型（阈值突破、保护触发、手动操作）、HF 差值、交易哈希、时间戳
- **AlertThreshold**: Configuration for when alerts should trigger, with attributes: threshold value (default 1.3), enabled status
- **AlertThreshold（警报阈值）**：警报触发配置，属性含：阈值（默认 1.3）、启用状态
- **ProtectionAction**: Record of executed protection with attributes: id, position reference, action type, before HF, after HF, collateral delta, debt delta, transaction hash, timestamp
- **ProtectionAction（保护操作）**：已执行保护的记录，属性含：id、头寸引用、操作类型、操作前 HF、操作后 HF、抵押品差值、债务差值、交易哈希、时间戳
- **ScenarioPrediction**: AI-generated forecast with attributes: position reference, scenario type (price_up_8, price_down_8), predicted HF, contributing factors, timestamp
- **ScenarioPrediction（场景预测）**：AI 生成的预测，属性含：头寸引用、场景类型（价格上涨 8%、价格下跌 8%）、预测 HF、促成因素、时间戳

## Success Criteria
## 成功标准

### Measurable Outcomes
### 可衡量结果

- **SC-001**: Demo flow completion time is between 2-4 minutes from wallet connection to protection confirmation
- **SC-001**：从连接钱包到保护确认，演示流程耗时 2–4 分钟
- **SC-002**: Users can view their Health Factor within 3 actions after landing on the application
- **SC-002**：用户进入应用后 3 个操作内可查看健康系数
- **SC-003**: Risk alerts appear in UI within 10 seconds of Health Factor dropping below threshold
- **SC-003**：健康系数跌破阈值后 10 秒内，风险警报出现在 UI
- **SC-004**: Protection action completes (transaction confirmed) within 5 seconds of user clicking "Protect Position"
- **SC-004**：用户点击“保护头寸”后 5 秒内保护操作完成（交易确认）
- **SC-005**: Before/after position comparison is displayed within 5 seconds of protection transaction confirmation
- **SC-005**：保护交易确认后 5 秒内展示头寸前后对比
- **SC-006**: System successfully handles 10+ concurrent position monitors without degradation
- **SC-006**：系统成功处理 10 个以上并发头寸监控且无性能下降
- **SC-007**: WebSocket notifications are delivered within 2 seconds of server-side event detection
- **SC-007**：服务器检测到事件后 2 秒内推送 WebSocket 通知
- **SC-008**: AI risk explanation is generated and displayed within 5 seconds of user request
- **SC-008**：用户请求后 5 秒内生成并展示 AI 风险解释
- **SC-009**: Scenario predictions (±8% price change) are calculated and displayed within 3 seconds
- **SC-009**：±8% 价格变动场景预测在 3 秒内计算并展示
- **SC-010**: System maintains >95% uptime during demo/testing period
- **SC-010**：演示/测试期间系统保持 >95% 可用时间
- **SC-011**: All critical operations (fetch HF, send alert, execute protection) are logged to Prometheus with <500ms instrumentation overhead
- **SC-011**：所有关键操作（获取 HF、发送警报、执行保护）记录到 Prometheus，插桩开销 <500 ms
- **SC-012**: Judges can access and query subgraph data without needing test funds
- **SC-012**：评委无需测试资金即可访问并查询子图数据
- **SC-013**: Observability dashboard displays all key metrics and is accessible via one-command startup
- **SC-013**：可观测仪表盘展示所有关键指标，可通过一键启动访问
- **SC-014**: Demo can be replayed offline using cached data without network dependencies
- **SC-014**：演示可使用缓存数据离线重放，无需网络依赖
- **SC-015**: Error states provide actionable guidance in 100% of failure scenarios
- **SC-015**：100% 失败场景下错误状态提供可操作指引

## Scope Boundaries
## 范围边界

### In Scope
### 范围内

- Minimal lending position contract for demonstration purposes
- 用于演示的极简借贷头寸合约
- Protector executor contract for automated protection actions
- 自动保护操作的 Protector 执行合约
- The Graph subgraph for position and event indexing
- 用于头寸与事件索引的 The Graph 子图
- Chainlink Automation for condition-based and time-based upkeep
- 基于条件与时间的 Chainlink Automation 维护
- Go-based API service using chi router with WebSocket support
- 基于 Go 的 API 服务，使用 chi 路由并支持 WebSocket
- Next.js frontend with wagmi/viem for wallet integration
- 使用 wagmi/viem 集成钱包的 Next.js 前端
- Prometheus metrics collection and Grafana dashboard
- Prometheus 指标收集与 Grafana 仪表盘
- Complete submission materials and compliance documentation (AI_USAGE.md, CHANGELOG.md, PROOF.md, community health files)
- 完整提交材料与合规文档（AI_USAGE.md、CHANGELOG.md、PROOF.md、社区健康文件）
- Support for up to 3 partner prize integrations with documented usage
- 最多 3 个合作伙伴奖励集成及使用记录

### Out of Scope
### 范围外

- Full-featured lending protocol implementation (Aave/Compound complexity)
- 全功能借贷协议实现（Aave/Compound 级复杂度）
- Mainnet deployment or real funds handling
- 主网部署或真实资金处理
- Multi-chain or cross-chain support
- 多链或跨链支持
- Complex liquidation engine with multiple asset types
- 多资产类型的复杂清算引擎
- Production-grade security audits
- 生产级安全审计
- User authentication or account management
- 用户认证或账户管理
- Advanced portfolio analytics or historical trend analysis
- 高级投资组合分析或历史趋势分析
- Mobile app or mobile-optimized responsive design (desktop-focused)
- 移动应用或移动优先响应式设计（聚焦桌面）
- Multi-language support (English only)
- 多语言支持（仅英语）
- Integration with more than 3 partner technologies
- 超过 3 个合作伙伴技术的集成

## Assumptions
## 假设

- Users have MetaMask or compatible Web3 wallet installed
- 用户已安装 MetaMask 或兼容 Web3 钱包
- Users can acquire test ETH and LINK from Base Sepolia faucets
- 用户可从 Base Sepolia 水龙头获取测试 ETH 与 LINK
- Base Sepolia RPC and The Graph hosted service have acceptable uptime during demo period
- 演示期间 Base Sepolia RPC 与 The Graph 托管服务有可接受的可用时间
- Judges and reviewers have technical capability to run Docker and local development environment
- 评委与审查者具备运行 Docker 与本地开发环境的技术能力
- Chainlink Automation services are available and functional on Base Sepolia
- Chainlink Automation 服务在 Base Sepolia 可用且功能正常
- Demo environment has stable internet connection for blockchain interactions
- 演示环境拥有稳定的区块链交互网络连接
- Test collateral/debt token contracts are deployed and accessible on Base Sepolia
- 测试抵押品/债务代币合约已部署并在 Base Sepolia 可访问
- AI explanation feature uses a cloud-based LLM API with available quota during demo
- AI 解释功能使用云端 LLM API，演示期间配额充足
- Grafana and Prometheus run locally via Docker Compose
- Grafana 与 Prometheus 通过 Docker Compose 本地运行
- One protection mechanism (e.g., debt repayment or collateral addition) is sufficient for demonstration
- 一种保护机制（如偿还债务或增加抵押品）足以用于演示

## Dependencies
## 依赖项

- Base Sepolia testnet availability and RPC access
- Base Sepolia 测试网可用性及 RPC 访问
- The Graph hosted service or self-hosted Graph Node
- The Graph 托管服务或自托管 Graph 节点
- Chainlink Automation/Upkeep services on Base Sepolia
- Base Sepolia 上的 Chainlink Automation/Upkeep 服务
- OpenZeppelin contract libraries for security patterns
- 用于安全模式的 OpenZeppelin 合约库
- External LLM API for AI risk explanation feature (e.g., OpenAI, Anthropic)
- AI 风险解释功能的外部 LLM API（如 OpenAI、Anthropic）
- MetaMask or WalletConnect for wallet integration
- 钱包集成的 MetaMask 或 WalletConnect
- Docker and Docker Compose for observability stack
- 可观测技术栈的 Docker 与 Docker Compose

## Risks & Mitigation
## 风险与缓解

| Risk | Impact | Mitigation Strategy |
| 风险 | 影响 | 缓解策略 |
|------|--------|---------------------|
| RPC rate limiting or downtime | Demo cannot fetch on-chain data | Implement caching layer, provide offline replay mode with simulated data, document fallback RPC providers |
| RPC 限流或宕机 | 演示无法获取链上数据 | 实现缓存层，提供带模拟数据的离线重放模式，记录备用 RPC 提供商 |
| The Graph subgraph sync delays | Stale data displayed to users | Show last sync timestamp, provide manual refresh, cache recent events client-side |
| 子图同步延迟 | 向用户展示过时数据 | 展示最后同步时间戳，提供手动刷新，客户端缓存近期事件 |
| Chainlink Automation delays | Protection not triggered automatically | Provide manual "Protect Now" button as fallback, log delay metrics for transparency |
| Chainlink Automation 延迟 | 保护未自动触发 | 提供“立即保护”手动按钮作为回退，记录延迟指标以透明化 |
| Insufficient test ETH/LINK | Users cannot execute transactions | Document faucet links prominently, provide pre-funded demo accounts, include troubleshooting guide |
| 测试 ETH/LINK 不足 | 用户无法执行交易 | 显著记录水龙头链接，提供预充演示账户，包含故障排查指南 |
| AI API quota exhaustion | Explanation feature unavailable | Implement fallback static explanations, show graceful error with retry option, cache recent responses |
| AI API 配额耗尽 | 解释功能不可用 | 实现静态回退解释，优雅错误提示带重试，缓存近期响应 |
| WebSocket connection failures | Real-time alerts not received | Auto-reconnect with exponential backoff, poll API as fallback, show connection status indicator |
| WebSocket 连接失败 | 无法接收实时警报 | 指数退避自动重连，轮询 API 作为回退，显示连接状态指示器 |
| Demo environment network issues | Cannot complete live demo | Record backup video, provide offline replay mode, document all steps in PROOF.md |
| 演示环境网络问题 | 无法完成实时演示 | 录制备份视频，提供离线重放模式，在 PROOF.md 记录所有步骤 |
| Hacker Dashboard submission issues | Cannot submit on time | Submit early, keep screenshot proofs in PROOF.md, have backup submission method documented |
| 黑客仪表板提交问题 | 无法按时提交 | 提前提交，PROOF.md 留存截图证明，记录备用提交方式 |

## Compliance & Deliverables Checklist
## 合规与交付清单

This feature must satisfy all items in the Constitution's "Deliverables & Documentation Requirements":
本功能必须满足宪法“交付与文档要求”所有项：

**Repository & Code**:
**代码仓库与代码**：
- [ ] Public GitHub repository
- [ ] 公开 GitHub 仓库
- [ ] Clear README with one-command startup
- [ ] 清晰 README 含一键启动
- [ ] Inline comments for complex logic
- [ ] 复杂逻辑内联注释
- [ ] MIT or compatible license file
- [ ] MIT 或兼容许可证文件
- [ ] SPDX headers in all contracts
- [ ] 所有合约含 SPDX 头
- [ ] Community health files: CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md
- [ ] 社区健康文件：CODE_OF_CONDUCT.md、CONTRIBUTING.md、SECURITY.md

**Blockchain Artifacts**:
**区块链产物**：
- [ ] Deployed contract addresses on Base Sepolia
- [ ] Base Sepolia 部署合约地址
- [ ] BaseScan links for all contracts
- [ ] 所有合约的 BaseScan 链接
- [ ] Subgraph deployment link
- [ ] 子图部署链接
- [ ] Chainlink Automation Upkeep ID and configuration details
- [ ] Chainlink Automation Upkeep ID 及配置详情

**Documentation**:
**文档**：
- [ ] README.md with one-command startup + demo walkthrough
- [ ] README.md 含一键启动 + 演示步骤
- [ ] AI_USAGE.md with file/commit-level attribution
- [ ] AI_USAGE.md 含文件/提交级归属
- [ ] CHANGELOG.md with daily updates
- [ ] CHANGELOG.md 每日更新
- [ ] docs/PROOF.md with Hacker Dashboard submission link and evidence
- [ ] docs/PROOF.md 含黑客仪表板提交链接及证据
- [ ] Architecture diagram (recommended)
- [ ] 架构图（推荐）

**Demo Materials**:
**演示材料**：
- [ ] Demo video (2-4 minutes) showing full user flow
- [ ] 演示视频（2–4 分钟）展示完整用户流程
- [ ] Screen recording: connect wallet → view risk → trigger protection
- [ ] 屏幕录制：连接钱包 → 查看风险 → 触发保护
- [ ] Deployed frontend URL (Vercel/Netlify)
- [ ] 部署前端地址（Vercel/Netlify）

**Observability**:
**可观测性**：
- [ ] Prometheus `/metrics` endpoint exposed
- [ ] 暴露 Prometheus `/metrics` 端点
- [ ] Core metrics implemented: triggers_total, failures_total, latency_seconds, positions_monitored
- [ ] 实现核心指标：triggers_total、failures_total、latency_seconds、positions_monitored
- [ ] Grafana dashboard JSON in configs/grafana/
- [ ] configs/grafana/ 含 Grafana 仪表盘 JSON
- [ ] README section on observability with export instructions
- [ ] README 含可观测性章节及导出说明

**Partner Prizes** (Optional, max 3):
**合作伙伴奖励**（可选，最多 3 个）：
- [ ] Document selected Partner Prizes (≤3)
- [ ] 记录所选合作伙伴奖励（≤3）
- [ ] Explain integration details for each
- [ ] 说明每项集成详情
- [ ] Provide feedback on partner tools/SDKs
- [ ] 提供合作伙伴工具/SDK 反馈

**Compliance**:
**合规**：
- [ ] Minimum 3 commits per development day
- [ ] 每个开发日至少 3 次提交
- [ ] Conventional Commits format for all commits
- [ ] 所有提交使用常规提交格式
- [ ] OpenZeppelin security patterns followed
- [ ] 遵循 OpenZeppelin 安全模式
- [ ] All secrets in .env files (not committed)
- [ ] 所有机密置于 .env 文件（不提交）
- [ ] .env.example provided
- [ ] 提供 .env.example
## Clarifications / 规格澄清

### Session 2025-10-14

- Q: What is the maximum number of lending positions per user that the system should support for the demo? → A: 5-10 positions (balanced demo complexity). Cap at 8 per user for demo; total demo capacity target: ~30 positions across all users.
- Q: 演示的错误恢复与重试策略的指数退避参数是什么？ → A: Exponential backoff with jitter. initial=500ms, multiplier=2.0, jitter=±20%, max_attempts=5, max_delay=8s. Circuit breaker: 5 failures/30s → open; half-open after 60s. Idempotent ops auto-retry; non-idempotent require manual override flag.
- Q: What is the source and scope of demo data fixtures for `?replay=1` mode? → A: Demo fixtures are synthetic + small seeded records. Include 3 scenarios: (S1) healthy → safe, (S2) near-liquidation alert, (S3) protection executed. Store under fixtures/replay/*.json.
- Q: AI 风险解释的预期输出长度与结构是什么？ → A: AI risk explanation length 120–160 words EN (+ZH pair). Structure: Signal, Reasoning, Confidence(0–1), Next Step. Plain language first, include 1 formula snippet if helpful.
- Q: Which partner prizes are being targeted for this feature? → A: Target ≤3 partners: Base (network + ecosystem), Chainlink (Automation), The Graph (subgraph). Each gets concrete usage + feedback note in PROOF.md.

---

1) Health Factor (HF) 定义与精度 / Data Source
- EN: HF = (Total Collateral Value × Weighted Avg. Liquidation Threshold) / Total Borrow Value. Precision: 4 decimals. Prices come from Chainlink price feeds on Base Sepolia. UI refreshes every 3s; backend recalculates every 5s. Show “Data as of <timestamp>”. If staleness >10s, mark “Stale” and disable one-click protection until data is fresh.  
- ZH：HF =（总抵押价值 × 加权清算阈值）/ 总借款价值；小数精度 4 位。价格来源为 Base Sepolia 上的 Chainlink 预言机。前端每 3 秒刷新，后端每 5 秒复核。UI 显示“数据时间戳”；当滞后 >10s，标注“Stale”，并暂时禁用一键保护，直至恢复新鲜数据。  
_Refs: Aave HF definition; Chainlink feeds._ :contentReference[oaicite:1]{index=1}

2) 阈值统一与状态带 / Threshold Bands
- EN: Unify bands and alert threshold as: Safe > 1.5; Warning (1.3, 1.5]; Critical ≤ 1.3. Alerts (UI/WS) trigger at HF ≤ 1.3 by default.  
- ZH：统一阈值与状态带：安全 > 1.5；警告 (1.3, 1.5]；危急 ≤ 1.3。默认当 HF ≤ 1.3 触发告警（UI/WS 同步）。

3) 告警节流与幂等 / Alert Throttling & Idempotency
- EN: De-duplicate alerts for the same (positionId, band) within 30s. Idempotency key: `positionId:band:tumblingWindow`. End-to-end SLO: detection→UI P95 ≤ 10s.  
- ZH：同一（positionId, band）在 30 秒内不重复告警。幂等键为 `positionId:band:tumblingWindow`。端到端 SLO：从检测到 UI 呈现的 P95 ≤ 10 秒。

4) WS 断线回放 / WebSocket Reconnect Replay
- EN: Client reconnects with last `serverEventTs`; server replays last 60s events with `replayed=true`.  
- ZH：客户端带上一次 `serverEventTs` 重连；服务端回放最近 60 秒事件并标注 `replayed=true`。

5) 一键保护的执行语义 / Protection Semantics
- EN: Default strategy = **Add Collateral** from a pre-funded **demo escrow** (test tokens) on Base Sepolia; **no flash loans**. The user pays gas from their wallet (UI guides approvals). Failures are retriable with the same idempotency key; operations are restricted to testnet and follow least-privilege.  
- ZH：默认策略为 **加抵押**，资金来自 Base Sepolia 的**预置演示金库**（测试代币），**不使用闪电贷**。gas 由用户钱包支付（UI 引导授权）。失败可使用同一幂等键重试；仅限测试网，执行器遵循最小授权。

6) 自动化触发策略 / Automation Triggers
- EN: Use Chainlink Automation **CRON every 5 minutes** plus an on-chain conditional fallback. Publish Upkeep ID and dashboard link in README.  
- ZH：采用 Chainlink Automation **CRON（每 5 分钟）**，并提供链上条件触发兜底。在 README 公示 Upkeep ID 与面板链接。  
_Refs: Chainlink Automation Supported Networks includes Base Sepolia._ :contentReference[oaicite:2]{index=2}

7) 子图部署与“陈旧度” / Subgraph & Staleness
- EN: Deploy subgraph to **The Graph Network** (or a managed alternative like **Alchemy Subgraphs**). Surface `lastSync` in UI; if `now - lastSync > 60s`, mark stale and favor RPC reads for HF-critical fields. Provide a manual “Refresh” that reconciles Graph+RPC.  
- ZH：子图部署到 **The Graph Network**（或 **Alchemy Subgraphs** 等托管方案）。UI 显示 `lastSync`；若 `now - lastSync > 60s`，标注为陈旧，并对 HF 关键字段优先使用 RPC 直读。提供“手动刷新”以对账 Graph 与 RPC。  
_Refs: Hosted Service sunsetting & migration guidance._ :contentReference[oaicite:3]{index=3}

8) 可观测性规范 / Observability Conventions
- EN: Prometheus metrics: use `_total` for counters (e.g., `risk_event_trigger_total`), durations in seconds with histograms (e.g., `alert_latency_seconds` with buckets 0.5/1/2/5/10). SLOs are computed via histograms (P95).  
- ZH：Prometheus 指标：计数器用 `_total`（如 `risk_event_trigger_total`），时延用“秒”并以直方图上报（如 `alert_latency_seconds`，建议桶 0.5/1/2/5/10）。基于直方图计算 P95 等 SLO。  
_Refs: Prometheus naming & histograms best practices._ :contentReference[oaicite:4]{index=4}

9) 零注资复现 / Zero-Funds Repro
- EN: Provide (a) read-only demo account list; (b) `?replay=1` toggle with bundled JSON event log under `docs/fixtures/`; (c) public endpoints: subgraph URL, Chainlink Upkeep ID, `/metrics`, and Grafana JSON in `configs/grafana/`.  
- ZH：提供 (a) 只读演示账户清单；(b) `?replay=1` 回放开关（`docs/fixtures/` 内置 JSON 事件日志）；(c) 公开端点：子图 URL、Upkeep ID、`/metrics` 与 `configs/grafana/` 的 Grafana 导出。

10) AI 解释回退 / AI Explanation Fallback
- EN: Provider is configurable; on quota exhaustion, fall back to a static template and a 10-minute in-memory cache. UI clearly indicates temporary unavailability.  
- ZH：LLM 供应商可配置；配额耗尽时回退为静态模板 + 10 分钟内存缓存；UI 明确提示临时不可用。
