#!/usr/bin/env bash
set -euo pipefail

echo "==> Bootstrapping DeRisk Watchtower..."

# Check prerequisites
echo "==> Checking prerequisites..."
command -v node >/dev/null 2>&1 || { echo "Node.js required"; exit 1; }
command -v go >/dev/null 2>&1 || { echo "Go required"; exit 1; }
command -v forge >/dev/null 2>&1 || { echo "Foundry required"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker required"; exit 1; }

# Create .env if not exists
if [ ! -f .env ]; then
  echo "==> Creating .env from template..."
  cp .env.example .env
  echo "Please edit .env with your configuration"
fi

# Install dependencies
echo "==> Installing dependencies..."
make install

echo "==> Bootstrap complete! Run 'make dev' to start."
