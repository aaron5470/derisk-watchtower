# E2 Subgraph Tasks（E2 子图任务）

**Feature**: DeRisk Watchtower | **分支**: `003-derisk-watchtower-real`
**Feature**: DeRisk 瞭望塔 | **Branch**: `003-derisk-watchtower-real`

---

## E2.1 Graph CLI Setup（Graph CLI 设置）

### E2.1.1 Install Graph CLI globally | 全局安装 Graph CLI
```bash
npm install -g @graphprotocol/graph-cli
```

### E2.1.2 Verify Graph CLI version | 验证 Graph CLI 版本
```bash
graph --version
```

### E2.1.3 Create subgraph directory | 创建子图目录
```bash
mkdir -p subgraph && cd subgraph
```

### E2.1.4 Initialize subgraph project | 初始化子图项目
```bash
graph init --product hosted-service derisk-watchtower/watchtower
```

### E2.1.5 Configure package.json for subgraph | 为子图配置 package.json
Add build and deploy scripts | 添加构建与部署脚本

---

## E2.2 Schema Definition（模式定义）

### E2.2.1 Create schema.graphql | 创建 schema.graphql
File path: `subgraph/schema.graphql` | 文件路径：`subgraph/schema.graphql`

### E2.2.2 Define Position entity | 定义 Position 实体
```graphql
type Position @entity {
  id: ID!
  owner: Bytes!
  collateralAmount: BigInt!
  collateralToken: Bytes!
  debtAmount: BigInt!
  debtToken: Bytes!
  healthFactor: BigInt!
  lastUpdateTimestamp: BigInt!
  riskEvents: [RiskEvent!]! @derivedFrom(field: "position")
  protectionActions: [ProtectionAction!]! @derivedFrom(field: "position")
  createdAt: BigInt!
  createdAtBlock: BigInt!
}
```

### E2.2.3 Define RiskEvent entity | 定义 RiskEvent 实体
```graphql
type RiskEvent @entity {
  id: ID!
  position: Position!
  eventType: RiskEventType!
  previousHF: BigInt!
  newHF: BigInt!
  deltaHF: BigInt!
  txHash: Bytes!
  timestamp: BigInt!
  blockNumber: BigInt!
}
```

### E2.2.4 Define RiskEventType enum | 定义 RiskEventType 枚举
```graphql
enum RiskEventType {
  ThresholdBreach
  ProtectionTriggered
  ManualAction
}
```

### E2.2.5 Define ProtectionAction entity | 定义 ProtectionAction 实体
```graphql
type ProtectionAction @entity {
  id: ID!
  position: Position!
  actionType: ProtectionActionType!
  beforeHF: BigInt!
  afterHF: BigInt!
  collateralDelta: BigInt!
  debtDelta: BigInt!
  txHash: Bytes!
  timestamp: BigInt!
  blockNumber: BigInt!
  executor: Bytes!
}
```

### E2.2.6 Define ProtectionActionType enum | 定义 ProtectionActionType 枚举
```graphql
enum ProtectionActionType {
  AddCollateral
  RepayDebt
}
```

### E2.2.7 Add GlobalStats entity for aggregates | 为聚合添加 GlobalStats 实体
```graphql
type GlobalStats @entity {
  id: ID!
  totalPositions: BigInt!
  totalProtections: BigInt!
  totalRiskEvents: BigInt!
  lastUpdateTimestamp: BigInt!
}
```

---

## E2.3 Subgraph Manifest（子图清单）

### E2.3.1 Create subgraph.yaml | 创建 subgraph.yaml
File path: `subgraph/subgraph.yaml` | 文件路径：`subgraph/subgraph.yaml`

### E2.3.2 Define dataSources for PositionVault | 为 PositionVault 定义 dataSources
```yaml
specVersion: 0.0.5
schema:
  file: ./schema.graphql
dataSources:
  - kind: ethereum/contract
    name: PositionVault
    network: base-sepolia
    source:
      address: "CONTRACT_ADDRESS_PLACEHOLDER"
      abi: PositionVault
      startBlock: START_BLOCK_PLACEHOLDER
```

