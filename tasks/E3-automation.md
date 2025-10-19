# E3 Chainlink Automation Tasks（E3 Chainlink Automation 任务）

**Feature**: DeRisk Watchtower | **分支**: `005-derisk-watchtower-automation`
**Feature**: DeRisk 瞭望塔 | **Branch**: `005-derisk-watchtower-automation`

---

## E3.0 Branch Setup & PR Management（分支设置与 PR 管理）

### E3.0.1 Create 005 Branch & Open Draft PR | 创建 005 分支并开启草稿 PR

#### 🎯 任务目标
从最新主分支创建新的功能分支 `005-derisk-watchtower-automation`，  
推送到远程仓库，并创建 **Draft PR（草稿 PR）** 以触发 CI/CD 测试并追踪开发进度。

---

#### ⚙️ 执行步骤
```bash
# 1️⃣ 切换到主分支并更新
git checkout main
git pull origin main

# 2️⃣ 创建新分支
git checkout -b 005-derisk-watchtower-automation

# 3️⃣ 推送分支到远程
git push -u origin 005-derisk-watchtower-automation

# 4️⃣ 创建 Draft PR（草稿 PR）
gh pr create \
  --base main \
  --head 005-derisk-watchtower-automation \
  --title "E3 Chainlink Automation — Draft PR (in progress)" \
  --body "Initialized Chainlink Automation development branch from latest main. Work in progress; CI/CD enabled for early validation." \
  --draft
```

#### 📋 完成标准（AC）
- ✅ 分支已成功创建并推送到远程
- ✅ Draft PR 已在 GitHub 显示（目标分支为 main）
- ✅ CI/CD 流水线自动触发
- ✅ AI_USAGE.md 更新包含本分支记录（mode: assist, verified: true）
- ✅ CHANGELOG.md 添加分支初始化日志

#### 🧠 提示
- 草稿 PR（Draft）不会被误合并，但可提前触发 CI/CD 测试。
- 当阶段开发完成后，使用以下命令将其转为正式 PR：
```bash
gh pr ready
```
- 在 PR 前再次同步主分支，确保无冲突：
```bash
git pull origin main
```

#### 🪶 输出物
- 新分支：`005-derisk-watchtower-automation`
- GitHub PR（Draft）链接
- CI 流程日志（构建与测试结果）
- 更新后的 AI_USAGE.md 与 CHANGELOG.md

---

## E3.1 Automation-Compatible Protector（自动化兼容 Protector）

### E3.1.1 Add AutomationCompatibleInterface | 添加 AutomationCompatibleInterface
File path: `contracts/src/interfaces/IAutomationCompatible.sol` | 文件路径

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AutomationCompatibleInterface {
    function checkUpkeep(bytes calldata checkData)
        external
        returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external;
}
```

### E3.1.2 Update Protector to implement interface | 更新 Protector 实现接口
File path: `contracts/src/Protector.sol` | 文件路径

```solidity
import "./interfaces/IAutomationCompatible.sol";

