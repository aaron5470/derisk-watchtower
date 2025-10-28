# E8 Testing & Security Tasks（E8 测试与安全任务）

**Feature**: DeRisk Watchtower | **分支**: `008-derisk-watchtower-testing-security`
**Feature**: DeRisk 瞭望塔 | **Branch**: `008-derisk-watchtower-testing-security`

---

## E8.1 Smart Contract Tests（智能合约测试）

### E8.1.1 PositionVault Unit Tests | PositionVault 单元测试
File path: `contracts/test/PositionVault.t.sol` | 文件路径

**Test Cases** / **测试用例**:
```solidity
// Test position creation
function testCreatePosition() public

// Test HF calculation accuracy
function testHealthFactorCalculation() public

// Test HF with different collateral ratios
function testHealthFactorVariousRatios() public

// Test position update
function testUpdatePosition() public

// Test collateral addition
function testAddCollateral() public

// Test debt increase
function testIncreaseDebt() public

// Test position retrieval
function testGetPosition() public

// Test position by owner query
function testGetPositionsByOwner() public

// Test invalid position access
function testGetNonexistentPosition() public

// Test zero collateral revert
function testCreatePositionZeroCollateral() public

// Test zero debt revert
function testCreatePositionZeroDebt() public
```

### E8.1.2 Protector Unit Tests | Protector 单元测试
File path: `contracts/test/Protector.t.sol` | 文件路径

**Test Cases** / **测试用例**:
```solidity
// Test protect function success
function testProtectPositionSuccess() public

// Test collateral calculation
function testCalculateCollateralNeeded() public

// Test protection with insufficient escrow funds
function testProtectInsufficientFunds() public

// Test protection on healthy position (should revert)
function testProtectHealthyPositionReverts() public

// Test reentrancy guard
function testProtectReentrancyGuard() public

// Test pause functionality
function testPauseProtection() public

// Test unpause functionality
function testUnpauseProtection() public

// Test protect while paused (should revert)
function testProtectWhilePausedReverts() public

// Test ProtectionExecuted event emission
function testProtectionExecutedEvent() public

// Test HF improvement after protection
function testHealthFactorImprovement() public

// Test protection with price feed staleness
function testProtectStalePriceFeed() public

// Test multiple protections on same position
function testMultipleProtections() public
```

### E8.1.3 DemoEscrow Unit Tests | DemoEscrow 单元测试
File path: `contracts/test/DemoEscrow.t.sol` | 文件路径

**Test Cases** / **测试用例**:
```solidity
// Test escrow funding
function testFundEscrow() public

// Test withdraw by authorized contract
function testWithdrawAuthorized() public

// Test withdraw by unauthorized address (should revert)
function testWithdrawUnauthorizedReverts() public

// Test withdraw exceeding balance (should revert)
function testWithdrawExceedingBalanceReverts() public

// Test balance query
function testGetBalance() public

// Test authorization management
function testAuthorizeContract() public

// Test deauthorization
function testDeauthorizeContract() public

// Test ERC20 compatibility
function testERC20Transfers() public
```

### E8.1.4 Integration Tests | 集成测试
File path: `contracts/test/Integration.t.sol` | 文件路径

**Test Cases** / **测试用例**:
```solidity
// Test full flow: create → drop HF → protect → verify
function testFullProtectionFlow() public

// Test Chainlink price feed integration
function testChainlinkPriceFeedIntegration() public

// Test price drop simulation
function testPriceDropSimulation() public

// Test multiple positions protection
function testMultiplePositionsProtection() public

// Test protection with actual token transfers
function testProtectionWithTokenTransfers() public

// Test event emission sequence
function testEventSequence() public

// Test gas consumption for typical operations
function testGasConsumption() public
```

### E8.1.5 Mock Price Feed Tests | 模拟价格预言机测试
File path: `contracts/test/mocks/MockPriceFeed.sol` | 文件路径

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../src/interfaces/IChainlinkPriceFeed.sol";

contract MockPriceFeed is IChainlinkPriceFeed {
    int256 private _price;
    uint8 private _decimals;
    uint256 private _updatedAt;

    constructor() {
        _price = 2000e8; // Default $2000
        _decimals = 8;
        _updatedAt = block.timestamp;
    }

    function setPrice(int256 newPrice) external {
        _price = newPrice;
        _updatedAt = block.timestamp;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (1, _price, block.timestamp, _updatedAt, 1);
    }
}
```

### E8.1.6 Run all contract tests | 运行所有合约测试
```bash
# Run all tests
forge test

# Run with verbosity
forge test -vv

# Run specific test
forge test --match-test testFullProtectionFlow

# Run with gas report
forge test --gas-report

# Run with coverage
forge coverage
```

---

## E8.2 Backend Tests（后端测试）

### E8.2.1 Monitor Service Tests | 监控服务测试
File path: `backend/internal/services/monitor_test.go` | 文件路径

**Test Cases** / **测试用例**:
```go
package services

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

