# E1 Contracts Tasks（E1 合约任务）

**Feature**: DeRisk Watchtower | **分支**: `001-derisk-watchtower-real`
**Feature**: DeRisk 瞭望塔 | **Branch**: `001-derisk-watchtower-real`

---

## E1.1 Foundry Project Setup（Foundry 项目设置）

### E1.1.1 Initialize Foundry project | 初始化 Foundry 项目
```bash
mkdir -p contracts && cd contracts && forge init --no-git
```

### E1.1.2 Configure foundry.toml for Base Sepolia | 配置 foundry.toml 用于 Base Sepolia
File path: `contracts/foundry.toml` | 文件路径：`contracts/foundry.toml`

### E1.1.3 Add Base Sepolia RPC URL | 添加 Base Sepolia RPC URL
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.20"

[rpc_endpoints]
base_sepolia = "${BASE_SEPOLIA_RPC}"
```

### E1.1.4 Install OpenZeppelin contracts | 安装 OpenZeppelin 合约
```bash
cd contracts && forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

### E1.1.5 Add remappings for OpenZeppelin | 添加 OpenZeppelin 重映射
File: `contracts/remappings.txt` | 文件：`contracts/remappings.txt`
```
@openzeppelin/=lib/openzeppelin-contracts/
```

### E1.1.6 Verify Foundry build works | 验证 Foundry 构建工作
```bash
cd contracts && forge build
```

### E1.1.7 Create contracts/src directory structure | 创建 contracts/src 目录结构
```bash
mkdir -p contracts/src/interfaces contracts/src/mocks
```

---

## E1.2 Position Vault Contract（Position Vault 合约）

### E1.2.1 Create PositionVault.sol skeleton | 创建 PositionVault.sol 骨架
File path: `contracts/src/PositionVault.sol` | 文件路径：`contracts/src/PositionVault.sol`

### E1.2.2 Add SPDX license and pragma | 添加 SPDX 许可证与 pragma
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
```

### E1.2.3 Import OpenZeppelin security modules | 导入 OpenZeppelin 安全模块
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
```

### E1.2.4 Define Position struct | 定义 Position 结构
```solidity
struct Position {
    bytes32 id;
    address owner;
    uint256 collateralAmount;
    address collateralToken;
    uint256 debtAmount;
    address debtToken;
    uint256 healthFactor;
    uint256 lastUpdateTimestamp;
}
```

### E1.2.5 Add state variables for positions mapping | 添加头寸映射状态变量
```solidity
mapping(bytes32 => Position) public positions;
mapping(address => bytes32[]) public userPositions;
uint256 public positionCount;
```

### E1.2.6 Define PositionCreated event | 定义 PositionCreated 事件
```solidity
event PositionCreated(
    bytes32 indexed id,
    address indexed owner,
    uint256 collateralAmount,
    uint256 debtAmount
);
```

### E1.2.7 Define PositionUpdated event | 定义 PositionUpdated 事件
```solidity
event PositionUpdated(
    bytes32 indexed id,
    uint256 newHealthFactor,
    uint256 previousHealthFactor,
    uint256 timestamp
);
```

### E1.2.8 Add createPosition function | 添加 createPosition 函数
```solidity
function createPosition(
    address collateralToken,
    uint256 collateralAmount,
    address debtToken,
    uint256 debtAmount
) external nonReentrant whenNotPaused returns (bytes32)
```

### E1.2.9 Implement position ID generation | 实现头寸 ID 生成
Use keccak256 hash of owner, tokens, and counter | 使用所有者、代币与计数器的 keccak256 哈希

### E1.2.10 Add health factor calculation helper | 添加健康系数计算辅助函数
```solidity
function calculateHealthFactor(
    uint256 collateralAmount,
    uint256 collateralPrice,
    uint256 debtAmount,
    uint256 debtPrice
) public pure returns (uint256)
```

### E1.2.11 Implement HF formula with 4 decimal precision | 实现 4 位小数精度 HF 公式
HF = (collateral * price * 0.8) / (debt * price) * 10000 | HF = (抵押品 * 价格 * 0.8) / (债务 * 价格) * 10000

### E1.2.12 Add getPosition view function | 添加 getPosition 查看函数
```solidity
function getPosition(bytes32 id) external view returns (Position memory)
```

### E1.2.13 Add getUserPositions view function | 添加 getUserPositions 查看函数
```solidity
function getUserPositions(address user) external view returns (bytes32[] memory)
```

