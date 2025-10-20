# DeRisk Watchtower Backend

Go backend service for monitoring Chainlink Automation health and exposing automation metrics via REST API.

## Features

- **Automation Health Monitoring**: Continuously monitors the Protector contract for automation statistics
- **Prometheus Metrics**: Exposes automation metrics for Grafana dashboards
- **REST API**: Provides `/api/automation/status` endpoint for frontend consumption
- **Graceful Shutdown**: Handles SIGTERM/SIGINT for clean shutdowns

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `RPC_URL` | Ethereum RPC endpoint | `http://localhost:8545` | No |
| `PROTECTOR_ADDRESS` | Deployed Protector contract address | - | **Yes** |
| `API_PORT` | HTTP server port | `8080` | No |

## Setup

### Prerequisites

- Go 1.21+
- Access to Ethereum RPC node (local or remote)
- Deployed Protector contract

### Install Dependencies

```bash
cd backend
go mod download
```

### Build

```bash
go build -o bin/server cmd/server/main.go
```

### Run

```bash
export RPC_URL=https://base-sepolia.g.alchemy.com/v2/YOUR_API_KEY
export PROTECTOR_ADDRESS=0x1234567890abcdef1234567890abcdef12345678
export API_PORT=8080

./bin/server
```

Or with `go run`:

```bash
go run cmd/server/main.go
```

## API Endpoints

### Health Check

**GET** `/healthz`

Returns server health status.

**Response:**
```json
{
  "status": "ok",
  "version": "0.1.0",
  "now": 1703001234
}
```

### Automation Status

**GET** `/api/automation/status`

Returns current Chainlink Automation health metrics.

**Response:**
```json
{
  "total_triggers": 42,
  "last_trigger_at": 1703000000,
  "delay_seconds": 120,
  "is_healthy": true
}
```

**Fields:**
- `total_triggers`: Total number of automation triggers since deployment
- `last_trigger_at`: Unix timestamp of last automation execution
- `delay_seconds`: Seconds since last automation trigger
- `is_healthy`: `true` if delay < 10 minutes, `false` otherwise

### Prometheus Metrics

**GET** `/metrics`

Exposes Prometheus metrics including:

- `automation_delay_seconds`: Seconds since last automation trigger (Gauge)
- `automation_triggers_total`: Total automation trigger count (Counter)
- `automation_healthy`: 1 if healthy (delay < 10min), 0 otherwise (Gauge)

## Architecture

```
backend/
├── cmd/
│   └── server/
│       └── main.go                  # Application entry point
├── internal/
│   ├── api/
│   │   └── handlers/
│   │       └── automation.go        # Automation API handlers
│   └── services/
│       └── automation.go            # Automation monitoring service
├── go.mod                           # Go module dependencies
└── README.md                        # This file
```

## Monitoring Background Process

The backend automatically starts a background goroutine that:

1. Queries `Protector.getAutomationStats()` every 30 seconds
2. Updates Prometheus metrics with current delay
3. Sets healthy status based on delay threshold (10 minutes)

This ensures Grafana dashboards always have fresh automation health data.

## Integration with Protector Contract

The service calls the following Protector contract function:

```solidity
function getAutomationStats()
    external
    view
    returns (
        uint256 totalTriggers,
        uint256 lastTrigger,
        uint256 timeSinceLastTrigger
    )
```

The ABI is loaded from `contracts/abis/Protector.json`.

## Error Handling

- **Contract Call Failures**: If RPC calls fail, metrics are not updated and API returns 500
- **Missing Configuration**: Server exits with error if `PROTECTOR_ADDRESS` is not set
- **Graceful Shutdown**: On SIGTERM/SIGINT, background monitoring stops and server shuts down cleanly

## Development

### Run Tests

```bash
go test ./...
```

### Lint

```bash
golangci-lint run
```

### Hot Reload (with `air`)

```bash
air
```

## Production Deployment

### Docker

```bash
docker build -t derisk-watchtower-backend .
docker run -p 8080:8080 \
  -e RPC_URL=https://base-sepolia.g.alchemy.com/v2/YOUR_KEY \
  -e PROTECTOR_ADDRESS=0x... \
  derisk-watchtower-backend
```

### Systemd Service

Create `/etc/systemd/system/derisk-backend.service`:

```ini
[Unit]
Description=DeRisk Watchtower Backend
After=network.target

[Service]
Type=simple
User=derisk
WorkingDirectory=/opt/derisk-watchtower/backend
Environment=RPC_URL=https://...
Environment=PROTECTOR_ADDRESS=0x...
ExecStart=/opt/derisk-watchtower/backend/bin/server
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable derisk-backend
sudo systemctl start derisk-backend
```

## Troubleshooting

### "PROTECTOR_ADDRESS environment variable is required"

Set the `PROTECTOR_ADDRESS` environment variable to your deployed Protector contract address.

### "Failed to connect to Ethereum client"

Check that `RPC_URL` points to a valid Ethereum RPC endpoint and that it's accessible.

### Metrics not updating

Ensure the background monitoring goroutine is running. Check logs for RPC errors.

## License

MIT