contract Protector is ReentrancyGuard, AutomationCompatibleInterface {
    // Existing code...
}
```

### E3.1.3 Add checkUpkeep function | 添加 checkUpkeep 函数
```solidity
function checkUpkeep(bytes calldata checkData)
    external
    view
    override
    returns (bool upkeepNeeded, bytes memory performData)
{
    bytes32[] memory positionIds = abi.decode(checkData, (bytes32[]));

    for (uint256 i = 0; i < positionIds.length; i++) {
        Position memory pos = positionVault.getPosition(positionIds[i]);
        uint256 hf = calculateHealthFactor(pos);

        if (hf <= CRITICAL_THRESHOLD) {
            upkeepNeeded = true;
            performData = abi.encode(positionIds[i]);
            break;
        }
    }
}
```

### E3.1.4 Define CRITICAL_THRESHOLD constant | 定义 CRITICAL_THRESHOLD 常量
```solidity
uint256 public constant CRITICAL_THRESHOLD = 13000; // 1.3 with 4 decimals
```

### E3.1.5 Implement performUpkeep function | 实现 performUpkeep 函数
```solidity
function performUpkeep(bytes calldata performData) external override nonReentrant {
    bytes32 positionId = abi.decode(performData, (bytes32));

    // Revalidate condition
    Position memory pos = positionVault.getPosition(positionId);
    uint256 currentHF = calculateHealthFactor(pos);
    require(currentHF <= CRITICAL_THRESHOLD, "HF above threshold");

    // Calculate collateral needed to restore to safe level (HF = 1.5)
    uint256 collateralToAdd = calculateCollateralNeeded(pos);

    // Execute protection
    protect(positionId, collateralToAdd);

    emit AutomationTriggered(positionId, currentHF, msg.sender);
}
```

### E3.1.6 Add calculateCollateralNeeded helper | 添加 calculateCollateralNeeded 辅助函数
```solidity
function calculateCollateralNeeded(Position memory pos)
    internal
    view
    returns (uint256)
{
    uint256 targetHF = 15000; // 1.5 with 4 decimals
    uint256 currentCollateralValue = pos.collateralAmount * getCollateralPrice(pos);
    uint256 debtValue = pos.debtAmount * getDebtPrice(pos);

    // targetHF = (currentCollateral + needed) * 0.8 / debt
    // needed = (targetHF * debt / 0.8) - currentCollateral
    uint256 neededValue = (targetHF * debtValue * 10000) / 8000 - currentCollateralValue;
    uint256 neededAmount = neededValue / getCollateralPrice(pos);

    return neededAmount;
}
```

### E3.1.7 Define AutomationTriggered event | 定义 AutomationTriggered 事件
```solidity
event AutomationTriggered(
    bytes32 indexed positionId,
    uint256 healthFactor,
    address indexed keeper
);
```

### E3.1.8 Add getCollateralPrice and getDebtPrice | 添加 getCollateralPrice 与 getDebtPrice
```solidity
function getCollateralPrice(Position memory pos) internal view returns (uint256) {
    IChainlinkPriceFeed feed = IChainlinkPriceFeed(collateralPriceFeed);
    (, int256 price,,,) = feed.latestRoundData();
    return uint256(price);
}

function getDebtPrice(Position memory pos) internal view returns (uint256) {
    IChainlinkPriceFeed feed = IChainlinkPriceFeed(debtPriceFeed);
    (, int256 price,,,) = feed.latestRoundData();
    return uint256(price);
}
```

### E3.1.9 Add price feed addresses to constructor | 添加价格预言机地址到构造函数
```solidity
address public immutable collateralPriceFeed;
address public immutable debtPriceFeed;

constructor(
    address _vault,
    address _escrow,
    address _collateralPriceFeed,
    address _debtPriceFeed
) {
    positionVault = IPositionVault(_vault);
    escrow = _escrow;
    collateralPriceFeed = _collateralPriceFeed;
    debtPriceFeed = _debtPriceFeed;
}
```

---

## E3.2 Automation Upkeep Tests（自动化 Upkeep 测试）

### E3.2.1 Create ProtectorAutomation.t.sol | 创建 ProtectorAutomation.t.sol
File path: `contracts/test/ProtectorAutomation.t.sol` | 文件路径

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Protector.sol";
import "../src/PositionVault.sol";
import "../src/DemoEscrow.sol";
import "../src/mocks/MockPriceFeed.sol";
```

### E3.2.2 Setup test with price feeds | 设置带价格预言机的测试
```solidity
contract ProtectorAutomationTest is Test {
    Protector protector;
    PositionVault vault;
    DemoEscrow escrow;
    MockPriceFeed collateralFeed;
    MockPriceFeed debtFeed;

    function setUp() public {
        vault = new PositionVault();
        escrow = new DemoEscrow();
        collateralFeed = new MockPriceFeed();
        debtFeed = new MockPriceFeed();

        collateralFeed.setPrice(2000e8); // $2000
        debtFeed.setPrice(1000e8);       // $1000

        protector = new Protector(
            address(vault),
            address(escrow),
            address(collateralFeed),
            address(debtFeed)
        );
    }
}
```

### E3.2.3 Test checkUpkeep returns false for healthy position | 测试健康头寸 checkUpkeep 返回 false
```solidity
function testCheckUpkeepHealthyPosition() public {
    bytes32 posId = createTestPosition(1000e18, 400e18); // HF > 1.3

    bytes32[] memory positions = new bytes32[](1);
    positions[0] = posId;
    bytes memory checkData = abi.encode(positions);

    (bool upkeepNeeded,) = protector.checkUpkeep(checkData);
    assertFalse(upkeepNeeded);
}
```

### E3.2.4 Test checkUpkeep returns true for critical position | 测试严重头寸 checkUpkeep 返回 true
```solidity
function testCheckUpkeepCriticalPosition() public {
    bytes32 posId = createTestPosition(1000e18, 800e18); // HF < 1.3

    bytes32[] memory positions = new bytes32[](1);
    positions[0] = posId;
    bytes memory checkData = abi.encode(positions);

    (bool upkeepNeeded, bytes memory performData) = protector.checkUpkeep(checkData);
    assertTrue(upkeepNeeded);
    assertEq(abi.decode(performData, (bytes32)), posId);
}
```