### E1.2.14 Add updateHealthFactor function | 添加 updateHealthFactor 函数
```solidity
function updateHealthFactor(
    bytes32 positionId,
    uint256 collateralPrice,
    uint256 debtPrice
) external nonReentrant
```

### E1.2.15 Emit PositionUpdated on HF change | HF 变化时发出 PositionUpdated
Only emit if HF crosses threshold bands | 仅当 HF 跨越阈值带时发出

### E1.2.16 Add pause/unpause admin functions | 添加暂停/取消暂停管理函数
```solidity
function pause() external onlyOwner
function unpause() external onlyOwner
```

---

## E1.3 Protector Contract（Protector 合约）

### E1.3.1 Create Protector.sol skeleton | 创建 Protector.sol 骨架
File path: `contracts/src/Protector.sol` | 文件路径：`contracts/src/Protector.sol`

### E1.3.2 Add SPDX license and imports | 添加 SPDX 许可证与导入
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
```

### E1.3.3 Define IPositionVault interface reference | 定义 IPositionVault 接口引用
```solidity
interface IPositionVault {
    function getPosition(bytes32 id) external view returns (...);
    function updateHealthFactor(bytes32 id, uint256, uint256) external;
}
```

### E1.3.4 Add state variable for PositionVault address | 添加 PositionVault 地址状态变量
```solidity
IPositionVault public immutable positionVault;
address public immutable escrow;
```

### E1.3.5 Define ProtectionExecuted event | 定义 ProtectionExecuted 事件
```solidity
event ProtectionExecuted(
    bytes32 indexed positionId,
    uint256 beforeHF,
    uint256 afterHF,
    uint256 collateralAdded,
    address indexed executor
);
```

### E1.3.6 Implement constructor with vault and escrow | 实现带 vault 与 escrow 的构造函数
```solidity
constructor(address _vault, address _escrow) {
    positionVault = IPositionVault(_vault);
    escrow = _escrow;
}
```

### E1.3.7 Add protect function signature | 添加 protect 函数签名
```solidity
function protect(
    bytes32 positionId,
    uint256 collateralToAdd
) external nonReentrant returns (uint256 newHF)
```

### E1.3.8 Fetch position from vault | 从 vault 获取头寸
```solidity
Position memory pos = positionVault.getPosition(positionId);
require(pos.owner != address(0), "Position not found");
```

### E1.3.9 Calculate current health factor | 计算当前健康系数
Call calculateHealthFactor with current prices | 用当前价格调用 calculateHealthFactor

### E1.3.10 Transfer collateral from escrow | 从 escrow 转移抵押品
```solidity
IERC20(pos.collateralToken).transferFrom(
    escrow,
    address(this),
    collateralToAdd
);
```

### E1.3.11 Calculate new health factor after add | 添加后计算新健康系数
```solidity
uint256 newCollateral = pos.collateralAmount + collateralToAdd;
uint256 newHF = calculateHealthFactor(newCollateral, ...);
```

### E1.3.12 Require HF improvement | 要求 HF 改善
```solidity
require(newHF > currentHF, "Protection did not improve HF");
```

### E1.3.13 Update position in vault | 在 vault 中更新头寸
```solidity
positionVault.updateHealthFactor(positionId, collateralPrice, debtPrice);
```

### E1.3.14 Emit ProtectionExecuted event | 发出 ProtectionExecuted 事件
Include beforeHF, afterHF, collateralAdded | 包含 beforeHF、afterHF、collateralAdded

### E1.3.15 Add requireHealthFactorBelow modifier | 添加 requireHealthFactorBelow 修饰符
```solidity
modifier requireHealthFactorBelow(bytes32 positionId, uint256 threshold) {
    uint256 hf = getPositionHF(positionId);
    require(hf < threshold, "HF above threshold");
    _;
}
```

---

## E1.4 Demo Escrow Contract（Demo Escrow 合约）

### E1.4.1 Create DemoEscrow.sol skeleton | 创建 DemoEscrow.sol 骨架
File path: `contracts/src/DemoEscrow.sol` | 文件路径：`contracts/src/DemoEscrow.sol`

### E1.4.2 Add SPDX and ERC20 imports | 添加 SPDX 与 ERC20 导入
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
```

### E1.4.3 Add authorized protector mapping | 添加授权 protector 映射
```solidity
mapping(address => bool) public authorizedProtectors;
```

