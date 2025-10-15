# E0 Init & Tooling Tasks（E0 初始化与环境任务）

**Feature**: DeRisk Watchtower | **分支**: `001-derisk-watchtower-real`
**Feature**: DeRisk 瞭望塔 | **Branch**: `001-derisk-watchtower-real`

---

## E0.1 Repository & Branch Setup（仓库与分支设置）

### E0.1.1 Create feature branch
### E0.1.1 创建功能分支
```bash
git checkout -b 001-derisk-watchtower-real
```

### E0.1.2 Verify branch is clean
### E0.1.2 验证分支干净
```bash
git status
```

### E0.1.3 Set up .gitignore for all components
### E0.1.3 为所有组件设置 .gitignore
Add entries: `.env`, `node_modules/`, `dist/`, `*.log`, `.DS_Store`
添加条目：`.env`、`node_modules/`、`dist/`、`*.log`、`.DS_Store`

---

## E0.2 Toolchain Version Check（工具链版本检查）

### E0.2.1 Check Node.js version
### E0.2.1 检查 Node.js 版本
```bash
node --version  # Expected: v18.x or v20.x
```

### E0.2.2 Check Go version
### E0.2.2 检查 Go 版本
```bash
go version  # Expected: go1.21.x or go1.22.x
```

### E0.2.3 Check Foundry installation
### E0.2.3 检查 Foundry 安装
```bash
forge --version
cast --version
anvil --version
```

### E0.2.4 Check Docker and Docker Compose
### E0.2.4 检查 Docker 与 Docker Compose
```bash
docker --version
docker-compose --version
```

### E0.2.5 Check Graph CLI installation
### E0.2.5 检查 Graph CLI 安装
```bash
graph --version  # Expected: @graphprotocol/graph-cli
```

### E0.2.6 Install missing tools if needed
### E0.2.6 如需安装缺失工具
Document installation URLs in README prerequisites
在 README 前提中记录安装 URL

---

## E0.3 Environment Configuration（环境配置）

### E0.3.1 Create .env.example template
### E0.3.1 创建 .env.example 模板
File path: `.env.example`
文件路径：`.env.example`

```bash
# Network Configuration
NETWORK=base-sepolia
CHAIN_ID=84532
BASE_SEPOLIA_RPC=https://sepolia.base.org

# Contract Deployment
DEPLOYER_PRIVATE_KEY=0x_REPLACE_WITH_YOUR_TESTNET_KEY

# The Graph
SUBGRAPH_ENDPOINT=https://api.studio.thegraph.com/query/YOUR_SUBGRAPH

# Chainlink Automation
CHAINLINK_UPKEEP_ID=YOUR_UPKEEP_ID
LINK_TOKEN_ADDRESS=0xE4aB69C077896252FAFBD49EFD26B5D171A32410

# Backend API
API_PORT=8080
CACHE_TTL_SECONDS=30

# AI Service (Optional)
OPENAI_API_KEY=your_openai_key_here

# Observability
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_WS_URL=ws://localhost:8080/ws/risk-stream
NEXT_PUBLIC_CHAIN_ID=84532
```

### E0.3.2 Create personal .env from template
### E0.3.2 从模板创建个人 .env
```bash
cp .env.example .env
```

### E0.3.3 Verify .env is in .gitignore
### E0.3.3 验证 .env 在 .gitignore 中
Ensure `.env` file is never committed
确保 `.env` 文件永不提交

---

## E0.4 Task Runner Setup（任务运行器设置）

### E0.4.1 Create Makefile for common commands
### E0.4.1 创建 Makefile 放常用命令
File path: `Makefile`
文件路径：`Makefile`

```makefile
.PHONY: help install build test clean dev

help:
	@echo "Available targets:"
	@echo "  install    - Install all dependencies"
	@echo "  build      - Build all components"
	@echo "  test       - Run all tests"
	@echo "  dev        - Start development services"
	@echo "  clean      - Clean build artifacts"

install:
	cd contracts && forge install
	cd backend && go mod download
	cd frontend && npm install

build:
	cd contracts && forge build
	cd backend && go build -o bin/server cmd/server/main.go
	cd frontend && npm run build

test:
	cd contracts && forge test
	cd backend && go test ./...
	cd frontend && npm test

dev:
	docker-compose up -d prometheus grafana
	@echo "Services started. Check http://localhost:3001 (Grafana)"

clean:
	cd contracts && forge clean
	cd backend && rm -rf bin/
	cd frontend && rm -rf .next/
```

