'use client'

import { Position } from '@/lib/api'
import { ProtectButton } from './ProtectButton'

interface PositionCardProps {
  position: Position
}

export function PositionCard({ position }: PositionCardProps) {
  const getHealthFactorStatus = (hf: number) => {
    if (hf < 1.3) return { status: 'critical', color: 'bg-red-100 border-red-500 text-red-800' }
    if (hf < 1.5) return { status: 'warning', color: 'bg-yellow-100 border-yellow-500 text-yellow-800' }
    return { status: 'healthy', color: 'bg-green-100 border-green-500 text-green-800' }
  }

  const { status, color } = getHealthFactorStatus(position.health_factor)

  const formatAmount = (amount: string) => {
    const num = parseFloat(amount) / 1e18 // Convert from wei
    return num.toFixed(4)
  }

  const formatAddress = (address: string) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`
  }

  return (
    <div className={`p-6 rounded-lg border-2 ${color} transition-all hover:shadow-lg`}>
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="font-semibold text-lg">
            Position {position.id.slice(0, 8)}...
          </h3>
          <p className="text-sm opacity-75">
            Owner: {formatAddress(position.owner)}
          </p>
        </div>
        <div className="text-right">
          <div className="text-2xl font-bold">
            {position.health_factor.toFixed(4)}
          </div>
          <div className="text-sm capitalize">{status}</div>
        </div>
      </div>

      <div className="space-y-3 mb-4">
        <div className="flex justify-between text-sm">
          <span>Collateral:</span>
          <span className="font-medium">
            {formatAmount(position.collateral_amount)} ETH
          </span>
        </div>
        <div className="flex justify-between text-sm">
          <span>Debt:</span>
          <span className="font-medium">
            {formatAmount(position.debt_amount)} USDC
          </span>
        </div>
        <div className="flex justify-between text-sm">
          <span>Last Update:</span>
          <span className="font-medium">
            {new Date(position.last_update_at * 1000).toLocaleString()}
          </span>
        </div>
      </div>

      {status === 'critical' && (
        <div className="mt-4">
          <ProtectButton positionId={position.id} />
        </div>
      )}

      {status === 'warning' && (
        <div className="mt-4 p-3 bg-yellow-50 rounded-lg">
          <p className="text-sm text-yellow-800">
            ⚠️ Position approaching liquidation threshold
          </p>
        </div>
      )}
    </div>
  )
}