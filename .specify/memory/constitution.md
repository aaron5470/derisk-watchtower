<!--
SYNC IMPACT REPORT
==================
Version Change: 1.0.0 → 1.0.1
Rationale: Apply compliance & verifiability patches (video 2–4 min, Hacker Dashboard proof, trunk-based short branches, CC examples, OZ patterns, /metrics endpoint, Grafana JSON export, community health files, SPDX)
Modified Principles:
- I. Hackathon Development Integrity (tightened proof path)
- II. AI Transparency & Human Oversight (unchanged semantics, clarified evidence)
- III. Version Control Discipline (short-lived branches + examples)
- IV. Security & Compliance Standards (OZ patterns explicitly named)
- V. Observability & Metrics (/metrics path + JSON export instructions)

Added Items:
- Hacker Dashboard submission link in docs/PROOF.md
- Community health files (CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md)
- SPDX headers requirement for contracts
- Demo video fixed to 2–4 minutes

Templates Requiring Updates:
- ✅ .specify/templates/plan-template.md (validated)
- ✅ .specify/templates/spec-template.md (validated)
- ✅ .specify/templates/tasks-template.md (validated)

Follow-up TODOs: None
-->

# DeRisk Watchtower (Base Sepolia) Constitution
DeRisk 瞭望塔（Base Sepolia）章程

## Core Principles
核心原则

### I. Hackathon Development Integrity (Start-Fresh)
### I. 黑客松开发完整性（从零开始）

**NON-NEGOTIABLE**: All implementation MUST be completed during the ETHOnline 2025 hackathon period.
**不可协商**：所有实现必须在 ETHOnline 2025 黑客松期间完成。

- All code, contracts, and features SHALL be developed from scratch during the hackathon
- 所有代码、合约和功能必须在黑客松期间从零开始开发
- Open-source libraries, frameworks, and scaffolding tools MAY be used
- 可以使用开源库、框架和脚手架工具
- When using external libraries/scaffolds, origin and license MUST be documented in README.md
- 使用外部库/脚手架时，必须在 README.md 中记录其来源和许可证
- Pre-hackathon private code reuse is STRICTLY PROHIBITED
- 严格禁止复用黑客松之前的私有代码
- Any borrowed/adapted code MUST include clear attribution with source links
- 任何借用/改编的代码必须附带清晰的归属和源链接

**Rationale**: Ensures fair competition, demonstrates genuine hackathon effort, and maintains compliance with ETHGlobal rules.
**理由**：确保公平竞争，展示真正的黑客松努力，并符合 ETHGlobal 规则。

### II. AI Transparency & Human Oversight
### II. AI 透明度与人类监督

AI tools (Claude, Copilot, etc.) MAY be used for scaffolding, refactoring, documentation, and testing. All AI assistance MUST be transparent and human-verified.
可以使用 AI 工具（Claude、Copilot 等）进行脚手架搭建、重构、文档编写和测试。所有 AI 协助必须透明且经过人类验证。

**Requirements**:
**要求**：
- Every AI-assisted contribution MUST be logged in `AI_USAGE.md` with file/commit granularity
- 每一次 AI 协助的贡献必须在 `AI_USAGE.md` 中以文件/提交粒度记录
- Format: `[Date] [Tool] [File/Commit] [Task Description] [Human Review Notes]`
- 格式：`[日期] [工具] [文件/提交] [任务描述] [人类审查备注]`
- All AI-generated code MUST undergo human review and necessary rewriting
- 所有 AI 生成的代码必须经过人类审查和必要的重写
- Critical logic (contract functions, risk calculations, automation triggers) MUST be explicitly reviewed and annotated with reviewer initials
- 关键逻辑（合约函数、风险计算、自动化触发器）必须明确审查并用审查者首字母标注
- AI tools MAY NOT be used for direct commit messages or governance decisions
- AI 工具不得用于直接的提交信息或治理决策

**Rationale**: Maintains transparency for judges, ensures code quality through human oversight, and demonstrates responsible AI usage.
**理由**：为评委保持透明度，通过人类监督确保代码质量，并展示负责任的 AI 使用。

### III. Version Control Discipline
### III. 版本控制纪律

**Workflow**: Trunk-Based Development + GitHub Flow
**工作流**：基于主干的开发 + GitHub Flow