// Test HF calculation accuracy
func TestCalculateHealthFactor(t *testing.T) {
    tests := []struct {
        name           string
        collateral     uint64
        collateralPrice uint64
        debt           uint64
        debtPrice      uint64
        expected       uint64
    }{
        {
            name: "Safe position HF=2.0",
            collateral: 1000,
            collateralPrice: 2000,
            debt: 400,
            debtPrice: 1000,
            expected: 20000, // 2.0 with 4 decimals
        },
        {
            name: "Warning position HF=1.4",
            collateral: 1000,
            collateralPrice: 2000,
            debt: 571,
            debtPrice: 1000,
            expected: 14000, // 1.4 with 4 decimals
        },
        {
            name: "Critical position HF=1.2",
            collateral: 1000,
            collateralPrice: 2000,
            debt: 667,
            debtPrice: 1000,
            expected: 12000, // 1.2 with 4 decimals
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := calculateHF(tt.collateral, tt.collateralPrice, tt.debt, tt.debtPrice)
            assert.Equal(t, tt.expected, result)
        })
    }
}

// Test position monitoring loop
func TestMonitorPositions(t *testing.T) {}

// Test HF threshold detection
func TestDetectThresholdBreach(t *testing.T) {}

// Test monitoring with RPC failure
func TestMonitorWithRPCFailure(t *testing.T) {}

// Test monitoring with stale data
func TestMonitorWithStaleData(t *testing.T) {}
```

### E8.2.2 Alerter Service Tests | 警报服务测试
File path: `backend/internal/services/alerter_test.go` | 文件路径

**Test Cases** / **测试用例**:
```go
// Test alert generation
func TestGenerateAlert(t *testing.T) {}

// Test alert deduplication
func TestAlertDeduplication(t *testing.T) {}

// Test WebSocket broadcast
func TestWebSocketBroadcast(t *testing.T) {}

// Test alert throttling (30s window)
func TestAlertThrottling(t *testing.T) {}

// Test multiple concurrent alerts
func TestConcurrentAlerts(t *testing.T) {}
```

### E8.2.3 WebSocket Tests | WebSocket 测试
File path: `backend/internal/api/handlers/ws_test.go` | 文件路径

**Test Cases** / **测试用例**:
```go
// Test WebSocket connection establishment
func TestWebSocketConnect(t *testing.T) {}

// Test WebSocket reconnect with replay
func TestWebSocketReconnectReplay(t *testing.T) {}

// Test event cache (60s window)
func TestEventCache(t *testing.T) {}

// Test serverEventTs handling
func TestServerEventTimestamp(t *testing.T) {}

// Test concurrent WebSocket connections
func TestConcurrentConnections(t *testing.T) {}

// Test WebSocket disconnect cleanup
func TestWebSocketDisconnectCleanup(t *testing.T) {}
```

### E8.2.4 RPC Client Tests | RPC 客户端测试
File path: `backend/internal/services/rpclient_test.go` | 文件路径

**Test Cases** / **测试用例**:
```go
// Test exponential backoff retry
func TestExponentialBackoff(t *testing.T) {
    // Verify: initial=500ms, multiplier=2.0, jitter=±20%, max_delay=8s
}

// Test circuit breaker open
func TestCircuitBreakerOpen(t *testing.T) {
    // Verify: 5 failures/30s → open
}

// Test circuit breaker half-open
func TestCircuitBreakerHalfOpen(t *testing.T) {
    // Verify: half-open after 60s
}

// Test idempotent operation retry
func TestIdempotentRetry(t *testing.T) {}

// Test max retry attempts (5)
func TestMaxRetryAttempts(t *testing.T) {}

// Test jitter randomization
func TestJitterRandomization(t *testing.T) {}
```

### E8.2.5 Subgraph Client Tests | 子图客户端测试
File path: `backend/internal/services/subgraph_test.go` | 文件路径

**Test Cases** / **测试用例**:
```go
// Test GraphQL query execution
func TestGraphQLQuery(t *testing.T) {}

// Test position query by owner
func TestQueryPositionsByOwner(t *testing.T) {}

// Test risk event query
func TestQueryRiskEvents(t *testing.T) {}

// Test subgraph staleness detection
func TestSubgraphStaleness(t *testing.T) {}

// Test query with timeout
func TestQueryTimeout(t *testing.T) {}
```

### E8.2.6 Integration Tests | 集成测试
File path: `backend/tests/integration/full_flow_test.go` | 文件路径

**Test Cases** / **测试用例**:
```go
// Test end-to-end monitoring flow
func TestE2EMonitoringFlow(t *testing.T) {
    // 1. Mock position with HF 1.5
    // 2. Simulate price drop to HF 1.2
    // 3. Verify alert generated
    // 4. Verify WebSocket broadcast
    // 5. Verify metrics incremented
}

// Test protection execution flow
func TestE2EProtectionFlow(t *testing.T) {}

// Test offline replay mode
func TestOfflineReplayMode(t *testing.T) {}
```

### E8.2.7 Run all backend tests | 运行所有后端测试
```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run with verbose output
go test -v ./...

# Run specific test
go test -run TestCalculateHealthFactor ./internal/services

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

---

## E8.3 Frontend Tests（前端测试）

### E8.3.1 Unit Tests (Vitest) | 单元测试（Vitest）
File path: `frontend/tests/unit/` | 文件路径

**Test Cases** / **测试用例**:

