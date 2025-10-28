# DeRisk Watchtower Demo Startup Script
# This script starts all services required for the demo

Write-Host "🚀 Starting DeRisk Watchtower Demo Environment..." -ForegroundColor Green
Write-Host ""

# Check if Docker is running
Write-Host "[1/5] Checking Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Start Docker Compose services
Write-Host ""
Write-Host "[2/5] Starting Docker Compose (Prometheus + Grafana)..." -ForegroundColor Yellow
docker-compose up -d

# Wait for services to initialize
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Verify Prometheus
try {
    Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5 | Out-Null
    Write-Host "✅ Prometheus is running at http://localhost:9090" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Prometheus may not be ready yet" -ForegroundColor Yellow
}

# Verify Grafana
try {
    Invoke-WebRequest -Uri "http://localhost:3001/api/health" -UseBasicParsing -TimeoutSec 5 | Out-Null
    Write-Host "✅ Grafana is running at http://localhost:3001 (admin/admin)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Grafana may not be ready yet" -ForegroundColor Yellow
}

# Start Backend Service
Write-Host ""
Write-Host "[3/5] Starting Backend Service..." -ForegroundColor Yellow

# Check if Go is installed
try {
    $goVersion = go version
    Write-Host "✅ Go is installed: $goVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Go is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Go 1.21+ from https://go.dev/dl/" -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Start backend in new window
Write-Host "🔧 Starting backend server in new window..." -ForegroundColor Cyan
$backendPath = Join-Path $PSScriptRoot "..\backend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; Write-Host '🔧 Backend Server' -ForegroundColor Cyan; go run cmd/server/main.go"

# Wait for backend to start
Write-Host "⏳ Waiting for backend to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 8

# Verify backend
$backendReady = $false
for ($i = 1; $i -le 5; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/health" -UseBasicParsing -TimeoutSec 3
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Backend is running at http://localhost:8080" -ForegroundColor Green
            $backendReady = $true
            break
        }
    } catch {
        Write-Host "⏳ Waiting for backend... (attempt $i/5)" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

if (-not $backendReady) {
    Write-Host "⚠️  Backend may not be ready yet. Check the backend window for errors." -ForegroundColor Yellow
}

# Start Frontend Service
Write-Host ""
Write-Host "[4/5] Starting Frontend Service..." -ForegroundColor Yellow

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js is installed: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js 18+ from https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Check if frontend dependencies are installed
$frontendPath = Join-Path $PSScriptRoot "..\frontend"
$nodeModulesPath = Join-Path $frontendPath "node_modules"

if (-not (Test-Path $nodeModulesPath)) {
    Write-Host "📦 Frontend dependencies not found. Installing..." -ForegroundColor Yellow
    Push-Location $frontendPath
    npm install
    Pop-Location
}

# Start frontend in new window
Write-Host "🌐 Starting frontend server in new window..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; Write-Host '🌐 Frontend Server' -ForegroundColor Cyan; npm run dev"

# Wait for frontend to start
Write-Host "⏳ Waiting for frontend to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# Verify frontend
$frontendReady = $false
for ($i = 1; $i -le 5; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Frontend is running at http://localhost:3000" -ForegroundColor Green
            $frontendReady = $true
            break
        }
    } catch {
        Write-Host "⏳ Waiting for frontend... (attempt $i/5)" -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
}

if (-not $frontendReady) {
    Write-Host "⚠️  Frontend may not be ready yet. Check the frontend window for errors." -ForegroundColor Yellow
}

# Generate Test Data (Optional)
Write-Host ""
Write-Host "[5/5] Test Data Generation" -ForegroundColor Yellow
Write-Host "Would you like to generate test data? (Y/N)" -ForegroundColor Cyan
$generateData = Read-Host

if ($generateData -eq "Y" -or $generateData -eq "y") {
    $scriptsPath = Join-Path $PSScriptRoot "..\backend\scripts"
    $testDataScript = Join-Path $scriptsPath "generate-test-data.go"

    if (Test-Path $testDataScript) {
        Write-Host "🔧 Generating test data..." -ForegroundColor Cyan
        Push-Location $scriptsPath
        go run generate-test-data.go
        Pop-Location
        Write-Host "✅ Test data generated" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Test data script not found at: $testDataScript" -ForegroundColor Yellow
    }
} else {
    Write-Host "⏭️  Skipping test data generation" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🎉 DeRisk Watchtower Demo Environment Started!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Service URLs:" -ForegroundColor Yellow
Write-Host "   Frontend:   http://localhost:3000" -ForegroundColor White
Write-Host "   Backend:    http://localhost:8080" -ForegroundColor White
Write-Host "   Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "   Grafana:    http://localhost:3001 (admin/admin)" -ForegroundColor White
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Open http://localhost:3000 in your browser" -ForegroundColor White
Write-Host "   2. Connect your wallet (MetaMask recommended)" -ForegroundColor White
Write-Host "   3. View the position dashboard" -ForegroundColor White
Write-Host "   4. Review docs/DEMO_PREPARATION.md for recording guide" -ForegroundColor White
Write-Host ""
Write-Host "🛑 To Stop All Services:" -ForegroundColor Yellow
Write-Host "   docker-compose down" -ForegroundColor White
Write-Host "   (Then close the backend and frontend windows)" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to open frontend in browser..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Process "http://localhost:3000"