**Commit Standards**:
**提交标准**：
- Small, atomic commits focused on single logical changes
- 小而原子的提交，聚焦单一逻辑变更
- MINIMUM 3 commits per development day
- 每个开发日至少 3 次提交
- Commit messages MUST follow Conventional Commits format:
- 提交信息必须遵循 Conventional Commits 格式：
  `<type>(<scope>): <description>`
  `<类型>(<范围>): <描述>`
  - Examples:
  - 示例：
    - `feat(contracts): add liquidation trigger logic`
    - `feat(contracts): 添加清算触发逻辑`
    - `fix(api): handle empty owner in /api/positions`
    - `fix(api): 处理 /api/positions 中的空所有者`
    - `docs(readme): add one-command start section`
    - `docs(readme): 添加一键启动章节`
- PROHIBITED: Monolithic commits containing multiple unrelated changes
- 禁止：包含多个无关变更的巨型提交
- Pull requests MUST include self-review checklist before merge
- 合并前拉取请求必须包含自审查清单
- `CHANGELOG.md` MUST be updated daily with human-readable summaries
- 必须每日更新 `CHANGELOG.md`，附带人类可读的摘要

**Branch Strategy**:
**分支策略**：
- `main` branch is protected and represents production-ready state
- `main` 分支受保护，代表可投产状态
- Feature branches named: `feat/<feature-name>`, `fix/<bug-name>`, `chore/<task-name>`
- 功能分支命名：`feat/<功能名>`、`fix/<缺陷名>`、`chore/<任务名>`
- Branches MUST be short-lived and merged frequently into `main` (trunk)
- 分支必须短生命周期并频繁合并到 `main`（主干）
- Merge to `main` only after self-review and testing
- 仅在自审查和测试后合并到 `main`

**Rationale**: Enables clear development history, facilitates rollback, demonstrates consistent progress to judges, and maintains code review discipline.
**理由**：提供清晰的开发历史，便于回滚，向评委展示持续进展，并保持代码审查纪律。

### IV. Security & Compliance Standards
### IV. 安全与合规标准

**Environment & Access Control**:
**环境与访问控制**：
- Testnet-only deployment (Base Sepolia)
- 仅部署在测试网（Base Sepolia）
- Principle of least privilege for all services and accounts
- 所有服务和账户遵循最小权限原则
- Private keys and secrets MUST use `.env` files (never committed)
- 私钥和机密必须使用 `.env` 文件（永不提交）
- `.env.example` MUST be provided with placeholder values
- 必须提供带占位符值的 `.env.example`

**Smart Contract Security**:
**智能合约安全**：
- Follow OpenZeppelin security baseline patterns (e.g., `ReentrancyGuard`, `Pausable`)
- 遵循 OpenZeppelin 安全基线模式（如 `ReentrancyGuard`、`Pausable`）
- All contract calls MUST have failure handling and user-facing error messages
- 所有合约调用必须包含失败处理和面向用户的错误信息
- Critical operations (liquidation protection, fund transfers) MUST include:
- 关键操作（清算保护、资金转移）必须包含：
  - Input validation
  - 输入验证
  - Reentrancy guards where applicable
  - 适用的重入锁
  - Event emission for observability
  - 用于可观测性的事件发出
  - Rollback mechanisms or clear failure recovery paths
  - 回滚机制或清晰的失败恢复路径
- Contracts SHOULD include SPDX license identifiers at the top of source files
- 合约源文件顶部应包含 SPDX 许可证标识符

**Automation & Off-Chain Security**:
**自动化与链下安全**：
- Chainlink Automation/Upkeep configurations MUST have documented failure modes
- Chainlink 自动化/维护配置必须有记录失败模式
- All automated triggers MUST have manual override capability
- 所有自动化触发器必须支持手动覆盖
- Rate limiting and circuit breakers for external API calls
- 外部 API 调用需有速率限制和熔断器

**Rationale**: Protects user funds (even on testnet), demonstrates production-ready thinking, and ensures safe demo operations for judges.
**理由**：保护用户资金（即使在测试网），展示可投产思维，并确保评委演示安全。

### V. Observability & Metrics
### V. 可观测性与指标

**Monitoring Requirements**:
**监控要求**：
- A Prometheus-compatible metrics endpoint MUST be exposed at `/metrics`
- 必须在 `/metrics` 暴露兼容 Prometheus 的指标端点
- Core metrics to track:
- 需跟踪的核心指标：
  - `watchtower_triggers_total` (counter): Successful position protection triggers
  - `watchtower_triggers_total`（计数器）：成功的头寸保护触发次数
  - `watchtower_failures_total` (counter): Failed operations by type
  - `watchtower_failures_total`（计数器）：按类型划分的失败操作次数
  - `watchtower_latency_seconds` (histogram): End-to-end operation latency
  - `watchtower_latency_seconds`（直方图）：端到端操作延迟
  - `watchtower_positions_monitored` (gauge): Active positions under watch
  - `watchtower_positions_monitored`（仪表盘）：正在监控的活跃头寸数