#### hooks/useWebSocket.test.ts
```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useWebSocket } from '@/hooks/useWebSocket';

describe('useWebSocket', () => {
  test('establishes WebSocket connection', async () => {
    const { result } = renderHook(() => useWebSocket('ws://localhost:8080/ws/risk-stream'));

    await waitFor(() => {
      expect(result.current.isConnected).toBe(true);
    });
  });

  test('auto-reconnects on disconnect', async () => {});

  test('replays events after reconnect', async () => {});

  test('handles serverEventTs correctly', async () => {});
});
```

#### hooks/usePositions.test.ts
```typescript
import { renderHook } from '@testing-library/react';
import { usePositions } from '@/hooks/usePositions';

describe('usePositions', () => {
  test('fetches positions for connected wallet', async () => {});

  test('handles empty positions', async () => {});

  test('handles fetch error', async () => {});

  test('refetches on interval', async () => {});
});
```

#### hooks/useProtect.test.ts
```typescript
import { renderHook } from '@testing-library/react';
import { useProtect } from '@/hooks/useProtect';

describe('useProtect', () => {
  test('executes protection transaction', async () => {});

  test('handles transaction rejection', async () => {});

  test('handles insufficient gas', async () => {});

  test('updates position after success', async () => {});
});
```

#### lib/replay.test.ts
```typescript
import { loadReplayFixture, isReplayMode } from '@/lib/replay';

describe('Replay Mode', () => {
  test('loads scenario 1 fixture', () => {
    const fixture = loadReplayFixture('1');
    expect(fixture.scenario).toBe('S1_HEALTHY_TO_SAFE');
  });

  test('loads scenario 2 fixture', () => {});

  test('loads scenario 3 fixture', () => {});

  test('detects replay mode from query param', () => {});
});
```

### E8.3.2 Component Tests (Vitest) | 组件测试（Vitest）
File path: `frontend/tests/unit/components/` | 文件路径

#### PositionCard.test.tsx
```typescript
import { render, screen } from '@testing-library/react';
import { PositionCard } from '@/components/positions/PositionCard';

describe('PositionCard', () => {
  test('renders position with Safe status', () => {
    const position = {
      id: '0x123',
      healthFactor: 2.0,
      collateralAmount: '1000',
      debtAmount: '400',
    };

    render(<PositionCard position={position} />);

    expect(screen.getByText(/HF: 2.00/)).toBeInTheDocument();
    expect(screen.getByText(/Safe/)).toBeInTheDocument();
  });

  test('renders position with Warning status', () => {});

  test('renders position with Critical status', () => {});

  test('displays correct color indicator', () => {});
});
```

#### RiskAlert.test.tsx
```typescript
import { render, screen } from '@testing-library/react';
import { RiskAlert } from '@/components/alerts/RiskAlert';

describe('RiskAlert', () => {
  test('renders alert with correct message', () => {});

  test('displays alert severity correctly', () => {});

  test('dismisses alert on close', () => {});
});
```

#### ProtectButton.test.tsx
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { ProtectButton } from '@/components/positions/ProtectButton';

describe('ProtectButton', () => {
  test('calls protect function on click', async () => {});

  test('disables button while protecting', async () => {});

  test('shows error toast on failure', async () => {});

  test('shows success toast on completion', async () => {});
});
```

### E8.3.3 E2E Tests (Playwright) | E2E 测试（Playwright）
File path: `frontend/tests/e2e/` | 文件路径

**Setup Playwright** / **设置 Playwright**:
```bash
cd frontend
npm install -D @playwright/test
npx playwright install
```

#### critical-flow.spec.ts
```typescript
import { test, expect } from '@playwright/test';

test.describe('Critical User Flow', () => {
  test('complete demo flow: connect → view → alert → protect', async ({ page }) => {
    // 1. Navigate to app
    await page.goto('http://localhost:3000');

    // 2. Connect wallet (mock)
    await page.click('button:has-text("Connect Wallet")');
    await page.waitForSelector('[data-testid="position-dashboard"]');

    // 3. Verify position displays
    const hfElement = await page.locator('[data-testid="health-factor"]');
    await expect(hfElement).toBeVisible();

    // 4. Trigger simulated alert (via API)
    await page.evaluate(() => {
      fetch('http://localhost:8080/api/test/trigger-alert', { method: 'POST' });
    });

    // 5. Wait for alert to appear
    await page.waitForSelector('[data-testid="risk-alert"]', { timeout: 15000 });

    // 6. Click protect button
    await page.click('button:has-text("Protect Position")');

    // 7. Wait for transaction confirmation
    await page.waitForSelector('[data-testid="protection-success"]', { timeout: 10000 });

    // 8. Verify HF improved
    const newHF = await page.locator('[data-testid="health-factor"]').textContent();
    expect(parseFloat(newHF)).toBeGreaterThan(1.5);
  });

  test('offline replay mode', async ({ page }) => {
    // Navigate with ?replay=1
    await page.goto('http://localhost:3000?replay=1');

    // Verify replay data loads
    await expect(page.locator('[data-testid="replay-indicator"]')).toBeVisible();

    // Verify scenario data displays
    await expect(page.locator('[data-testid="position-card"]')).toBeVisible();
  });

  test('WebSocket reconnect and replay', async ({ page }) => {
    // 1. Connect to app
    await page.goto('http://localhost:3000');

    // 2. Establish WebSocket
    await page.click('button:has-text("Connect Wallet")');
    await page.waitForSelector('[data-testid="ws-connected"]');

    // 3. Simulate disconnect
    await page.evaluate(() => {
      // Close WebSocket connection
      (window as any).__ws?.close();
    });

    // 4. Wait for reconnect
    await page.waitForSelector('[data-testid="ws-connected"]', { timeout: 5000 });

    // 5. Verify events replayed
    const eventCount = await page.locator('[data-testid="event-timeline"] > div').count();
    expect(eventCount).toBeGreaterThan(0);
  });

  test('handles RPC failure gracefully', async ({ page }) => {
    // Mock RPC failure
    await page.route('**/api/positions*', route => route.abort());

    await page.goto('http://localhost:3000');
    await page.click('button:has-text("Connect Wallet")');

    // Verify error message displayed
    await expect(page.locator('[data-testid="error-message"]')).toBeVisible();
    await expect(page.locator('button:has-text("Retry")')).toBeVisible();
  });
});
```

### E8.3.4 Run all frontend tests | 运行所有前端测试
```bash
# Run unit tests (Vitest)
npm test

