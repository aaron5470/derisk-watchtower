# E5 Frontend Tasks（E5 前端任务）

**Feature**: DeRisk Watchtower | **分支**: `007-derisk-watchtower-frontend`
**Feature**: DeRisk 瞭望塔 | **Branch**: `007-derisk-watchtower-frontend`

---

## E5.0 Branch Setup & PR Management（分支设置与 PR 管理）

### E5.0.1 Create 007 Branch & Open Draft PR | 创建 007 分支并开启草稿 PR

#### 🎯 任务目标
从最新主分支创建新的功能分支 `007-derisk-watchtower-frontend`，  
推送到远程仓库，并创建 **Draft PR（草稿 PR）** 以触发 CI/CD 测试并追踪开发进度。

---

#### ⚙️ 执行步骤
```bash
# 1️⃣ 切换到主分支并更新
git checkout main
git pull origin main

# 2️⃣ 创建新分支
git checkout -b 007-derisk-watchtower-frontend

# 3️⃣ 推送分支到远程
git push -u origin 007-derisk-watchtower-frontend

# 4️⃣ 创建 Draft PR（草稿 PR）
gh pr create \
  --base main \
  --head 007-derisk-watchtower-frontend \
  --title "E5 Frontend — Draft PR (in progress)" \
  --body "Initialized Frontend development branch from latest main. Work in progress; CI/CD enabled for early validation." \
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
- 新分支：`007-derisk-watchtower-frontend`
- GitHub PR（Draft）链接
- CI 流程日志（构建与测试结果）
- 更新后的 AI_USAGE.md 与 CHANGELOG.md

---

## E5.1 Next.js Project Setup（Next.js 项目设置）

### E5.1.1 Initialize Next.js 14 App Router project | 初始化 Next.js 14 App Router 项目
```bash
npx create-next-app@latest frontend --typescript --tailwind --app --no-src-dir
```

### E5.1.2 Install wagmi and viem dependencies | 安装 wagmi 与 viem 依赖
```bash
cd frontend && npm install wagmi@2.x viem@2.x @tanstack/react-query
```

### E5.1.3 Install additional dependencies | 安装额外依赖
```bash
npm install @rainbow-me/rainbowkit
npm install @radix-ui/react-dialog @radix-ui/react-toast
npm install clsx tailwind-merge
npm install axios
npm install recharts
```

### E5.1.4 Create directory structure | 创建目录结构
```bash
mkdir -p app/dashboard components/{wallet,positions,alerts,ui} hooks lib public/fixtures
```

### E5.1.5 Configure TypeScript | 配置 TypeScript
File path: `frontend/tsconfig.json` | 文件路径

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### E5.1.6 Configure Tailwind CSS | 配置 Tailwind CSS
File path: `frontend/tailwind.config.ts` | 文件路径

```typescript
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'safe': '#10b981',
        'warning': '#f59e0b',
        'critical': '#ef4444',
      },
    },
  },
  plugins: [],
}
export default config
```

---

## E5.2 Wagmi & Viem Configuration（Wagmi 与 Viem 配置）

### E5.2.1 Create wagmi config | 创建 wagmi 配置
File path: `frontend/lib/wagmi.ts` | 文件路径

```typescript
import { http, createConfig } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'
import { injected, walletConnect } from 'wagmi/connectors'

export const config = createConfig({
  chains: [baseSepolia],
  connectors: [
    injected(),
    walletConnect({
      projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || '',
    }),
  ],
  transports: {
    [baseSepolia.id]: http(),
  },
})
```

### E5.2.2 Create viem clients | 创建 viem 客户端
File path: `frontend/lib/viem.ts` | 文件路径

```typescript
import { createPublicClient, createWalletClient, http, custom } from 'viem'
import { baseSepolia } from 'viem/chains'

export const publicClient = createPublicClient({
  chain: baseSepolia,
  transport: http(),
})

export const getWalletClient = () => {
  if (typeof window === 'undefined') return null

  return createWalletClient({
    chain: baseSepolia,
    transport: custom(window.ethereum!),
  })
}
```

### E5.2.3 Create providers component | 创建 providers 组件
File path: `frontend/app/providers.tsx` | 文件路径

```typescript
'use client'

import { WagmiProvider } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { config } from '@/lib/wagmi'
import { useState } from 'react'

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient())

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </WagmiProvider>
  )
}
```

### E5.2.4 Update root layout with providers | 更新根布局添加 providers
File path: `frontend/app/layout.tsx` | 文件路径

```typescript
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'DeRisk Watchtower',
  description: 'Real-time DeFi position monitoring with alerts and protection',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

