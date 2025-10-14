 DeRisk Watchtower（How：在不改动规格的前提下）

目标：以最小可行、评审可复现、证据可链接的工程方案，兑现 spec.md 的 FR/NFR 与成功标准；严格对齐 constitution.md 1.0.1 的“测试网、AI 归因、Trunk-Based、小步提交、/metrics 与 Grafana JSON、≤3 Partner、Hacker Dashboard 取证”等约束。

A. 架构与交互（含时序要点）

组件拓扑
Solidity（Foundry：PositionVault / Protector）
→ The Graph 子图（或等价托管子图）
→ Chainlink Automation（CRON/条件触发 + 手动 override 兜底）
→ Go(chi) API & WebSocket 服务（暴露 /metrics、/healthz）
→ Next.js + wagmi/viem 前端（WS 实时、重连回放、离线回放）
→ Prometheus / Grafana（指标采集 + JSON 导出）

Base Sepolia 作为唯一网络（水龙头/浏览器/文档齐全，评审易复现）。
Foundry 工具链（forge/anvil/cast）作为合约开发与本地链模拟。
前端钱包交互采用 wagmi/viem（现代、轻量、与 RPC/签名深度集成）。
核心时序（含可观测与兜底）

1）用户连接钱包 → 前端读取子图/RPC 基础数据（positions/HF）。

2）后端周期复核 HF：RPC 拉取价格/余额并计算；将 hf 与时间戳回填给前端。

3）触发判定：HF ≤ 阈值(默认 1.3) → 生成 RiskEvent（UI Banner + WS 推送，P95≤10s）。

4）自动化：满足条件时由 Chainlink Upkeep 调用 Protector.protect(...)；若延迟/额度受限→后端提供手动 override API/脚本兜底。

5）上链事件 → 子图索引更新 → 前端时间线刷新 & 前/后对比。

6）可观测：在每一步埋点 Prometheus（计数器 _total、直方图 _seconds）；暴露 /metrics，Grafana 看板展示触发/失败/延迟/监控数。

