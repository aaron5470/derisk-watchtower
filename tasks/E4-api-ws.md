# E4 Go API & WebSocket Tasks（E4 Go API 与 WebSocket 任务）

**Feature**: DeRisk Watchtower | **分支**: `006-derisk-watchtower-api-ws`
**Feature**: DeRisk 瞭望塔 | **Branch**: `006-derisk-watchtower-api-ws`

---

## E4.0 Branch Setup & PR Management（分支设置与 PR 管理）

### E4.0.1 Create 006 Branch & Open Draft PR | 创建 006 分支并开启草稿 PR

#### 🎯 任务目标
从最新主分支创建新的功能分支 `006-derisk-watchtower-api-ws`，  
推送到远程仓库，并创建 **Draft PR（草稿 PR）** 以触发 CI/CD 测试并追踪开发进度。

---

#### ⚙️ 执行步骤
```bash
# 1️⃣ 切换到主分支并更新
git checkout main
git pull origin main

# 2️⃣ 创建新分支
git checkout -b 006-derisk-watchtower-api-ws

# 3️⃣ 推送分支到远程
git push -u origin 006-derisk-watchtower-api-ws

# 4️⃣ 创建 Draft PR（草稿 PR）
gh pr create \
  --base main \
  --head 006-derisk-watchtower-api-ws \
  --title "E4 Go API & WebSocket — Draft PR (in progress)" \
  --body "Initialized Go API & WebSocket development branch from latest main. Work in progress; CI/CD enabled for early validation." \
  --draft
```

#### 📋 完成标准（AC）
- ✅ 分支已成功创建并推送到远程
- ✅ Draft PR 已在 GitHub 显示（目标分支为 main）
- ✅ CI/CD 流水线自动触发
- ✅ AI_USAGE.md 更新包含本分支记录（mode: assist, verified: true）
- ✅ CHANGELOG.md 添加分支初始化日志

#### 🧠 提示
- 草稿 PR（Draft）不会被误合并，但可提前触发 CI/CD 测试。
- 当阶段开发完成后，使用以下命令将其转为正式 PR：
```bash
gh pr ready
```
- 在 PR 前再次同步主分支，确保无冲突：
```bash
git pull origin main
```

#### 🪶 输出物
- 新分支：`006-derisk-watchtower-api-ws`
- GitHub PR（Draft）链接
- CI 流程日志（构建与测试结果）
- 更新后的 AI_USAGE.md 与 CHANGELOG.md

---

## E4.1 Go Project Setup（Go 项目设置）

### E4.1.1 Initialize Go module | 初始化 Go 模块
```bash
mkdir -p backend && cd backend && go mod init github.com/derisk-watchtower/backend
```

### E4.1.2 Add core dependencies | 添加核心依赖
```bash
go get github.com/go-chi/chi/v5
go get github.com/gorilla/websocket
go get github.com/ethereum/go-ethereum
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promhttp
go get github.com/joho/godotenv
```

### E4.1.3 Create directory structure | 创建目录结构
```bash
mkdir -p cmd/server internal/{api,services,models,config} tests/{unit,integration}
```

### E4.1.4 Create main.go entry point | 创建 main.go 入口点
File path: `backend/cmd/server/main.go` | 文件路径

```go
package main

import (
	"log"
	"net/http"
	"os"

	"github.com/derisk-watchtower/backend/internal/api"
	"github.com/derisk-watchtower/backend/internal/config"
	"github.com/joho/godotenv"
)

func main() {
	// Load .env
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// Load config
	cfg := config.Load()

	// Setup router
	router := api.NewRouter(cfg)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on :%s", port)
	if err := http.ListenAndServe(":"+port, router); err != nil {
		log.Fatal(err)
	}
}
```

### E4.1.5 Create config loader | 创建配置加载器
File path: `backend/internal/config/config.go` | 文件路径

```go
package config

import (
	"os"
)

type Config struct {
	Port              string
	RPCEndpoint       string
	SubgraphEndpoint  string
	VaultAddress      string
	ProtectorAddress  string
	ChainID           int64
}

func Load() *Config {
	return &Config{
		Port:              getEnv("PORT", "8080"),
		RPCEndpoint:       getEnv("BASE_SEPOLIA_RPC", ""),
		SubgraphEndpoint:  getEnv("SUBGRAPH_ENDPOINT", ""),
		VaultAddress:      getEnv("VAULT_ADDRESS", ""),
		ProtectorAddress:  getEnv("PROTECTOR_ADDRESS", ""),
		ChainID:           84532, // Base Sepolia
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
```

---

## E4.2 Models（模型）

### E4.2.1 Create Position model | 创建 Position 模型
File path: `backend/internal/models/position.go` | 文件路径