### E2.3.3 Add PositionVault ABI | 添加 PositionVault ABI
```yaml
    mapping:
      kind: ethereum/events
      apiVersion: 0.0.7
      language: wasm/assemblyscript
      entities:
        - Position
        - RiskEvent
      abis:
        - name: PositionVault
          file: ./abis/PositionVault.json
```

### E2.3.4 Define PositionCreated event handler | 定义 PositionCreated 事件处理器
```yaml
      eventHandlers:
        - event: PositionCreated(indexed bytes32,indexed address,uint256,uint256)
          handler: handlePositionCreated
        - event: PositionUpdated(indexed bytes32,uint256,uint256,uint256)
          handler: handlePositionUpdated
```

### E2.3.5 Add Protector dataSource | 添加 Protector dataSource
```yaml
  - kind: ethereum/contract
    name: Protector
    network: base-sepolia
    source:
      address: "PROTECTOR_ADDRESS_PLACEHOLDER"
      abi: Protector
      startBlock: START_BLOCK_PLACEHOLDER
```

### E2.3.6 Define ProtectionExecuted event handler | 定义 ProtectionExecuted 事件处理器
```yaml
      eventHandlers:
        - event: ProtectionExecuted(indexed bytes32,uint256,uint256,uint256,indexed address)
          handler: handleProtectionExecuted
```

### E2.3.7 Add file reference for mappings | 为映射添加文件引用
```yaml
      file: ./src/mapping.ts
```

---

## E2.4 ABI Files（ABI 文件）

### E2.4.1 Create abis directory | 创建 abis 目录
```bash
mkdir -p subgraph/abis
```

### E2.4.2 Export PositionVault ABI from Foundry | 从 Foundry 导出 PositionVault ABI
```bash
cd contracts && forge inspect PositionVault abi > ../subgraph/abis/PositionVault.json
```

### E2.4.3 Export Protector ABI from Foundry | 从 Foundry 导出 Protector ABI
```bash
forge inspect Protector abi > ../subgraph/abis/Protector.json
```

### E2.4.4 Verify ABI JSON format valid | 验证 ABI JSON 格式有效
```bash
cd ../subgraph && cat abis/PositionVault.json | jq .
```

---

## E2.5 Mapping Implementation（映射实现）

### E2.5.1 Create src/mapping.ts | 创建 src/mapping.ts
File path: `subgraph/src/mapping.ts` | 文件路径：`subgraph/src/mapping.ts`

### E2.5.2 Import generated types | 导入生成类型
```typescript
import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import {
  PositionCreated,
  PositionUpdated
} from "../generated/PositionVault/PositionVault";
import { ProtectionExecuted } from "../generated/Protector/Protector";
import { Position, RiskEvent, ProtectionAction, GlobalStats } from "../generated/schema";
```

### E2.5.3 Implement handlePositionCreated | 实现 handlePositionCreated
```typescript
export function handlePositionCreated(event: PositionCreated): void {
  let position = new Position(event.params.id.toHex());
  position.owner = event.params.owner;
  position.collateralAmount = event.params.collateralAmount;
  position.debtAmount = event.params.debtAmount;
  position.healthFactor = BigInt.fromI32(0); // Will be updated
  position.lastUpdateTimestamp = event.block.timestamp;
  position.createdAt = event.block.timestamp;
  position.createdAtBlock = event.block.number;
  position.save();

  updateGlobalStats();
}
```

### E2.5.4 Implement handlePositionUpdated | 实现 handlePositionUpdated
```typescript
export function handlePositionUpdated(event: PositionUpdated): void {
  let position = Position.load(event.params.id.toHex());
  if (position == null) return;

  let previousHF = position.healthFactor;
  position.healthFactor = event.params.newHealthFactor;
  position.lastUpdateTimestamp = event.block.timestamp;
  position.save();

  // Create RiskEvent if threshold breach
  if (shouldCreateRiskEvent(previousHF, event.params.newHealthFactor)) {
    createRiskEvent(event, position, previousHF);
  }
}
```

