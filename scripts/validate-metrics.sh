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