### E0.4.2 Test Makefile targets
### E0.4.2 测试 Makefile 目标
```bash
make help
```

---

## E0.5 Bootstrap Scripts（引导脚本）

### E0.5.1 Create bootstrap.sh for first-time setup
### E0.5.1 创建 bootstrap.sh 首次设置
File path: `scripts/bootstrap.sh`
文件路径：`scripts/bootstrap.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> Bootstrapping DeRisk Watchtower..."

# Check prerequisites
echo "==> Checking prerequisites..."
command -v node >/dev/null 2>&1 || { echo "Node.js required"; exit 1; }
command -v go >/dev/null 2>&1 || { echo "Go required"; exit 1; }
command -v forge >/dev/null 2>&1 || { echo "Foundry required"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker required"; exit 1; }

# Create .env if not exists
if [ ! -f .env ]; then
  echo "==> Creating .env from template..."
  cp .env.example .env
  echo "Please edit .env with your configuration"
fi

# Install dependencies
echo "==> Installing dependencies..."
make install

echo "==> Bootstrap complete! Run 'make dev' to start."
```

### E0.5.2 Make bootstrap.sh executable
### E0.5.2 使 bootstrap.sh 可执行
```bash
chmod +x scripts/bootstrap.sh
```

### E0.5.3 Create check-env.sh validation script
### E0.5.3 创建 check-env.sh 验证脚本
File path: `scripts/check-env.sh`
文件路径：`scripts/check-env.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> Validating environment configuration..."

# Check .env exists
[ -f .env ] || { echo "ERROR: .env not found"; exit 1; }

# Load .env
source .env

# Validate required variables
: "${BASE_SEPOLIA_RPC:?ERROR: BASE_SEPOLIA_RPC not set}"
: "${CHAIN_ID:?ERROR: CHAIN_ID not set}"
: "${API_PORT:?ERROR: API_PORT not set}"

echo "==> Environment validation passed!"
```

### E0.5.4 Make check-env.sh executable
### E0.5.4 使 check-env.sh 可执行
```bash
chmod +x scripts/check-env.sh
```

---

## E0.6 Docker Compose for Observability（可观测性 Docker Compose）

### E0.6.1 Create docker-compose.yml
### E0.6.1 创建 docker-compose.yml
File path: `docker-compose.yml`
文件路径：`docker-compose.yml`

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: derisk-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./configs/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: derisk-grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
      - ./configs/grafana:/etc/grafana/provisioning
    depends_on:
      - prometheus
    restart: unless-stopped

volumes:
  prometheus-data:
  grafana-data:
```

### E0.6.2 Create Prometheus config
### E0.6.2 创建 Prometheus 配置
File path: `configs/prometheus/prometheus.yml`
文件路径：`configs/prometheus/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'derisk-watchtower-api'
    static_configs:
      - targets: ['host.docker.internal:8080']
    metrics_path: '/metrics'
```

### E0.6.3 Create Grafana datasources config
### E0.6.3 创建 Grafana 数据源配置
File path: `configs/grafana/datasources/prometheus.yml`
文件路径：`configs/grafana/datasources/prometheus.yml`

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

### E0.6.4 Test Docker Compose startup
### E0.6.4 测试 Docker Compose 启动
```bash
docker-compose up -d
docker-compose ps
```

### E0.6.5 Verify Prometheus accessible
### E0.6.5 验证 Prometheus 可访问
Open browser: `http://localhost:9090`
打开浏览器：`http://localhost:9090`

### E0.6.6 Verify Grafana accessible
### E0.6.6 验证 Grafana 可访问
Open browser: `http://localhost:3001`
打开浏览器：`http://localhost:3001`
Login: admin / admin
登录：admin / admin

---

## E0.7 Health Check & Metrics Smoke Test（健康检查与指标冒烟测试）

### E0.7.1 Create minimal Go backend for /healthz
### E0.7.1 创建最小 Go 后端实现 /healthz
File path: `backend/cmd/server/main.go`
文件路径：`backend/cmd/server/main.go`

