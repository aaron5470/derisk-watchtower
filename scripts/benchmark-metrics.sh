#!/usr/bin/env bash
set -euo pipefail

echo "📊 Benchmarking metrics collection..."

API_URL="${API_URL:-http://localhost:8080}"

# Check if API is running
if ! curl -s "$API_URL/healthz" > /dev/null; then
    echo "❌ API is not running at $API_URL"
    exit 1
fi

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