# E6 Observability Tasks（E6 可观测性任务）

**Feature**: DeRisk Watchtower | **分支**: `008-derisk-watchtower-observability`
**Feature**: DeRisk 瞭望塔 | **Branch**: `008-derisk-watchtower-observability`

---

## E6.0 Branch Setup & PR Management（分支设置与 PR 管理）

### E6.0.1 Create 008 Branch & Open Draft PR | 创建 008 分支并开启草稿 PR

#### 🎯 任务目标
从最新主分支创建新的功能分支 `008-derisk-watchtower-observability`，  
推送到远程仓库，并创建 **Draft PR（草稿 PR）** 以触发 CI/CD 测试并追踪开发进度。

---

#### ⚙️ 执行步骤
```bash
# 1️⃣ 切换到主分支并更新
git checkout main
git pull origin main

# 2️⃣ 创建新分支
git checkout -b 008-derisk-watchtower-observability

# 3️⃣ 推送分支到远程
git push -u origin 008-derisk-watchtower-observability

# 4️⃣ 创建 Draft PR（草稿 PR）
gh pr create \
  --base main \
  --head 008-derisk-watchtower-observability \
  --title "E6 Observability — Draft PR (in progress)" \
  --body "Initialized Observability development branch from latest main. Work in progress; CI/CD enabled for early validation." \
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
- 新分支：`008-derisk-watchtower-observability`
- GitHub PR（Draft）链接
- CI 流程日志（构建与测试结果）
- 更新后的 AI_USAGE.md 与 CHANGELOG.md

---

## E6.1 Docker Compose Setup（Docker Compose 设置）

### E6.1.1 Create docker-compose.yml for observability stack | 创建可观测性栈 docker-compose.yml
File path: `docker-compose.yml` | 文件路径

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: watchtower-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./configs/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    networks:
      - watchtower

  grafana:
    image: grafana/grafana:latest
    container_name: watchtower-grafana
    ports:
      - "3001:3000"
    volumes:
      - ./configs/grafana/provisioning:/etc/grafana/provisioning
      - ./configs/grafana/dashboards:/var/lib/grafana/dashboards
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    networks:
      - watchtower
    depends_on:
      - prometheus

volumes:
  prometheus-data:
  grafana-data:

networks:
  watchtower:
    driver: bridge
```

### E6.1.2 Create configs directory structure | 创建 configs 目录结构
```bash
mkdir -p configs/prometheus configs/grafana/{provisioning/datasources,provisioning/dashboards,dashboards}
```

---

## E6.2 Prometheus Configuration（Prometheus 配置）

### E6.2.1 Create prometheus.yml config | 创建 prometheus.yml 配置
File path: `configs/prometheus/prometheus.yml` | 文件路径

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'watchtower-api'
    static_configs:
      - targets: ['host.docker.internal:8080']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

### E6.2.2 Add recording rules | 添加记录规则
File path: `configs/prometheus/rules.yml` | 文件路径

```yaml
groups:
  - name: watchtower_metrics
    interval: 30s
    rules:
      - record: watchtower:risk_events:rate5m
        expr: rate(risk_event_trigger_total[5m])

      - record: watchtower:protection:success_rate
        expr: |
          rate(protect_success_total[5m]) /
          (rate(protect_success_total[5m]) + rate(protect_failure_total[5m]))

      - record: watchtower:alert_latency:p95
        expr: histogram_quantile(0.95, rate(alert_latency_seconds_bucket[5m]))

      - record: watchtower:alert_latency:p99
        expr: histogram_quantile(0.99, rate(alert_latency_seconds_bucket[5m]))
```

### E6.2.3 Add alerting rules | 添加告警规则
File path: `configs/prometheus/alerts.yml` | 文件路径

```yaml
groups:
  - name: watchtower_alerts
    interval: 30s
    rules:
      - alert: HighAlertLatency
        expr: watchtower:alert_latency:p95 > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High alert latency detected"
          description: "P95 alert latency is {{ $value }}s (threshold: 10s)"

      - alert: ProtectionFailureRate
        expr: watchtower:protection:success_rate < 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High protection failure rate"
          description: "Protection success rate is {{ $value }} (threshold: 0.9)"

      - alert: APIDown
        expr: up{job="watchtower-api"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Watchtower API is down"
          description: "API has been down for more than 1 minute"

      - alert: NoMonitoredPositions
        expr: positions_monitored == 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "No positions being monitored"
          description: "The system is not monitoring any positions"
```

### E6.2.4 Update prometheus.yml to include rules | 更新 prometheus.yml 包含规则
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - 'rules.yml'
  - 'alerts.yml'

