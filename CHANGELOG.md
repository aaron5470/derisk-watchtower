# Changelog (ETHOnline 2025)

## 2025-01-16 (E5 Frontend)
**EN:** Initialize E5 Frontend development branch with Next.js 14 setup.
**中文：** 初始化 E5 前端开发分支，配置 Next.js 14。

### Added / 新增
- 007-derisk-watchtower-frontend branch created from latest main
- 007-derisk-watchtower-frontend 分支从最新 main 创建
- Draft PR opened for early CI/CD validation
- 草稿 PR 已开启用于早期 CI/CD 验证

## 2025-10-14 (D2)
**EN:** Complete E0 initialization tasks - environment setup, tooling, observability stack.
**中文：** 完成 E0 初始化任务 - 环境设置、工具、可观测性栈。

### Added / 新增
- .gitignore patterns for Go, Foundry, IDE files
- .gitignore 模式：Go、Foundry、IDE 文件
- .env.example template with all configuration variables
- .env.example 模板包含所有配置变量
- Makefile with install, build, test, dev, clean targets
- Makefile 包含 install、build、test、dev、clean 目标
- Bootstrap script (scripts/bootstrap.sh) for first-time setup
- 引导脚本（scripts/bootstrap.sh）用于首次设置
- Environment validation script (scripts/check-env.sh)
- 环境验证脚本（scripts/check-env.sh）
- Docker Compose configuration for Prometheus + Grafana
- Docker Compose 配置：Prometheus + Grafana
- Prometheus scrape configuration (configs/prometheus/prometheus.yml)
- Prometheus 抓取配置（configs/prometheus/prometheus.yml）
- Grafana datasource configuration (configs/grafana/datasources/prometheus.yml)
- Grafana 数据源配置（configs/grafana/datasources/prometheus.yml）
- Minimal Go backend with /healthz and /metrics endpoints
- 最小 Go 后端包含 /healthz 与 /metrics 端点
- Smoke test script (scripts/smoke-test.sh) for integration testing
- 冒烟测试脚本（scripts/smoke-test.sh）用于集成测试
- Updated README with quick start commands and architecture diagram
- 更新 README 包含快速开始命令与架构图

### Technical Details / 技术细节
- Backend uses chi router and Prometheus client for Go
- 后端使用 chi 路由与 Prometheus Go 客户端
- All scripts are executable and follow bash best practices
- 所有脚本可执行并遵循 bash 最佳实践
- Observability stack runs on ports 9090 (Prometheus), 3001 (Grafana)
- 可观测性栈运行在端口 9090（Prometheus）、3001（Grafana）
- Backend API runs on port 8080
- 后端 API 运行在端口 8080

## 2025-10-13 (D1)
**EN:** Initialize project skeleton directories, add compliance files (AI_USAGE / CHANGELOG / docs).  
**中文：** 初始化项目结构目录，添加合规文件（AI_USAGE / CHANGELOG / docs）。

### Added / 新增
- Core project directories: web, api, contracts, scripts, configs, docs, core, internal, tests
- 核心项目目录：web, api, contracts, scripts, configs, docs, core, internal, tests
- .gitkeep files for Git tracking of empty directories
- .gitkeep 文件用于 Git 跟踪空目录
- AI_USAGE.md for AI tool attribution and compliance
- AI_USAGE.md 用于 AI 工具归因和合规
- CHANGELOG.md for project development tracking
- CHANGELOG.md 用于项目开发跟踪
- docs/PROOF.md template for work proof documentation
- docs/PROOF.md 工作证明文档模板
- README.md with bilingual project description and setup instructions
- README.md 包含双语项目描述和设置说明

### Technical Details / 技术细节
- Project structure follows ETHOnline 2025 requirements
- 项目结构遵循 ETHOnline 2025 要求
- Bilingual documentation (English/Chinese) for international accessibility
- 双语文档（英文/中文）便于国际访问
- Compliance-ready for hackathon submission
- 为黑客马拉松提交做好合规准备
## 2025-10-19 (D6 - E3 Chainlink Automation)
**EN:** Initialize E3 Chainlink Automation branch for automated position protection.
**中文：** 初始化 E3 Chainlink Automation 分支用于自动化头寸保护。

### Added / 新增
- Branch 005-derisk-watchtower-automation created from main
- 从 main 创建分支 005-derisk-watchtower-automation
- Draft PR opened for early CI/CD validation
- 开启草稿 PR 以提前进行 CI/CD 验证

### Planned / 计划中
- AutomationCompatibleInterface implementation in Protector contract
- Protector 合约中实现 AutomationCompatibleInterface
- Chainlink Automation Upkeep registration scripts
- Chainlink Automation Upkeep 注册脚本
- Backend automation monitoring service
- 后端自动化监控服务
- Subgraph automation event indexing
- 子图自动化事件索引

## 2025-01-19 (D7 - E4 Go API & WebSocket)
**EN:** Initialize E4 Go API & WebSocket branch for real-time risk monitoring.
**中文：** 初始化 E4 Go API & WebSocket 分支用于实时风险监控。

### Added / 新增
- Branch 006-derisk-watchtower-api-ws created from main
- 从 main 创建分支 006-derisk-watchtower-api-ws
- Draft PR #3 opened for early CI/CD validation
- 开启草稿 PR #3 以提前进行 CI/CD 验证

### Planned / 计划中
- Go backend API with chi router and WebSocket support
- Go 后端 API 使用 chi 路由器和 WebSocket 支持
- Real-time risk alert broadcasting via WebSocket
- 通过 WebSocket 实时风险警报广播
- Position monitoring service with health factor tracking
- 头寸监控服务与健康因子跟踪
- Subgraph client with staleness detection
- 子图客户端与陈旧度检测
- Prometheus metrics for API performance monitoring
- Prometheus 指标用于 API 性能监控
