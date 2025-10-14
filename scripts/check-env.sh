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