7）数据“陈旧度”治理：UI 显示 lastSync；若 now - lastSync > 60s 标记 Stale，并对 HF 关键视图优先 RPC 直读；手动“Refresh” 对账 Graph+RPC。
8）WS 断线回放：客户端带 serverEventTs 重连；服务端回放 60s 内事件并标注 replayed=true。
9）Demo 兜底：提供 ?replay=1 离线回放（docs/fixtures/*.json），保证 2–4 分钟演示稳定。


B. 技术选型与权衡（Why）
网络：Base Sepolia — Faucet 友好、官方浏览器可验证、生态活跃，评委零资金复现门槛低。
合约：Foundry + OpenZeppelin — Foundry 编译/测试/部署一体；OZ 提供 ReentrancyGuard/Pausable 等安全基线，配 SPDX 头，降低演示风险与审查成本。
索引：The Graph Network / 替代托管 — 官方 Hosted Service 已迁移至去中心化网络；必要时使用等价托管（如 Alchemy Subgraphs）以提升稳定性与上手速度。
自动化：Chainlink Automation — 原生 CRON/条件触发，支持 Base Sepolia；如网络/额度约束，则用本地 CRON + 手动 override API 兜底，保证 Demo 不掉链。
后端：Go + chi + OpenAPI — 轻量高并发；promhttp 快速暴露 /metrics；OpenAPI 便于评审用 Postman 验证。
前端：Next.js + wagmi/viem — 现代 React 生态 + 简洁的链上交互抽象；内建连接器，减少自写签名/RPC 细节。
可观测：Prometheus + Grafana — 采用官方命名/直方图最佳实践，导出看板 JSON 随仓库交付，评委一键导入复现。

C. 数据与接口契约（供代码生成/联调）
GraphQL（Subgraph）
positionsByOwner(owner: String!, first: Int, skip: Int): [Position!]!
riskEventsByPosition(positionId: ID!, first: Int, order: String): [RiskEvent!]!

说明：Position{id, owner, collateral, debt, hf, lastUpdateAt}；RiskEvent{id, positionId, type, deltaHF, txHash, createdAt}
注：部署至 Graph Network 或托管替代，端点写入 README & PROOF。

REST（后端）

GET /api/positions?owner=0x... → [{ id, collateral, debt, hf, lastUpdateAt }]

GET /api/hf/{address} → { hf, lastUpdateAt }

GET /healthz → { status: "ok", version, now }（健康检查）

GET /metrics → Prometheus 暴露（采集端拉取）。


WebSocket

WS /ws/risk-stream（消息结构）：

{
  "type": "RiskAlert",
  "positionId": "0x...",
  "hf": 0.85,
  "threshold": 1.30,
  "txHash": "0x...",
  "timestamp": 1699999999,
  "replayed": false
}


重连：客户端带 serverEventTs，服务端回放最近 60s（并 replayed=true）。

指标（Prometheus 命名与类型）

计数器：risk_event_trigger_total、protect_success_total、protect_failure_total

直方图（秒）：alert_latency_seconds、protect_e2e_seconds（建议桶：0.5/1/2/5/10）

量表：positions_monitored

采用官方命名/单位指引与直方图实践；SLO 以 P95 计算。


D. 安全与合规

仅测试网：Base Sepolia，杜绝主网。

最小授权：合约/后端/自动化均按最小权限设计；手动 override 需受限开关与审计日志。
OZ 安全基线：关键路径使用 ReentrancyGuard、必要时 Pausable；输入校验、事件发射、失败回滚清晰。
机密管理：.env + .env.example；严禁泄露密钥。
Start-Fresh & AI 归因：AI_USAGE.md 到“文件/提交粒度”，CHANGELOG.md 日更，docs/PROOF.md 存 Hacker Dashboard 提交链接与截图。
自动化兜底：Chainlink Upkeep 之外，提供 CLI/CRON/后端接口手动触发；将 Upkeep ID/面板链接写入 README。
索引迁移策略：优先 Graph Network；若托管端点不稳，切至替代服务并在 README 标注；UI 显式 lastSync 与 Stale 提示。


E. 交付与集成

一键脚本：docker-compose up -d backend frontend prometheus grafana（含 sample env）。

合约：部署/验证脚本；BaseScan/Blockscout 链接；SPDX 头。

子图：schema.graphql、subgraph.yaml、部署命令与端点；两条查询样例文档。

自动化：Upkeep 名称/频率/条件、ID、面板截图与链接。

可观测：/metrics 采集配置；configs/grafana/*.json 看板导出与 README 导入步骤（Export as JSON / JSON Model）。

前端演示：Vercel/Netlify 部署链接；?replay=1 回放开关；只读 Demo 账户清单（零资金复现）。

文档：README（运行/演示/端点/Partner 用法与反馈）、AI_USAGE、CHANGELOG、PROOF（区块浏览器/子图/Upkeep/Grafana 截图与 Dashboard 提交链接）。


F. Definition of Done（DoD）
满足 spec.md 全部 FR/NFR 与“成功标准”（2–4 分钟全链路、≤8 次点击、P95≤10s 预警、5s 内前后对比更新等）。
端到端 Demo 顺滑：在线演示 + ?replay=1 离线回放均可完成。
可观测齐全：/metrics 可抓取、Grafana 三图（触发/失败/延迟）可见、看板 JSON 已随仓库交付并在 README 写明导入步骤。
交付物完备：公开仓库、合约与区块浏览器链接、子图端点、Upkeep 详情与截图、前端部署链接、OpenAPI、Postman 集合、视频（2–4 分钟）、PROOF（含 Hacker Dashboard 提交链接）。

合规通过：仅测试网、AI 归因、Trunk-Based 小步提交（≥3 次/日）、Conventional Commits、SPDX/OZ、安全/最小授权、.env 管理全部落实。