- Grafana dashboard JSON MUST be provided in `configs/grafana/`
- 必须在 `configs/grafana/` 提供 Grafana 仪表板 JSON

**Developer Experience**:
**开发者体验**：
- README MUST include one-command observability stack startup:
- README 必须包含一键启动可观测性栈：
  ```bash
  docker-compose up -d prometheus grafana
  ```
- Dashboard access instructions with default credentials documented
- 记录仪表板访问说明及默认凭据
- README “Observability” section MUST include example PromQL queries and a short note on **Export as JSON** (how-to) so reviewers can import the dashboard elsewhere
- README “可观测性”章节必须包含示例 PromQL 查询及简短说明**导出为 JSON**（如何操作），以便评审在其他地方导入仪表板

**Rationale**: Enables real-time debugging during demo, demonstrates production-grade architecture, and provides quantifiable metrics for judges.
**理由**：支持演示期间的实时调试，展示可投产级架构，并为评委提供可量化指标。

## Deliverables & Documentation Requirements
## 交付物与文档要求

All items MUST be completed before final submission:
所有项目必须在最终提交前完成：

**Repository & Code**:
**仓库与代码**：
- Public GitHub repository with clear README
- 带有清晰 README 的公开 GitHub 仓库
- All source code with inline comments for complex logic
- 所有源码对复杂逻辑附有行内注释
- License file (MIT or compatible); contracts include SPDX headers
- 许可证文件（MIT 或兼容）；合约包含 SPDX 头
- Community health files: `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md` (root or `.github/`)
- 社区健康文件：`CODE_OF_CONDUCT.md`、`CONTRIBUTING.md`、`SECURITY.md`（根目录或 `.github/`）

**Blockchain Artifacts**:
**区块链产物**：
- Deployed contract addresses on Base Sepolia
- 在 Base Sepolia 部署的合约地址
- Block explorer links (BaseScan) for all contracts
- 所有合约的区块浏览器链接（BaseScan）
- Subgraph deployment link (if applicable)
- 子图部署链接（如适用）
- Chainlink Automation/Upkeep registration details with Upkeep ID
- 带 Upkeep ID 的 Chainlink 自动化/维护注册详情

**Documentation**:
**文档**：
- `README.md`: One-command startup instructions + demo walkthrough
- `README.md`：一键启动说明 + 演示流程
- `AI_USAGE.md`: Complete AI assistance log
- `AI_USAGE.md`：完整的 AI 协助日志
- `CHANGELOG.md`: Daily development log
- `CHANGELOG.md`：每日开发日志
- `docs/PROOF.md`: Hackathon period evidence (commit history, timestamps, **Hacker Dashboard submission link**)
- `docs/PROOF.md`：黑客松期间证据（提交历史、时间戳、**黑客仪表板提交链接**）
- Architecture diagram (optional but recommended)
- 架构图（可选但推荐）

**Demo Materials**:
**演示材料**：
- Demo video (**2–4 minutes**, per ETHGlobal submission guidance)
- 演示视频（**2–4 分钟**，按 ETHGlobal 提交指南）
- Screen recording of full user flow: connect wallet → view risk → trigger protection
- 完整用户流程录屏：连接钱包 → 查看风险 → 触发保护
- Deployed frontend URL (Vercel/Netlify or similar)
- 已部署的前端 URL（Vercel/Netlify 等）

**Partner Prize Claims** (Optional; select **up to 3**):
**合作伙伴奖项申报**（可选；最多选 3 个）：
- Document which Partner Prizes are targeted
- 记录所申报的合作伙伴奖项
- Explain “How we used [Partner Tech]” with specific integration details
- 用具体集成细节说明“我们如何使用了 [合作伙伴技术]”
- Provide feedback on partner tools/SDKs used
- 提供对所使用合作伙伴工具/SDK 的反馈

**Rationale**: Ensures judges can fully evaluate the project, demonstrates completeness, and facilitates potential follow-up or replication.
**理由**：确保评委可全面评估项目，展示完整性，并便于后续跟进或复现。

## Development Workflow Standards
## 开发工作流标准

**Daily Rituals**:
**每日仪式**：
- Start of day: Review previous day's CHANGELOG, prioritize tasks
- 每日开始：回顾前一天 CHANGELOG，优先安排任务
- During development: Commit frequently (min 3x/day), log AI usage immediately
- 开发期间：频繁提交（每天至少 3 次），立即记录 AI 使用情况
- End of day: Update CHANGELOG with bullet-point summary, push all commits
- 每日结束：用要点更新 CHANGELOG，推送所有提交