### E1.4.4 Define EscrowFunded event | 定义 EscrowFunded 事件
```solidity
event EscrowFunded(address indexed token, uint256 amount);
event ProtectorAuthorized(address indexed protector);
```

### E1.4.5 Implement fund function for owner | 实现所有者资金函数
```solidity
function fund(address token, uint256 amount) external onlyOwner {
    IERC20(token).transferFrom(msg.sender, address(this), amount);
    emit EscrowFunded(token, amount);
}
```

### E1.4.6 Add authorizeProtector function | 添加 authorizeProtector 函数
```solidity
function authorizeProtector(address protector) external onlyOwner {
    authorizedProtectors[protector] = true;
    emit ProtectorAuthorized(protector);
}
```

### E1.4.7 Add withdraw function with auth check | 添加带授权检查的 withdraw 函数
```solidity
function withdraw(
    address token,
    address to,
    uint256 amount
) external {
    require(authorizedProtectors[msg.sender], "Not authorized");
    IERC20(token).transfer(to, amount);
}
```

### E1.4.8 Add getBalance view function | 添加 getBalance 查看函数
```solidity
function getBalance(address token) external view returns (uint256) {
    return IERC20(token).balanceOf(address(this));
}
```

---

## E1.5 Interfaces（接口）

### E1.5.1 Create IChainlinkPriceFeed.sol | 创建 IChainlinkPriceFeed.sol
File path: `contracts/src/interfaces/IChainlinkPriceFeed.sol` | 文件路径

### E1.5.2 Define AggregatorV3Interface functions | 定义 AggregatorV3Interface 函数
```solidity
interface IChainlinkPriceFeed {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
    function decimals() external view returns (uint8);
}
```

### E1.5.3 Create IProtector.sol interface | 创建 IProtector.sol 接口
File path: `contracts/src/interfaces/IProtector.sol` | 文件路径

### E1.5.4 Define protect function signature | 定义 protect 函数签名
```solidity
interface IProtector {
    function protect(bytes32 positionId, uint256 collateralToAdd)
        external
        returns (uint256 newHF);
}
```

### E1.5.5 Add checkUpkeep for Chainlink Automation | 为 Chainlink Automation 添加 checkUpkeep
```solidity
interface IAutomationCompatible {
    function checkUpkeep(bytes calldata checkData)
        external
        returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
}
```

---

## E1.6 Mock Contracts for Testing（测试用模拟合约）

### E1.6.1 Create MockERC20.sol | 创建 MockERC20.sol
File path: `contracts/src/mocks/MockERC20.sol` | 文件路径

### E1.6.2 Import OpenZeppelin ERC20 base | 导入 OpenZeppelin ERC20 基础
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

### E1.6.3 Add mint function for testing | 添加 mint 函数用于测试
```solidity
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
    {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
```

### E1.6.4 Create MockPriceFeed.sol | 创建 MockPriceFeed.sol
File path: `contracts/src/mocks/MockPriceFeed.sol` | 文件路径

### E1.6.5 Implement settable price for tests | 实现测试可设置价格
```solidity
contract MockPriceFeed {
    int256 public price;
    uint8 public decimals = 8;

    function setPrice(int256 _price) external {
        price = _price;
    }

    function latestRoundData()
        external
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (0, price, 0, block.timestamp, 0);
    }
}
```

---

## E1.7 Foundry Unit Tests（Foundry 单元测试）

### E1.7.1 Create PositionVault.t.sol | 创建 PositionVault.t.sol
File path: `contracts/test/PositionVault.t.sol` | 文件路径

### E1.7.2 Import Foundry Test and contracts | 导入 Foundry Test 与合约
```solidity
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PositionVault.sol";
import "../src/mocks/MockERC20.sol";
```

### E1.7.3 Setup test contract with fixtures | 设置带固件的测试合约
```solidity
contract PositionVaultTest is Test {
    PositionVault vault;
    MockERC20 collateralToken;
    MockERC20 debtToken;
    address user = address(0x1);

    function setUp() public {
        vault = new PositionVault();
        collateralToken = new MockERC20("Collateral", "COL");
        debtToken = new MockERC20("Debt", "DBT");
    }
}
```

### E1.7.4 Test createPosition success case | 测试 createPosition 成功情况
```solidity
function testCreatePosition() public {
    vm.startPrank(user);
    bytes32 id = vault.createPosition(
        address(collateralToken),
        1000e18,
        address(debtToken),
        500e18
    );
    assertNotEq(id, bytes32(0));
    vm.stopPrank();
}
```