### E2.5.5 Implement handleProtectionExecuted | 实现 handleProtectionExecuted
```typescript
export function handleProtectionExecuted(event: ProtectionExecuted): void {
  let id = event.transaction.hash.toHex() + "-" + event.logIndex.toString();
  let action = new ProtectionAction(id);
  action.position = event.params.positionId.toHex();
  action.actionType = "AddCollateral";
  action.beforeHF = event.params.beforeHF;
  action.afterHF = event.params.afterHF;
  action.collateralDelta = event.params.collateralAdded;
  action.debtDelta = BigInt.fromI32(0);
  action.txHash = event.transaction.hash;
  action.timestamp = event.block.timestamp;
  action.blockNumber = event.block.number;
  action.executor = event.params.executor;
  action.save();

  updateGlobalStats();
}
```

### E2.5.6 Add createRiskEvent helper function | 添加 createRiskEvent 辅助函数
```typescript
function createRiskEvent(
  event: PositionUpdated,
  position: Position,
  previousHF: BigInt
): void {
  let id = event.transaction.hash.toHex() + "-" + event.logIndex.toString();
  let riskEvent = new RiskEvent(id);
  riskEvent.position = position.id;
  riskEvent.eventType = "ThresholdBreach";
  riskEvent.previousHF = previousHF;
  riskEvent.newHF = event.params.newHealthFactor;
  riskEvent.deltaHF = event.params.newHealthFactor.minus(previousHF);
  riskEvent.txHash = event.transaction.hash;
  riskEvent.timestamp = event.block.timestamp;
  riskEvent.blockNumber = event.block.number;
  riskEvent.save();
}
```

### E2.5.7 Add shouldCreateRiskEvent threshold logic | 添加 shouldCreateRiskEvent 阈值逻辑
```typescript
function shouldCreateRiskEvent(previousHF: BigInt, newHF: BigInt): boolean {
  const THRESHOLD = BigInt.fromI32(13000); // 1.3 with 4 decimals
  return newHF.le(THRESHOLD) && previousHF.gt(THRESHOLD);
}
```

### E2.5.8 Implement updateGlobalStats function | 实现 updateGlobalStats 函数
```typescript
function updateGlobalStats(): void {
  let stats = GlobalStats.load("global");
  if (stats == null) {
    stats = new GlobalStats("global");
    stats.totalPositions = BigInt.fromI32(0);
    stats.totalProtections = BigInt.fromI32(0);
    stats.totalRiskEvents = BigInt.fromI32(0);
  }
  stats.totalPositions = stats.totalPositions.plus(BigInt.fromI32(1));
  stats.lastUpdateTimestamp = BigInt.fromI32(Date.now());
  stats.save();
}
```

---

## E2.6 Code Generation（代码生成）

### E2.6.1 Run graph codegen | 运行 graph codegen
```bash
cd subgraph && graph codegen
```

### E2.6.2 Verify generated directory | 验证 generated 目录
Check `subgraph/generated/` contains types | 检查 `subgraph/generated/` 包含类型

### E2.6.3 Inspect generated Position type | 检查生成的 Position 类型
```bash
cat generated/schema.ts | grep "class Position"
```

### E2.6.4 Verify event types generated | 验证事件类型已生成
Check PositionCreated, ProtectionExecuted classes | 检查 PositionCreated、ProtectionExecuted 类

---

## E2.7 Build Subgraph（构建子图）

### E2.7.1 Build subgraph WASM | 构建子图 WASM
```bash
cd subgraph && graph build
```

### E2.7.2 Verify build/subgraph.yaml created | 验证 build/subgraph.yaml 已创建
```bash
ls -lh build/
```