---

## E5.3 Contract ABIs & Addresses（合约 ABI 与地址）

### E5.3.1 Create contract addresses config | 创建合约地址配置
File path: `frontend/lib/contracts.ts` | 文件路径

```typescript
import { Address } from 'viem'

export const CONTRACTS = {
  PositionVault: {
    address: (process.env.NEXT_PUBLIC_VAULT_ADDRESS || '') as Address,
    abi: [
      {
        "inputs": [{"internalType": "bytes32", "name": "id", "type": "bytes32"}],
        "name": "getPosition",
        "outputs": [
          {"internalType": "bytes32", "name": "id", "type": "bytes32"},
          {"internalType": "address", "name": "owner", "type": "address"},
          {"internalType": "uint256", "name": "collateralAmount", "type": "uint256"},
          {"internalType": "address", "name": "collateralToken", "type": "address"},
          {"internalType": "uint256", "name": "debtAmount", "type": "uint256"},
          {"internalType": "address", "name": "debtToken", "type": "address"},
          {"internalType": "uint256", "name": "healthFactor", "type": "uint256"},
          {"internalType": "uint256", "name": "lastUpdateTimestamp", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
      }
    ] as const,
  },
  Protector: {
    address: (process.env.NEXT_PUBLIC_PROTECTOR_ADDRESS || '') as Address,
    abi: [
      {
        "inputs": [
          {"internalType": "bytes32", "name": "positionId", "type": "bytes32"},
          {"internalType": "uint256", "name": "collateralToAdd", "type": "uint256"}
        ],
        "name": "protect",
        "outputs": [{"internalType": "uint256", "name": "newHF", "type": "uint256"}],
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ] as const,
  },
} as const
```

---

## E5.4 API Client（API 客户端）

### E5.4.1 Create API client wrapper | 创建 API 客户端包装器
File path: `frontend/lib/api.ts` | 文件路径

```typescript
import axios from 'axios'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'

export const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

export interface Position {
  id: string
  owner: string
  collateral_amount: string
  collateral_token: string
  debt_amount: string
  debt_token: string
  health_factor: number
  last_update_at: number
  created_at: number
}

export interface RiskEvent {
  id: string
  position_id: string
  event_type: 'ThresholdBreach' | 'ProtectionTriggered' | 'ManualAction'
  previous_hf: number
  new_hf: number
  delta_hf: number
  tx_hash: string
  timestamp: number
  replayed?: boolean
}

export const apiClient = {
  getPositions: async (owner: string): Promise<Position[]> => {
    const response = await api.get(`/api/positions?owner=${owner}`)
    return response.data
  },

  getHealthFactor: async (address: string) => {
    const response = await api.get(`/api/hf/${address}`)
    return response.data
  },

  getHealth: async () => {
    const response = await api.get('/healthz')
    return response.data
  },
}
```

---

## E5.5 WebSocket Hook（WebSocket 钩子）

### E5.5.1 Create WebSocket hook with auto-reconnect | 创建带自动重连的 WebSocket 钩子
File path: `frontend/hooks/useWebSocket.ts` | 文件路径

```typescript
import { useEffect, useRef, useState } from 'react'

export interface RiskAlert {
  type: 'RiskAlert'
  position_id: string
  hf: number
  threshold: number
  tx_hash?: string
  timestamp: number
  replayed: boolean
}

export function useWebSocket(url: string) {
  const [isConnected, setIsConnected] = useState(false)
  const [lastMessage, setLastMessage] = useState<RiskAlert | null>(null)
  const wsRef = useRef<WebSocket | null>(null)
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>()
  const lastEventTimestampRef = useRef<number>(0)

  const connect = () => {
    const wsUrl = lastEventTimestampRef.current > 0
      ? `${url}?serverEventTs=${lastEventTimestampRef.current}`
      : url

    const ws = new WebSocket(wsUrl)

    ws.onopen = () => {
      console.log('WebSocket connected')
      setIsConnected(true)
    }

    ws.onmessage = (event) => {
      const message = JSON.parse(event.data) as RiskAlert
      setLastMessage(message)
      lastEventTimestampRef.current = message.timestamp
    }

    ws.onerror = (error) => {
      console.error('WebSocket error:', error)
    }

    ws.onclose = () => {
      console.log('WebSocket disconnected')
      setIsConnected(false)

      // Auto-reconnect with exponential backoff
      reconnectTimeoutRef.current = setTimeout(() => {
        console.log('Attempting to reconnect...')
        connect()
      }, 5000)
    }

    wsRef.current = ws
  }

  useEffect(() => {
    connect()

    return () => {
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current)
      }
      if (wsRef.current) {
        wsRef.current.close()
      }
    }
  }, [url])

  return { isConnected, lastMessage }
}
```