```go
package models

import (
	"math/big"
	"time"
)

type Position struct {
	ID                string    `json:"id"`
	Owner             string    `json:"owner"`
	CollateralAmount  *big.Int  `json:"collateral_amount"`
	CollateralToken   string    `json:"collateral_token"`
	DebtAmount        *big.Int  `json:"debt_amount"`
	DebtToken         string    `json:"debt_token"`
	HealthFactor      float64   `json:"health_factor"`
	LastUpdateAt      time.Time `json:"last_update_at"`
	CreatedAt         time.Time `json:"created_at"`
}

func (p *Position) IsHealthy() bool {
	return p.HealthFactor > 1.5
}

func (p *Position) IsWarning() bool {
	return p.HealthFactor > 1.3 && p.HealthFactor <= 1.5
}

func (p *Position) IsCritical() bool {
	return p.HealthFactor <= 1.3
}
```

### E4.2.2 Create RiskEvent model | 创建 RiskEvent 模型
File path: `backend/internal/models/riskevent.go` | 文件路径

```go
package models

import (
	"time"
)

type RiskEventType string

const (
	ThresholdBreach     RiskEventType = "ThresholdBreach"
	ProtectionTriggered RiskEventType = "ProtectionTriggered"
	ManualAction        RiskEventType = "ManualAction"
)

type RiskEvent struct {
	ID         string        `json:"id"`
	PositionID string        `json:"position_id"`
	EventType  RiskEventType `json:"event_type"`
	PreviousHF float64       `json:"previous_hf"`
	NewHF      float64       `json:"new_hf"`
	DeltaHF    float64       `json:"delta_hf"`
	TxHash     string        `json:"tx_hash"`
	Timestamp  time.Time     `json:"timestamp"`
	Replayed   bool          `json:"replayed,omitempty"`
}
```

### E4.2.3 Create ProtectionAction model | 创建 ProtectionAction 模型
File path: `backend/internal/models/protection.go` | 文件路径

```go
package models

import (
	"math/big"
	"time"
)

type ProtectionActionType string

const (
	AddCollateral ProtectionActionType = "AddCollateral"
	RepayDebt     ProtectionActionType = "RepayDebt"
)

type ProtectionAction struct {
	ID              string               `json:"id"`
	PositionID      string               `json:"position_id"`
	ActionType      ProtectionActionType `json:"action_type"`
	BeforeHF        float64              `json:"before_hf"`
	AfterHF         float64              `json:"after_hf"`
	CollateralDelta *big.Int             `json:"collateral_delta"`
	DebtDelta       *big.Int             `json:"debt_delta"`
	TxHash          string               `json:"tx_hash"`
	Timestamp       time.Time            `json:"timestamp"`
	Executor        string               `json:"executor"`
}
```

### E4.2.4 Create RiskAlert WebSocket message | 创建 RiskAlert WebSocket 消息
File path: `backend/internal/models/alert.go` | 文件路径

```go
package models

import "time"

type RiskAlert struct {
	Type       string    `json:"type"`
	PositionID string    `json:"position_id"`
	HF         float64   `json:"hf"`
	Threshold  float64   `json:"threshold"`
	TxHash     string    `json:"tx_hash,omitempty"`
	Timestamp  int64     `json:"timestamp"`
	Replayed   bool      `json:"replayed"`
}

func NewRiskAlert(positionID string, hf, threshold float64) *RiskAlert {
	return &RiskAlert{
		Type:       "RiskAlert",
		PositionID: positionID,
		HF:         hf,
		Threshold:  threshold,
		Timestamp:  time.Now().Unix(),
		Replayed:   false,
	}
}
```

---

## E4.3 RPC Client Service（RPC 客户端服务）

### E4.3.1 Create RPC client with retry logic | 创建带重试逻辑的 RPC 客户端
File path: `backend/internal/services/rpclient.go` | 文件路径

```go
package services

import (
	"context"
	"math/big"
	"time"

	"github.com/ethereum/go-ethereum/ethclient"
)

type RPCClient struct {
	client   *ethclient.Client
	endpoint string
}

func NewRPCClient(endpoint string) (*RPCClient, error) {
	client, err := ethclient.Dial(endpoint)
	if err != nil {
		return nil, err
	}

	return &RPCClient{
		client:   client,
		endpoint: endpoint,
	}, nil
}

func (r *RPCClient) GetBlockNumber(ctx context.Context) (*big.Int, error) {
	return r.retryOperation(func() (*big.Int, error) {
		return r.client.BlockNumber(ctx)
	})
}
```