### E2.7.3 Check for AssemblyScript compilation errors | 检查 AssemblyScript 编译错误
Ensure no type errors in mapping.ts | 确保 mapping.ts 无类型错误

### E2.7.4 Test build with --debug flag | 使用 --debug 标志测试构建
```bash
graph build --debug
```

---

## E2.8 Local Graph Node Testing（本地 Graph 节点测试）

### E2.8.1 Pull Graph Node Docker image | 拉取 Graph Node Docker 镜像
```bash
docker pull graphprotocol/graph-node:latest
```

### E2.8.2 Create docker-compose-graph.yml | 创建 docker-compose-graph.yml
File path: `subgraph/docker-compose-graph.yml` | 文件路径

### E2.8.3 Add Graph Node service | 添加 Graph Node 服务
```yaml
version: '3'
services:
  graph-node:
    image: graphprotocol/graph-node:latest
    ports:
      - '8000:8000'
      - '8001:8001'
      - '8020:8020'
      - '8030:8030'
      - '8040:8040'
    environment:
      postgres_host: postgres
      postgres_user: graph-node
      postgres_pass: let-me-in
      postgres_db: graph-node
      ipfs: 'ipfs:5001'
      ethereum: 'base-sepolia:${BASE_SEPOLIA_RPC}'
```

### E2.8.4 Add PostgreSQL service | 添加 PostgreSQL 服务
```yaml
  postgres:
    image: postgres:14
    ports:
      - '5432:5432'
    environment:
      POSTGRES_USER: graph-node
      POSTGRES_PASSWORD: let-me-in
      POSTGRES_DB: graph-node
    volumes:
      - postgres-data:/var/lib/postgresql/data
```

### E2.8.5 Add IPFS service | 添加 IPFS 服务
```yaml
  ipfs:
    image: ipfs/go-ipfs:latest
    ports:
      - '5001:5001'
    volumes:
      - ipfs-data:/data/ipfs
```

### E2.8.6 Start local Graph Node stack | 启动本地 Graph Node 栈
```bash
docker-compose -f docker-compose-graph.yml up -d
```

### E2.8.7 Verify Graph Node health | 验证 Graph Node 健康
```bash
curl http://localhost:8030/
```

---

## E2.9 Deployment Configuration（部署配置）

### E2.9.1 Create subgraph.config.json | 创建 subgraph.config.json
File path: `subgraph/subgraph.config.json` | 文件路径

### E2.9.2 Add network configurations | 添加网络配置
```json
{
  "networks": {
    "base-sepolia": {
      "PositionVault": {
        "address": "0xYOUR_VAULT_ADDRESS",
        "startBlock": 12345678
      },
      "Protector": {
        "address": "0xYOUR_PROTECTOR_ADDRESS",
        "startBlock": 12345678
      }
    }
  }
}
```

### E2.9.3 Create deploy script | 创建部署脚本
File path: `subgraph/scripts/deploy.sh` | 文件路径

### E2.9.4 Add config replacement in deploy script | 在部署脚本添加配置替换
```bash
#!/usr/bin/env bash
set -euo pipefail

# Load deployed addresses
VAULT_ADDR=$(jq -r '.PositionVault' ../contracts/deployments/base-sepolia.json)
PROTECTOR_ADDR=$(jq -r '.Protector' ../contracts/deployments/base-sepolia.json)

# Replace placeholders in subgraph.yaml
sed -i "s/CONTRACT_ADDRESS_PLACEHOLDER/$VAULT_ADDR/g" subgraph.yaml
sed -i "s/PROTECTOR_ADDRESS_PLACEHOLDER/$PROTECTOR_ADDR/g" subgraph.yaml
```

### E2.9.5 Make deploy script executable | 使部署脚本可执行
```bash
chmod +x subgraph/scripts/deploy.sh
```

---

## E2.10 Subgraph Studio Deployment（Subgraph Studio 部署）

### E2.10.1 Authenticate with Graph CLI | 使用 Graph CLI 认证
```bash
graph auth --studio YOUR_DEPLOY_KEY
```