### E3.2.5 Test performUpkeep executes protection | 测试 performUpkeep 执行保护
```solidity
function testPerformUpkeepExecutesProtection() public {
    bytes32 posId = createTestPosition(1000e18, 800e18);
    bytes memory performData = abi.encode(posId);

    uint256 beforeHF = getPositionHF(posId);
    assertLt(beforeHF, 13000);

    protector.performUpkeep(performData);

    uint256 afterHF = getPositionHF(posId);
    assertGt(afterHF, beforeHF);
    assertGt(afterHF, 15000); // Restored to safe level
}
```

### E3.2.6 Test performUpkeep emits AutomationTriggered | 测试 performUpkeep 发出 AutomationTriggered
```solidity
function testPerformUpkeepEmitsEvent() public {
    bytes32 posId = createTestPosition(1000e18, 800e18);
    bytes memory performData = abi.encode(posId);

    vm.expectEmit(true, true, false, true);
    emit AutomationTriggered(posId, anyHF, address(this));

    protector.performUpkeep(performData);
}
```

### E3.2.7 Test performUpkeep reverts if HF above threshold | 测试 HF 高于阈值时 performUpkeep 回滚
```solidity
function testPerformUpkeepRevertsIfHealthy() public {
    bytes32 posId = createTestPosition(1000e18, 400e18); // Healthy
    bytes memory performData = abi.encode(posId);

    vm.expectRevert("HF above threshold");
    protector.performUpkeep(performData);
}
```

### E3.2.8 Test calculateCollateralNeeded accuracy | 测试 calculateCollateralNeeded 准确性
```solidity
function testCalculateCollateralNeeded() public {
    // Create position with HF = 1.25
    bytes32 posId = createTestPosition(1000e18, 640e18);
    Position memory pos = vault.getPosition(posId);

    uint256 needed = protector.calculateCollateralNeeded(pos);

    // Verify adding this amount brings HF to 1.5
    uint256 newHF = calculateHFAfterAdd(pos, needed);
    assertEq(newHF, 15000); // 1.5 with 4 decimals
}
```

---

## E3.3 Upkeep Registration Script（Upkeep 注册脚本）