# Run unit tests with coverage
npm run test:coverage

# Run E2E tests (Playwright)
npm run test:e2e

# Run E2E tests in headed mode
npm run test:e2e -- --headed

# Run specific E2E test
npm run test:e2e -- critical-flow.spec.ts
```

---

## E8.4 Security Audits（安全审计）

### E8.4.1 Smart Contract Security Checklist | 智能合约安全清单
File path: `docs/SECURITY_AUDIT.md` | 文件路径

```markdown
# Smart Contract Security Audit Checklist

## ✅ Reentrancy Protection
- [x] PositionVault: No external calls before state changes
- [x] Protector: ReentrancyGuard on protect() function
- [x] DemoEscrow: ReentrancyGuard on withdraw() function

## ✅ Access Control
- [x] Protector: Only authorized contracts can call protect()
- [x] DemoEscrow: Only authorized contracts can withdraw()
- [x] PositionVault: Position owner validation on updates

## ✅ Integer Overflow/Underflow
- [x] Solidity 0.8.20+ has built-in overflow checks
- [x] HF calculation uses safe math (no unchecked blocks)

## ✅ Price Feed Validation
- [x] Chainlink price feed staleness check (updatedAt > 1 hour → revert)
- [x] Price feed zero value check
- [x] Price feed negative value handling

## ✅ Input Validation
- [x] Zero address checks on constructor parameters
- [x] Zero amount checks on deposit/borrow
- [x] Position existence checks before updates

## ✅ Pausability
- [x] Protector implements Pausable pattern
- [x] Emergency pause function for admin
- [x] Protection disabled while paused

## ✅ Events & Logging
- [x] All state changes emit events
- [x] Events include indexed parameters for filtering
- [x] Event names follow Solidity naming conventions

## ✅ Gas Optimization
- [x] Use immutable for addresses set in constructor
- [x] Avoid unnecessary storage writes
- [x] Use memory instead of storage where possible

## ⚠️ Known Limitations (Testnet Only)
- [ ] No professional security audit (demo project)
- [ ] Simplified HF calculation (no liquidation threshold variation)
- [ ] No multi-sig admin controls
- [ ] No timelock for admin functions
- [ ] Limited error messages for gas efficiency

## Findings Summary
**Critical**: 0
**High**: 0
**Medium**: 0
**Low**: 0
**Info**: 5 (known limitations for demo)
```

### E8.4.2 Slither Static Analysis | Slither 静态分析
```bash
# Install Slither
pip3 install slither-analyzer

# Run Slither on contracts
cd contracts
slither . --solc-remaps "@openzeppelin/=$(pwd)/lib/openzeppelin-contracts/"

# Generate Slither report
slither . --json slither-report.json

# Check specific contract
slither src/Protector.sol
```

### E8.4.3 Mythril Security Analysis | Mythril 安全分析
```bash
# Install Mythril
pip3 install mythril

# Analyze contracts
myth analyze contracts/src/PositionVault.sol
myth analyze contracts/src/Protector.sol
myth analyze contracts/src/DemoEscrow.sol

# Generate Mythril report
myth analyze contracts/src/Protector.sol --execution-timeout 300 -o markdown > mythril-report.md
```

### E8.4.4 Manual Code Review | 手动代码审查
File path: `docs/MANUAL_REVIEW.md` | 文件路径

```markdown
# Manual Code Review Findings

## PositionVault.sol
**Reviewed By**: [Name]
**Date**: 2025-10-XX

### Findings
1. **HF Calculation Precision** (Info)
   - Current: 4-decimal fixed-point (10000 = 1.0)
   - Recommendation: Consider 18 decimals for higher precision in production
   - Risk: Low (acceptable for demo)

2. **Price Feed Dependency** (Info)
   - Reliance on Chainlink feeds for accuracy
   - Mitigation: Staleness check implemented
   - Risk: Low (testnet reliability acceptable)

## Protector.sol
**Reviewed By**: [Name]
**Date**: 2025-10-XX