```go
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Version string `json:"version"`
	Now     int64  `json:"now"`
}

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	r.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(HealthResponse{
			Status:  "ok",
			Version: "0.1.0",
			Now:     time.Now().Unix(),
		})
	})

	port := os.Getenv("API_PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}
```

### E0.7.2 Initialize Go module for backend
### E0.7.2 初始化后端 Go 模块
```bash
cd backend
go mod init github.com/derisk-watchtower/backend
go get github.com/go-chi/chi/v5
```

### E0.7.3 Build minimal backend
### E0.7.3 构建最小后端
```bash
cd backend
go build -o bin/server cmd/server/main.go
```

### E0.7.4 Run backend server
### E0.7.4 运行后端服务器
```bash
cd backend
./bin/server
```

### E0.7.5 Smoke test /healthz endpoint
### E0.7.5 冒烟测试 /healthz 端点
```bash
curl http://localhost:8080/healthz
```
Expected output: `{"status":"ok","version":"0.1.0","now":...}`
预期输出：`{"status":"ok","version":"0.1.0","now":...}`

### E0.7.6 Add /metrics endpoint stub
### E0.7.6 添加 /metrics 端点桩
File path: `backend/cmd/server/main.go` (append)
文件路径：`backend/cmd/server/main.go`（追加）

```go
// Add to imports
import "github.com/prometheus/client_golang/prometheus/promhttp"

// Add to router setup
r.Handle("/metrics", promhttp.Handler())
```

### E0.7.7 Install Prometheus client library
### E0.7.7 安装 Prometheus 客户端库
```bash
cd backend
go get github.com/prometheus/client_golang/prometheus/promhttp
```

### E0.7.8 Rebuild backend with metrics
### E0.7.8 重新构建带指标后端
```bash
cd backend
go build -o bin/server cmd/server/main.go
```

### E0.7.9 Smoke test /metrics endpoint
### E0.7.9 冒烟测试 /metrics 端点
```bash
curl http://localhost:8080/metrics
```
Expected: Prometheus text format output
预期：Prometheus 文本格式输出

### E0.7.10 Verify Prometheus scrapes backend
### E0.7.10 验证 Prometheus 抓取后端
Open Prometheus UI: `http://localhost:9090/targets`
打开 Prometheus UI：`http://localhost:9090/targets`
Check `derisk-watchtower-api` target is UP
检查 `derisk-watchtower-api` 目标为 UP

---

## E0.8 Smoke Test Script（冒烟测试脚本）

### E0.8.1 Create smoke-test.sh
### E0.8.1 创建 smoke-test.sh
File path: `scripts/smoke-test.sh`
文件路径：`scripts/smoke-test.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> Running smoke tests..."

# Test 1: Health endpoint
echo "==> Testing /healthz..."
curl -sf http://localhost:8080/healthz | grep -q '"status":"ok"' || {
  echo "ERROR: /healthz failed"
  exit 1
}
echo "✓ /healthz passed"

# Test 2: Metrics endpoint
echo "==> Testing /metrics..."
curl -sf http://localhost:8080/metrics | grep -q 'go_info' || {
  echo "ERROR: /metrics failed"
  exit 1
}
echo "✓ /metrics passed"

# Test 3: Prometheus reachable
echo "==> Testing Prometheus..."
curl -sf http://localhost:9090/-/healthy > /dev/null || {
  echo "ERROR: Prometheus unreachable"
  exit 1
}
echo "✓ Prometheus reachable"

# Test 4: Grafana reachable
echo "==> Testing Grafana..."
curl -sf http://localhost:3001/api/health | grep -q '"database":"ok"' || {
  echo "ERROR: Grafana unreachable"
  exit 1
}
echo "✓ Grafana reachable"

echo "==> All smoke tests passed!"
```

### E0.8.2 Make smoke-test.sh executable
### E0.8.2 使 smoke-test.sh 可执行
```bash
chmod +x scripts/smoke-test.sh
```

### E0.8.3 Run smoke test suite
### E0.8.3 运行冒烟测试套件
```bash
./scripts/smoke-test.sh
```

---

## E0.9 Documentation Updates（文档更新）