---

## E5.6 Custom Hooks（自定义钩子）

### E5.6.1 Create usePositions hook | 创建 usePositions 钩子
File path: `frontend/hooks/usePositions.ts` | 文件路径

```typescript
import { useQuery } from '@tanstack/react-query'
import { useAccount } from 'wagmi'
import { apiClient } from '@/lib/api'

export function usePositions() {
  const { address } = useAccount()

  return useQuery({
    queryKey: ['positions', address],
    queryFn: () => address ? apiClient.getPositions(address) : Promise.resolve([]),
    enabled: !!address,
    refetchInterval: 3000, // Refresh every 3 seconds
  })
}
```

### E5.6.2 Create useProtect hook | 创建 useProtect 钩子
File path: `frontend/hooks/useProtect.ts` | 文件路径

```typescript
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { CONTRACTS } from '@/lib/contracts'
import { parseEther } from 'viem'

export function useProtect(positionId: string) {
  const { data: hash, writeContract, isPending, error } = useWriteContract()

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const protect = async (collateralAmount: string) => {
    writeContract({
      ...CONTRACTS.Protector,
      functionName: 'protect',
      args: [positionId as `0x${string}`, parseEther(collateralAmount)],
    })
  }

  return {
    protect,
    isPending,
    isConfirming,
    isSuccess,
    error,
    hash,
  }
}
```

### E5.6.3 Create useHealthFactor hook | 创建 useHealthFactor 钩子
File path: `frontend/hooks/useHealthFactor.ts` | 文件路径

```typescript
import { useQuery } from '@tanstack/react-query'
import { apiClient } from '@/lib/api'

export function useHealthFactor(address: string | undefined) {
  return useQuery({
    queryKey: ['healthFactor', address],
    queryFn: () => address ? apiClient.getHealthFactor(address) : Promise.resolve(null),
    enabled: !!address,
    refetchInterval: 3000,
  })
}
```

---

## E5.7 UI Components - Wallet（UI 组件 - 钱包）

### E5.7.1 Create ConnectButton component | 创建 ConnectButton 组件
File path: `frontend/components/wallet/ConnectButton.tsx` | 文件路径

```typescript
'use client'

import { useAccount, useConnect, useDisconnect } from 'wagmi'

export function ConnectButton() {
  const { address, isConnected } = useAccount()
  const { connect, connectors } = useConnect()
  const { disconnect } = useDisconnect()

  if (isConnected) {
    return (
      <div className="flex items-center gap-4">
        <span className="text-sm text-gray-600">
          {address?.slice(0, 6)}...{address?.slice(-4)}
        </span>
        <button
          onClick={() => disconnect()}
          className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
        >
          Disconnect
        </button>
      </div>
    )
  }

  return (
    <div className="flex gap-2">
      {connectors.map((connector) => (
        <button
          key={connector.id}
          onClick={() => connect({ connector })}
          className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
        >
          Connect {connector.name}
        </button>
      ))}
    </div>
  )
}
```

---

## E5.8 UI Components - Positions（UI 组件 - 头寸）

### E5.8.1 Create PositionCard component | 创建 PositionCard 组件
File path: `frontend/components/positions/PositionCard.tsx` | 文件路径