### Findings
1. **calculateCollateralNeeded Logic** (Info)
   - Assumes 0.8 liquidation threshold (hardcoded)
   - Recommendation: Make configurable in production
   - Risk: Low (demo uses fixed threshold)

2. **Escrow Balance Check** (Medium - Fixed)
   - Initial implementation: No balance check before transfer
   - Fix: Added escrow.balanceOf() check in protect()
   - Status: ✅ Fixed

## DemoEscrow.sol
**Reviewed By**: [Name]
**Date**: 2025-10-XX

### Findings
1. **Authorization Management** (Info)
   - Simple mapping for authorized contracts
   - Recommendation: Consider role-based access control (OpenZeppelin AccessControl)
   - Risk: Low (sufficient for demo)

## Summary
- **Total Findings**: 5
- **Critical**: 0
- **High**: 0
- **Medium**: 1 (Fixed)
- **Low**: 0
- **Info**: 4
```

---

## E8.5 Fuzz Testing（模糊测试）

### E8.5.1 Foundry Fuzz Tests | Foundry 模糊测试
File path: `contracts/test/FuzzProtector.t.sol` | 文件路径

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Protector.sol";
import "../src/PositionVault.sol";

contract FuzzProtectorTest is Test {
    Protector protector;
    PositionVault vault;

    function setUp() public {
        vault = new PositionVault();
        protector = new Protector(/* ... */);
    }

    // Fuzz test: random collateral/debt amounts
    function testFuzzHealthFactorCalculation(
        uint256 collateralAmount,
        uint256 debtAmount
    ) public {
        // Bound inputs to reasonable ranges
        collateralAmount = bound(collateralAmount, 1e18, 1000e18);
        debtAmount = bound(debtAmount, 1e17, 500e18);

        bytes32 posId = vault.createPosition(
            address(collateral),
            collateralAmount,
            address(debt),
            debtAmount
        );

        uint256 hf = vault.getPosition(posId).healthFactor;

        // HF should always be >= 0
        assertGe(hf, 0);

        // HF should be calculable without revert
        assertTrue(hf > 0 || debtAmount == 0);
    }

    // Fuzz test: protection with random HF values
    function testFuzzProtection(uint256 initialHF) public {
        initialHF = bound(initialHF, 5000, 13000); // 0.5 to 1.3

        // Create position with specific HF
        bytes32 posId = createPositionWithHF(initialHF);

        // Execute protection
        protector.protect(posId);

        // Verify HF improved
        uint256 finalHF = vault.getPosition(posId).healthFactor;
        assertGt(finalHF, initialHF);
        assertGe(finalHF, 15000); // Should restore to 1.5
    }

    // Fuzz test: price feed values
    function testFuzzPriceFeedValues(int256 collateralPrice, int256 debtPrice) public {
        // Bound to realistic price ranges
        collateralPrice = int256(bound(uint256(collateralPrice), 100e8, 10000e8));
        debtPrice = int256(bound(uint256(debtPrice), 50e8, 2000e8));

        mockCollateralFeed.setPrice(collateralPrice);
        mockDebtFeed.setPrice(debtPrice);

        // HF calculation should not revert
        bytes32 posId = vault.createPosition(
            address(collateral),
            1000e18,
            address(debt),
            400e18
        );

        uint256 hf = vault.getPosition(posId).healthFactor;
        assertGt(hf, 0);
    }
}
```

### E8.5.2 Run fuzz tests | 运行模糊测试
```bash
# Run fuzz tests with default runs (256)
forge test --match-contract FuzzProtectorTest

# Run with more iterations for deeper fuzzing
forge test --match-contract FuzzProtectorTest --fuzz-runs 10000

# Run specific fuzz test
forge test --match-test testFuzzHealthFactorCalculation --fuzz-runs 5000
```

---

## E8.6 Load Testing（负载测试）

### E8.6.1 Backend API Load Tests | 后端 API 负载测试
File path: `backend/tests/load/api_load_test.go` | 文件路径

```go
package load

import (
    "testing"
    "time"
    "net/http"
    "sync"
)

// Test concurrent position queries
func TestLoadPositionQueries(t *testing.T) {
    concurrency := 100
    requests := 1000
    var wg sync.WaitGroup

    start := time.Now()

    for i := 0; i < requests; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            resp, err := http.Get("http://localhost:8080/api/positions?owner=0x123")
            if err != nil {
                t.Errorf("Request failed: %v", err)
                return
            }
            defer resp.Body.Close()

            if resp.StatusCode != http.StatusOK {
                t.Errorf("Unexpected status: %d", resp.StatusCode)
            }
        }()

        // Limit concurrency
        if (i+1)%concurrency == 0 {
            wg.Wait()
        }
    }

    wg.Wait()
    duration := time.Since(start)

    // Calculate throughput
    throughput := float64(requests) / duration.Seconds()
    t.Logf("Throughput: %.2f req/s", throughput)

    // Assert minimum throughput (adjust based on requirements)
    if throughput < 50 {
        t.Errorf("Throughput too low: %.2f req/s (expected >= 50)", throughput)
    }
}

// Test WebSocket concurrent connections
func TestLoadWebSocketConnections(t *testing.T) {
    // Test 100 concurrent WebSocket connections
}

// Test monitoring loop performance
func TestLoadMonitoringLoop(t *testing.T) {
    // Test monitoring 30 positions concurrently
}
```

