# Changelog (ETHOnline 2025)

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