### E3.3.1 Create RegisterUpkeep.s.sol | 创建 RegisterUpkeep.s.sol
File path: `contracts/script/RegisterUpkeep.s.sol` | 文件路径

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Protector.sol";
```

### E3.3.2 Define Chainlink Automation Registrar interface | 定义 Chainlink Automation Registrar 接口
```solidity
interface AutomationRegistrarInterface {
    function registerUpkeep(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source,
        address sender
    ) external;
}
```

### E3.3.3 Add run function for registration | 添加注册 run 函数
```solidity
function run() external {
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
    address protectorAddress = vm.envAddress("PROTECTOR_ADDRESS");
    address linkToken = vm.envAddress("LINK_TOKEN_BASE_SEPOLIA");
    address registrar = vm.envAddress("AUTOMATION_REGISTRAR_BASE_SEPOLIA");

    vm.startBroadcast(deployerPrivateKey);

    // Prepare checkData with monitored position IDs
    bytes32[] memory positions = loadMonitoredPositions();
    bytes memory checkData = abi.encode(positions);

    // Register upkeep
    AutomationRegistrarInterface(registrar).registerUpkeep(
        "DeRisk Watchtower Protection",
        "",
        protectorAddress,
        500000, // gas limit
        msg.sender,
        checkData,
        5 ether, // 5 LINK funding
        0, // source
        msg.sender
    );

    console.log("Upkeep registered for Protector:", protectorAddress);

    vm.stopBroadcast();
}
```

### E3.3.4 Add loadMonitoredPositions helper | 添加 loadMonitoredPositions 辅助函数
```solidity
function loadMonitoredPositions() internal view returns (bytes32[] memory) {
    string memory json = vm.readFile("contracts/deployments/monitored-positions.json");
    // Parse JSON and return position IDs
    // Implementation depends on JSON structure
}
```

---

## E3.4 CRON-Based Upkeep（基于 CRON 的 Upkeep）

### E3.4.1 Document CRON schedule format | 记录 CRON 调度格式
File path: `docs/AUTOMATION.md` | 文件路径

**CRON Schedule**: `0 */5 * * * *` (every 5 minutes)
**CRON 调度**：`0 */5 * * * *`（每 5 分钟）

### E3.4.2 Add CRON registration alternative | 添加 CRON 注册替代方案
```solidity
// Alternative: Use Chainlink Automation UI
// 1. Navigate to https://automation.chain.link
// 2. Connect wallet
// 3. Select "Time-based" upkeep
// 4. Set CRON expression: "0 */5 * * * *"
// 5. Set target contract: Protector address
// 6. Fund with LINK
```

### E3.4.3 Create manual upkeep trigger script | 创建手动 upkeep 触发脚本
File path: `contracts/script/TriggerUpkeep.s.sol` | 文件路径

```solidity
function run() external {
    address protector = vm.envAddress("PROTECTOR_ADDRESS");

    // Load positions to check
    bytes32[] memory positions = loadMonitoredPositions();
    bytes memory checkData = abi.encode(positions);

    vm.startBroadcast();

    (bool upkeepNeeded, bytes memory performData) =
        Protector(protector).checkUpkeep(checkData);

    if (upkeepNeeded) {
        Protector(protector).performUpkeep(performData);
        console.log("Upkeep performed successfully");
    } else {
        console.log("No upkeep needed");
    }

    vm.stopBroadcast();
}
```

---

## E3.5 Monitoring & Logging（监控与日志）

### E3.5.1 Add automation metrics to Protector | 添加自动化指标到 Protector
```solidity
uint256 public totalAutomationTriggers;
uint256 public lastAutomationTimestamp;
mapping(bytes32 => uint256) public positionAutomationCount;
```

### E3.5.2 Update performUpkeep to track metrics | 更新 performUpkeep 跟踪指标
```solidity
function performUpkeep(bytes calldata performData) external override nonReentrant {
    bytes32 positionId = abi.decode(performData, (bytes32));

    // ... existing logic ...

    totalAutomationTriggers++;
    lastAutomationTimestamp = block.timestamp;
    positionAutomationCount[positionId]++;

    emit AutomationTriggered(positionId, currentHF, msg.sender);
}
```

### E3.5.3 Add getAutomationStats view function | 添加 getAutomationStats 查看函数
```solidity
function getAutomationStats()
    external
    view
    returns (
        uint256 totalTriggers,
        uint256 lastTrigger,
        uint256 timeSinceLastTrigger
    )
{
    return (
        totalAutomationTriggers,
        lastAutomationTimestamp,
        block.timestamp - lastAutomationTimestamp
    );
}
```

### E3.5.4 Add position-specific automation history | 添加头寸特定自动化历史
```solidity
function getPositionAutomationHistory(bytes32 positionId)
    external
    view
    returns (uint256 triggerCount)
{
    return positionAutomationCount[positionId];
}
```

---

## E3.6 Backend Integration（后端集成）

### E3.6.1 Add automation service to backend | 添加自动化服务到后端
File path: `backend/internal/services/automation.go` | 文件路径

```go
package services

import (
    "context"
    "math/big"
    "time"
)

type AutomationService struct {
    protectorAddr common.Address
    client        *ethclient.Client
}

func (s *AutomationService) CheckUpkeepStatus(ctx context.Context) (bool, error) {
    // Query Protector.getAutomationStats()
    // Return current automation health
}
```

### E3.6.2 Add automation delay metric | 添加自动化延迟指标
```go
var automationDelaySeconds = prometheus.NewGauge(prometheus.GaugeOpts{
    Name: "automation_delay_seconds",
    Help: "Seconds since last automation trigger",
})