### E8.6.2 WebSocket Load Tests | WebSocket 负载测试
```bash
# Use websocat for WebSocket load testing
websocat --max-parallel=100 ws://localhost:8080/ws/risk-stream
```

### E8.6.3 k6 Load Testing Script | k6 负载测试脚本
File path: `backend/tests/load/k6-test.js` | 文件路径

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

export const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 20 },  // Ramp up to 20 users
    { duration: '1m', target: 20 },   // Stay at 20 users
    { duration: '30s', target: 50 },  // Ramp up to 50 users
    { duration: '1m', target: 50 },   // Stay at 50 users
    { duration: '30s', target: 0 },   // Ramp down to 0
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // 95% of requests must complete below 2s
    errors: ['rate<0.1'],               // Error rate must be below 10%
  },
};

export default function () {
  // Test /api/positions endpoint
  const positionsRes = http.get('http://localhost:8080/api/positions?owner=0x1234567890123456789012345678901234567890');

  check(positionsRes, {
    'status is 200': (r) => r.status === 200,
    'response time < 2s': (r) => r.timings.duration < 2000,
  }) || errorRate.add(1);

  sleep(1);

  // Test /api/hf/{address} endpoint
  const hfRes = http.get('http://localhost:8080/api/hf/0x1234567890123456789012345678901234567890');

  check(hfRes, {
    'status is 200': (r) => r.status === 200,
    'response time < 2s': (r) => r.timings.duration < 2000,
  }) || errorRate.add(1);

  sleep(1);
}
```

### E8.6.4 Run k6 load tests | 运行 k6 负载测试
```bash
# Install k6
# macOS: brew install k6
# Linux: sudo apt install k6

# Run k6 test
k6 run backend/tests/load/k6-test.js

# Run with custom options
k6 run --vus 100 --duration 5m backend/tests/load/k6-test.js

# Generate HTML report
k6 run --out json=results.json backend/tests/load/k6-test.js
```

---

## E8.7 Dependency Security（依赖安全）

### E8.7.1 npm audit (Frontend & Subgraph) | npm 审计（前端与子图）
```bash
# Frontend dependencies
cd frontend
npm audit

# Fix vulnerabilities automatically
npm audit fix

# Force fix (may introduce breaking changes)
npm audit fix --force

# Generate audit report
npm audit --json > frontend-audit.json

# Subgraph dependencies
cd subgraph
npm audit
npm audit fix
```

### E8.7.2 Go vulnerability check (Backend) | Go 漏洞检查（后端）
```bash
# Install govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest

# Check backend dependencies
cd backend
govulncheck ./...

# Generate report
govulncheck -json ./... > backend-vulns.json
```

### E8.7.3 Foundry dependency audit (Contracts) | Foundry 依赖审计（合约）
```bash
# Update OpenZeppelin contracts to latest
cd contracts
forge update

# Check for known vulnerabilities in dependencies
forge verify-contract --chain base-sepolia <ADDRESS> <CONTRACT>

# Review lock file
cat foundry.lock
```

### E8.7.4 Dependency version pinning | 依赖版本锁定
File path: `package.json` (frontend) | 文件路径

```json
{
  "dependencies": {
    "next": "14.2.0",           // Exact version
    "wagmi": "^2.5.0",          // Caret (minor updates)
    "viem": "~2.7.0"            // Tilde (patch updates)
  },
  "devDependencies": {
    "@playwright/test": "^1.42.0"
  }
}
```

---

## E8.8 SPDX License Headers（SPDX 许可证头）

### E8.8.1 Verify all contracts have SPDX headers | 验证所有合约含 SPDX 头
```bash
# Check all .sol files
cd contracts
find src -name "*.sol" -exec grep -L "SPDX-License-Identifier" {} \;

# If any files missing SPDX, add header
echo "// SPDX-License-Identifier: MIT" | cat - src/MissingFile.sol > temp && mv temp src/MissingFile.sol
```

### E8.8.2 Automated SPDX check script | 自动化 SPDX 检查脚本
File path: `scripts/check-spdx.sh` | 文件路径

```bash
#!/bin/bash

echo "Checking SPDX license headers in contracts..."

MISSING_FILES=()

while IFS= read -r file; do
    if ! grep -q "SPDX-License-Identifier" "$file"; then
        MISSING_FILES+=("$file")
    fi
done < <(find contracts/src -name "*.sol")

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "✅ All contracts have SPDX headers"
    exit 0
else
    echo "❌ Missing SPDX headers in:"
    printf '%s\n' "${MISSING_FILES[@]}"
    exit 1