### E2.10.2 Create subgraph in Studio | 在 Studio 创建子图
Visit https://thegraph.com/studio/ | 访问 https://thegraph.com/studio/

### E2.10.3 Deploy to Studio | 部署到 Studio
```bash
cd subgraph && graph deploy --studio derisk-watchtower
```

### E2.10.4 Verify deployment status | 验证部署状态
Check Studio dashboard for sync progress | 检查 Studio 仪表板同步进度

### E2.10.5 Test query in Studio playground | 在 Studio playground 测试查询
Query for positions and risk events | 查询头寸与风险事件

---

## E2.11 Alternative: Alchemy Subgraphs（替代方案：Alchemy Subgraphs）

### E2.11.1 Create Alchemy account | 创建 Alchemy 账户
Visit https://www.alchemy.com/ | 访问 https://www.alchemy.com/

### E2.11.2 Install Alchemy CLI | 安装 Alchemy CLI
```bash
npm install -g @alch/alchemy-subgraph-cli
```

### E2.11.3 Initialize Alchemy subgraph | 初始化 Alchemy 子图
```bash
alchemy subgraph init
```

### E2.11.4 Deploy to Alchemy | 部署到 Alchemy
```bash
alchemy subgraph deploy
```

### E2.11.5 Get Alchemy subgraph endpoint | 获取 Alchemy 子图端点
Save endpoint URL to .env | 保存端点 URL 到 .env

---

## E2.12 Query Testing（查询测试）

### E2.12.1 Create test-queries.graphql | 创建 test-queries.graphql
File path: `subgraph/test-queries.graphql` | 文件路径

### E2.12.2 Add query for all positions | 添加查询所有头寸
```graphql
query AllPositions {
  positions(first: 10, orderBy: createdAt, orderDirection: desc) {
    id
    owner
    collateralAmount
    debtAmount
    healthFactor
    lastUpdateTimestamp
  }
}
```

### E2.12.3 Add query for positions by owner | 添加按所有者查询头寸
```graphql
query PositionsByOwner($owner: Bytes!) {
  positions(where: { owner: $owner }) {
    id
    healthFactor
    riskEvents {
      id
      eventType
      newHF
      timestamp
    }
  }
}
```

### E2.12.4 Add query for risk events | 添加查询风险事件
```graphql
query RecentRiskEvents {
  riskEvents(first: 20, orderBy: timestamp, orderDirection: desc) {
    id
    position {
      id
      owner
    }
    eventType
    previousHF
    newHF
    timestamp
  }
}
```

### E2.12.5 Add query for protection actions | 添加查询保护操作
```graphql
query ProtectionActions {
  protectionActions(first: 10, orderBy: timestamp, orderDirection: desc) {
    id
    position {
      id
      owner
    }
    beforeHF
    afterHF
    collateralDelta
    executor
    timestamp
  }
}
```

### E2.12.6 Add query for global statistics | 添加查询全局统计
```graphql
query GlobalStatistics {
  globalStats(id: "global") {
    totalPositions
    totalProtections
    totalRiskEvents
    lastUpdateTimestamp
  }
}
```

### E2.12.7 Test queries with curl | 使用 curl 测试查询
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query": "{ positions { id healthFactor } }"}' \
  https://api.studio.thegraph.com/query/YOUR_SUBGRAPH_ID
```

---

## E2.13 Indexing Performance（索引性能）

### E2.13.1 Add indexing status check | 添加索引状态检查
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query": "{ indexingStatusForCurrentVersion(subgraphName: \"derisk-watchtower\") { synced health chains { latestBlock { number } } } }"}' \
  https://api.thegraph.com/index-node/graphql
```

### E2.13.2 Monitor sync progress | 监控同步进度
Check latestBlock vs network head block | 检查 latestBlock vs 网络头区块

### E2.13.3 Test query response time | 测试查询响应时间
```bash
time curl -X POST ... | jq .
```