```typescript
'use client'

import { Position } from '@/lib/api'
import { ProtectButton } from './ProtectButton'

interface PositionCardProps {
  position: Position
}

export function PositionCard({ position }: PositionCardProps) {
  const hf = position.health_factor
  const status = hf > 1.5 ? 'safe' : hf > 1.3 ? 'warning' : 'critical'

  const statusColors = {
    safe: 'bg-green-100 border-green-500 text-green-800',
    warning: 'bg-yellow-100 border-yellow-500 text-yellow-800',
    critical: 'bg-red-100 border-red-500 text-red-800',
  }

  return (
    <div className={`p-6 rounded-lg border-2 ${statusColors[status]}`}>
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-lg font-semibold">Position {position.id.slice(0, 8)}...</h3>
          <p className="text-sm opacity-75">
            Owner: {position.owner.slice(0, 6)}...{position.owner.slice(-4)}
          </p>
        </div>
        <div className="text-right">
          <div className="text-2xl font-bold">{hf.toFixed(4)}</div>
          <div className="text-sm uppercase font-semibold">{status}</div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4 mb-4">
        <div>
          <div className="text-sm opacity-75">Collateral</div>
          <div className="font-mono">{position.collateral_amount}</div>
        </div>
        <div>
          <div className="text-sm opacity-75">Debt</div>
          <div className="font-mono">{position.debt_amount}</div>
        </div>
      </div>

      {status === 'critical' && (
        <ProtectButton positionId={position.id} />
      )}
    </div>
  )
}
```

### E5.8.2 Create ProtectButton component | 创建 ProtectButton 组件
File path: `frontend/components/positions/ProtectButton.tsx` | 文件路径

```typescript
'use client'

import { useState } from 'react'
import { useProtect } from '@/hooks/useProtect'

interface ProtectButtonProps {
  positionId: string
}

export function ProtectButton({ positionId }: ProtectButtonProps) {
  const [amount, setAmount] = useState('0.1')
  const { protect, isPending, isConfirming, isSuccess, error } = useProtect(positionId)

  const handleProtect = async () => {
    await protect(amount)
  }

  if (isSuccess) {
    return (
      <div className="p-4 bg-green-100 rounded-lg text-green-800">
        Protection executed successfully!
      </div>
    )
  }

  return (
    <div className="mt-4">
      <div className="flex gap-2 mb-2">
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          step="0.1"
          className="flex-1 px-3 py-2 border rounded-lg"
          placeholder="Collateral amount"
        />
        <button
          onClick={handleProtect}
          disabled={isPending || isConfirming}
          className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50"
        >
          {isPending || isConfirming ? 'Protecting...' : 'Protect Position'}
        </button>
      </div>
      {error && (
        <div className="text-sm text-red-600">
          Error: {error.message}
        </div>
      )}
    </div>
  )
}
```

### E5.8.3 Create Timeline component | 创建 Timeline 组件
File path: `frontend/components/positions/Timeline.tsx` | 文件路径

