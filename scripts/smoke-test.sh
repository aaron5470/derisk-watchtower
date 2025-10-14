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
