'use client'

import Link from 'next/link'
import { useAccount } from 'wagmi'
import { usePositions } from '@/hooks/usePositions'
import { ConnectButton } from '@/components/wallet/ConnectButton'

export default function AnalyticsPage() {
  const { address, isConnected } = useAccount()
  const { data: positions, isLoading } = usePositions(address)

  if (!isConnected) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">📊</div>
          <h2 className="text-2xl font-bold mb-4">Analytics Dashboard</h2>
          <p className="text-gray-600 mb-6">
            Connect your wallet to view detailed analytics
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
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-4">
              <Link href="/dashboard" className="flex items-center gap-2 text-gray-600 hover:text-gray-900">
                <span>←</span>
                <span className="text-2xl">🛡️</span>
                <span className="text-xl font-bold">DeRisk Watchtower</span>
              </Link>
            </div>
            <ConnectButton />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-6 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">📊 Analytics Dashboard</h1>
          <p className="text-gray-600">Detailed insights into your DeFi positions and risk metrics</p>
        </div>

        {isLoading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading analytics...</p>
          </div>
        ) : !positions || positions.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">📈</div>
            <h3 className="text-xl font-semibold mb-2">No Data Available</h3>
            <p className="text-gray-600 mb-6">
              You don't have any positions to analyze yet.
            </p>
            <Link
              href="/dashboard"
              className="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
            >
              Go to Dashboard
            </Link>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Risk Distribution */}
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <h3 className="text-lg font-semibold mb-4">Risk Distribution</h3>
              <div className="space-y-4">
                {positions.map((position, index) => (
                  <div key={position.id} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className={`w-3 h-3 rounded-full ${
                        position.health_factor < 1.2 ? 'bg-red-500' :
                        position.health_factor < 1.5 ? 'bg-yellow-500' : 'bg-green-500'
                      }`}></div>
                      <span className="text-sm font-medium">Position {index + 1}</span>
                    </div>
                    <span className="text-sm text-gray-600">
                      HF: {position.health_factor.toFixed(4)}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Portfolio Summary */}
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <h3 className="text-lg font-semibold mb-4">Portfolio Summary</h3>
              <div className="space-y-4">
                <div className="flex justify-between">
                  <span className="text-gray-600">Total Positions:</span>
                  <span className="font-medium">{positions.length}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Lowest Health Factor:</span>
                  <span className="font-medium">
                    {Math.min(...positions.map(p => p.health_factor)).toFixed(4)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Average Health Factor:</span>
                  <span className="font-medium">
                    {(positions.reduce((sum, p) => sum + p.health_factor, 0) / positions.length).toFixed(4)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Total Collateral:</span>
                  <span className="font-medium">
                    {(positions.reduce((sum, p) => sum + parseFloat(p.collateral_amount), 0) / 1e18).toFixed(2)} ETH
                  </span>
                </div>
              </div>
            </div>

            {/* Risk Timeline */}
            <div className="bg-white p-6 rounded-lg shadow-sm lg:col-span-2">
              <h3 className="text-lg font-semibold mb-4">Risk Timeline</h3>
              <div className="text-center py-8 text-gray-500">
                <div className="text-4xl mb-2">📈</div>
                <p>Historical risk data visualization coming soon...</p>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  )
}