### E4.3.2 Add exponential backoff retry | 添加指数退避重试
```go
func (r *RPCClient) retryOperation(op func() (*big.Int, error)) (*big.Int, error) {
	const (
		initialDelay = 500 * time.Millisecond
		multiplier   = 2.0
		maxAttempts  = 5
		maxDelay     = 8 * time.Second
	)

	delay := initialDelay
	for attempt := 1; attempt <= maxAttempts; attempt++ {
		result, err := op()
		if err == nil {
			return result, nil
		}

		if attempt == maxAttempts {
			return nil, err
		}

		// Add jitter (±20%)
		jitter := time.Duration(float64(delay) * 0.2 * (2*rand.Float64() - 1))
		sleepTime := delay + jitter

		time.Sleep(sleepTime)

		delay = time.Duration(float64(delay) * multiplier)
		if delay > maxDelay {
			delay = maxDelay
		}
	}

	return nil, fmt.Errorf("max retries exceeded")
}
```

### E4.3.3 Add circuit breaker | 添加熔断器
```go
type CircuitBreaker struct {
	failures      int
	lastFailTime  time.Time
	state         string // "closed", "open", "half-open"
	failThreshold int
	resetTimeout  time.Duration
	mu            sync.Mutex
}

func NewCircuitBreaker() *CircuitBreaker {
	return &CircuitBreaker{
		failThreshold: 5,
		resetTimeout:  60 * time.Second,
		state:         "closed",
	}
}

func (cb *CircuitBreaker) Call(fn func() error) error {
	cb.mu.Lock()
	defer cb.mu.Unlock()

	if cb.state == "open" {
		if time.Since(cb.lastFailTime) > cb.resetTimeout {
			cb.state = "half-open"
			cb.failures = 0
		} else {
			return fmt.Errorf("circuit breaker open")
		}
	}

	err := fn()
	if err != nil {
		cb.failures++
		cb.lastFailTime = time.Now()

		if cb.failures >= cb.failThreshold {
			cb.state = "open"
		}
		return err
	}

	if cb.state == "half-open" {
		cb.state = "closed"
		cb.failures = 0
	}

	return nil
}
```

---

## E4.4 Subgraph Client Service（子图客户端服务）

### E4.4.1 Create GraphQL client | 创建 GraphQL 客户端
File path: `backend/internal/services/subgraph.go` | 文件路径

```go
package services

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
)

type SubgraphClient struct {
	endpoint string
	client   *http.Client
}

func NewSubgraphClient(endpoint string) *SubgraphClient {
	return &SubgraphClient{
		endpoint: endpoint,
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}
```

### E4.4.2 Add query for positions by owner | 添加按所有者查询头寸
```go
func (s *SubgraphClient) GetPositionsByOwner(ctx context.Context, owner string) ([]*models.Position, error) {
	query := `
		query PositionsByOwner($owner: Bytes!) {
			positions(where: { owner: $owner }) {
				id
				owner
				collateralAmount
				collateralToken
				debtAmount
				debtToken
				healthFactor
				lastUpdateTimestamp
				createdAt
			}
		}
	`

	variables := map[string]interface{}{
		"owner": owner,
	}

	var response struct {
		Data struct {
			Positions []struct {
				ID                string `json:"id"`
				Owner             string `json:"owner"`
				CollateralAmount  string `json:"collateralAmount"`
				CollateralToken   string `json:"collateralToken"`
				DebtAmount        string `json:"debtAmount"`
				DebtToken         string `json:"debtToken"`
				HealthFactor      string `json:"healthFactor"`
				LastUpdateTimestamp string `json:"lastUpdateTimestamp"`
				CreatedAt         string `json:"createdAt"`
			} `json:"positions"`
		} `json:"data"`
	}

	if err := s.executeQuery(ctx, query, variables, &response); err != nil {
		return nil, err
	}

	// Convert to models.Position
	positions := make([]*models.Position, 0, len(response.Data.Positions))
	for _, p := range response.Data.Positions {
		position := convertToPosition(p)
		positions = append(positions, position)
	}

	return positions, nil
}
```

### E4.4.3 Add query execution helper | 添加查询执行辅助函数
```go
func (s *SubgraphClient) executeQuery(ctx context.Context, query string, variables map[string]interface{}, result interface{}) error {
	body := map[string]interface{}{
		"query":     query,
		"variables": variables,
	}

	jsonBody, err := json.Marshal(body)
	if err != nil {
		return err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", s.endpoint, bytes.NewBuffer(jsonBody))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := s.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("subgraph query failed: %s", resp.Status)
	}

	return json.NewDecoder(resp.Body).Decode(result)
}
```

