# DeRisk Watchtower (ETHOnline 2025)

**EN:** Real-time DeFi position risk monitor with alerts and one-click auto-protect on Base testnet.  
**中文：** 在 Base 测试网演示"借贷仓位实时风控 + 告警 + 一键保仓"的最小可用方案。

- **Why / 为什么：** Reduce liquidation risk with simple, explainable protection flows. / 用直观可解释流程降低被清算风险。
- **Stack / 技术栈：** web / api / contracts / scripts / configs / core / internal / tests
- **Start Fresh & AI Attribution / 从零开发与 AI 归因：** See `AI_USAGE.md` + `CHANGELOG.md`.
- **How to run / 运行方式（示例）：**
  ```bash
  cd web && npm run dev
  cd api && go run main.go
  cd contracts && forge build
  ```

**Networks & faucets / 测试网与水龙头：** Base Sepolia（ETH / LINK 水龙头）。

## Project Structure / 项目结构

```
derisk-watchtower/
├── web/           # Frontend React/Next.js application / 前端应用
├── api/           # Backend API service / 后端 API 服务
├── contracts/     # Smart contracts (Solidity/Foundry) / 智能合约
├── scripts/       # Deployment and utility scripts / 部署和工具脚本
├── configs/       # Configuration files / 配置文件
├── docs/          # Documentation / 文档
├── core/          # Core business logic / 核心业务逻辑
├── internal/      # Internal utilities / 内部工具
├── tests/         # Test suites / 测试套件
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
- Node.js 18+ / Node.js 18+
- Go 1.21+ / Go 1.21+
- Foundry / Foundry
- MetaMask or compatible wallet / MetaMask 或兼容钱包

### Installation / 安装

1. **Clone the repository / 克隆仓库**
   ```bash
   git clone <repository-url>
   cd derisk-watchtower
   ```

2. **Setup Frontend / 设置前端**
   ```bash
   cd web
   npm install
   npm run dev
   ```

3. **Setup Backend / 设置后端**
   ```bash
   cd api
   go mod init derisk-watchtower-api
   go run main.go
   ```

4. **Setup Contracts / 设置合约**
   ```bash
   cd contracts
   forge install
   forge build
   forge test
   ```

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