scrape_configs:
  # ... existing configs
```

---

## E6.3 Grafana Data Source Provisioning（Grafana 数据源配置）

### E6.3.1 Create datasource provisioning config | 创建数据源配置
File path: `configs/grafana/provisioning/datasources/prometheus.yml` | 文件路径

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
```

---

## E6.4 Grafana Dashboard Provisioning（Grafana 仪表盘配置）

### E6.4.1 Create dashboard provisioning config | 创建仪表盘配置
File path: `configs/grafana/provisioning/dashboards/dashboards.yml` | 文件路径

```yaml
apiVersion: 1

providers:
  - name: 'DeRisk Watchtower'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
```

---

## E6.5 Grafana Dashboard JSON（Grafana 仪表盘 JSON）

### E6.5.1 Create main watchtower dashboard | 创建主 watchtower 仪表盘
File path: `configs/grafana/dashboards/watchtower-dashboard.json` | 文件路径

```json
{
  "annotations": {
    "list": []
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "tooltip": false,
              "viz": false,
              "legend": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 1,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "rate(risk_event_trigger_total[5m])",
          "refId": "A",
          "legendFormat": "Risk Events"
        }
      ],
      "title": "Risk Events Rate (5m)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 10
              }
            ]
          },
          "unit": "s"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "id": 2,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "values": false,
          "calcs": ["lastNotNull"],
          "fields": ""
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "histogram_quantile(0.95, rate(alert_latency_seconds_bucket[5m]))",
          "refId": "A"
        }
      ],
      "title": "Alert Latency P95",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "tooltip": false,
              "viz": false,
              "legend": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "normal"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 8
      },
      "id": 3,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "rate(protect_success_total[5m])",
          "refId": "A",
          "legendFormat": "Success"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "rate(protect_failure_total[5m])",
          "refId": "B",
          "legendFormat": "Failure"
        }
      ],
      "title": "Protection Actions (5m)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "yellow",
                "value": 1
              },
              {
                "color": "green",
                "value": 5
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 8
      },
      "id": 4,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "values": false,
          "calcs": ["lastNotNull"],
          "fields": ""
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "positions_monitored",
          "refId": "A"
        }
      ],
      "title": "Positions Monitored",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "hideFrom": {
              "tooltip": false,
              "viz": false,
              "legend": false
            }
          },
          "mappings": []
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 16
      },
      "id": 5,
      "options": {
        "legend": {
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "pieType": "pie",
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "sum by (job) (up)",
          "refId": "A",
          "legendFormat": "{{job}}"
        }
      ],
      "title": "Service Uptime",
      "type": "piechart"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "tooltip": false,
              "viz": false,
              "legend": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              }
            ]
          },
          "unit": "s"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 16
      },
      "id": 6,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "histogram_quantile(0.50, rate(alert_latency_seconds_bucket[5m]))",
          "refId": "A",
          "legendFormat": "P50"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "histogram_quantile(0.95, rate(alert_latency_seconds_bucket[5m]))",
          "refId": "B",
          "legendFormat": "P95"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "expr": "histogram_quantile(0.99, rate(alert_latency_seconds_bucket[5m]))",
          "refId": "C",
          "legendFormat": "P99"
        }
      ],
      "title": "Alert Latency Percentiles",
      "type": "timeseries"
    }
  ],
  "refresh": "5s",
  "schemaVersion": 38,
  "style": "dark",
  "tags": ["watchtower", "defi", "monitoring"],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "DeRisk Watchtower Dashboard",
  "uid": "watchtower-main",
  "version": 1,
  "weekStart": ""
}
```

---

## E6.6 Startup Scripts（启动脚本）

### E6.6.1 Create one-command startup script | 创建一键启动脚本
File path: `scripts/start-observability.sh` | 文件路径

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting DeRisk Watchtower Observability Stack..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose is not installed"
    exit 1
fi

# Start the stack
echo "📦 Starting Prometheus and Grafana..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 5

# Check Prometheus
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus is running at http://localhost:9090"
else
    echo "⚠️  Prometheus may not be ready yet"
fi

# Check Grafana
if curl -s http://localhost:3001/api/health > /dev/null; then
    echo "✅ Grafana is running at http://localhost:3001"
    echo "   Default credentials: admin / admin"
else
    echo "⚠️  Grafana may not be ready yet"
fi