### E2.13.4 Verify lastSync timestamp | 验证 lastSync 时间戳
Compare with current time for staleness | 与当前时间比较陈旧度

### E2.13.5 Add pagination for large results | 为大结果添加分页
Use first, skip parameters in queries | 在查询中使用 first、skip 参数

---

## E2.14 Error Handling in Mappings（映射中错误处理）

### E2.14.1 Add null checks for entity loads | 为实体加载添加空检查
```typescript
let position = Position.load(id);
if (position == null) {
  log.warning("Position not found: {}", [id]);
  return;
}
```

### E2.14.2 Handle missing related entities | 处理缺失关联实体
Check if position exists before creating RiskEvent | 创建 RiskEvent 前检查头寸存在

### E2.14.3 Add try-catch for contract calls | 为合约调用添加 try-catch
```typescript
let contract = PositionVault.bind(event.address);
let result = contract.try_getPosition(positionId);
if (result.reverted) {
  log.error("Contract call reverted", []);
  return;
}
```

### E2.14.4 Log warnings for unexpected data | 记录意外数据警告
```typescript
if (healthFactor.equals(BigInt.fromI32(0))) {
  log.warning("Zero health factor detected for position {}", [position.id]);
}
```

### E2.14.5 Test mapping with invalid events | 使用无效事件测试映射
Create test with malformed event data | 使用格式错误事件数据创建测试

---

## E2.15 Subgraph Testing Framework（子图测试框架）

### E2.15.1 Install matchstick-as for testing | 安装 matchstick-as 用于测试
```bash
cd subgraph && npm install --save-dev matchstick-as
```

### E2.15.2 Create tests directory | 创建 tests 目录
```bash
mkdir -p subgraph/tests
```

### E2.15.3 Create mapping.test.ts | 创建 mapping.test.ts
File path: `subgraph/tests/mapping.test.ts` | 文件路径

### E2.15.4 Add test for handlePositionCreated | 添加 handlePositionCreated 测试
```typescript
import { describe, test, assert, clearStore } from "matchstick-as/assembly/index";
import { handlePositionCreated } from "../src/mapping";
import { createPositionCreatedEvent } from "./utils";

describe("Position Creation", () => {
  test("should create Position entity", () => {
    let event = createPositionCreatedEvent(...);
    handlePositionCreated(event);
    assert.entityCount("Position", 1);
  });
});
```

### E2.15.5 Add test for risk event creation | 添加风险事件创建测试
```typescript
test("should create RiskEvent on threshold breach", () => {
  // Setup position with HF > 1.3
  // Update position with HF < 1.3
  // Assert RiskEvent created
});
```

### E2.15.6 Add test for global stats update | 添加全局统计更新测试
Verify totalPositions increments correctly | 验证 totalPositions 正确递增

### E2.15.7 Run subgraph tests | 运行子图测试
```bash
cd subgraph && graph test
```

---

## E2.16 Documentation & Metadata（文档与元数据）

### E2.16.1 Add subgraph README | 添加子图 README
File path: `subgraph/README.md` | 文件路径

### E2.16.2 Document entity relationships | 记录实体关系
Position → RiskEvents, ProtectionActions | Position → RiskEvents、ProtectionActions

### E2.16.3 Add example queries to README | 添加示例查询到 README
Include common queries for integration | 包含集成常用查询

### E2.16.4 Document indexing latency expectations | 记录索引延迟预期
Typical sync delay 10-30 seconds on Base Sepolia | Base Sepolia 典型同步延迟 10–30 秒

### E2.16.5 Add subgraph.yaml to version control | 添加 subgraph.yaml 到版本控制
Commit with placeholder addresses | 提交占位符地址

### E2.16.6 Create SUBGRAPH.md in docs/ | 在 docs/ 创建 SUBGRAPH.md
Document deployment process and queries | 记录部署流程与查询

---

## E2.17 Integration with Backend（与后端集成）