### E4.4.4 Add staleness detection | 添加陈旧度检测
```go
func (s *SubgraphClient) CheckStaleness(ctx context.Context) (bool, int64, error) {
	query := `
		query CheckSync {
			_meta {
				block {
					number
					timestamp
				}
			}
		}
	`

	var response struct {
		Data struct {
			Meta struct {
				Block struct {
					Timestamp int64 `json:"timestamp"`
				} `json:"block"`
			} `json:"_meta"`
		} `json:"data"`
	}

	if err := s.executeQuery(ctx, query, nil, &response); err != nil {
		return false, 0, err
	}

	lastSync := response.Data.Meta.Block.Timestamp
	now := time.Now().Unix()
	isStale := (now - lastSync) > 60 // >60s = stale

	return isStale, lastSync, nil
}
```

---

## E4.5 Monitor Service（监控服务）

### E4.5.1 Create monitor service | 创建监控服务
File path: `backend/internal/services/monitor.go` | 文件路径

```go
package services

import (
	"context"
	"log"
	"sync"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
)

type MonitorService struct {
	subgraph    *SubgraphClient
	rpcClient   *RPCClient
	alerter     *AlerterService
	interval    time.Duration
	mu          sync.RWMutex
	positions   map[string]*models.Position
	stopCh      chan struct{}
}

func NewMonitorService(
	subgraph *SubgraphClient,
	rpcClient *RPCClient,
	alerter *AlerterService,
) *MonitorService {
	return &MonitorService{
		subgraph:  subgraph,
		rpcClient: rpcClient,
		alerter:   alerter,
		interval:  5 * time.Second,
		positions: make(map[string]*models.Position),
		stopCh:    make(chan struct{}),
	}
}
```

### E4.5.2 Add monitoring loop | 添加监控循环
```go
func (m *MonitorService) Start(ctx context.Context) {
	ticker := time.NewTicker(m.interval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			if err := m.checkAllPositions(ctx); err != nil {
				log.Printf("Monitor error: %v", err)
			}
		case <-m.stopCh:
			return
		case <-ctx.Done():
			return
		}
	}
}

func (m *MonitorService) Stop() {
	close(m.stopCh)
}
```

### E4.5.3 Implement position health check | 实现头寸健康检查
```go
func (m *MonitorService) checkAllPositions(ctx context.Context) error {
	m.mu.RLock()
	positions := make([]*models.Position, 0, len(m.positions))
	for _, p := range m.positions {
		positions = append(positions, p)
	}
	m.mu.RUnlock()

	for _, position := range positions {
		if err := m.checkPosition(ctx, position); err != nil {
			log.Printf("Error checking position %s: %v", position.ID, err)
			continue
		}
	}

	return nil
}

func (m *MonitorService) checkPosition(ctx context.Context, position *models.Position) error {
	// Check if HF crossed threshold
	if position.IsCritical() {
		alert := models.NewRiskAlert(
			position.ID,
			position.HealthFactor,
			1.3,
		)
		m.alerter.BroadcastAlert(alert)
	}

	return nil
}
```

### E4.5.4 Add position registration | 添加头寸注册
```go
func (m *MonitorService) RegisterPosition(position *models.Position) {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.positions[position.ID] = position
	log.Printf("Registered position: %s (HF: %.4f)", position.ID, position.HealthFactor)
}

func (m *MonitorService) UnregisterPosition(positionID string) {
	m.mu.Lock()
	defer m.mu.Unlock()

	delete(m.positions, positionID)
	log.Printf("Unregistered position: %s", positionID)
}

func (m *MonitorService) GetMonitoredCount() int {
	m.mu.RLock()
	defer m.mu.RUnlock()

	return len(m.positions)
}
```

---

## E4.6 Alerter Service with WebSocket（带 WebSocket 的警报服务）

### E4.6.1 Create alerter service | 创建警报服务
File path: `backend/internal/services/alerter.go` | 文件路径

```go
package services

import (
	"log"
	"sync"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
	"github.com/gorilla/websocket"
)

type AlerterService struct {
	clients   map[*websocket.Conn]bool
	broadcast chan *models.RiskAlert
	register  chan *websocket.Conn
	unregister chan *websocket.Conn
	mu        sync.RWMutex
	history   []*models.RiskAlert
	historyTTL time.Duration
}

func NewAlerterService() *AlerterService {
	return &AlerterService{
		clients:    make(map[*websocket.Conn]bool),
		broadcast:  make(chan *models.RiskAlert, 100),
		register:   make(chan *websocket.Conn),
		unregister: make(chan *websocket.Conn),
		history:    make([]*models.RiskAlert, 0),
		historyTTL: 60 * time.Second,
	}
}
```