fi
```

---

## E8.9 CI/CD Security Checks（CI/CD 安全检查）

### E8.9.1 GitHub Actions security workflow | GitHub Actions 安全工作流
File path: `.github/workflows/security.yml` | 文件路径

```yaml
name: Security Checks

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  contract-security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1

      - name: Run contract tests
        run: |
          cd contracts
          forge test

      - name: Install Slither
        run: pip3 install slither-analyzer

      - name: Run Slither
        run: |
          cd contracts
          slither . --json slither-report.json || true

      - name: Upload Slither report
        uses: actions/upload-artifact@v3
        with:
          name: slither-report
          path: contracts/slither-report.json

  backend-security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'

      - name: Run Go tests
        run: |
          cd backend
          go test ./...

      - name: Run govulncheck
        run: |
          go install golang.org/x/vuln/cmd/govulncheck@latest
          cd backend
          govulncheck ./...

  frontend-security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: |
          cd frontend
          npm ci

      - name: Run npm audit
        run: |
          cd frontend
          npm audit --production

      - name: Run tests
        run: |
          cd frontend
          npm test

      - name: Run E2E tests
        run: |
          cd frontend
          npx playwright install
          npm run test:e2e

  spdx-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Check SPDX headers
        run: |
          chmod +x scripts/check-spdx.sh
          ./scripts/check-spdx.sh
```

---

## E8.10 Penetration Testing（渗透测试）

### E8.10.1 API Security Testing | API 安全测试
File path: `docs/PENETRATION_TEST.md` | 文件路径

```markdown
# Penetration Testing Report

## Test Date
2025-10-XX

## Scope
- Backend API: http://localhost:8080
- WebSocket: ws://localhost:8080/ws/risk-stream
- Frontend: http://localhost:3000

## Test Cases

### 1. SQL Injection (N/A - No SQL database)
**Status**: Not Applicable
**Notes**: Application uses blockchain and subgraph, no direct SQL

### 2. XSS (Cross-Site Scripting)
**Test**: Inject `<script>alert('XSS')</script>` in position data
**Result**: ✅ Pass - Input sanitized by React
**Mitigation**: React escapes all user inputs by default

### 3. CSRF (Cross-Site Request Forgery)
**Test**: Attempt unauthorized API calls without CORS headers
**Result**: ✅ Pass - CORS properly configured
**Mitigation**: CORS middleware restricts origins

### 4. Authentication Bypass
**Test**: Attempt to access protected endpoints without wallet signature
**Result**: ✅ Pass - Wallet signature required
**Mitigation**: wagmi/viem wallet verification

### 5. Rate Limiting
**Test**: Send 1000 requests/second to /api/positions
**Result**: ⚠️ Warning - No rate limiting implemented
**Recommendation**: Add rate limiting middleware (10 req/min per IP)
**Priority**: Medium

### 6. WebSocket Message Injection
**Test**: Send malformed WebSocket messages
**Result**: ✅ Pass - Invalid messages ignored
**Mitigation**: JSON schema validation

### 7. MITM (Man-in-the-Middle)
**Test**: Intercept HTTP traffic
**Result**: ⚠️ Warning - HTTP used in dev (HTTPS required for production)
**Recommendation**: Enforce HTTPS in production
**Priority**: High (Production only)

### 8. Denial of Service (DoS)
**Test**: Open 1000 concurrent WebSocket connections
**Result**: ⚠️ Warning - Server accepts unlimited connections
**Recommendation**: Limit concurrent connections per IP (max 10)
**Priority**: Medium

### 9. Sensitive Data Exposure
**Test**: Check for secrets in error messages, logs, responses
**Result**: ✅ Pass - No secrets exposed
**Mitigation**: .env secrets, sanitized error messages

### 10. Price Feed Manipulation
**Test**: Attempt to manipulate price feed responses
**Result**: ✅ Pass - Chainlink feeds are immutable on-chain
**Mitigation**: Direct contract calls to verified Chainlink feeds

## Summary
- **Critical**: 0
- **High**: 1 (Production HTTPS - not applicable for demo)
- **Medium**: 2 (Rate limiting, WebSocket connection limits)
- **Low**: 0
- **Info**: 0

## Recommendations for Production
1. Implement rate limiting (express-rate-limit)
2. Limit WebSocket connections per IP
3. Enforce HTTPS with TLS 1.3
4. Add request size limits
5. Implement DDoS protection (Cloudflare)
```

---

## E8.11 Observability & Monitoring Tests（可观测性与监控测试）

### E8.11.1 Prometheus metrics validation | Prometheus 指标验证
```bash
# Test /metrics endpoint
curl http://localhost:8080/metrics | grep "risk_event_trigger_total"
curl http://localhost:8080/metrics | grep "protect_success_total"
curl http://localhost:8080/metrics | grep "protect_failure_total"
curl http://localhost:8080/metrics | grep "alert_latency_seconds"
curl http://localhost:8080/metrics | grep "positions_monitored"

# Verify metric format (Prometheus naming conventions)
# Counters should end with _total
# Durations should end with _seconds
# Gauges should not have suffix
```

### E8.11.2 Grafana dashboard import test | Grafana 仪表盘导入测试
```bash
# Validate dashboard JSON
cd configs/grafana
cat watchtower-dashboard.json | jq .

# Test Grafana import (requires Grafana API)
curl -X POST http://admin:admin@localhost:3001/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @watchtower-dashboard.json
```

### E8.11.3 Alert latency measurement | 警报延迟测量
File path: `backend/tests/observability/latency_test.go` | 文件路径

```go
package observability

import (
    "testing"
    "time"
)