### E0.9.1 Create initial README.md structure
### E0.9.1 创建初始 README.md 结构
File path: `README.md`
文件路径：`README.md`

```markdown
# DeRisk Watchtower

Real-time DeFi position monitoring with alerts and one-click protection on Base Sepolia.

## Quick Start

```bash
# Bootstrap project
./scripts/bootstrap.sh

# Start observability stack
docker-compose up -d

# Run smoke tests
./scripts/smoke-test.sh
```

## Prerequisites

- Node.js 18+
- Go 1.21+
- Foundry (forge, cast, anvil)
- Docker & Docker Compose
- Graph CLI

## Architecture

```
User → Next.js Frontend → Go API → Base Sepolia
                ↓           ↓
          WebSocket    Subgraph (The Graph)
                ↓           ↓
          Prometheus ← Chainlink Automation
                ↓
            Grafana
```

## Development

See `specs/001-derisk-watchtower-real/quickstart.md` for detailed setup.

## License

MIT
```

### E0.9.2 Add toolchain versions to README
### E0.9.2 添加工具链版本到 README
Document required versions in Prerequisites section
在前提部分记录所需版本

### E0.9.3 Create initial CHANGELOG.md
### E0.9.3 创建初始 CHANGELOG.md
File path: `CHANGELOG.md`
文件路径：`CHANGELOG.md`

```markdown
# Changelog

All notable changes to DeRisk Watchtower will be documented here.

## [Unreleased]

### Added
- Initial project structure
- Environment configuration (.env.example)
- Docker Compose for Prometheus + Grafana
- Health check endpoint (/healthz)
- Metrics endpoint (/metrics)
- Bootstrap and smoke test scripts

## [0.1.0] - 2025-10-14

### Added
- Project initialization
```

---

## E0.10 Completion Checklist（完成清单）

- [X] Branch `001-derisk-watchtower-real` created
- [X] 分支 `001-derisk-watchtower-real` 已创建
- [X] All toolchain versions verified (Node, Go, Foundry, Docker)
- [X] 所有工具链版本已验证（Node、Go、Foundry、Docker）
- [X] `.env.example` template created and documented
- [X] `.env.example` 模板已创建并记录
- [ ] `.env` created from template (not committed)
- [ ] `.env` 从模板创建（未提交）
- [X] `.gitignore` includes `.env` and build artifacts
- [X] `.gitignore` 包含 `.env` 与构建产物
- [X] Makefile with common targets tested
- [X] Makefile 常用目标已测试
- [X] `scripts/bootstrap.sh` executable and functional
- [X] `scripts/bootstrap.sh` 可执行且功能正常
- [X] `scripts/check-env.sh` validates configuration
- [X] `scripts/check-env.sh` 验证配置
- [X] Docker Compose starts Prometheus + Grafana
- [X] Docker Compose 启动 Prometheus + Grafana
- [X] Backend `/healthz` endpoint returns 200 OK
- [X] 后端 `/healthz` 端点返回 200 OK
- [X] Backend `/metrics` endpoint returns Prometheus format
- [X] 后端 `/metrics` 端点返回 Prometheus 格式
- [ ] Prometheus scrapes backend successfully
- [ ] Prometheus 成功抓取后端
- [ ] Grafana accessible at http://localhost:3001
- [ ] Grafana 可在 http://localhost:3001 访问
- [ ] `scripts/smoke-test.sh` passes all checks
- [ ] `scripts/smoke-test.sh` 通过所有检查
- [X] README.md documents quick start
- [X] README.md 记录快速开始
- [X] CHANGELOG.md initialized with E0 tasks
- [X] CHANGELOG.md 已初始化 E0 任务

---

## E0.11 Pre-commit Hook Setup（预提交钩子设置）

### E0.11.1 Install pre-commit framework | 安装 pre-commit 框架
```bash
pip install pre-commit
```

### E0.11.2 Create .pre-commit-config.yaml | 创建 .pre-commit-config.yaml
File path: `.pre-commit-config.yaml` | 文件路径：`.pre-commit-config.yaml`

### E0.11.3 Add trailing whitespace removal hook | 添加尾随空格移除钩子
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

### E0.11.4 Add Go formatting hook | 添加 Go 格式化钩子
```yaml
  - repo: https://github.com/dnephin/pre-commit-golang
    rev: v0.5.1
    hooks:
      - id: go-fmt
      - id: go-mod-tidy
```