### E4.6.2 Add alerter run loop | 添加警报器运行循环
```go
func (a *AlerterService) Run() {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case conn := <-a.register:
			a.mu.Lock()
			a.clients[conn] = true
			a.mu.Unlock()
			log.Printf("WebSocket client connected. Total: %d", len(a.clients))

		case conn := <-a.unregister:
			a.mu.Lock()
			if _, ok := a.clients[conn]; ok {
				delete(a.clients, conn)
				conn.Close()
			}
			a.mu.Unlock()
			log.Printf("WebSocket client disconnected. Total: %d", len(a.clients))

		case alert := <-a.broadcast:
			a.addToHistory(alert)
			a.broadcastToClients(alert)

		case <-ticker.C:
			a.cleanHistory()
		}
	}
}
```

### E4.6.3 Implement broadcast to clients | 实现向客户端广播
```go
func (a *AlerterService) broadcastToClients(alert *models.RiskAlert) {
	a.mu.RLock()
	defer a.mu.RUnlock()

	for conn := range a.clients {
		if err := conn.WriteJSON(alert); err != nil {
			log.Printf("WebSocket write error: %v", err)
			conn.Close()
			delete(a.clients, conn)
		}
	}
}

func (a *AlerterService) BroadcastAlert(alert *models.RiskAlert) {
	select {
	case a.broadcast <- alert:
	default:
		log.Println("Broadcast channel full, dropping alert")
	}
}
```

### E4.6.4 Add history management | 添加历史管理
```go
func (a *AlerterService) addToHistory(alert *models.RiskAlert) {
	a.mu.Lock()
	defer a.mu.Unlock()

	a.history = append(a.history, alert)
}

func (a *AlerterService) cleanHistory() {
	a.mu.Lock()
	defer a.mu.Unlock()

	cutoff := time.Now().Add(-a.historyTTL).Unix()
	filtered := make([]*models.RiskAlert, 0)

	for _, alert := range a.history {
		if alert.Timestamp >= cutoff {
			filtered = append(filtered, alert)
		}
	}

	a.history = filtered
}

func (a *AlerterService) GetRecentAlerts(since int64) []*models.RiskAlert {
	a.mu.RLock()
	defer a.mu.RUnlock()

	recent := make([]*models.RiskAlert, 0)
	for _, alert := range a.history {
		if alert.Timestamp >= since {
			alert.Replayed = true
			recent = append(recent, alert)
		}
	}

	return recent
}
```

### E4.6.5 Add client registration methods | 添加客户端注册方法
```go
func (a *AlerterService) RegisterClient(conn *websocket.Conn) {
	a.register <- conn
}

func (a *AlerterService) UnregisterClient(conn *websocket.Conn) {
	a.unregister <- conn
}
```

---

## E4.7 HTTP Handlers（HTTP 处理器）

### E4.7.1 Create health check handler | 创建健康检查处理器
File path: `backend/internal/api/handlers/health.go` | 文件路径

```go
package handlers

import (
	"encoding/json"
	"net/http"
	"time"
)

type HealthHandler struct{}

func NewHealthHandler() *HealthHandler {
	return &HealthHandler{}
}

func (h *HealthHandler) HandleHealth(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"status":  "ok",
		"version": "1.0.0",
		"now":     time.Now().Unix(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
```

### E4.7.2 Create positions handler | 创建头寸处理器
File path: `backend/internal/api/handlers/positions.go` | 文件路径

```go
package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/derisk-watchtower/backend/internal/services"
)

type PositionsHandler struct {
	subgraph *services.SubgraphClient
}

func NewPositionsHandler(subgraph *services.SubgraphClient) *PositionsHandler {
	return &PositionsHandler{
		subgraph: subgraph,
	}
}

func (h *PositionsHandler) GetPositions(w http.ResponseWriter, r *http.Request) {
	owner := r.URL.Query().Get("owner")
	if owner == "" {
		http.Error(w, "owner parameter required", http.StatusBadRequest)
		return
	}

	positions, err := h.subgraph.GetPositionsByOwner(r.Context(), owner)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(positions)
}
```

### E4.7.3 Create HF handler | 创建 HF 处理器
File path: `backend/internal/api/handlers/hf.go` | 文件路径

```go
package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/go-chi/chi/v5"
)

type HFHandler struct {
	subgraph *services.SubgraphClient
}

func NewHFHandler(subgraph *services.SubgraphClient) *HFHandler {
	return &HFHandler{
		subgraph: subgraph,
	}
}

func (h *HFHandler) GetHealthFactor(w http.ResponseWriter, r *http.Request) {
	address := chi.URLParam(r, "address")

	// Fetch position from subgraph
	positions, err := h.subgraph.GetPositionsByOwner(r.Context(), address)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if len(positions) == 0 {
		http.Error(w, "position not found", http.StatusNotFound)
		return
	}

	position := positions[0]

	// Check staleness
	isStale, lastSync, _ := h.subgraph.CheckStaleness(r.Context())

	response := map[string]interface{}{
		"hf":            position.HealthFactor,
		"last_update_at": position.LastUpdateAt.Unix(),
		"is_stale":      isStale,
		"last_sync":     lastSync,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
```

