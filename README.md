# DeRisk Watchtower (ETHOnline 2025)

**EN:** Real-time DeFi position risk monitor with alerts and one-click auto-protect on Base testnet.  
**中文：** 在 Base 测试网演示"借贷仓位实时风控 + 告警 + 一键保仓"的最小可用方案。

- **Why / 为什么：** Reduce liquidation risk with simple, explainable protection flows. / 用直观可解释流程降低被清算风险。
- **Stack / 技术栈：** web / api / contracts / scripts / configs / core / internal / tests
- **Start Fresh & AI Attribution / 从零开发与 AI 归因：** See `AI_USAGE.md` + `CHANGELOG.md`.
- **How to run / 运行方式：**
  ```bash
  # Bootstrap project / 引导项目
  ./scripts/bootstrap.sh

  # Start observability stack / 启动可观测性栈
  docker-compose up -d

  # Run smoke tests / 运行冒烟测试
  ./scripts/smoke-test.sh
  ```

**Networks & faucets / 测试网与水龙头：** Base Sepolia（ETH / LINK 水龙头）。

## Project Structure / 项目结构

```
derisk-watchtower/
├── contracts/     # Smart contracts (Foundry) / 智能合约（Foundry）
├── subgraph/      # The Graph indexing / The Graph 索引
├── backend/       # Go API server + WebSocket / Go API 服务器 + WebSocket
├── frontend/      # Next.js 14 App Router / Next.js 14 App Router
├── configs/       # Prometheus + Grafana configs / Prometheus + Grafana 配置
├── docs/          # Documentation / 文档
├── scripts/       # Bootstrap and utility scripts / 引导与工具脚本
├── AI_USAGE.md    # AI tool attribution / AI 工具归因
└── CHANGELOG.md   # Development log / 开发日志
```

## Features / 功能特性

### Core Features / 核心功能
- **Real-time Monitoring / 实时监控:** Track DeFi positions and liquidation risks
- **Smart Alerts / 智能告警:** Proactive notifications before liquidation events
- **Auto-Protection / 自动保护:** One-click position protection mechanisms
- **Base Integration / Base 集成:** Native support for Base testnet ecosystem

### Technical Features / 技术特性
- **Multi-Protocol Support / 多协议支持:** Compatible with major DeFi protocols
- **Risk Calculation Engine / 风险计算引擎:** Advanced algorithms for risk assessment
- **User-Friendly Interface / 用户友好界面:** Intuitive dashboard for position management
- **Compliance Ready / 合规就绪:** Full documentation and audit trails

## Getting Started / 快速开始

### Prerequisites / 前置要求
- Node.js 18+ ([Download](https://nodejs.org/))
- Go 1.21+ ([Download](https://golang.org/doc/install))
- Foundry ([Install](https://book.getfoundry.sh/getting-started/installation))
- Docker & Docker Compose ([Download](https://docs.docker.com/get-docker/))
- Graph CLI (`npm install -g @graphprotocol/graph-cli`)

### Installation / 安装

1. **Bootstrap the project / 引导项目**
   ```bash
   ./scripts/bootstrap.sh
   ```

2. **Start observability services / 启动可观测性服务**
   ```bash
   docker-compose up -d
   ```
   - Grafana: http://localhost:3001 (admin/admin)
   - Prometheus: http://localhost:9090

3. **Start backend server / 启动后端服务器**
   ```bash
   cd backend && go run cmd/server/main.go
   ```
   - Health check: http://localhost:8080/healthz
   - Metrics: http://localhost:8080/metrics

### Development Workflow / 开发流程

1. **Daily Documentation / 每日文档更新**
   - Update `docs/PROOF.md` with daily progress / 更新每日进度到 `docs/PROOF.md`
   - Log AI assistance in `AI_USAGE.md` / 在 `AI_USAGE.md` 中记录 AI 协助
   - Update `CHANGELOG.md` with new features / 在 `CHANGELOG.md` 中更新新功能

2. **Testing / 测试**
   ```bash
   # Run all tests / 运行所有测试
   cd tests && npm test
   
   # Contract tests / 合约测试
   cd contracts && forge test
   
   # API tests / API 测试
   cd api && go test ./...
   ```

## Contributing / 贡献

This project is developed for ETHOnline 2025. All AI assistance is documented in `AI_USAGE.md` for transparency and compliance.

本项目为 ETHOnline 2025 开发。所有 AI 协助都记录在 `AI_USAGE.md` 中以确保透明度和合规性。

## License / 许可证

MIT License - see LICENSE file for details.