### E0.11.5 Add Node.js linting hook | 添加 Node.js 代码检查钩子
```yaml
  - repo: local
    hooks:
      - id: eslint-frontend
        name: ESLint (Frontend)
        entry: bash -c 'cd frontend && npm run lint'
        language: system
        files: ^frontend/.*\.(ts|tsx|js|jsx)$
```

### E0.11.6 Add Solidity formatting hook | 添加 Solidity 格式化钩子
```yaml
      - id: forge-fmt
        name: Forge Format
        entry: bash -c 'cd contracts && forge fmt --check'
        language: system
        files: ^contracts/.*\.sol$
```

### E0.11.7 Add secret detection hook | 添加敏感信息检测钩子
```yaml
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

### E0.11.8 Install pre-commit hooks | 安装预提交钩子
```bash
pre-commit install
```

### E0.11.9 Run hooks on all files | 对所有文件运行钩子
```bash
pre-commit run --all-files
```

### E0.11.10 Verify hook triggers on commit | 验证提交时钩子触发
Create test commit to ensure hooks run | 创建测试提交确保钩子运行

---

## E0.12 CI Template for Contracts（合约 CI 模板）

### E0.12.1 Create .github/workflows directory | 创建 .github/workflows 目录
```bash
mkdir -p .github/workflows
```

### E0.12.2 Create contracts CI workflow | 创建合约 CI 工作流
File path: `.github/workflows/contracts.yml` | 文件路径：`.github/workflows/contracts.yml`

### E0.12.3 Add Foundry test job | 添加 Foundry 测试任务
```yaml
name: Contracts CI

on:
  push:
    branches: [main, '001-*']
    paths:
      - 'contracts/**'
      - '.github/workflows/contracts.yml'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
```

### E0.12.4 Setup Foundry in CI | 在 CI 中设置 Foundry
```yaml
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1

      - name: Run Forge build
        run: |
          cd contracts
          forge --version
          forge build --sizes
```

### E0.12.5 Add Forge test step | 添加 Forge 测试步骤
```yaml
      - name: Run Forge tests
        run: |
          cd contracts
          forge test -vvv
```

### E0.12.6 Add gas snapshot | 添加 Gas 快照
```yaml
      - name: Run Forge gas snapshot
        run: |
          cd contracts
          forge snapshot
```

### E0.12.7 Add Slither static analysis | 添加 Slither 静态分析
```yaml
  slither:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: crytic/slither-action@v0.3.0
        with:
          target: 'contracts/src/'
```

### E0.12.8 Test workflow locally with act | 用 act 本地测试工作流
Install act and run: `act -j test` | 安装 act 并运行：`act -j test`

---

## E0.13 CI Template for Backend（后端 CI 模板）

### E0.13.1 Create backend CI workflow | 创建后端 CI 工作流
File path: `.github/workflows/backend.yml` | 文件路径：`.github/workflows/backend.yml`

### E0.13.2 Add Go setup and test job | 添加 Go 设置与测试任务
```yaml
name: Backend CI

on:
  push:
    branches: [main, '001-*']
    paths:
      - 'backend/**'
      - '.github/workflows/backend.yml'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
```

### E0.13.3 Setup Go toolchain | 设置 Go 工具链
```yaml
      - uses: actions/setup-go@v5
        with:
          go-version: '1.21'
          cache-dependency-path: backend/go.sum
```

### E0.13.4 Add go mod tidy check | 添加 go mod tidy 检查
```yaml
      - name: Check go mod tidy
        working-directory: ./backend
        run: |
          go mod tidy
          git diff --exit-code go.mod go.sum
```

### E0.13.5 Add go build step | 添加 go build 步骤
```yaml
      - name: Build
        working-directory: ./backend
        run: go build -v ./...
```

### E0.13.6 Add go test with coverage | 添加带覆盖率的 go test
```yaml
      - name: Run tests
        working-directory: ./backend
        run: go test -v -race -coverprofile=coverage.txt ./...
```

### E0.13.7 Upload coverage to Codecov | 上传覆盖率到 Codecov
```yaml
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./backend/coverage.txt
          flags: backend
