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