### E4.7.4 Create WebSocket handler | 创建 WebSocket 处理器
File path: `backend/internal/api/handlers/ws.go` | 文件路径

```go
package handlers

import (
	"log"
	"net/http"
	"strconv"

	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for demo
	},
}

type WSHandler struct {
	alerter *services.AlerterService
}

func NewWSHandler(alerter *services.AlerterService) *WSHandler {
	return &WSHandler{
		alerter: alerter,
	}
}

func (h *WSHandler) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade failed: %v", err)
		return
	}

	// Register client
	h.alerter.RegisterClient(conn)
	defer h.alerter.UnregisterClient(conn)

	// Check for replay request
	serverEventTs := r.URL.Query().Get("serverEventTs")
	if serverEventTs != "" {
		if ts, err := strconv.ParseInt(serverEventTs, 10, 64); err == nil {
			// Replay events since timestamp
			recentAlerts := h.alerter.GetRecentAlerts(ts)
			for _, alert := range recentAlerts {
				if err := conn.WriteJSON(alert); err != nil {
					log.Printf("Replay write error: %v", err)
					return
				}
			}
		}
	}

	// Keep connection alive
	for {
		if _, _, err := conn.ReadMessage(); err != nil {
			break
		}
	}
}
```

---

## E4.8 Prometheus Metrics（Prometheus 指标）

### E4.8.1 Create metrics handler | 创建指标处理器
File path: `backend/internal/api/handlers/metrics.go` | 文件路径

```go
package handlers

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	RiskEventTriggerTotal = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "risk_event_trigger_total",
		Help: "Total number of risk events triggered",
	})

	ProtectSuccessTotal = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "protect_success_total",
		Help: "Total number of successful protection executions",
	})

	ProtectFailureTotal = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "protect_failure_total",
		Help: "Total number of failed protection executions",
	})

	AlertLatencySeconds = prometheus.NewHistogram(prometheus.HistogramOpts{
		Name:    "alert_latency_seconds",
		Help:    "Latency from detection to UI display in seconds",
		Buckets: []float64{0.5, 1, 2, 5, 10},
	})

	PositionsMonitored = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "positions_monitored",
		Help: "Current number of positions being monitored",
	})
)

func init() {
	prometheus.MustRegister(RiskEventTriggerTotal)
	prometheus.MustRegister(ProtectSuccessTotal)
	prometheus.MustRegister(ProtectFailureTotal)
	prometheus.MustRegister(AlertLatencySeconds)
	prometheus.MustRegister(PositionsMonitored)
}

func HandleMetrics() http.Handler {
	return promhttp.Handler()
}
```

---

## E4.9 Router Setup（路由设置）

### E4.9.1 Create router | 创建路由器
File path: `backend/internal/api/router.go` | 文件路径

```go
package api

import (
	"github.com/derisk-watchtower/backend/internal/api/handlers"
	"github.com/derisk-watchtower/backend/internal/api/middleware"
	"github.com/derisk-watchtower/backend/internal/config"
	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
)

func NewRouter(cfg *config.Config) *chi.Mux {
	r := chi.NewRouter()

	// Middleware
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(middleware.CORS())

	// Services
	subgraph := services.NewSubgraphClient(cfg.SubgraphEndpoint)
	alerter := services.NewAlerterService()
	go alerter.Run()

	// Handlers
	healthHandler := handlers.NewHealthHandler()
	positionsHandler := handlers.NewPositionsHandler(subgraph)
	hfHandler := handlers.NewHFHandler(subgraph)
	wsHandler := handlers.NewWSHandler(alerter)

	// Routes
	r.Get("/healthz", healthHandler.HandleHealth)
	r.Get("/metrics", handlers.HandleMetrics().ServeHTTP)

	r.Route("/api", func(r chi.Router) {
		r.Get("/positions", positionsHandler.GetPositions)
		r.Get("/hf/{address}", hfHandler.GetHealthFactor)
	})

	r.Get("/ws/risk-stream", wsHandler.HandleWebSocket)

	return r
}
```

---

## E4.10 Middleware（中间件）

### E4.10.1 Create CORS middleware | 创建 CORS 中间件
File path: `backend/internal/api/middleware/cors.go` | 文件路径

```go
package middleware

import (
	"net/http"
)

func CORS() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

			if r.Method == "OPTIONS" {
				w.WriteHeader(http.StatusOK)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
```

### E4.10.2 Create logging middleware | 创建日志中间件
File path: `backend/internal/api/middleware/logging.go` | 文件路径