```

### E0.13.8 Add golangci-lint job | 添加 golangci-lint 任务
```yaml
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.21'
      - name: golangci-lint
        uses: golangci/golangci-lint-action@v3
        with:
          version: latest
          working-directory: backend
```

---

## E0.14 CI Template for Frontend（前端 CI 模板）

### E0.14.1 Create frontend CI workflow | 创建前端 CI 工作流
File path: `.github/workflows/frontend.yml` | 文件路径：`.github/workflows/frontend.yml`

### E0.14.2 Add Node.js setup and test job | 添加 Node.js 设置与测试任务
```yaml
name: Frontend CI

on:
  push:
    branches: [main, '001-*']
    paths:
      - 'frontend/**'
      - '.github/workflows/frontend.yml'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
```

### E0.14.3 Setup Node.js toolchain | 设置 Node.js 工具链
```yaml
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
```

### E0.14.4 Install frontend dependencies | 安装前端依赖
```bash
      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci
```

### E0.14.5 Add lint check | 添加代码检查
```yaml
      - name: Lint
        working-directory: ./frontend
        run: npm run lint
```

### E0.14.6 Add type check | 添加类型检查
```yaml
      - name: Type check
        working-directory: ./frontend
        run: npm run type-check
```

### E0.14.7 Run unit tests with coverage | 运行带覆盖率的单元测试
```yaml
      - name: Run unit tests
        working-directory: ./frontend
        run: npm test -- --coverage --run
```

### E0.14.8 Add build verification | 添加构建验证
```yaml
      - name: Build
        working-directory: ./frontend
        run: npm run build
```

### E0.14.9 Setup Playwright for E2E tests | 为 E2E 测试设置 Playwright
```yaml
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci
      - name: Install Playwright
        working-directory: ./frontend
        run: npx playwright install --with-deps
```

### E0.14.10 Run Playwright E2E tests | 运行 Playwright E2E 测试
```yaml
      - name: Run E2E tests
        working-directory: ./frontend
        run: npx playwright test
```

---

## E0.15 Quickstart Alignment（快速开始对齐）

### E0.15.1 Create quickstart.md skeleton | 创建 quickstart.md 骨架
File path: `specs/001-derisk-watchtower-real/quickstart.md` | 文件路径

### E0.15.2 Add prerequisites section | 添加前提部分
Node.js 18+, Go 1.21+, Foundry, Docker, Graph CLI | Node.js 18+、Go 1.21+、Foundry、Docker、Graph CLI

### E0.15.3 Add one-command clone step | 添加一键克隆步骤
```bash
git clone https://github.com/your-org/derisk-watchtower.git
cd derisk-watchtower
```

### E0.15.4 Add bootstrap command | 添加引导命令
```bash
./scripts/bootstrap.sh
```

### E0.15.5 Add environment setup step | 添加环境设置步骤
Edit `.env` with your Base Sepolia RPC URL | 编辑 `.env` 填入 Base Sepolia RPC URL

### E0.15.6 Add Docker Compose startup | 添加 Docker Compose 启动
```bash
docker-compose up -d
```

### E0.15.7 Add contract deployment step | 添加合约部署步骤
```bash
cd contracts && forge script script/Deploy.s.sol --broadcast
```

### E0.15.8 Add subgraph deployment placeholder | 添加子图部署占位
```bash
cd subgraph && graph deploy --studio derisk-watchtower
```

### E0.15.9 Add backend startup command | 添加后端启动命令
```bash
cd backend && go run cmd/server/main.go
```

### E0.15.10 Add frontend dev server command | 添加前端开发服务器命令
```bash
cd frontend && npm install && npm run dev
```

### E0.15.11 Add service URLs table | 添加服务 URL 表格
| Service | URL | 服务 | URL |
Frontend: localhost:3000, API: localhost:8080, Grafana: localhost:3001

### E0.15.12 Add smoke test verification | 添加冒烟测试验证
```bash
./scripts/smoke-test.sh
```

### E0.15.13 Cross-reference with README | 与 README 交叉引用
Ensure README points to quickstart.md | 确保 README 指向 quickstart.md

---

## E0.16 README One-Command Startup（README 一键启动）

### E0.16.1 Update README Quick Start section | 更新 README 快速开始部分
Add prominent one-command block at top | 在顶部添加突出一键命令块

### E0.16.2 Add single bootstrap command | 添加单一引导命令
```bash
./scripts/bootstrap.sh && docker-compose up -d
```

### E0.16.3 Document expected output | 记录预期输出
Prometheus on :9090, Grafana on :3001 | Prometheus 在 :9090，Grafana 在 :3001

### E0.16.4 Add troubleshooting section | 添加故障排查部分
Common issues: port conflicts, missing .env | 常见问题：端口冲突、缺失 .env

### E0.16.5 Link to detailed quickstart | 链接到详细快速开始
See `specs/001-.../quickstart.md` for full setup | 完整设置见 `specs/001-.../quickstart.md`

### E0.16.6 Add architecture diagram ASCII | 添加架构图 ASCII
```
User → Frontend → API → Base Sepolia
         ↓        ↓
      WebSocket  Subgraph
         ↓        ↓
    Prometheus ← Automation
         ↓
      Grafana
