'use client'

import { ConnectButton } from '@/components/wallet/ConnectButton'
import { PositionCard } from '@/components/positions/PositionCard'
import { Timeline } from '@/components/positions/Timeline'
import { RiskAlert } from '@/components/alerts/RiskAlert'
import { ConnectionStatus } from '@/components/alerts/ConnectionStatus'
import { usePositions } from '@/hooks/usePositions'
import { useAccount } from 'wagmi'
import { useState } from 'react'
import Link from 'next/link'

export default function DashboardPage() {
  const { address, isConnected } = useAccount()
  const { data: positions, isLoading, error } = usePositions(address)
  const [selectedPosition, setSelectedPosition] = useState<string | null>(null)

  if (!isConnected) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">🔒</div>
          <h2 className="text-2xl font-bold mb-4">Wallet Not Connected</h2>
          <p className="text-gray-600 mb-6">
            Please connect your wallet to view your positions
          </p>
          <ConnectButton />
          <div className="mt-4">
            <Link href="/" className="text-blue-600 hover:underline">
              ← Back to Home
            </Link>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Risk Alerts */}
      <RiskAlert />

      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-4">
              <Link href="/" className="flex items-center gap-2 text-gray-600 hover:text-gray-900">
                <span>←</span>
                <span className="text-2xl">🛡️</span>
              </Link>
              <h1 className="text-2xl font-bold">Dashboard</h1>
            </div>
            <ConnectButton />
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid lg:grid-cols-4 gap-6">
          {/* Main Content */}
          <div className="lg:col-span-3 space-y-6">
            {/* Summary Stats */}
            <div className="grid md:grid-cols-3 gap-4">
              <div className="bg-white p-6 rounded-lg shadow-sm">
                <div className="text-2xl font-bold text-blue-600">
                  {positions?.length || 0}
                </div>
                <div className="text-sm text-gray-600">Total Positions</div>
              </div>
              
              <div className="bg-white p-6 rounded-lg shadow-sm">
                <div className="text-2xl font-bold text-red-600">
                  {positions?.filter(p => p.health_factor < 1.3).length || 0}
                </div>
                <div className="text-sm text-gray-600">At Risk</div>
              </div>
              
              <div className="bg-white p-6 rounded-lg shadow-sm">
                <div className="text-2xl font-bold text-green-600">
                  {positions?.filter(p => p.health_factor >= 1.5).length || 0}
                </div>
                <div className="text-sm text-gray-600">Healthy</div>
              </div>
            </div>

            {/* Positions Grid */}
            <div>
              <h2 className="text-xl font-semibold mb-4">Your Positions</h2>
              
              {isLoading && (
                <div className="grid md:grid-cols-2 gap-4">
                  {[1, 2, 3, 4].map(i => (
                    <div key={i} className="bg-white p-6 rounded-lg shadow-sm animate-pulse">
                      <div className="h-4 bg-gray-200 rounded mb-2"></div>
                      <div className="h-4 bg-gray-200 rounded w-3/4 mb-4"></div>
                      <div className="space-y-2">
                        <div className="h-3 bg-gray-200 rounded"></div>
                        <div className="h-3 bg-gray-200 rounded w-2/3"></div>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {error && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
                  <div className="text-red-600 font-medium mb-2">
                    Failed to load positions
                  </div>
                  <div className="text-sm text-red-500">
                    {error.message}
                  </div>
                </div>
              )}

              {positions && positions.length === 0 && (
                <div className="bg-white rounded-lg p-12 text-center shadow-sm">
                  <div className="text-6xl mb-4">📊</div>
                  <h3 className="text-xl font-semibold mb-2">No Positions Found</h3>
                  <p className="text-gray-600">
                    You don't have any lending positions to monitor yet.
                  </p>
                </div>
              )}

              {positions && positions.length > 0 && (
                <div className="grid md:grid-cols-2 gap-4">
                  {positions
                    .sort((a, b) => a.health_factor - b.health_factor) // Show risky positions first
                    .map((position) => (
                      <div
                        key={position.id}
                        onClick={() => setSelectedPosition(
                          selectedPosition === position.id ? null : position.id
                        )}
                        className="cursor-pointer"
                      >
                        <PositionCard position={position} />
                      </div>
                    ))}
                </div>
              )}
            </div>

            {/* Position Timeline */}
            {selectedPosition && (
              <div className="mt-6">
                <h3 className="text-lg font-semibold mb-4">
                  Position Timeline
                </h3>
                <Timeline positionId={selectedPosition} />
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            <ConnectionStatus />
            
            {/* Quick Actions */}
            <div className="bg-white p-4 rounded-lg shadow-sm">
              <h3 className="font-semibold mb-3">Quick Actions</h3>
              <div className="space-y-2">
                <Link href="/analytics" className="block w-full px-3 py-2 text-left text-sm bg-gray-50 hover:bg-gray-100 rounded transition-colors">
                  📊 View Analytics
                </Link>
                <Link href="/settings" className="block w-full px-3 py-2 text-left text-sm bg-gray-50 hover:bg-gray-100 rounded transition-colors">
                  ⚙️ Settings
                </Link>
                <Link href="/documentation" className="block w-full px-3 py-2 text-left text-sm bg-gray-50 hover:bg-gray-100 rounded transition-colors">
                  📖 Documentation
                </Link>
              </div>
            </div>

            {/* Risk Summary */}
            {positions && positions.length > 0 && (
              <div className="bg-white p-4 rounded-lg shadow-sm">
                <h3 className="font-semibold mb-3">Risk Summary</h3>
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span>Lowest Health Factor:</span>
                    <span className="font-medium">
                      {Math.min(...positions.map(p => p.health_factor)).toFixed(4)}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span>Average Health Factor:</span>
                    <span className="font-medium">
                      {(positions.reduce((sum, p) => sum + p.health_factor, 0) / positions.length).toFixed(4)}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span>Total Collateral:</span>
                    <span className="font-medium">
                      {(positions.reduce((sum, p) => sum + parseFloat(p.collateral_amount), 0) / 1e18).toFixed(2)} ETH
                    </span>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}