```go
package middleware

import (
	"log"
	"net/http"
	"time"
)

func Logging() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()

			next.ServeHTTP(w, r)

			log.Printf(
				"%s %s %s",
				r.Method,
				r.RequestURI,
				time.Since(start),
			)
		})
	}
}
```

### E4.10.3 Create rate limiting middleware | 创建限流中间件
File path: `backend/internal/api/middleware/ratelimit.go` | 文件路径

```go
package middleware

import (
	"net/http"
	"sync"
	"time"
)

type RateLimiter struct {
	requests map[string][]time.Time
	mu       sync.Mutex
	limit    int
	window   time.Duration
}

func NewRateLimiter(limit int, window time.Duration) *RateLimiter {
	return &RateLimiter{
		requests: make(map[string][]time.Time),
		limit:    limit,
		window:   window,
	}
}

func (rl *RateLimiter) Middleware() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ip := r.RemoteAddr

			rl.mu.Lock()
			defer rl.mu.Unlock()

			now := time.Now()
			cutoff := now.Add(-rl.window)

			// Clean old requests
			if times, ok := rl.requests[ip]; ok {
				filtered := make([]time.Time, 0)
				for _, t := range times {
					if t.After(cutoff) {
						filtered = append(filtered, t)
					}
				}
				rl.requests[ip] = filtered
			}

			// Check limit
			if len(rl.requests[ip]) >= rl.limit {
				http.Error(w, "rate limit exceeded", http.StatusTooManyRequests)
				return
			}

			// Add current request
			rl.requests[ip] = append(rl.requests[ip], now)

			next.ServeHTTP(w, r)
		})
	}
}
```

---

## E4.11 Unit Tests（单元测试）

### E4.11.1 Create monitor service tests | 创建监控服务测试
File path: `backend/tests/unit/monitor_test.go` | 文件路径

```go
package unit

import (
	"context"
	"testing"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestMonitorService_RegisterPosition(t *testing.T) {
	alerter := services.NewAlerterService()
	monitor := services.NewMonitorService(nil, nil, alerter)

	position := &models.Position{
		ID:           "0x123",
		Owner:        "0xabc",
		HealthFactor: 1.5,
	}

	monitor.RegisterPosition(position)

	assert.Equal(t, 1, monitor.GetMonitoredCount())
}

func TestMonitorService_UnregisterPosition(t *testing.T) {
	alerter := services.NewAlerterService()
	monitor := services.NewMonitorService(nil, nil, alerter)

	position := &models.Position{
		ID:           "0x123",
		Owner:        "0xabc",
		HealthFactor: 1.5,
	}

	monitor.RegisterPosition(position)
	monitor.UnregisterPosition("0x123")

	assert.Equal(t, 0, monitor.GetMonitoredCount())
}
```

### E4.11.2 Create alerter service tests | 创建警报服务测试
File path: `backend/tests/unit/alerter_test.go` | 文件路径

```go
package unit

import (
	"testing"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/stretchr/testify/assert"
)

func TestAlerterService_BroadcastAlert(t *testing.T) {
	alerter := services.NewAlerterService()
	go alerter.Run()

	alert := models.NewRiskAlert("0x123", 1.2, 1.3)

	alerter.BroadcastAlert(alert)

	// Allow time for processing
	time.Sleep(100 * time.Millisecond)

	recent := alerter.GetRecentAlerts(time.Now().Add(-1 * time.Minute).Unix())
	assert.Len(t, recent, 1)
	assert.Equal(t, "0x123", recent[0].PositionID)
}

func TestAlerterService_CleanHistory(t *testing.T) {
	alerter := services.NewAlerterService()

	// Add old alert
	oldAlert := models.NewRiskAlert("0x123", 1.2, 1.3)
	oldAlert.Timestamp = time.Now().Add(-2 * time.Minute).Unix()

	alerter.BroadcastAlert(oldAlert)

	// Clean history
	time.Sleep(100 * time.Millisecond)

	recent := alerter.GetRecentAlerts(time.Now().Add(-30 * time.Second).Unix())
	assert.Len(t, recent, 0)
}
```

### E4.11.3 Create HF calculation tests | 创建 HF 计算测试
File path: `backend/tests/unit/hf_test.go` | 文件路径