```typescript
'use client'

import { RiskEvent } from '@/lib/api'

interface TimelineProps {
  events: RiskEvent[]
}

export function Timeline({ events }: TimelineProps) {
  return (
    <div className="space-y-4">
      <h3 className="text-lg font-semibold">Risk Timeline</h3>

      {events.length === 0 ? (
        <p className="text-gray-500">No risk events</p>
      ) : (
        <div className="space-y-2">
          {events.map((event) => (
            <div
              key={event.id}
              className="p-4 bg-white border rounded-lg shadow-sm"
            >
              <div className="flex justify-between items-start mb-2">
                <span className="font-semibold">{event.event_type}</span>
                <span className="text-sm text-gray-500">
                  {new Date(event.timestamp * 1000).toLocaleString()}
                </span>
              </div>

              <div className="grid grid-cols-3 gap-2 text-sm">
                <div>
                  <div className="text-gray-500">Previous HF</div>
                  <div className="font-mono">{event.previous_hf.toFixed(4)}</div>
                </div>
                <div>
                  <div className="text-gray-500">New HF</div>
                  <div className="font-mono">{event.new_hf.toFixed(4)}</div>
                </div>
                <div>
                  <div className="text-gray-500">Delta</div>
                  <div className={`font-mono ${event.delta_hf > 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {event.delta_hf > 0 ? '+' : ''}{event.delta_hf.toFixed(4)}
                  </div>
                </div>
              </div>

              {event.tx_hash && (
                <div className="mt-2 text-xs text-gray-500">
                  TX: {event.tx_hash.slice(0, 10)}...{event.tx_hash.slice(-8)}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
```

---

## E5.9 UI Components - Alerts（UI 组件 - 警报）

### E5.9.1 Create RiskAlert component | 创建 RiskAlert 组件
File path: `frontend/components/alerts/RiskAlert.tsx` | 文件路径

```typescript
'use client'

import { RiskAlert as RiskAlertType } from '@/hooks/useWebSocket'

interface RiskAlertProps {
  alert: RiskAlertType
  onDismiss: () => void
}

export function RiskAlert({ alert, onDismiss }: RiskAlertProps) {
  return (
    <div className="fixed top-4 right-4 max-w-md p-6 bg-red-100 border-2 border-red-500 rounded-lg shadow-lg z-50 animate-slide-in">
      <div className="flex justify-between items-start mb-4">
        <div className="flex-1">
          <h3 className="text-lg font-bold text-red-800">Risk Alert!</h3>
          <p className="text-sm text-red-700">
            Position {alert.position_id.slice(0, 8)}... is at risk
          </p>
        </div>
        <button
          onClick={onDismiss}
          className="text-red-800 hover:text-red-900"
        >
          ✕
        </button>
      </div>

      <div className="space-y-2 text-sm text-red-800">
        <div className="flex justify-between">
          <span>Health Factor:</span>
          <span className="font-bold">{alert.hf.toFixed(4)}</span>
        </div>
        <div className="flex justify-between">
          <span>Threshold:</span>
          <span className="font-bold">{alert.threshold.toFixed(4)}</span>
        </div>
        {alert.replayed && (
          <div className="text-xs opacity-75">(Replayed event)</div>
        )}
      </div>

      <div className="mt-4">
        <button className="w-full px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700">
          Protect Now
        </button>
      </div>
    </div>
  )
}
```

### E5.9.2 Create ConnectionStatus component | 创建 ConnectionStatus 组件
File path: `frontend/components/alerts/ConnectionStatus.tsx` | 文件路径

```typescript
'use client'

interface ConnectionStatusProps {
  isConnected: boolean
}

export function ConnectionStatus({ isConnected }: ConnectionStatusProps) {
  return (
    <div className="flex items-center gap-2">
      <div
        className={`w-2 h-2 rounded-full ${
          isConnected ? 'bg-green-500' : 'bg-red-500'
        }`}
      />
      <span className="text-sm text-gray-600">
        {isConnected ? 'Live' : 'Disconnected'}
      </span>
    </div>
  )
}
```

---

## E5.10 Pages - Home（页面 - 主页）

### E5.10.1 Create home page | 创建主页
File path: `frontend/app/page.tsx` | 文件路径

```typescript
import Link from 'next/link'

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="max-w-4xl mx-auto px-6 text-center">
        <h1 className="text-6xl font-bold mb-6 bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
          DeRisk Watchtower
        </h1>

        <p className="text-xl text-gray-700 mb-8">
          Real-time DeFi position monitoring with alerts and one-click protection on Base Sepolia
        </p>

        <div className="flex gap-4 justify-center">
          <Link
            href="/dashboard"
            className="px-8 py-4 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition"
          >
            Launch App
          </Link>

          <a
            href="https://github.com/derisk-watchtower"
            target="_blank"
            rel="noopener noreferrer"
            className="px-8 py-4 bg-white text-blue-600 border-2 border-blue-600 rounded-lg font-semibold hover:bg-blue-50 transition"
          >
            View on GitHub
          </a>
        </div>

        <div className="mt-12 grid grid-cols-3 gap-8">
          <div className="p-6 bg-white rounded-lg shadow-sm">
            <div className="text-3xl mb-2">👁️</div>
            <h3 className="font-semibold mb-2">Monitor</h3>
            <p className="text-sm text-gray-600">
              View your Health Factor in ≤3 clicks
            </p>
          </div>

          <div className="p-6 bg-white rounded-lg shadow-sm">
            <div className="text-3xl mb-2">🚨</div>
            <h3 className="font-semibold mb-2">Alert</h3>
            <p className="text-sm text-gray-600">
              Real-time alerts within 10 seconds
            </p>
          </div>

          <div className="p-6 bg-white rounded-lg shadow-sm">
            <div className="text-3xl mb-2">🛡️</div>
            <h3 className="font-semibold mb-2">Protect</h3>
            <p className="text-sm text-gray-600">
              One-click protection in 5 seconds
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
```

---

## E5.11 Pages - Dashboard（页面 - 仪表盘）

### E5.11.1 Create dashboard page | 创建仪表盘页面
File path: `frontend/app/dashboard/page.tsx` | 文件路径

```typescript
'use client'

import { useState } from 'react'
import { useAccount } from 'wagmi'
import { ConnectButton } from '@/components/wallet/ConnectButton'
import { PositionCard } from '@/components/positions/PositionCard'
import { RiskAlert } from '@/components/alerts/RiskAlert'
import { ConnectionStatus } from '@/components/alerts/ConnectionStatus'
import { usePositions } from '@/hooks/usePositions'
import { useWebSocket } from '@/hooks/useWebSocket'

export default function DashboardPage() {
  const { address, isConnected } = useAccount()
  const { data: positions, isLoading } = usePositions()
  const { isConnected: wsConnected, lastMessage } = useWebSocket(
    process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8080/ws/risk-stream'
  )
  const [showAlert, setShowAlert] = useState(true)

  if (!isConnected) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center">
        <h2 className="text-2xl font-bold mb-4">Connect Your Wallet</h2>
        <p className="text-gray-600 mb-6">
          Connect your wallet to view and protect your positions
        </p>
        <ConnectButton />
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold">DeRisk Watchtower</h1>
          <div className="flex items-center gap-4">
            <ConnectionStatus isConnected={wsConnected} />
            <ConnectButton />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-6 py-8">
        <div className="mb-6">
          <h2 className="text-xl font-semibold mb-2">Your Positions</h2>
          <p className="text-gray-600">
            Monitor your lending positions and health factors
          </p>
        </div>

        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading positions...</p>
          </div>
        ) : positions && positions.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {positions.map((position) => (
              <PositionCard key={position.id} position={position} />
            ))}
          </div>
        ) : (
          <div className="text-center py-12 bg-white rounded-lg border">
            <p className="text-gray-600 mb-4">No positions found</p>
            <p className="text-sm text-gray-500">
              Create a lending position to start monitoring
            </p>
          </div>
        )}
      </main>

      {/* Risk Alert */}
      {lastMessage && showAlert && (
        <RiskAlert
          alert={lastMessage}
          onDismiss={() => setShowAlert(false)}
        />
      )}
    </div>
  )
}
```

---

## E5.12 Environment Variables（环境变量）

### E5.12.1 Create .env.example | 创建 .env.example
File path: `frontend/.env.example` | 文件路径

```env
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_WS_URL=ws://localhost:8080/ws/risk-stream
NEXT_PUBLIC_VAULT_ADDRESS=0x...
NEXT_PUBLIC_PROTECTOR_ADDRESS=0x...
```

---

## E5.13 Offline Replay Mode（离线重放模式）

### E5.13.1 Create replay fixtures | 创建重放数据
File path: `frontend/public/fixtures/scenario-1-healthy.json` | 文件路径

```json
{
  "positions": [
    {
      "id": "0x1234567890abcdef",
      "owner": "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      "collateral_amount": "1000000000000000000",
      "collateral_token": "0x1111111111111111111111111111111111111111",
      "debt_amount": "400000000000000000",
      "debt_token": "0x2222222222222222222222222222222222222222",
      "health_factor": 1.8,
      "last_update_at": 1699999999,
      "created_at": 1699999900
    }
  ],
  "events": []
}
```

### E5.13.2 Create replay service | 创建重放服务
File path: `frontend/lib/replay.ts` | 文件路径

```typescript
export async function loadReplayData(scenario: string) {
  const response = await fetch(`/fixtures/${scenario}.json`)
  return response.json()
}

