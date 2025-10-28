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