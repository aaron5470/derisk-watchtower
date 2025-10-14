.PHONY: help install build test clean dev

help:
	@echo "Available targets:"
	@echo "  install    - Install all dependencies"
	@echo "  build      - Build all components"
	@echo "  test       - Run all tests"
	@echo "  dev        - Start development services"
	@echo "  clean      - Clean build artifacts"

install:
	cd contracts && forge install
	cd backend && go mod download
	cd frontend && npm install

build:
	cd contracts && forge build
	cd backend && go build -o bin/server cmd/server/main.go
	cd frontend && npm run build

test:
	cd contracts && forge test
	cd backend && go test ./...
	cd frontend && npm test

dev:
	docker-compose up -d prometheus grafana
	@echo "Services started. Check http://localhost:3001 (Grafana)"

clean:
	cd contracts && forge clean
	cd backend && rm -rf bin/
	cd frontend && rm -rf .next/
