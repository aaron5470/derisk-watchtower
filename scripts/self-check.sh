#!/usr/bin/env bash
set -euo pipefail

echo "==> Self-check starting..."
echo ""

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check required commands
echo "Checking required tools..."

if command -v node >/dev/null 2>&1; then
    NODE_VER=$(node -v | cut -d 'v' -f2 | cut -d '.' -f1)
    if [[ $NODE_VER -ge 18 ]]; then
        echo -e "${GREEN}✓${NC} Node.js $(node -v)"
    else
        echo -e "${RED}❌ Node.js <18 (found $(node -v))${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${RED}❌ Node.js missing${NC}"
    ((ERRORS++))
fi

if command -v npm >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} npm $(npm -v)"
else
    echo -e "${RED}❌ npm missing${NC}"
    ((ERRORS++))
fi

if command -v go >/dev/null 2>&1; then
    GO_VER=$(go version | awk '{print $3}' | cut -d 'o' -f2 | cut -d '.' -f1-2)
    echo -e "${GREEN}✓${NC} Go $(go version | awk '{print $3}')"
else
    echo -e "${RED}❌ Go missing${NC}"
    ((ERRORS++))
fi

if command -v forge >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Foundry (forge $(forge --version | head -1))"
else
    echo -e "${RED}❌ Foundry (forge) missing${NC}"
    ((ERRORS++))
fi

if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker $(docker --version | awk '{print $3}' | tr -d ',')"
else
    echo -e "${RED}❌ Docker missing${NC}"
    ((ERRORS++))
fi

if command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker Compose"
else
    echo -e "${RED}❌ Docker Compose missing${NC}"
    ((ERRORS++))
fi

if command -v graph >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Graph CLI"
else
    echo -e "${YELLOW}⚠️  Graph CLI missing (optional)${NC}"
    ((WARNINGS++))
fi

echo ""

# Check .env file
echo "Checking environment configuration..."

if [ -f .env ]; then
    echo -e "${GREEN}✓${NC} .env file exists"

    # Source .env and check required variables
    set +e
    source .env 2>/dev/null
    set -e

    if [ -n "${BASE_SEPOLIA_RPC:-}" ]; then
        echo -e "${GREEN}✓${NC} BASE_SEPOLIA_RPC is set"
    else
        echo -e "${RED}❌ BASE_SEPOLIA_RPC not set${NC}"
        ((ERRORS++))
    fi

    if [ -n "${CHAIN_ID:-}" ]; then
        echo -e "${GREEN}✓${NC} CHAIN_ID is set"
    else
        echo -e "${YELLOW}⚠️  CHAIN_ID not set${NC}"
        ((WARNINGS++))
    fi

    if [ -n "${API_PORT:-}" ]; then
        echo -e "${GREEN}✓${NC} API_PORT is set"
    else
        echo -e "${YELLOW}⚠️  API_PORT not set (will default to 8080)${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌ .env file missing (run: cp .env.example .env)${NC}"
    ((ERRORS++))
fi

echo ""

# Check Docker daemon
echo "Checking Docker daemon..."

if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
else
    echo -e "${RED}❌ Docker daemon not running${NC}"
    ((ERRORS++))
fi

echo ""

# Check port availability
echo "Checking port availability..."

check_port() {
    local port=$1
    local service=$2
    if command -v nc >/dev/null 2>&1; then
        if nc -z localhost $port 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Port $port in use ($service)${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}✓${NC} Port $port free ($service)"
        fi
    elif command -v netstat >/dev/null 2>&1; then
        if netstat -an | grep ":$port.*LISTEN" >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  Port $port in use ($service)${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}✓${NC} Port $port free ($service)"
        fi
    else
        echo -e "${YELLOW}⚠️  Cannot check port $port (nc/netstat missing)${NC}"
    fi
}

check_port 8080 "Backend API"
check_port 3000 "Frontend"
check_port 3001 "Grafana"
check_port 9090 "Prometheus"

echo ""

# Check disk space
echo "Checking disk space..."

if command -v df >/dev/null 2>&1; then
    AVAIL=$(df . | tail -1 | awk '{print $4}')
    if [[ $AVAIL -gt 5000000 ]]; then
        echo -e "${GREEN}✓${NC} Sufficient disk space (>5GB available)"
    else
        echo -e "${YELLOW}⚠️  Low disk space (<5GB available)${NC}"
        ((WARNINGS++))
    fi
fi

echo ""

# Check internet connectivity
echo "Checking internet connectivity..."

if command -v curl >/dev/null 2>&1; then
    if curl -sf https://sepolia.base.org >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Can reach Base Sepolia RPC"
    else
        echo -e "${YELLOW}⚠️  Cannot reach Base Sepolia RPC${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️  curl not available, cannot test connectivity${NC}"
fi

echo ""
echo "==> Self-check complete!"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Found $ERRORS error(s) that must be fixed.${NC}"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}Found $WARNINGS warning(s). You can proceed but some features may not work.${NC}"
    exit 0
else
    echo -e "${GREEN}All checks passed! You're ready to start development.${NC}"
    exit 0
fi