### E2.17.1 Save subgraph endpoint to .env | 保存子图端点到 .env
```bash
SUBGRAPH_ENDPOINT=https://api.studio.thegraph.com/query/YOUR_ID/derisk-watchtower/v0.0.1
```

### E2.17.2 Test GraphQL query from backend | 从后端测试 GraphQL 查询
```bash
curl -X POST $SUBGRAPH_ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{"query": "{ positions { id } }"}'
```

### E2.17.3 Verify backend can fetch positions | 验证后端可获取头寸
Backend service should parse GraphQL response | 后端服务应解析 GraphQL 响应

### E2.17.4 Add GraphQL client to backend | 添加 GraphQL 客户端到后端
Document integration in backend service code | 在后端服务代码记录集成

---

## E2.18 Staleness Detection（陈旧度检测）

### E2.18.1 Add lastSync field to queries | 添加 lastSync 字段到查询
```graphql
query PositionsWithSync {
  positions {
    id
    healthFactor
  }
  _meta {
    block {
      number
      timestamp
    }
  }
}
```

### E2.18.2 Calculate staleness in backend | 在后端计算陈旧度
```typescript
const now = Date.now() / 1000;
const isStale = now - data._meta.block.timestamp > 60;
```

### E2.18.3 Add staleness indicator to API response | 添加陈旧度指示器到 API 响应
Include `isStale: boolean` in position data | 在头寸数据包含 `isStale: boolean`

### E2.18.4 Test staleness with delayed subgraph | 使用延迟子图测试陈旧度
Simulate slow sync and verify indicator | 模拟慢同步并验证指示器

---

## E2.19 Completion Checklist（完成清单）

- [ ] Graph CLI installed and verified | Graph CLI 已安装并验证
- [ ] Subgraph directory created | 子图目录已创建
- [ ] schema.graphql defines all entities | schema.graphql 定义所有实体
- [ ] Position entity includes all required fields | Position 实体包含所有必需字段
- [ ] RiskEvent and ProtectionAction entities defined | RiskEvent 与 ProtectionAction 实体已定义
- [ ] subgraph.yaml configured for Base Sepolia | subgraph.yaml 为 Base Sepolia 配置
- [ ] PositionVault and Protector ABIs exported | PositionVault 与 Protector ABI 已导出
- [ ] mapping.ts implements all event handlers | mapping.ts 实现所有事件处理器
- [ ] handlePositionCreated creates Position entity | handlePositionCreated 创建 Position 实体
- [ ] handlePositionUpdated updates HF and creates RiskEvent | handlePositionUpdated 更新 HF 并创建 RiskEvent
- [ ] handleProtectionExecuted creates ProtectionAction | handleProtectionExecuted 创建 ProtectionAction
- [ ] GlobalStats entity tracks aggregates | GlobalStats 实体跟踪聚合
- [ ] graph codegen generates types successfully | graph codegen 成功生成类型
- [ ] graph build compiles WASM without errors | graph build 无错编译 WASM
- [ ] Subgraph deployed to Studio or Alchemy | 子图已部署到 Studio 或 Alchemy
- [ ] Deployment endpoint saved to .env | 部署端点已保存到 .env
- [ ] Test queries execute successfully | 测试查询成功执行
- [ ] Positions query returns correct data | Positions 查询返回正确数据
- [ ] Risk events query shows threshold breaches | 风险事件查询显示阈值突破
- [ ] Protection actions query shows HF improvements | 保护操作查询显示 HF 改善
- [ ] Subgraph syncs within 30 seconds of events | 子图在事件后 30 秒内同步
- [ ] Staleness detection implemented with _meta | 使用 _meta 实现陈旧度检测
- [ ] Backend can query subgraph successfully | 后端可成功查询子图
- [ ] Subgraph README documents deployment | 子图 README 记录部署
- [ ] SUBGRAPH.md added to docs/ | SUBGRAPH.md 已添加到 docs/

---

**End of E2 Subgraph Tasks | E2 子图任务结束**