func (s *AutomationService) RecordDelay() {
    stats, err := s.CheckUpkeepStatus(context.Background())
    if err == nil {
        automationDelaySeconds.Set(float64(stats.TimeSinceLastTrigger))
    }
}
```

### E3.6.3 Add automation failure detection | 添加自动化失败检测
```go
func (s *AutomationService) DetectAutomationFailure() bool {
    stats, err := s.CheckUpkeepStatus(context.Background())
    if err != nil {
        return true
    }

    // If no trigger in >10 minutes, flag as potential failure
    return stats.TimeSinceLastTrigger > 600
}
```

### E3.6.4 Expose automation status endpoint | 暴露自动化状态端点
File path: `backend/internal/api/handlers/automation.go` | 文件路径

```go
func (h *AutomationHandler) GetAutomationStatus(w http.ResponseWriter, r *http.Request) {
    stats, err := h.automationService.CheckUpkeepStatus(r.Context())
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(map[string]interface{}{
        "total_triggers": stats.TotalTriggers,
        "last_trigger_at": stats.LastTrigger,
        "delay_seconds": stats.TimeSinceLastTrigger,
        "is_healthy": stats.TimeSinceLastTrigger < 600,
    })
}
```

---

## E3.7 Fallback Manual Protection（回退手动保护）

### E3.7.1 Add manual protection endpoint | 添加手动保护端点
File path: `backend/internal/api/handlers/protection.go` | 文件路径

```go
func (h *ProtectionHandler) ManualProtect(w http.ResponseWriter, r *http.Request) {
    var req struct {
        PositionID string `json:"position_id"`
    }

    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    // Call Protector.protect() directly
    tx, err := h.protectionService.ExecuteManualProtection(r.Context(), req.PositionID)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(map[string]string{
        "tx_hash": tx.Hash().Hex(),
        "status": "pending",
    })
}
```

### E3.7.2 Add frontend manual protection button | 添加前端手动保护按钮
File path: `frontend/components/positions/ProtectButton.tsx` | 文件路径

```typescript
export function ProtectButton({ positionId }: { positionId: string }) {
  const { writeAsync: protect } = useProtect(positionId);
  const [isProtecting, setIsProtecting] = useState(false);

  const handleProtect = async () => {
    setIsProtecting(true);
    try {
      await protect();
      toast.success("Protection executed successfully");
    } catch (error) {
      toast.error("Protection failed: " + error.message);
    } finally {
      setIsProtecting(false);
    }
  };

  return (
    <button onClick={handleProtect} disabled={isProtecting}>
      {isProtecting ? "Protecting..." : "Protect Position"}
    </button>
  );
}
```

---

## E3.8 Subgraph Automation Events（子图自动化事件）

### E3.8.1 Update schema.graphql for automation | 为自动化更新 schema.graphql
File path: `subgraph/schema.graphql` | 文件路径

```graphql
type AutomationEvent @entity {
  id: ID!
  position: Position!
  healthFactor: BigInt!
  keeper: Bytes!
  timestamp: BigInt!
  blockNumber: BigInt!
  txHash: Bytes!
}
```

### E3.8.2 Add AutomationTriggered event handler | 添加 AutomationTriggered 事件处理器
File path: `subgraph/subgraph.yaml` | 文件路径

```yaml
- event: AutomationTriggered(indexed bytes32,uint256,indexed address)
  handler: handleAutomationTriggered
```

### E3.8.3 Implement handleAutomationTriggered | 实现 handleAutomationTriggered
File path: `subgraph/src/mapping.ts` | 文件路径

```typescript
export function handleAutomationTriggered(event: AutomationTriggered): void {
  let id = event.transaction.hash.toHex() + "-" + event.logIndex.toString();
  let automationEvent = new AutomationEvent(id);

  automationEvent.position = event.params.positionId.toHex();
  automationEvent.healthFactor = event.params.healthFactor;
  automationEvent.keeper = event.params.keeper;
  automationEvent.timestamp = event.block.timestamp;
  automationEvent.blockNumber = event.block.number;
  automationEvent.txHash = event.transaction.hash;

  automationEvent.save();
}
```

### E3.8.4 Add automation query to test-queries.graphql | 添加自动化查询到 test-queries.graphql
File path: `subgraph/test-queries.graphql` | 文件路径

```graphql
query AutomationHistory {
  automationEvents(first: 20, orderBy: timestamp, orderDirection: desc) {
    id
    position {
      id
      owner
    }
    healthFactor
    keeper
    timestamp
  }
}
```

---

## E3.9 Documentation（文档）

### E3.9.1 Create AUTOMATION.md | 创建 AUTOMATION.md
File path: `docs/AUTOMATION.md` | 文件路径

**Content** / **内容**:
- Chainlink Automation overview
- Upkeep registration steps
- CRON schedule: every 5 minutes
- Manual fallback via frontend button
- Monitoring automation health
- Troubleshooting delayed triggers

### E3.9.2 Add Upkeep ID to PROOF.md | 添加 Upkeep ID 到 PROOF.md
File path: `docs/PROOF.md` | 文件路径

```markdown
## Chainlink Automation Integration

- **Upkeep ID**: `123456789` (Base Sepolia)
- **Dashboard**: https://automation.chain.link/base-sepolia/[UPKEEP_ID]
- **CRON Schedule**: `0 */5 * * * *` (every 5 minutes)
- **Trigger Count**: [VIEW ON DASHBOARD]
- **Funded with**: 5 LINK
```

### E3.9.3 Update README with automation section | 更新 README 添加自动化章节
File path: `README.md` | 文件路径

```markdown
## Chainlink Automation