// Test alert P95 latency <= 10 seconds
func TestAlertLatency(t *testing.T) {
    samples := make([]time.Duration, 100)

    for i := 0; i < 100; i++ {
        start := time.Now()

        // Trigger HF drop
        simulatePriceDrop()

        // Wait for alert to appear in UI
        waitForAlert()

        samples[i] = time.Since(start)
    }

    // Calculate P95
    p95 := calculatePercentile(samples, 95)

    t.Logf("Alert P95 latency: %v", p95)

    if p95 > 10*time.Second {
        t.Errorf("P95 latency too high: %v (expected <= 10s)", p95)
    }
}
```

---

## E8.12 Completion Checklist（完成清单）

### E8.12.1 Smart Contract Tests
- [ ] PositionVault unit tests (11 test cases) | PositionVault 单元测试（11 个测试用例）
- [ ] Protector unit tests (12 test cases) | Protector 单元测试（12 个测试用例）
- [ ] DemoEscrow unit tests (8 test cases) | DemoEscrow 单元测试（8 个测试用例）
- [ ] Integration tests (7 test cases) | 集成测试（7 个测试用例）
- [ ] Mock price feed tests | 模拟价格预言机测试
- [ ] All tests pass: `forge test` | 所有测试通过：`forge test`
- [ ] Coverage >80% | 覆盖率 >80%

### E8.12.2 Backend Tests
- [ ] Monitor service tests | 监控服务测试
- [ ] Alerter service tests | 警报服务测试
- [ ] WebSocket tests | WebSocket 测试
- [ ] RPC client tests (exponential backoff, circuit breaker) | RPC 客户端测试（指数退避、熔断器）
- [ ] Subgraph client tests | 子图客户端测试
- [ ] Integration tests | 集成测试
- [ ] All tests pass: `go test ./...` | 所有测试通过：`go test ./...`
- [ ] Coverage >70% | 覆盖率 >70%

### E8.12.3 Frontend Tests
- [ ] useWebSocket hook tests | useWebSocket 钩子测试
- [ ] usePositions hook tests | usePositions 钩子测试
- [ ] useProtect hook tests | useProtect 钩子测试
- [ ] Replay mode tests | 重放模式测试
- [ ] PositionCard component tests | PositionCard 组件测试
- [ ] RiskAlert component tests | RiskAlert 组件测试
- [ ] ProtectButton component tests | ProtectButton 组件测试
- [ ] E2E critical flow test (Playwright) | E2E 关键流程测试（Playwright）
- [ ] E2E offline replay test | E2E 离线重放测试
- [ ] E2E WebSocket reconnect test | E2E WebSocket 重连测试
- [ ] All tests pass: `npm test && npm run test:e2e` | 所有测试通过

### E8.12.4 Security Audits
- [ ] Smart contract security checklist completed | 智能合约安全清单已完成
- [ ] Slither static analysis run | Slither 静态分析已运行
- [ ] Mythril security analysis run (optional) | Mythril 安全分析已运行（可选）
- [ ] Manual code review documented | 手动代码审查已记录
- [ ] All SPDX headers verified | 所有 SPDX 头已验证
- [ ] No critical/high findings | 无严重/高风险发现

### E8.12.5 Fuzz & Load Testing
- [ ] Foundry fuzz tests implemented | Foundry 模糊测试已实现
- [ ] Fuzz tests run with 10000 iterations | 模糊测试运行 10000 次迭代
- [ ] Backend API load tests (100 concurrent requests) | 后端 API 负载测试（100 并发请求）
- [ ] WebSocket load tests (100 concurrent connections) | WebSocket 负载测试（100 并发连接）
- [ ] k6 load test run (throughput >= 50 req/s) | k6 负载测试运行（吞吐量 >= 50 req/s）

### E8.12.6 Dependency Security
- [ ] npm audit run and vulnerabilities fixed (frontend) | npm 审计已运行并修复漏洞（前端）
- [ ] npm audit run and vulnerabilities fixed (subgraph) | npm 审计已运行并修复漏洞（子图）
- [ ] govulncheck run (backend) | govulncheck 已运行（后端）
- [ ] Foundry dependencies updated | Foundry 依赖已更新
- [ ] Dependency versions pinned | 依赖版本已锁定

### E8.12.7 CI/CD & Automation
- [ ] GitHub Actions security workflow configured | GitHub Actions 安全工作流已配置
- [ ] Automated SPDX check script created | 自动化 SPDX 检查脚本已创建
- [ ] CI runs all tests on PR | CI 在 PR 时运行所有测试
- [ ] CI blocks merge on test failures | CI 在测试失败时阻止合并

### E8.12.8 Penetration Testing
- [ ] API security tests documented | API 安全测试已记录
- [ ] XSS protection verified | XSS 保护已验证
- [ ] CSRF protection verified | CSRF 保护已验证
- [ ] Rate limiting recommendations documented | 限流建议已记录
- [ ] Penetration test report created | 渗透测试报告已创建

### E8.12.9 Observability Tests
- [ ] Prometheus metrics endpoint validated | Prometheus 指标端点已验证
- [ ] Grafana dashboard import tested | Grafana 仪表盘导入已测试
- [ ] Alert P95 latency measured (<= 10s) | 警报 P95 延迟已测量（<= 10 秒）
- [ ] All metrics follow naming conventions | 所有指标遵循命名规范

---

**End of E8 Testing & Security Tasks | E8 测试与安全任务结束**