echo ""
echo "🎉 Observability stack started successfully!"
echo ""
echo "📊 Access points:"
echo "   - Prometheus: http://localhost:9090"
echo "   - Grafana:    http://localhost:3001 (admin/admin)"
echo ""
echo "To view logs:"
echo "   docker-compose logs -f"
echo ""
echo "To stop:"
echo "   docker-compose down"
```

### E6.6.2 Make script executable | 使脚本可执行
```bash
chmod +x scripts/start-observability.sh
```

### E6.6.3 Create Windows PowerShell startup script | 创建 Windows PowerShell 启动脚本
File path: `scripts/start-observability.ps1` | 文件路径

```powershell
Write-Host "🚀 Starting DeRisk Watchtower Observability Stack..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Error: Docker is not running" -ForegroundColor Red
    exit 1
}

# Start the stack
Write-Host "📦 Starting Prometheus and Grafana..." -ForegroundColor Cyan
docker-compose up -d

# Wait for services
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Check Prometheus
try {
    Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing | Out-Null
    Write-Host "✅ Prometheus is running at http://localhost:9090" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Prometheus may not be ready yet" -ForegroundColor Yellow
}

# Check Grafana
try {
    Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing | Out-Null
    Write-Host "✅ Grafana is running at http://localhost:3001" -ForegroundColor Green
    Write-Host "   Default credentials: admin / admin" -ForegroundColor Cyan
} catch {
    Write-Host "⚠️  Grafana may not be ready yet" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Observability stack started successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Access points:" -ForegroundColor Cyan
Write-Host "   - Prometheus: http://localhost:9090"
Write-Host "   - Grafana:    http://localhost:3001 (admin/admin)"
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Cyan
Write-Host "   docker-compose logs -f"
Write-Host ""
Write-Host "To stop:" -ForegroundColor Cyan
Write-Host "   docker-compose down"
```

---

## E6.7 Documentation（文档）

### E6.7.1 Create observability documentation | 创建可观测性文档
File path: `docs/OBSERVABILITY.md` | 文件路径

```markdown
# DeRisk Watchtower Observability

Complete observability stack with Prometheus metrics and Grafana dashboards.

## Quick Start

**One-command startup**:
```bash
./scripts/start-observability.sh
```

Or on Windows:
```powershell
.\scripts\start-observability.ps1
```

## Architecture

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards

## Access Points

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001
  - Default credentials: `admin` / `admin`
  - Change password on first login

## Metrics

### Core Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `risk_event_trigger_total` | Counter | Total risk events triggered |
| `protect_success_total` | Counter | Successful protection executions |
| `protect_failure_total` | Counter | Failed protection executions |
| `alert_latency_seconds` | Histogram | Alert latency (detection → UI) |
| `positions_monitored` | Gauge | Current positions being monitored |

### Recording Rules

- `watchtower:risk_events:rate5m` - Risk events per second (5m rate)
- `watchtower:protection:success_rate` - Protection success rate
- `watchtower:alert_latency:p95` - P95 alert latency
- `watchtower:alert_latency:p99` - P99 alert latency

## Dashboards

### Main Dashboard

Access at: http://localhost:3001/d/watchtower-main

**Panels**:
1. **Risk Events Rate** - Real-time risk event frequency
2. **Alert Latency P95** - 95th percentile alert latency
3. **Protection Actions** - Success/failure breakdown
4. **Positions Monitored** - Active position count
5. **Service Uptime** - Service availability
6. **Alert Latency Percentiles** - P50/P95/P99 latency

## Alerts

### Configured Alerts

1. **HighAlertLatency**
   - Condition: P95 latency > 10s
   - Severity: Warning
   - Duration: 2 minutes

2. **ProtectionFailureRate**
   - Condition: Success rate < 90%
   - Severity: Critical
   - Duration: 5 minutes

3. **APIDown**
   - Condition: API unreachable
   - Severity: Critical
   - Duration: 1 minute

4. **NoMonitoredPositions**
   - Condition: 0 positions monitored
   - Severity: Warning
   - Duration: 5 minutes

## Querying Metrics

### Prometheus Queries

**Risk event rate**:
```promql
rate(risk_event_trigger_total[5m])
```

**Protection success rate**:
```promql
rate(protect_success_total[5m]) /
(rate(protect_success_total[5m]) + rate(protect_failure_total[5m]))
```

**Alert latency P95**:
```promql
histogram_quantile(0.95, rate(alert_latency_seconds_bucket[5m]))
```

**Positions monitored**:
```promql
positions_monitored
```

## Grafana Dashboard Export

To export the dashboard:

1. Open Grafana at http://localhost:3001
2. Navigate to Dashboard → Settings
3. Click "JSON Model"
4. Copy JSON content
5. Save to `configs/grafana/dashboards/watchtower-dashboard.json`

## Troubleshooting

### Prometheus not scraping metrics

1. Check API is exposing `/metrics`:
   ```bash
   curl http://localhost:8080/metrics
   ```

2. Check Prometheus targets:
   - Open http://localhost:9090/targets
   - Verify `watchtower-api` target is UP

### Grafana dashboard not loading

1. Check provisioning config:
   ```bash
   cat configs/grafana/provisioning/dashboards/dashboards.yml
   ```

2. Verify dashboard JSON is valid:
   ```bash
   cat configs/grafana/dashboards/watchtower-dashboard.json | jq .
   ```

3. Check Grafana logs:
   ```bash
   docker-compose logs grafana
   ```

### Data not appearing in Grafana

1. Verify Prometheus datasource:
   - Open Grafana → Configuration → Data Sources
   - Test Prometheus connection

2. Check query in Explore:
   - Open Grafana → Explore
   - Run test query: `up{job="watchtower-api"}`

## Stopping the Stack

```bash
docker-compose down
```

To remove volumes (delete all data):
```bash
docker-compose down -v
```

## Backup

To backup Grafana dashboards:
```bash
docker cp watchtower-grafana:/var/lib/grafana/dashboards ./backup/
```

To backup Prometheus data:
```bash
docker cp watchtower-prometheus:/prometheus ./backup/
```
```

### E6.7.2 Update main README with observability section | 更新主 README 添加可观测性章节
File path: `README.md` (append) | 文件路径（追加）

```markdown
## Observability

DeRisk Watchtower includes a complete observability stack with Prometheus and Grafana.

### Quick Start

```bash
./scripts/start-observability.sh
```

### Access

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001 (admin/admin)

### Metrics

- `risk_event_trigger_total` - Total risk events
- `protect_success_total` - Successful protections
- `protect_failure_total` - Failed protections
- `alert_latency_seconds` - Alert latency histogram
- `positions_monitored` - Active position count

See [docs/OBSERVABILITY.md](docs/OBSERVABILITY.md) for detailed documentation.
```

---

## E6.8 Testing（测试）

### E6.8.1 Create metrics validation script | 创建指标验证脚本
File path: `scripts/validate-metrics.sh` | 文件路径

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Validating Prometheus metrics..."

API_URL="${API_URL:-http://localhost:8080}"
PROMETHEUS_URL="${PROMETHEUS_URL:-http://localhost:9090}"

# Check if API is running
if ! curl -s "$API_URL/healthz" > /dev/null; then
    echo "❌ API is not running at $API_URL"
    exit 1
fi

# Check if Prometheus is running
if ! curl -s "$PROMETHEUS_URL/-/healthy" > /dev/null; then
    echo "❌ Prometheus is not running at $PROMETHEUS_URL"
    exit 1
fi

# Validate metrics endpoint
echo "📊 Checking /metrics endpoint..."
METRICS=$(curl -s "$API_URL/metrics")

# Check for required metrics
REQUIRED_METRICS=(
    "risk_event_trigger_total"
    "protect_success_total"
    "protect_failure_total"
    "alert_latency_seconds"
    "positions_monitored"
)

MISSING_METRICS=()

for metric in "${REQUIRED_METRICS[@]}"; do
    if echo "$METRICS" | grep -q "^$metric"; then
        echo "✅ Found: $metric"
    else
        echo "❌ Missing: $metric"
        MISSING_METRICS+=("$metric")
    fi
done

if [ ${#MISSING_METRICS[@]} -eq 0 ]; then
    echo ""
    echo "🎉 All required metrics are present!"
    exit 0
else
    echo ""
    echo "❌ Missing metrics: ${MISSING_METRICS[*]}"
    exit 1
fi
```

### E6.8.2 Make validation script executable | 使验证脚本可执行
```bash
chmod +x scripts/validate-metrics.sh
```

---

## E6.9 Dashboard Screenshots（仪表盘截图）

### E6.9.1 Create screenshots directory | 创建截图目录
```bash
mkdir -p docs/screenshots
```

### E6.9.2 Add dashboard screenshot placeholder | 添加仪表盘截图占位符
File path: `docs/screenshots/README.md` | 文件路径

```markdown
# Dashboard Screenshots

## Main Dashboard

![Watchtower Dashboard](watchtower-dashboard.png)

**Panels**:
- Risk Events Rate
- Alert Latency P95
- Protection Actions
- Positions Monitored
- Service Uptime
- Alert Latency Percentiles

## Prometheus Targets

![Prometheus Targets](prometheus-targets.png)

## Grafana Data Source

![Grafana Data Source](grafana-datasource.png)
```

---

## E6.10 CI/CD Integration（CI/CD 集成）

### E6.10.1 Add observability validation to CI | 添加可观测性验证到 CI
File path: `.github/workflows/observability.yml` | 文件路径

```yaml
name: Observability Stack

on:
  push:
    branches: [main, develop]
    paths:
      - 'configs/prometheus/**'
      - 'configs/grafana/**'
      - 'docker-compose.yml'
  pull_request:
    paths:
      - 'configs/prometheus/**'
      - 'configs/grafana/**'
      - 'docker-compose.yml'

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Validate Prometheus config
        run: |
          docker run --rm -v $(pwd)/configs/prometheus:/etc/prometheus \
            prom/prometheus:latest \
            promtool check config /etc/prometheus/prometheus.yml

      - name: Validate Prometheus rules
        run: |
          docker run --rm -v $(pwd)/configs/prometheus:/etc/prometheus \
            prom/prometheus:latest \
            promtool check rules /etc/prometheus/rules.yml

      - name: Validate Grafana dashboard JSON
        run: |
          sudo apt-get install -y jq
          jq empty configs/grafana/dashboards/watchtower-dashboard.json

      - name: Start observability stack
        run: |
          docker-compose up -d
          sleep 10

      - name: Check Prometheus health
        run: |
          curl -f http://localhost:9090/-/healthy

      - name: Check Grafana health
        run: |
          curl -f http://localhost:3001/api/health

      - name: Stop observability stack
        if: always()
        run: |
          docker-compose down -v
```

---

## E6.11 Performance Benchmarks（性能基准）

### E6.11.1 Create benchmark script | 创建基准脚本
File path: `scripts/benchmark-metrics.sh` | 文件路径

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "📊 Benchmarking metrics collection..."

API_URL="${API_URL:-http://localhost:8080}"

# Warm up
echo "🔥 Warming up..."
for i in {1..10}; do
    curl -s "$API_URL/metrics" > /dev/null
done

# Benchmark
echo "⏱️  Running benchmark (100 requests)..."
TOTAL_TIME=0

for i in {1..100}; do
    START=$(date +%s.%N)
    curl -s "$API_URL/metrics" > /dev/null
    END=$(date +%s.%N)
    DURATION=$(echo "$END - $START" | bc)
    TOTAL_TIME=$(echo "$TOTAL_TIME + $DURATION" | bc)
done

AVG_TIME=$(echo "scale=3; $TOTAL_TIME / 100" | bc)

echo ""
echo "📈 Results:"
echo "   Total requests: 100"
echo "   Average time:   ${AVG_TIME}s"
echo ""

# Check if under threshold (500ms)
if (( $(echo "$AVG_TIME < 0.5" | bc -l) )); then
    echo "✅ Performance OK (< 500ms)"
    exit 0
else
    echo "❌ Performance degraded (> 500ms)"
    exit 1
fi
```

---

## E6.12 Completion Checklist（完成清单）

- [ ] docker-compose.yml created | docker-compose.yml 已创建
- [ ] Prometheus service configured | Prometheus 服务已配置
- [ ] Grafana service configured | Grafana 服务已配置
- [ ] prometheus.yml scrape config | prometheus.yml 抓取配置
- [ ] Recording rules defined | 记录规则已定义
- [ ] Alerting rules defined | 告警规则已定义
- [ ] Grafana datasource provisioning | Grafana 数据源配置
- [ ] Grafana dashboard provisioning | Grafana 仪表盘配置
- [ ] Main dashboard JSON created | 主仪表盘 JSON 已创建
- [ ] 6 dashboard panels configured | 6 个仪表盘面板已配置
- [ ] One-command startup script (bash) | 一键启动脚本（bash）
- [ ] One-command startup script (PowerShell) | 一键启动脚本（PowerShell）
- [ ] OBSERVABILITY.md documentation | OBSERVABILITY.md 文档
- [ ] README updated with observability section | README 已更新可观测性章节
- [ ] Metrics validation script | 指标验证脚本
- [ ] Dashboard screenshot placeholders | 仪表盘截图占位符
- [ ] CI/CD observability validation | CI/CD 可观测性验证
- [ ] Performance benchmark script | 性能基准脚本
- [ ] All 5 core metrics exposed | 所有 5 个核心指标已暴露
- [ ] 4 alerts configured | 4 个告警已配置
- [ ] Prometheus accessible at :9090 | Prometheus 可在 :9090 访问
- [ ] Grafana accessible at :3001 | Grafana 可在 :3001 访问
- [ ] Dashboard auto-loads on startup | 启动时仪表盘自动加载
- [ ] Metrics instrumentation < 500ms overhead | 指标插桩开销 < 500ms

---

**End of E6 Observability Tasks | E6 可观测性任务结束**