DeRisk Watchtower uses Chainlink Automation to automatically protect positions at risk.

- **Automatic Protection**: Triggered every 5 minutes via CRON
- **Manual Fallback**: Users can manually trigger protection via UI
- **Monitoring**: View automation health at `/api/automation/status`
```

---

## E3.10 Grafana Metrics（Grafana 指标）

### E3.10.1 Add automation panel to dashboard JSON | 添加自动化面板到仪表盘 JSON
File path: `configs/grafana/watchtower-dashboard.json` | 文件路径

```json
{
  "panels": [
    {
      "title": "Automation Triggers",
      "targets": [
        {
          "expr": "rate(automation_triggers_total[5m])"
        }
      ]
    },
    {
      "title": "Automation Delay",
      "targets": [
        {
          "expr": "automation_delay_seconds"
        }
      ]
    }
  ]
}
```

### E3.10.2 Add alert for automation failure | 添加自动化失败告警
```json
{
  "alert": {
    "name": "Automation Delayed",
    "conditions": [
      {
        "evaluator": {
          "params": [600],
          "type": "gt"
        },
        "query": {
          "model": "automation_delay_seconds"
        }
      }
    ]
  }
}
```

---

## E3.11 Integration Tests（集成测试）

### E3.11.1 Test full automation flow | 测试完整自动化流程
File path: `contracts/test/IntegrationAutomation.t.sol` | 文件路径

```solidity
function testFullAutomationFlow() public {
    // 1. Create position
    bytes32 posId = vault.createPosition(
        address(collateral),
        1000e18,
        address(debt),
        400e18
    );

    // 2. Simulate price drop (HF drops to 1.2)
    collateralFeed.setPrice(1500e8);

    // 3. Check upkeep returns true
    bytes32[] memory positions = new bytes32[](1);
    positions[0] = posId;
    (bool upkeepNeeded,) = protector.checkUpkeep(abi.encode(positions));
    assertTrue(upkeepNeeded);

    // 4. Perform upkeep
    bytes memory performData = abi.encode(posId);
    protector.performUpkeep(performData);

    // 5. Verify HF restored
    uint256 finalHF = vault.getPosition(posId).healthFactor;
    assertGt(finalHF, 15000); // > 1.5

    // 6. Verify automation event emitted
    // 7. Verify metrics updated
}
```

---

## E3.12 Completion Checklist（完成清单）

- [ ] Protector implements AutomationCompatibleInterface | Protector 实现 AutomationCompatibleInterface
- [ ] checkUpkeep function implemented | checkUpkeep 函数已实现
- [ ] performUpkeep function implemented | performUpkeep 函数已实现
- [ ] calculateCollateralNeeded helper added | calculateCollateralNeeded 辅助函数已添加
- [ ] Price feed integration for HF calculation | HF 计算的价格预言机集成
- [ ] AutomationTriggered event defined | AutomationTriggered 事件已定义
- [ ] ProtectorAutomation.t.sol tests pass | ProtectorAutomation.t.sol 测试通过
- [ ] RegisterUpkeep.s.sol script created | RegisterUpkeep.s.sol 脚本已创建
- [ ] Upkeep registered on Base Sepolia | Upkeep 已在 Base Sepolia 注册
- [ ] CRON schedule configured (every 5 minutes) | CRON 调度已配置（每 5 分钟）
- [ ] Automation metrics tracking added | 自动化指标跟踪已添加
- [ ] Backend automation service implemented | 后端自动化服务已实现
- [ ] Automation status endpoint exposed | 自动化状态端点已暴露
- [ ] Manual protection fallback added | 手动保护回退已添加
- [ ] Frontend manual protect button added | 前端手动保护按钮已添加
- [ ] AutomationEvent entity added to subgraph | AutomationEvent 实体已添加到子图
- [ ] handleAutomationTriggered implemented | handleAutomationTriggered 已实现
- [ ] AUTOMATION.md documentation created | AUTOMATION.md 文档已创建
- [ ] Upkeep ID added to PROOF.md | Upkeep ID 已添加到 PROOF.md
- [ ] Grafana automation panels added | Grafana 自动化面板已添加
- [ ] Integration tests for full flow pass | 完整流程集成测试通过

---

**End of E3 Chainlink Automation Tasks | E3 Chainlink Automation 任务结束**