### E1.7.5 Test createPosition emits event | 测试 createPosition 发出事件
```solidity
function testCreatePositionEmitsEvent() public {
    vm.expectEmit(true, true, false, true);
    emit PositionCreated(...);
    vault.createPosition(...);
}
```

### E1.7.6 Test getPosition returns correct data | 测试 getPosition 返回正确数据
Verify all struct fields match input | 验证所有结构字段匹配输入

### E1.7.7 Test getUserPositions returns IDs | 测试 getUserPositions 返回 ID
Create multiple positions and verify array | 创建多个头寸并验证数组

### E1.7.8 Test calculateHealthFactor formula | 测试 calculateHealthFactor 公式
```solidity
function testCalculateHealthFactor() public {
    uint256 hf = vault.calculateHealthFactor(1000e18, 2000e8, 500e18, 1000e8);
    assertEq(hf, 32000); // HF = 3.2 with 4 decimals
}
```

### E1.7.9 Test updateHealthFactor changes HF | 测试 updateHealthFactor 改变 HF
Mock price change and verify HF updates | 模拟价格变化并验证 HF 更新

### E1.7.10 Test pause prevents createPosition | 测试暂停阻止 createPosition
```solidity
function testPausePreventsCreate() public {
    vault.pause();
    vm.expectRevert("Pausable: paused");
    vault.createPosition(...);
}
```

### E1.7.11 Test reentrancy protection | 测试重入保护
Create malicious contract attempting reentry | 创建恶意合约尝试重入

### E1.7.12 Test zero address validation | 测试零地址验证
Expect revert when creating with zero address | 创建零地址时预期回滚

---

## E1.8 Protector Contract Tests（Protector 合约测试）

### E1.8.1 Create Protector.t.sol | 创建 Protector.t.sol
File path: `contracts/test/Protector.t.sol` | 文件路径

### E1.8.2 Setup with vault, escrow, protector | 设置 vault、escrow、protector
```solidity
contract ProtectorTest is Test {
    PositionVault vault;
    DemoEscrow escrow;
    Protector protector;
    MockERC20 collateral;
    MockERC20 debt;

    function setUp() public {
        vault = new PositionVault();
        escrow = new DemoEscrow();
        protector = new Protector(address(vault), address(escrow));
        collateral = new MockERC20("COL", "COL");
        debt = new MockERC20("DBT", "DBT");
    }
}
```

### E1.8.3 Test protect improves health factor | 测试 protect 改善健康系数
```solidity
function testProtectImprovesHF() public {
    bytes32 posId = createTestPosition();
    uint256 beforeHF = getPositionHF(posId);
    protector.protect(posId, 100e18);
    uint256 afterHF = getPositionHF(posId);
    assertGt(afterHF, beforeHF);
}
```

### E1.8.4 Test protect emits ProtectionExecuted | 测试 protect 发出 ProtectionExecuted
```solidity
function testProtectEmitsEvent() public {
    vm.expectEmit(true, false, false, true);
    emit ProtectionExecuted(posId, beforeHF, afterHF, amount, executor);
    protector.protect(posId, amount);
}
```

### E1.8.5 Test protect reverts if HF unchanged | 测试 HF 不变时 protect 回滚
```solidity
function testProtectRevertsIfNoImprovement() public {
    vm.expectRevert("Protection did not improve HF");
    protector.protect(posId, 0);
}
```

### E1.8.6 Test protect transfers from escrow | 测试 protect 从 escrow 转移
Verify escrow balance decreases | 验证 escrow 余额减少

### E1.8.7 Test protect with unauthorized caller | 测试未授权调用者的 protect
Escrow should reject if not authorized | 若未授权 escrow 应拒绝

### E1.8.8 Test protect nonexistent position | 测试保护不存在头寸
```solidity
function testProtectNonexistentPosition() public {
    vm.expectRevert("Position not found");
    protector.protect(bytes32(uint256(999)), 100e18);
}
```

---

## E1.9 Integration Tests（集成测试）

### E1.9.1 Create Integration.t.sol | 创建 Integration.t.sol
File path: `contracts/test/Integration.t.sol` | 文件路径