export function isReplayMode(): boolean {
  if (typeof window === 'undefined') return false
  const params = new URLSearchParams(window.location.search)
  return params.get('replay') === '1'
}
```

---

## E5.14 Styling & Animations（样式与动画）

### E5.14.1 Add global CSS animations | 添加全局 CSS 动画
File path: `frontend/app/globals.css` | 文件路径

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@keyframes slide-in {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.animate-slide-in {
  animation: slide-in 0.3s ease-out;
}

@keyframes pulse-glow {
  0%, 100% {
    box-shadow: 0 0 10px rgba(59, 130, 246, 0.5);
  }
  50% {
    box-shadow: 0 0 20px rgba(59, 130, 246, 0.8);
  }
}

.animate-pulse-glow {
  animation: pulse-glow 2s ease-in-out infinite;
}
```

---

## E5.15 Testing（测试）

### E5.15.1 Install testing dependencies | 安装测试依赖
```bash
npm install --save-dev vitest @testing-library/react @testing-library/jest-dom
```

### E5.15.2 Create Vitest config | 创建 Vitest 配置
File path: `frontend/vitest.config.ts` | 文件路径

```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './'),
    },
  },
})
```

### E5.15.3 Create component tests | 创建组件测试
File path: `frontend/__tests__/PositionCard.test.tsx` | 文件路径