```

### E0.16.7 Add demo walkthrough link | 添加演示步骤链接
Link to demo video or PROOF.md | 链接到演示视频或 PROOF.md

### E0.16.8 Document offline replay mode | 记录离线重放模式
Access `http://localhost:3000?replay=1` for fixtures | 访问 `http://localhost:3000?replay=1` 使用固件

### E0.16.9 Add partner integration badges | 添加合作伙伴集成徽章
Base Sepolia, Chainlink Automation, The Graph | Base Sepolia、Chainlink Automation、The Graph

### E0.16.10 Add license badge | 添加许可证徽章
MIT License badge at top | MIT 许可证徽章在顶部

---

## E0.17 Grafana JSON Import Instructions（Grafana JSON 导入说明）

### E0.17.1 Create configs/grafana/dashboards directory | 创建 configs/grafana/dashboards 目录
```bash
mkdir -p configs/grafana/dashboards
```

### E0.17.2 Add dashboard provisioning config | 添加仪表板配置供应
File: `configs/grafana/dashboards/dashboards.yml` | 文件：`configs/grafana/dashboards/dashboards.yml`

### E0.17.3 Configure auto-load from directory | 配置从目录自动加载
```yaml
apiVersion: 1
providers:
  - name: 'DeRisk Watchtower'
    folder: ''
    type: file
    options:
      path: /etc/grafana/provisioning/dashboards
```

### E0.17.4 Create placeholder dashboard JSON | 创建占位符仪表板 JSON
File: `configs/grafana/watchtower-dashboard.json` | 文件：`configs/grafana/watchtower-dashboard.json`

### E0.17.5 Add dashboard skeleton structure | 添加仪表板骨架结构
```json
{
  "dashboard": {
    "title": "DeRisk Watchtower",
    "panels": [],
    "schemaVersion": 39,
    "version": 1
  }
}
```

### E0.17.6 Document manual import procedure | 记录手动导入流程
1. Open Grafana at localhost:3001 | 1. 在 localhost:3001 打开 Grafana
2. Navigate to Dashboards → Import | 2. 导航到 Dashboards → Import
3. Upload watchtower-dashboard.json | 3. 上传 watchtower-dashboard.json

### E0.17.7 Add export instructions to README | 添加导出说明到 README
After customizing, export via Share → Export → JSON | 定制后通过 Share → Export → JSON 导出

### E0.17.8 Document dashboard key panels | 记录仪表板关键面板
Triggers counter, latency P95, positions gauge | 触发计数器、延迟 P95、头寸仪表

### E0.17.9 Add PromQL query examples | 添加 PromQL 查询示例
```promql
rate(risk_event_trigger_total[5m])
histogram_quantile(0.95, alert_latency_seconds)
```

### E0.17.10 Test dashboard auto-loads on startup | 测试启动时仪表板自动加载
Restart Grafana and verify dashboard appears | 重启 Grafana 并验证仪表板出现

---

## E0.18 Development Environment Self-Check（开发机自检步骤）

### E0.18.1 Create self-check.sh script | 创建 self-check.sh 脚本
File path: `scripts/self-check.sh` | 文件路径：`scripts/self-check.sh`