### E1.9.2 Test full flow: create → drop HF → protect | 测试完整流程：创建 → HF 下降 → 保护
```solidity
function testFullProtectionFlow() public {
    // 1. Create position
    bytes32 posId = vault.createPosition(...);

    // 2. Simulate price drop (HF decreases)
    mockFeed.setPrice(1000e8); // Lower collateral price

    // 3. Execute protection
    protector.protect(posId, 500e18);

    // 4. Verify HF restored above threshold
    uint256 finalHF = vault.getPosition(posId).healthFactor;
    assertGt(finalHF, 13000); // > 1.3
}
```

### E1.9.3 Test multiple positions protection | 测试多头寸保护
Create 3 positions and protect each | 创建 3 个头寸并保护每个

### E1.9.4 Test escrow funding and authorization | 测试 escrow 资金与授权
Fund escrow, authorize protector, verify withdraw | 资金 escrow、授权 protector、验证 withdraw

### E1.9.5 Test vault pause prevents protection | 测试 vault 暂停阻止保护
Pause vault and ensure protect fails | 暂停 vault 并确保 protect 失败

### E1.9.6 Test event sequence in full flow | 测试完整流程事件序列
Verify PositionCreated, PositionUpdated, ProtectionExecuted | 验证 PositionCreated、PositionUpdated、ProtectionExecuted

---

## E1.10 Gas Optimization Tests（Gas 优化测试）

### E1.10.1 Add gas reporter to foundry.toml | 添加 gas reporter 到 foundry.toml
```toml
[profile.default]
gas_reports = ["PositionVault", "Protector"]
```

### E1.10.2 Run forge snapshot for baseline | 运行 forge snapshot 建立基线
```bash
cd contracts && forge snapshot
```

### E1.10.3 Test createPosition gas cost | 测试 createPosition gas 成本
```solidity
function testGasCreatePosition() public {
    uint256 gasBefore = gasleft();
    vault.createPosition(...);
    uint256 gasUsed = gasBefore - gasleft();
    assertLt(gasUsed, 200000); // < 200k gas
}
```

### E1.10.4 Test protect gas cost | 测试 protect gas 成本
Ensure protection execution is efficient | 确保保护执行高效

### E1.10.5 Compare storage layout optimization | 比较存储布局优化
Verify struct packing reduces storage slots | 验证结构打包减少存储槽

---

## E1.11 Security Validations（安全验证）

### E1.11.1 Test reentrancy guard on createPosition | 测试 createPosition 重入保护
```solidity
function testReentrancyProtection() public {
    MaliciousContract attacker = new MaliciousContract(vault);
    vm.expectRevert("ReentrancyGuard: reentrant call");
    attacker.attack();
}
```

### E1.11.2 Test Pausable on all state-changing functions | 测试所有状态变更函数的 Pausable
Pause and verify all externals revert | 暂停并验证所有外部函数回滚

### E1.11.3 Test access control on admin functions | 测试管理函数访问控制
```solidity
function testOnlyOwnerCanPause() public {
    vm.prank(address(0x999));
    vm.expectRevert("Ownable: caller is not the owner");
    vault.pause();
}
```

### E1.11.4 Test integer overflow protection | 测试整数溢出保护
Try extreme values in HF calculation | 在 HF 计算中尝试极端值

### E1.11.5 Test zero amount validation | 测试零数量验证
Ensure contracts reject zero collateral/debt | 确保合约拒绝零抵押品/债务

### E1.11.6 Verify no uninitialized storage | 验证无未初始化存储
Check all mappings and structs initialized | 检查所有映射与结构已初始化

---

## E1.12 Deploy Script（部署脚本）

### E1.12.1 Create Deploy.s.sol script | 创建 Deploy.s.sol 脚本
File path: `contracts/script/Deploy.s.sol` | 文件路径

### E1.12.2 Import Foundry Script base | 导入 Foundry Script 基础
```solidity
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PositionVault.sol";
import "../src/Protector.sol";
import "../src/DemoEscrow.sol";
```

### E1.12.3 Add run function with deployment order | 添加带部署顺序的 run 函数
```solidity
function run() external {
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    // 1. Deploy PositionVault
    PositionVault vault = new PositionVault();
    console.log("PositionVault:", address(vault));

    // 2. Deploy DemoEscrow
    DemoEscrow escrow = new DemoEscrow();
    console.log("DemoEscrow:", address(escrow));

    // 3. Deploy Protector
    Protector protector = new Protector(address(vault), address(escrow));
    console.log("Protector:", address(protector));

    vm.stopBroadcast();
}
```