```go
package unit

import (
	"testing"

	"github.com/derisk-watchtower/backend/internal/models"
	"github.com/stretchr/testify/assert"
)

func TestPosition_IsHealthy(t *testing.T) {
	tests := []struct {
		name     string
		hf       float64
		expected bool
	}{
		{"Safe", 1.6, true},
		{"Borderline", 1.5, false},
		{"Warning", 1.4, false},
		{"Critical", 1.2, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			position := &models.Position{
				HealthFactor: tt.hf,
			}
			assert.Equal(t, tt.expected, position.IsHealthy())
		})
	}
}

func TestPosition_IsCritical(t *testing.T) {
	tests := []struct {
		name     string
		hf       float64
		expected bool
	}{
		{"Safe", 1.6, false},
		{"Warning", 1.4, false},
		{"Threshold", 1.3, false},
		{"Critical", 1.2, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			position := &models.Position{
				HealthFactor: tt.hf,
			}
			assert.Equal(t, tt.expected, position.IsCritical())
		})
	}
}
```

---

## E4.12 Integration Tests（集成测试）

### E4.12.1 Create API integration tests | 创建 API 集成测试
File path: `backend/tests/integration/api_test.go` | 文件路径

```go
package integration

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/derisk-watchtower/backend/internal/api"
	"github.com/derisk-watchtower/backend/internal/config"
	"github.com/stretchr/testify/assert"
)

func TestHealthEndpoint(t *testing.T) {
	cfg := &config.Config{
		SubgraphEndpoint: "http://localhost:8000",
	}

	router := api.NewRouter(cfg)
	req := httptest.NewRequest("GET", "/healthz", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "ok")
}

func TestMetricsEndpoint(t *testing.T) {
	cfg := &config.Config{}
	router := api.NewRouter(cfg)

	req := httptest.NewRequest("GET", "/metrics", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "positions_monitored")
}
```

---

## E4.13 Documentation（文档）

### E4.13.1 Create API documentation | 创建 API 文档
File path: `backend/README.md` | 文件路径

```markdown
# DeRisk Watchtower Backend API

Go-based API service with WebSocket support for real-time risk alerts.

## Architecture

- **Framework**: chi router
- **WebSocket**: gorilla/websocket
- **Metrics**: Prometheus
- **RPC**: go-ethereum

## Endpoints

### Health
- `GET /healthz` - Health check

### Positions
- `GET /api/positions?owner={address}` - Get positions by owner

### Health Factor
- `GET /api/hf/{address}` - Get health factor for position

### WebSocket
- `WS /ws/risk-stream` - Real-time risk alerts

### Metrics
- `GET /metrics` - Prometheus metrics

## Running Locally

```bash
cd backend
cp .env.example .env
# Edit .env with your values
go run cmd/server/main.go
```

## Testing

```bash
go test ./tests/unit/...
go test ./tests/integration/...
```
```

---

## E4.14 Completion Checklist（完成清单）

- [ ] Go module initialized | Go 模块已初始化
- [ ] Core dependencies installed | 核心依赖已安装
- [ ] Directory structure created | 目录结构已创建
- [ ] Config loader implemented | 配置加载器已实现
- [ ] Position model created | Position 模型已创建
- [ ] RiskEvent model created | RiskEvent 模型已创建
- [ ] ProtectionAction model created | ProtectionAction 模型已创建
- [ ] RiskAlert WebSocket message created | RiskAlert WebSocket 消息已创建
- [ ] RPC client with retry logic | 带重试逻辑的 RPC 客户端
- [ ] Circuit breaker implemented | 熔断器已实现
- [ ] Subgraph GraphQL client created | 子图 GraphQL 客户端已创建
- [ ] Position query by owner implemented | 按所有者查询头寸已实现
- [ ] Staleness detection implemented | 陈旧度检测已实现
- [ ] Monitor service created | 监控服务已创建
- [ ] Position health check loop implemented | 头寸健康检查循环已实现
- [ ] Alerter service with WebSocket | 带 WebSocket 的警报服务
- [ ] Alert broadcast to clients | 向客户端广播警报
- [ ] Alert history management (60s TTL) | 警报历史管理（60 秒 TTL）
- [ ] Health check handler | 健康检查处理器
- [ ] Positions handler | 头寸处理器
- [ ] HF handler with staleness | 带陈旧度的 HF 处理器
- [ ] WebSocket handler with replay | 带回放的 WebSocket 处理器
- [ ] Prometheus metrics defined | Prometheus 指标已定义
- [ ] Router with all endpoints | 带所有端点的路由器
- [ ] CORS middleware | CORS 中间件
- [ ] Logging middleware | 日志中间件
- [ ] Rate limiting middleware | 限流中间件
- [ ] Unit tests for monitor service | 监控服务单元测试
- [ ] Unit tests for alerter service | 警报服务单元测试
- [ ] Unit tests for HF calculation | HF 计算单元测试
- [ ] Integration tests for API endpoints | API 端点集成测试
- [ ] Backend README documentation | 后端 README 文档

---

**End of E4 Go API & WebSocket Tasks | E4 Go API 与 WebSocket 任务结束**
