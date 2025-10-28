'use client'

import { ConnectButton } from '@/components/wallet/ConnectButton'
import { useAccount } from 'wagmi'
import Link from 'next/link'
import { useEffect, useState } from 'react'

export default function HomePage() {
  const { isConnected } = useAccount()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <header className="p-6 bg-white shadow-sm">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-3">
            <div className="text-2xl">🛡️</div>
            <h1 className="text-2xl font-bold text-gray-900">
              DeRisk Watchtower
            </h1>
          </div>
          <ConnectButton />
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-6 py-12">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <h2 className="text-5xl font-bold text-gray-900 mb-6">
            Protect Your DeFi Positions
          </h2>
          <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
            Real-time monitoring and automated protection for your lending positions. 
            Get instant alerts when your health factor drops and protect against liquidation.
          </p>
          
          {!mounted ? (
            <div className="px-8 py-4 bg-gray-200 text-gray-400 rounded-lg text-lg">
              Loading...
            </div>
          ) : (
            <>
              {isConnected ? (
                <Link
                  href="/dashboard"
                  className="inline-flex items-center gap-2 px-8 py-4 bg-blue-600 text-white rounded-lg text-lg font-semibold hover:bg-blue-700 transition"
                >
                  View Dashboard
                  <span>→</span>
                </Link>
              ) : (
                <div className="text-gray-500">
                  Connect your wallet to get started
                </div>
              )}
            </>
          )}
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          <div className="p-6 bg-white rounded-xl shadow-sm">
            <div className="text-3xl mb-4">📊</div>
            <h3 className="text-xl font-semibold mb-3">Real-time Monitoring</h3>
            <p className="text-gray-600">
              Track your lending positions across multiple protocols with live health factor updates.
            </p>
          </div>

          <div className="p-6 bg-white rounded-xl shadow-sm">
            <div className="text-3xl mb-4">🚨</div>
            <h3 className="text-xl font-semibold mb-3">Instant Alerts</h3>
            <p className="text-gray-600">
              Get immediate notifications when your positions approach liquidation thresholds.
            </p>
          </div>

          <div className="p-6 bg-white rounded-xl shadow-sm">
            <div className="text-3xl mb-4">🛡️</div>
            <h3 className="text-xl font-semibold mb-3">Auto Protection</h3>
            <p className="text-gray-600">
              One-click protection to safeguard your positions from liquidation events.
            </p>
          </div>
        </div>

        {/* How it Works */}
        <div className="bg-white rounded-xl p-8 shadow-sm">
          <h3 className="text-2xl font-bold text-center mb-8">How It Works</h3>
          
          <div className="grid md:grid-cols-4 gap-6">
            <div className="text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-blue-600 font-bold">1</span>
              </div>
              <h4 className="font-semibold mb-2">Connect Wallet</h4>
              <p className="text-sm text-gray-600">
                Connect your wallet to start monitoring your positions
              </p>
            </div>

            <div className="text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-blue-600 font-bold">2</span>
              </div>
              <h4 className="font-semibold mb-2">Monitor Positions</h4>
              <p className="text-sm text-gray-600">
                View all your lending positions and their health factors
              </p>
            </div>

            <div className="text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-blue-600 font-bold">3</span>
              </div>
              <h4 className="font-semibold mb-2">Get Alerts</h4>
              <p className="text-sm text-gray-600">
                Receive real-time alerts when positions are at risk
              </p>
            </div>

            <div className="text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-blue-600 font-bold">4</span>
              </div>
              <h4 className="font-semibold mb-2">Protect Assets</h4>
              <p className="text-sm text-gray-600">
                Use one-click protection to prevent liquidation
              </p>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-8">
        <div className="max-w-6xl mx-auto px-6 text-center">
          <p className="text-gray-400">
            Built for ETH Global 2025 • Protecting DeFi users from liquidation
          </p>
        </div>
      </footer>
    </div>
  )
}