### E1.12.4 Add deployment verification | 添加部署验证
Log all deployed addresses to console | 将所有已部署地址记录到控制台

### E1.12.5 Test deploy script on local anvil | 在本地 anvil 测试部署脚本
```bash
anvil &
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### E1.12.6 Test deploy script on Base Sepolia | 在 Base Sepolia 测试部署脚本
```bash
forge script script/Deploy.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast --verify
```

### E1.12.7 Save deployed addresses to JSON | 保存已部署地址到 JSON
File: `contracts/deployments/base-sepolia.json` | 文件：`contracts/deployments/base-sepolia.json`

---

## E1.13 Seed Script（种子脚本）

### E1.13.1 Create Seed.s.sol script | 创建 Seed.s.sol 脚本
File path: `contracts/script/Seed.s.sol` | 文件路径

### E1.13.2 Deploy test tokens for demo | 部署演示用测试代币
```solidity
MockERC20 collateral = new MockERC20("Demo Collateral", "DCOL");
MockERC20 debt = new MockERC20("Demo Debt", "DDBT");
```

### E1.13.3 Mint tokens to demo escrow | 铸造代币到演示 escrow
```solidity
collateral.mint(address(escrow), 10000e18);
debt.mint(address(escrow), 5000e18);
```

### E1.13.4 Authorize protector in escrow | 在 escrow 中授权 protector
```solidity
escrow.authorizeProtector(address(protector));
```

### E1.13.5 Create 3 demo positions | 创建 3 个演示头寸
```solidity
vault.createPosition(address(collateral), 1000e18, address(debt), 400e18);
vault.createPosition(address(collateral), 2000e18, address(debt), 900e18);
vault.createPosition(address(collateral), 500e18, address(debt), 300e18);
```

### E1.13.6 Log seed data to console | 将种子数据记录到控制台
Print position IDs and token addresses | 打印头寸 ID 与代币地址

### E1.13.7 Save seed config to JSON | 保存种子配置到 JSON
File: `contracts/deployments/seed-data.json` | 文件：`contracts/deployments/seed-data.json`

---

## E1.14 Contract Documentation（合约文档）

### E1.14.1 Add NatSpec to PositionVault functions | 为 PositionVault 函数添加 NatSpec
```solidity
/// @notice Creates a new lending position
/// @param collateralToken Address of collateral ERC20
/// @param collateralAmount Amount of collateral
/// @return id Unique position identifier
```

### E1.14.2 Add NatSpec to Protector functions | 为 Protector 函数添加 NatSpec
Document protect function parameters and returns | 记录 protect 函数参数与返回

### E1.14.3 Add contract-level documentation | 添加合约级文档
```solidity
/// @title PositionVault
/// @notice Manages DeFi lending positions with health factor tracking
/// @dev Uses OpenZeppelin ReentrancyGuard and Pausable
```

### E1.14.4 Document security assumptions | 记录安全假设
Note: Testnet only, demo escrow trusted | 注意：仅测试网，演示 escrow 受信任

### E1.14.5 Generate Foundry docs | 生成 Foundry 文档
```bash
cd contracts && forge doc
```

---

## E1.15 OpenZeppelin Baseline（OpenZeppelin 基线）

### E1.15.1 Verify ReentrancyGuard usage | 验证 ReentrancyGuard 使用
All external state-changing functions use nonReentrant | 所有外部状态变更函数使用 nonReentrant

### E1.15.2 Verify Pausable usage | 验证 Pausable 使用
All critical functions include whenNotPaused | 所有关键函数包含 whenNotPaused

### E1.15.3 Verify Ownable access control | 验证 Ownable 访问控制
Admin functions restricted to owner | 管理函数限制为所有者

### E1.15.4 Check SafeERC20 for token transfers | 检查代币转移的 SafeERC20
```solidity
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;
```

### E1.15.5 Use Address.isContract for validation | 使用 Address.isContract 验证
Validate contract addresses on deployment | 部署时验证合约地址

---

## E1.16 Reentrancy & Pause Testing（重入与暂停测试）

### E1.16.1 Create malicious reentrancy contract | 创建恶意重入合约
```solidity
contract MaliciousReentrancy {
    PositionVault vault;
    function attack() external {
        vault.createPosition(...);
        // Attempt reentry
        vault.createPosition(...);
    }
}
```

### E1.16.2 Test reentrancy blocked by guard | 测试重入被保护阻止
```solidity
function testReentrancyBlocked() public {
    vm.expectRevert("ReentrancyGuard: reentrant call");
    malicious.attack();
}
```

### E1.16.3 Test pause blocks all mutations | 测试暂停阻止所有变更
Verify createPosition, updateHF, protect all revert | 验证 createPosition、updateHF、protect 全部回滚

### E1.16.4 Test unpause restores functionality | 测试取消暂停恢复功能
```solidity
function testUnpauseRestores() public {
    vault.pause();
    vault.unpause();
    vault.createPosition(...); // Should succeed
}
```

### E1.16.5 Test pause requires owner | 测试暂停需要所有者
Non-owner cannot pause | 非所有者无法暂停

---

## E1.17 Health Factor Validation（健康系数验证）

### E1.17.1 Test HF calculation edge cases | 测试 HF 计算边缘情况
```solidity
function testHFZeroDebt() public {
    // HF should be max uint256 if debt is zero
    uint256 hf = vault.calculateHealthFactor(1000e18, 2000e8, 0, 1000e8);
    assertEq(hf, type(uint256).max);
}
```

### E1.17.2 Test HF precision with 4 decimals | 测试 4 位小数 HF 精度
Verify 1.3000 stored as 13000 | 验证 1.3000 存储为 13000

### E1.17.3 Test HF thresholds: Safe, Warning, Critical | 测试 HF 阈值：安全、警告、严重
```solidity
function testHFThresholds() public {
    assertGt(safeLevelHF, 15000); // Safe > 1.5
    assertEq(warningHF, 13000);  // Warning = 1.3
    assertLt(criticalHF, 13000);  // Critical < 1.3
}
```

### E1.17.4 Test HF with price feed decimals | 测试带价格预言机小数的 HF
Handle 8-decimal Chainlink feeds correctly | 正确处理 8 位小数 Chainlink 预言机

### E1.17.5 Test HF update only on significant change | 测试仅在显著变化时 HF 更新
Event emitted only if delta > 1% | 仅当差值 > 1% 时发出事件

---

## E1.18 Completion Checklist（完成清单）

- [ ] Foundry project initialized with Base Sepolia config | Foundry 项目已初始化 Base Sepolia 配置
- [ ] OpenZeppelin contracts installed and remapped | OpenZeppelin 合约已安装并重映射
- [ ] PositionVault contract implements all functions | PositionVault 合约实现所有函数
- [ ] Protector contract implements protection logic | Protector 合约实现保护逻辑
- [ ] DemoEscrow contract authorizes protector | DemoEscrow 合约授权 protector
- [ ] All contracts use ReentrancyGuard | 所有合约使用 ReentrancyGuard
- [ ] All contracts use Pausable pattern | 所有合约使用 Pausable 模式
- [ ] Health factor calculation uses 4 decimal precision | 健康系数计算使用 4 位小数精度
- [ ] Events defined for all state changes | 为所有状态变化定义事件
- [ ] MockERC20 and MockPriceFeed for testing | 测试用 MockERC20 与 MockPriceFeed
- [ ] PositionVault.t.sol covers all functions | PositionVault.t.sol 覆盖所有函数
- [ ] Protector.t.sol tests protection flow | Protector.t.sol 测试保护流程
- [ ] Integration.t.sol tests full create→protect flow | Integration.t.sol 测试完整创建→保护流程
- [ ] Gas snapshot baseline established | Gas 快照基线已建立
- [ ] Reentrancy tests pass | 重入测试通过
- [ ] Pausable tests pass | 暂停测试通过
- [ ] Deploy.s.sol deploys all contracts | Deploy.s.sol 部署所有合约
- [ ] Seed.s.sol creates demo positions | Seed.s.sol 创建演示头寸
- [ ] Contracts deployed to Base Sepolia | 合约已部署到 Base Sepolia
- [ ] Deployed addresses saved to JSON | 已部署地址保存到 JSON
- [ ] NatSpec documentation added to all contracts | 所有合约添加 NatSpec 文档
- [ ] Forge doc generated successfully | Forge doc 成功生成
- [ ] All tests pass with forge test | 所有测试通过 forge test
- [ ] Contract verification on BaseScan completed | BaseScan 合约验证完成

---

**End of E1 Contracts Tasks | E1 合约任务结束**