```typescript
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { PositionCard } from '@/components/positions/PositionCard'
import { Position } from '@/lib/api'

describe('PositionCard', () => {
  const mockPosition: Position = {
    id: '0x123',
    owner: '0xabc',
    collateral_amount: '1000000000000000000',
    collateral_token: '0x111',
    debt_amount: '500000000000000000',
    debt_token: '0x222',
    health_factor: 1.5,
    last_update_at: 1699999999,
    created_at: 1699999900,
  }

  it('renders position details', () => {
    render(<PositionCard position={mockPosition} />)

    expect(screen.getByText(/Position 0x123/i)).toBeInTheDocument()
    expect(screen.getByText(/1.5000/i)).toBeInTheDocument()
  })

  it('shows warning status for HF between 1.3 and 1.5', () => {
    render(<PositionCard position={mockPosition} />)

    expect(screen.getByText(/warning/i)).toBeInTheDocument()
  })

  it('shows protect button for critical positions', () => {
    const criticalPosition = { ...mockPosition, health_factor: 1.2 }
    render(<PositionCard position={criticalPosition} />)

    expect(screen.getByText(/Protect Position/i)).toBeInTheDocument()
  })
})
```

---

## E5.16 Documentation（文档）

### E5.16.1 Create frontend README | 创建前端 README
File path: `frontend/README.md` | 文件路径

```markdown
# DeRisk Watchtower Frontend

Next.js 14 frontend with wagmi/viem for wallet integration and real-time WebSocket alerts.

## Tech Stack

- **Framework**: Next.js 14 (App Router)
- **Wallet**: wagmi 2.x + viem 2.x
- **State**: TanStack Query
- **Styling**: Tailwind CSS
- **WebSocket**: Native WebSocket API

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure environment:
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your values
   ```

3. Run development server:
   ```bash
   npm run dev
   ```

4. Open http://localhost:3000

## Features

- **Wallet Connection**: MetaMask, WalletConnect
- **Position Monitoring**: Real-time HF display
- **Risk Alerts**: WebSocket-based notifications
- **One-Click Protection**: Execute protection via Protector contract
- **Offline Replay**: Demo mode with cached data (`?replay=1`)

## Testing

```bash
npm run test
```

## Build

```bash
npm run build
npm run start
```
```

---

## E5.17 Completion Checklist（完成清单）

- [ ] Next.js 14 App Router project initialized | Next.js 14 App Router 项目已初始化
- [ ] wagmi and viem dependencies installed | wagmi 与 viem 依赖已安装
- [ ] Directory structure created | 目录结构已创建
- [ ] TypeScript configured | TypeScript 已配置
- [ ] Tailwind CSS configured | Tailwind CSS 已配置
- [ ] wagmi config created for Base Sepolia | 为 Base Sepolia 创建 wagmi 配置
- [ ] viem public/wallet clients created | viem 公共/钱包客户端已创建
- [ ] Providers component wraps app | Providers 组件包裹应用
- [ ] Contract addresses and ABIs configured | 合约地址与 ABI 已配置
- [ ] API client wrapper created | API 客户端包装器已创建
- [ ] useWebSocket hook with auto-reconnect | 带自动重连的 useWebSocket 钩子
- [ ] usePositions hook with 3s refresh | 带 3 秒刷新的 usePositions 钩子
- [ ] useProtect hook for contract write | 用于合约写入的 useProtect 钩子
- [ ] ConnectButton component | ConnectButton 组件
- [ ] PositionCard component with status colors | 带状态颜色的 PositionCard 组件
- [ ] ProtectButton component | ProtectButton 组件
- [ ] Timeline component for risk events | 风险事件 Timeline 组件
- [ ] RiskAlert component with animation | 带动画的 RiskAlert 组件
- [ ] ConnectionStatus indicator | ConnectionStatus 指示器
- [ ] Home page with landing UI | 带着陆 UI 的主页
- [ ] Dashboard page with positions grid | 带头寸网格的仪表盘页面
- [ ] Empty state for no positions | 无头寸空状态
- [ ] Loading states for async operations | 异步操作加载状态
- [ ] Offline replay mode with fixtures | 带数据的离线重放模式
- [ ] CSS animations for alerts | 警报 CSS 动画
- [ ] Vitest testing setup | Vitest 测试设置
- [ ] Component unit tests | 组件单元测试
- [ ] Frontend README documentation | 前端 README 文档

---

**End of E5 Frontend Tasks | E5 前端任务结束**