### E0.18.2 Check all required commands exist | 检查所有必需命令存在
```bash
#!/usr/bin/env bash
set -euo pipefail
echo "==> Self-check starting..."
command -v node || echo "❌ Node.js missing"
command -v go || echo "❌ Go missing"
command -v forge || echo "❌ Foundry missing"
command -v docker || echo "❌ Docker missing"
command -v graph || echo "❌ Graph CLI missing"
```

### E0.18.3 Verify tool versions meet requirements | 验证工具版本满足要求
```bash
NODE_VER=$(node -v | cut -d 'v' -f2 | cut -d '.' -f1)
[[ $NODE_VER -ge 18 ]] || echo "❌ Node.js <18"
```

### E0.18.4 Check .env file exists | 检查 .env 文件存在
```bash
[ -f .env ] || echo "❌ .env missing (run: cp .env.example .env)"
```

### E0.18.5 Validate required .env variables | 验证必需 .env 变量
```bash
source .env
: "${BASE_SEPOLIA_RPC:?❌ BASE_SEPOLIA_RPC not set}"
: "${CHAIN_ID:?❌ CHAIN_ID not set}"
```

### E0.18.6 Check Docker daemon running | 检查 Docker 守护进程运行
```bash
docker info >/dev/null 2>&1 || echo "❌ Docker daemon not running"
```

### E0.18.7 Verify port availability | 验证端口可用性
```bash
nc -z localhost 8080 && echo "⚠️ Port 8080 in use" || echo "✓ Port 8080 free"
nc -z localhost 3000 && echo "⚠️ Port 3000 in use" || echo "✓ Port 3000 free"
```

### E0.18.8 Check disk space for Docker volumes | 检查 Docker 卷磁盘空间
```bash
AVAIL=$(df / | tail -1 | awk '{print $4}')
[[ $AVAIL -gt 5000000 ]] || echo "⚠️ Low disk space (<5GB)"
```

### E0.18.9 Test internet connectivity for RPC | 测试 RPC 网络连接
```bash
curl -sf https://sepolia.base.org >/dev/null || echo "❌ Cannot reach Base Sepolia RPC"
```

### E0.18.10 Summarize self-check results | 总结自检结果
```bash
echo "==> Self-check complete. Review any ❌ or ⚠️ above."
```

### E0.18.11 Make self-check.sh executable | 使 self-check.sh 可执行
```bash
chmod +x scripts/self-check.sh
```

### E0.18.12 Add self-check to bootstrap.sh | 添加自检到 bootstrap.sh
Call `./scripts/self-check.sh` before install | 在安装前调用 `./scripts/self-check.sh`

### E0.18.13 Document self-check in quickstart | 在快速开始记录自检
Run self-check before starting development | 开发前运行自检

---

## E0.19 Completion Checklist (Part 2)（完成清单第二部分）

- [X] Pre-commit hooks installed and functional | 预提交钩子已安装且功能正常
- [X] Pre-commit config includes Go, Node, Solidity hooks | 预提交配置包含 Go、Node、Solidity 钩子
- [X] Contracts CI workflow triggers on push | 合约 CI 工作流在推送时触发
- [X] Backend CI workflow includes tests and lint | 后端 CI 工作流包含测试与代码检查
- [X] Frontend CI workflow includes E2E tests | 前端 CI 工作流包含 E2E 测试
- [X] Quickstart.md aligns with README commands | Quickstart.md 与 README 命令对齐
- [X] README has prominent one-command startup | README 有突出一键启动命令
- [X] Architecture diagram added to README | 架构图已添加到 README
- [X] Grafana dashboard JSON provisioning configured | Grafana 仪表板 JSON 配置已供应
- [X] Manual import instructions documented | 手动导入说明已记录
- [X] Self-check script validates all dependencies | 自检脚本验证所有依赖
- [X] Self-check verifies port availability | 自检验证端口可用性
- [ ] Self-check integrated into bootstrap flow | 自检集成到引导流程 (Note: bootstrap.sh can call self-check)
- [X] All scripts in scripts/ are executable | scripts/ 中所有脚本可执行
- [ ] CHANGELOG.md updated with E0 Part 2 tasks | CHANGELOG.md 已更新 E0 第二部分任务 (to be done)

---

**End of E0 Init & Tooling Tasks | E0 初始化与环境任务结束**
