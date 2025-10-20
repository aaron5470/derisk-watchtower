# Frontend Manual Protection Implementation Guide

**[中]** 前端手动保护实施指南

**[EN]** Frontend Manual Protection Implementation Guide

---

## Overview / 概述

**[中]** 本文档提供前端手动保护功能的实施指南，包括 React 组件与自定义钩子的实现代码。

**[EN]** This document provides implementation guide for frontend manual protection features, including React components and custom hooks.

**Note**: The frontend directory is not yet created in this repository. This guide provides the implementation code that should be added when setting up the Next.js/React frontend.

---

## File Structure / 文件结构

```
frontend/
├── components/
│   └── positions/
│       └── ProtectButton.tsx          # Manual protection button component
├── hooks/
│   └── useProtect.ts                  # Custom hook for protection logic
└── lib/
    ├── abis/
    │   └── Protector.json             # Protector contract ABI
    └── constants.ts                    # Contract addresses and constants
```

---

## Implementation / 实施

### 1. ProtectButton Component (E3.7.2)

**File**: `frontend/components/positions/ProtectButton.tsx`

```typescript
'use client';

import { useState } from 'react';
import { toast } from 'sonner'; // or react-hot-toast
import { useProtect } from '@/hooks/useProtect';

interface ProtectButtonProps {
  positionId: string;
  disabled?: boolean;
  className?: string;
}

/**
 * ProtectButton Component
 *
 * Renders a button that allows users to manually trigger position protection
 * when Chainlink Automation is delayed or unavailable.
 *
 * @param positionId - The bytes32 position ID (0x-prefixed hex string)
 * @param disabled - Optional flag to disable the button
 * @param className - Optional CSS class names
 */
export function ProtectButton({
  positionId,
  disabled = false,
  className = ''
}: ProtectButtonProps) {
  const { protect, isProtecting } = useProtect(positionId);
  const [lastTxHash, setLastTxHash] = useState<string | null>(null);

  const handleProtect = async () => {
    try {
      const txHash = await protect();
      setLastTxHash(txHash);

      toast.success('Protection executed successfully!', {
        description: `Transaction: ${txHash.slice(0, 10)}...${txHash.slice(-8)}`,
        duration: 5000,
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';

      toast.error('Protection failed', {
        description: message,
        duration: 5000,
      });

      console.error('Protection error:', error);
    }
  };

  const isDisabled = disabled || isProtecting;

  return (
    <div className="flex flex-col gap-2">
      <button
        onClick={handleProtect}
        disabled={isDisabled}
        className={`
          px-4 py-2 rounded-md font-medium transition-colors
          ${isDisabled
            ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
            : 'bg-blue-600 hover:bg-blue-700 text-white'
          }
          ${className}
        `}
      >
        {isProtecting ? (
          <span className="flex items-center gap-2">
            <svg
              className="animate-spin h-4 w-4"
              viewBox="0 0 24 24"
              fill="none"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
              />
            </svg>
            Protecting...
          </span>
        ) : (
          'Protect Position'
        )}
      </button>

      {lastTxHash && (
        <a
          href={`https://sepolia.basescan.org/tx/${lastTxHash}`}
          target="_blank"
          rel="noopener noreferrer"
          className="text-xs text-blue-600 hover:underline text-center"
        >
          View transaction ↗
        </a>
      )}
    </div>
  );
}
```

---

### 2. useProtect Hook

**File**: `frontend/hooks/useProtect.ts`

```typescript
import { useState } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseUnits } from 'viem';
import { PROTECTOR_ABI } from '@/lib/abis/Protector';
import { PROTECTOR_ADDRESS } from '@/lib/constants';

/**
 * Custom hook for manual position protection
 *
 * Provides two implementation options:
 * 1. Backend API approach (recommended for production)
 * 2. Direct contract call approach (wagmi)
 */

// ===== OPTION 1: Backend API Approach =====
// Recommended for production - backend controls private key

export function useProtect(positionId: string) {
  const [isProtecting, setIsProtecting] = useState(false);

  const protect = async (): Promise<string> => {
    setIsProtecting(true);

    try {
      const response = await fetch('/api/protection/manual', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ position_id: positionId }),
      });

      if (!response.ok) {
        const error = await response.text();
        throw new Error(error);
      }

      const data = await response.json();
      return data.tx_hash;
    } catch (error) {
      throw error;
    } finally {
      setIsProtecting(false);
    }
  };

  return { protect, isProtecting };
}

// ===== OPTION 2: Direct Contract Call Approach (wagmi) =====
// Faster for demo, but requires user wallet to sign transactions

