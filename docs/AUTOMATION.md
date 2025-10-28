# Chainlink Automation Guide（Chainlink Automation 指南）

**[中]** 本文档介绍如何为 DeRisk Watchtower 配置与管理 Chainlink Automation。

**[EN]** This document explains how to configure and manage Chainlink Automation for DeRisk Watchtower.

---

## Table of Contents / 目录

1. [CRON Schedule Configuration](#cron-schedule-configuration--cron-调度配置)
2. [UI-Based Registration](#ui-based-registration--基于-ui-的注册)
3. [Script-Based Registration](#script-based-registration--基于脚本的注册)
4. [Monitoring Automation Health](#monitoring-automation-health--监控自动化健康状态)
5. [Manual Fallback](#manual-fallback--手动回退)
6. [Troubleshooting](#troubleshooting--故障排查)

---

## CRON Schedule Configuration / CRON 调度配置

### CRON Expression / CRON 表达式

**[中]** DeRisk Watchtower 使用以下 CRON 调度表达式：

**[EN]** DeRisk Watchtower uses the following CRON schedule expression:

```
0 */5 * * * *
```

**Frequency / 频率**: Every 5 minutes / 每 5 分钟

**Format / 格式**:
```
┌───────────── second (0 - 59)
│ ┌───────────── minute (0 - 59)
│ │ ┌───────────── hour (0 - 23)
│ │ │ ┌───────────── day of month (1 - 31)
│ │ │ │ ┌───────────── month (1 - 12)
│ │ │ │ │ ┌───────────── day of week (0 - 6)
│ │ │ │ │ │
0 */5 * * * *
```

**Explanation / 说明**:
- **[中]** `0`: 每分钟的第 0 秒
- **[EN]** `0`: At the 0th second of every minute
- **[中]** `*/5`: 每 5 分钟
- **[EN]** `*/5`: Every 5 minutes
- **[中]** `* * * *`: 每小时、每天、每月、每周的每一天
- **[EN]** `* * * *`: Every hour, day, month, and day of week

### Why Every 5 Minutes? / 为何每 5 分钟？

**[中]**
- 足够频繁以检测价格波动导致的 HF 下降
- 不会过于频繁以避免不必要的 gas 费用
- 符合 DeFi 协议的标准监控间隔

**[EN]**
- Frequent enough to detect HF drops due to price volatility
- Not too frequent to avoid unnecessary gas costs
- Aligns with standard monitoring intervals for DeFi protocols

---

## UI-Based Registration / 基于 UI 的注册

**[中]** 推荐方法：通过 Chainlink Automation 网页界面注册 Upkeep

**[EN]** Recommended method: Register Upkeep via Chainlink Automation web interface

### Step 1: Navigate to Chainlink Automation Dashboard

**[中]** 访问 Chainlink Automation 仪表盘

**[EN]** Visit Chainlink Automation Dashboard

**URL**: https://automation.chain.link

### Step 2: Connect Wallet / 连接钱包

**[中]**
1. 点击 "Connect Wallet" 按钮
2. 选择 MetaMask 或其他兼容钱包
3. 切换到 **Base Sepolia** 网络

**[EN]**
1. Click "Connect Wallet" button
2. Select MetaMask or other compatible wallet
3. Switch to **Base Sepolia** network

### Step 3: Create Time-Based Upkeep / 创建基于时间的 Upkeep

**[中]**
1. 点击 "Register New Upkeep"
2. 选择 "Time-based" 触发类型（而非 "Custom logic"）
3. 进入配置页面

**[EN]**
1. Click "Register New Upkeep"
2. Select "Time-based" trigger type (not "Custom logic")
3. Proceed to configuration page

### Step 4: Configure Upkeep Parameters / 配置 Upkeep 参数

**[中]** 填写以下配置：

**[EN]** Fill in the following configuration:

| Parameter | Value | Description |
| 参数 | 值 | 描述 |
|-----------|-------|-------------|
| **Name** | DeRisk Watchtower Protection | Upkeep 名称 |
| **CRON Expression** | `0 */5 * * * *` | 每 5 分钟触发 |
| **Target Contract** | `0x...` (Protector Address) | 目标合约地址 |
| **Gas Limit** | `500,000` | Gas 限制 |
| **Check Data** | Encoded position IDs | 编码的头寸 ID（见下文）|

#### Preparing Check Data / 准备 Check Data

**[中]** Check Data 是 ABI 编码的头寸 ID 数组。您可以：

**[EN]** Check Data is ABI-encoded array of position IDs. You can:

**Option 1: Use RegisterUpkeep Script / 选项 1：使用注册脚本**
```bash
# Script will output encoded checkData
forge script script/RegisterUpkeep.s.sol --rpc-url $BASE_SEPOLIA_RPC
```

**Option 2: Manual Encoding / 选项 2：手动编码**
```javascript
// Using ethers.js
const ethers = require('ethers');
const positions = [
  "0x05160687fb252bb950f996cafae447c81269b909d6fb181b0fb7b293bec00aed",
  "0x15160687fb252bb950f996cafae447c81269b909d6fb181b0fb7b293bec00aed"
];
const checkData = ethers.utils.defaultAbiCoder.encode(
  ["bytes32[]"],
  [positions]
);
console.log(checkData);
```

### Step 5: Fund with LINK / 使用 LINK 充值

**[中]**
- **最低金额**: 5 LINK
- **推荐金额**: 10 LINK（用于长期监控）
- 确保您的钱包在 Base Sepolia 网络上有足够的 LINK

**[EN]**
- **Minimum**: 5 LINK
- **Recommended**: 10 LINK (for extended monitoring)
- Ensure your wallet has sufficient LINK on Base Sepolia network

**Get Base Sepolia LINK**:
- Faucet: https://faucets.chain.link/base-sepolia
- LINK Token Address: `0xE4aB69C077896252FAFBD49EFD26B5D171A32410`

### Step 6: Confirm Registration / 确认注册

**[中]**
1. 审查所有配置参数
2. 点击 "Register Upkeep"
3. 在钱包中确认交易
4. **保存 Upkeep ID**（用于监控）

**[EN]**
1. Review all configuration parameters
2. Click "Register Upkeep"
3. Confirm transaction in wallet
4. **Save the Upkeep ID** (for monitoring)

---

## Script-Based Registration / 基于脚本的注册

**[中]** 替代方法：使用 Foundry 脚本注册 Upkeep

**[EN]** Alternative method: Register Upkeep using Foundry script

### Prerequisites / 前提条件

**[中]** 在 `.env` 文件中设置以下环境变量：

**[EN]** Set the following environment variables in `.env`:

```bash
DEPLOYER_PRIVATE_KEY=0x...
PROTECTOR_ADDRESS=0x...
LINK_TOKEN_BASE_SEPOLIA=0xE4aB69C077896252FAFBD49EFD26B5D171A32410
AUTOMATION_REGISTRAR_BASE_SEPOLIA=0x... # Get from Chainlink docs
```

### Execute Registration Script / 执行注册脚本

**Dry Run (Simulation) / 模拟运行**:
```bash
# [中] 不广播交易，仅模拟
# [EN] No transaction broadcast, simulation only
forge script script/RegisterUpkeep.s.sol --rpc-url $BASE_SEPOLIA_RPC
```

**Actual Registration / 实际注册**:
```bash
# [中] 实际注册 Upkeep（需要 LINK 余额）
# [EN] Actually register Upkeep (requires LINK balance)
forge script script/RegisterUpkeep.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast
```

---

## Monitoring Automation Health / 监控自动化健康状态

### Chainlink Dashboard / Chainlink 仪表盘

**[中]** 访问您的 Upkeep 详情页面：

**[EN]** Visit your Upkeep details page:

**URL**: `https://automation.chain.link/base-sepolia/[UPKEEP_ID]`

**Metrics to Monitor / 监控指标**:

| Metric | Description | Warning Threshold |
| 指标 | 描述 | 警告阈值 |
|--------|-------------|-------------------|
| **Total Upkeep Triggers** | 总触发次数 | - |
| **Last Trigger Timestamp** | 上次触发时间 | > 10 minutes ago |
| **Remaining LINK Balance** | 剩余 LINK 余额 | < 1 LINK |
| **Failed Execution Count** | 失败执行次数 | > 3 in 24h |
| **Average Gas Used** | 平均 Gas 使用量 | > 450,000 |

### Backend API Monitoring / 后端 API 监控

**[中]** DeRisk Watchtower 后端提供自动化健康状态 API：

**[EN]** DeRisk Watchtower backend provides automation health status API:

**Endpoint**: `GET /api/automation/status`

**Response**:
```json
{
  "total_triggers": 1234,
  "last_trigger_at": 1697856000,
  "delay_seconds": 120,
  "is_healthy": true
}
```

**Health Criteria / 健康标准**:
- **[中]** `delay_seconds < 600`（10 分钟）
- **[EN]** `delay_seconds < 600` (10 minutes)

### Prometheus Metrics / Prometheus 指标

**[中]** 后端导出以下 Prometheus 指标：

**[EN]** Backend exports the following Prometheus metrics:

- `automation_delay_seconds`: Seconds since last automation trigger
- `automation_triggers_total`: Total number of automation triggers
- `automation_healthy`: 1 if healthy (delay < 10min), 0 otherwise

---

## Manual Fallback / 手动回退

**[中]** 当 Chainlink Automation 延迟或失败时，使用手动触发脚本。

**[EN]** Use manual trigger script when Chainlink Automation is delayed or failed.

### TriggerUpkeep Script / 手动触发脚本

**File**: `contracts/script/TriggerUpkeep.s.sol`

**Execute Manual Trigger / 执行手动触发**:
```bash
# [中] 检查并手动触发 Upkeep（如需要）
# [EN] Check and manually trigger Upkeep (if needed)
forge script script/TriggerUpkeep.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast
```

**Output Example / 输出示例**:
```
Checking 3 positions...
Upkeep needed, executing performUpkeep...
Upkeep performed successfully
Position protected: 0x05160687...
```

### When to Use Manual Fallback? / 何时使用手动回退？

**[中]** 在以下情况下使用手动触发：

**[EN]** Use manual trigger in the following scenarios:

1. **Automation Delay / 自动化延迟**
   - Chainlink Automation 未在 10 分钟内触发
   - Chainlink Automation hasn't triggered in 10 minutes

2. **Critical Position / 严重头寸**
   - HF < 1.1（接近清算）
   - HF < 1.1 (near liquidation)

3. **Testing / 测试**
   - 验证保护逻辑正常工作
   - Verify protection logic works correctly

---

## Troubleshooting / 故障排查

### Issue 1: Upkeep Not Triggering / Upkeep 未触发

**[中] 可能原因**:
1. LINK 余额不足
2. CRON 表达式语法错误
3. Protector 合约已暂停
4. `checkUpkeep()` 返回 false（无头寸需要保护）

**[中] 解决方案**:
1. 检查 LINK 余额 > 0
2. 验证 CRON 表达式：`0 */5 * * * *`
3. 确认合约未暂停
4. 手动调用 `checkUpkeep()` 验证逻辑

**[EN] Possible Causes**:
1. Insufficient LINK balance
2. CRON expression syntax error
3. Protector contract is paused
4. `checkUpkeep()` returns false (no positions need protection)

**[EN] Solutions**:
1. Check LINK balance > 0
2. Verify CRON expression: `0 */5 * * * *`
3. Confirm contract is not paused
4. Manually call `checkUpkeep()` to verify logic

---

### Issue 2: Execution Reverts / 执行回滚

**[中] 可能原因**:
1. Gas limit 不足（< 500,000）
2. DemoEscrow 无足够抵押品
3. 头寸 ID 在 checkData 中无效
4. 价格预言机返回过期数据

**[中] 解决方案**:
1. 增加 gas limit 到 500,000
2. 检查 DemoEscrow 余额
3. 验证 checkData 中的头寸 ID
4. 确认价格预言机正常工作

**[EN] Possible Causes**:
1. Insufficient gas limit (< 500,000)
2. DemoEscrow lacks collateral tokens
3. Invalid position IDs in checkData
4. Price feed returns stale data

**[EN] Solutions**:
1. Increase gas limit to 500,000
2. Check DemoEscrow balance
3. Validate position IDs in checkData
4. Confirm price feeds are working

---

### Issue 3: High Gas Costs / Gas 费用过高

**[中] 可能原因**:
1. 监控过多头寸（checkData 太大）
2. `checkUpkeep` 逻辑复杂
3. 网络拥堵

**[中] 解决方案**:
1. 减少监控的头寸数量
2. 优化 `checkUpkeep` 逻辑（添加 early return）
3. 调整 CRON 频率（如每 10 分钟而非 5 分钟）

**[EN] Possible Causes**:
1. Monitoring too many positions (checkData too large)
2. Complex `checkUpkeep` logic
3. Network congestion

**[EN] Solutions**:
1. Reduce number of monitored positions
2. Optimize `checkUpkeep` logic (add early returns)
3. Adjust CRON frequency (e.g., every 10 min instead of 5 min)

---

### Issue 4: Automation Delay > 10 Minutes / 自动化延迟 > 10 分钟

**[中] 可能原因**:
1. Chainlink Keeper 网络拥堵
2. Upkeep 未正确注册
3. LINK 余额已耗尽

**[中] 解决方案**:
1. 使用手动触发脚本作为临时解决方案
2. 重新注册 Upkeep
3. 充值 LINK 余额

**[EN] Possible Causes**:
1. Chainlink Keeper network congestion
2. Upkeep not registered correctly
3. LINK balance depleted

**[EN] Solutions**:
1. Use manual trigger script as temporary solution
2. Re-register Upkeep
3. Top up LINK balance

---

## Useful Links / 有用链接

**[中]** 官方文档与资源

**[EN]** Official documentation and resources

- **Chainlink Automation Dashboard**: https://automation.chain.link
- **Chainlink Docs**: https://docs.chain.link/chainlink-automation
- **CRON Expression Reference**: https://crontab.guru
- **Base Sepolia Faucet**: https://faucets.chain.link/base-sepolia
- **LINK Token Contract**: `0xE4aB69C077896252FAFBD49EFD26B5D171A32410`

---

## Summary / 总结

**[中]**
- 使用 CRON 表达式 `0 */5 * * * *` 每 5 分钟检查头寸
- 通过 UI 或脚本注册 Upkeep
- 监控 Upkeep 健康状态（delay < 10 分钟）
- 使用 TriggerUpkeep 脚本作为手动回退
- 维护足够的 LINK 余额（推荐 > 5 LINK）

**[EN]**
- Use CRON expression `0 */5 * * * *` to check positions every 5 minutes
- Register Upkeep via UI or script
- Monitor Upkeep health (delay < 10 minutes)
- Use TriggerUpkeep script as manual fallback
- Maintain sufficient LINK balance (recommended > 5 LINK)

---

**Document Version**: 1.0
**Last Updated**: 2025-10-19
**Maintained By**: DeRisk Watchtower Team