**Pre-Commit Checklist**:
**提交前清单**：
- [ ] Code compiles/builds without errors
- [ ] 代码无错误编译/构建
- [ ] Relevant tests pass (or are marked TODO if blocked)
- [ ] 相关测试通过（如受阻则标记 TODO）
- [ ] AI assistance logged in AI_USAGE.md (if applicable)
- [ ] AI 协助已记录于 AI_USAGE.md（如适用）
- [ ] .env files not staged for commit
- [ ] .env 文件未加入提交暂存
- [ ] Commit message follows Conventional Commits format
- [ ] 提交信息遵循 Conventional Commits 格式

**Pre-PR Merge Checklist**:
**PR 合并前清单**：
- [ ] Self-review completed (read your own diff)
- [ ] 完成自审（阅读自己的差异）
- [ ] No debug console.logs or commented-out code blocks
- [ ] 无调试 console.log 或注释掉的代码块
- [ ] CHANGELOG.md updated
- [ ] 已更新 CHANGELOG.md
- [ ] README updated if user-facing changes
- [ ] 如有面向用户的变更，已更新 README
- [ ] Manual testing of affected features performed
- [ ] 已对手动测试受影响功能

**Testing Discipline**:
**测试纪律**：
- Unit tests for pure functions (utilities, calculations)
- 纯函数（工具、计算）需有单元测试
- Integration tests for contract interactions
- 合约交互需有集成测试
- E2E tests for critical user flows (optional but recommended)
- 关键用户流程需有端到端测试（可选但推荐）
- Test coverage SHOULD increase over time; decreases MUST be justified
- 测试覆盖率应随时间增长；下降必须说明理由

**Rationale**: Maintains consistent quality, prevents last-minute scrambles, and creates a professional development cadence.
**理由**：保持一致质量，避免最后时刻慌乱，并建立专业开发节奏。

## Governance
## 治理

This Constitution is the supreme authority for all development, planning, and delivery decisions for the DeRisk Watchtower project during ETHOnline 2025.
本章程是 ETHOnline 2025 期间 DeRisk 瞭望塔项目所有开发、规划与交付决策的最高权威。

**Precedence**:
**优先级**：
- Constitution principles supersede all other practices, conventions, or preferences
- 章程原则高于所有其他实践、惯例或偏好
- In case of conflict, Constitution rules apply; document the conflict and resolution in CHANGELOG.md
- 如发生冲突，以章程规则为准；在 CHANGELOG.md 中记录冲突及解决方案
- Speckit-generated artifacts (spec.md, plan.md, tasks.md) MUST align with Constitution principles
- Speckit 生成的产物（spec.md、plan.md、tasks.md）必须与章程原则保持一致

**Amendment Process**:
**修订流程**：
1. Proposed amendment documented with rationale
1. 记录拟议修订及其理由
2. Version bump determined (MAJOR/MINOR/PATCH per semver)
2. 确定版本号升级（按 semver 的主/次/补丁）
3. Update Constitution with new version and Last Amended date
3. 更新章程，注明新版本及最后修订日期
4. Validate and update dependent templates (plan-template, spec-template, tasks-template)
4. 验证并更新相关模板（plan-template、spec-template、tasks-template）
5. Commit with message: `docs: amend constitution to vX.Y.Z (<summary>)`
5. 提交信息：`docs: amend constitution to vX.Y.Z (<摘要>)`

**Compliance Review**:
**合规审查**：
- All pull requests SHOULD self-certify alignment with relevant principles
- 所有拉取请求应自我认证与相关原则一致
- Daily standup/log review SHOULD verify CHANGELOG and AI_USAGE updates
- 每日站会/日志审查应验证 CHANGELOG 和 AI_USAGE 更新
- Pre-submission audit MUST verify all Deliverables checklist items
- 提交前审计必须验证所有交付物清单项

**Runtime Development Guidance**:
**运行时开发指导**：
- For agent-specific workflow guidance, see `.specify/templates/commands/` documentation
- 代理特定工作流指导见 `.specify/templates/commands/` 文档
- For human developer guidance, see `docs/` directory
- 人类开发者指导见 `docs/` 目录
- When Constitution and guidance conflict, Constitution takes precedence
- 章程与指导冲突时，以章程为准

**Version**: 1.0.1 | **Ratified**: 2025-10-13 | **Last Amended**: 2025-10-13
**版本**：1.0.1 | **批准**：2025-10-13 | **最后修订**：2025-10-13