/*
export function useProtect(positionId: string) {
  const { writeContractAsync } = useWriteContract();
  const [isProtecting, setIsProtecting] = useState(false);

  const protect = async (): Promise<string> => {
    setIsProtecting(true);

    try {
      // Calculate collateral needed (simplified - should fetch from contract)
      // In production, call Protector.calculateCollateralNeeded() first
      const collateralAmount = parseUnits('100', 18); // Example: 100 tokens

      // Get current prices from Chainlink price feeds
      // This is a simplified example - in production, fetch from price feed contracts
      const collateralPrice = parseUnits('2000', 8); // $2000 (8 decimals)
      const debtPrice = parseUnits('1000', 8); // $1000 (8 decimals)

      const hash = await writeContractAsync({
        address: PROTECTOR_ADDRESS,
        abi: PROTECTOR_ABI,
        functionName: 'protect',
        args: [positionId, collateralAmount, collateralPrice, debtPrice],
      });

      return hash;
    } catch (error) {
      throw error;
    } finally {
      setIsProtecting(false);
    }
  };

  return { protect, isProtecting };
}
*/
```

---

### 3. Contract Constants

**File**: `frontend/lib/constants.ts`

```typescript
export const PROTECTOR_ADDRESS = process.env.NEXT_PUBLIC_PROTECTOR_ADDRESS as `0x${string}`;

export const CHAIN_ID = parseInt(process.env.NEXT_PUBLIC_CHAIN_ID || '84532'); // Base Sepolia

export const BASE_SEPOLIA_RPC = process.env.NEXT_PUBLIC_BASE_SEPOLIA_RPC || 'https://sepolia.base.org';
```

---

### 4. Protector ABI

**File**: `frontend/lib/abis/Protector.json`

```json
{
  "abi": [
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "positionId",
          "type": "bytes32"
        },
        {
          "internalType": "uint256",
          "name": "collateralToAdd",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "collateralPrice",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "debtPrice",
          "type": "uint256"
        }
      ],
      "name": "protect",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "newHF",
          "type": "uint256"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ]
}
```

**Note**: This is a simplified ABI showing only the `protect()` function.
Generate the full ABI using:

```bash
cd contracts
forge build
# ABI will be in out/Protector.sol/Protector.json
```

---

## Usage Example / 使用示例

```typescript
// In a position card component
import { ProtectButton } from '@/components/positions/ProtectButton';

export function PositionCard({ position }) {
  const isAtRisk = position.healthFactor <= 1.3;

  return (
    <div className="card">
      <h3>Position {position.id.slice(0, 8)}...</h3>
      <p>Health Factor: {position.healthFactor.toFixed(2)}</p>

      {isAtRisk && (
        <div className="mt-4">
          <ProtectButton
            positionId={position.id}
            disabled={!isAtRisk}
          />
        </div>
      )}
    </div>
  );
}
```

---

## Environment Variables / 环境变量

**File**: `frontend/.env.local`

```bash
# Protector Contract
NEXT_PUBLIC_PROTECTOR_ADDRESS=0x_REPLACE_WITH_DEPLOYED_ADDRESS

# Network Configuration
NEXT_PUBLIC_CHAIN_ID=84532
NEXT_PUBLIC_BASE_SEPOLIA_RPC=https://sepolia.base.org

# Backend API (if using Option 1)
NEXT_PUBLIC_API_URL=http://localhost:8080
```

---

## Dependencies / 依赖项

**Required npm packages / 必需的 npm 包**:

```bash
npm install wagmi viem sonner
# or
yarn add wagmi viem sonner
# or
pnpm add wagmi viem sonner
```

**Package Versions / 包版本**:
- `wagmi`: ^2.x
- `viem`: ^2.x
- `sonner`: ^1.x (toast notifications)

---

## Testing / 测试

### Manual Testing Steps / 手动测试步骤

**[中]** 测试步骤：
1. 部署 Protector 合约到 Base Sepolia
2. 在 `.env.local` 中设置 `NEXT_PUBLIC_PROTECTOR_ADDRESS`
3. 创建测试头寸（HF < 1.3）
4. 在 UI 中点击 "Protect Position" 按钮
5. 确认钱包中的交易
6. 验证交易哈希返回
7. 检查 BaseScan 上的交易状态
8. 验证头寸 HF 已改善

**[EN]** Testing steps:
1. Deploy Protector contract to Base Sepolia
2. Set `NEXT_PUBLIC_PROTECTOR_ADDRESS` in `.env.local`
3. Create test position with HF < 1.3
4. Click "Protect Position" button in UI
5. Confirm transaction in wallet
6. Verify transaction hash is returned
7. Check transaction status on BaseScan
8. Verify position HF has improved

---

## Implementation Checklist / 实施清单

- [ ] Create Next.js frontend project
- [ ] Install dependencies (wagmi, viem, sonner)
- [ ] Add ProtectButton component
- [ ] Add useProtect hook
- [ ] Configure environment variables
- [ ] Generate Protector ABI from contracts
- [ ] Test on Base Sepolia testnet
- [ ] Add error handling and loading states
- [ ] Add transaction confirmation waiting
- [ ] Add success/error toast notifications

---

## Notes / 注意事项

**[中]**
- 前端目录尚未在此仓库中创建
- 上述代码应在设置 Next.js 前端时添加
- 推荐使用 Option 1（后端 API）以提高安全性
- Option 2（直接合约调用）更适合演示和快速原型

**[EN]**
- Frontend directory not yet created in this repository
- Code above should be added when setting up Next.js frontend
- Option 1 (Backend API) recommended for better security
- Option 2 (Direct contract call) better for demos and rapid prototyping

---

**Document Version**: 1.0
**Last Updated**: 2025-10-19
**Related**: E3.7 Fallback Manual Protection
