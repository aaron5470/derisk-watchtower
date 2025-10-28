'use client'

import Link from 'next/link'
import { useAccount } from 'wagmi'
import { ConnectButton } from '@/components/wallet/ConnectButton'
import { useState } from 'react'

export default function SettingsPage() {
  const { address, isConnected } = useAccount()
  const [notifications, setNotifications] = useState(true)
  const [emailAlerts, setEmailAlerts] = useState(false)
  const [riskThreshold, setRiskThreshold] = useState(1.3)

  if (!isConnected) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">⚙️</div>
          <h2 className="text-2xl font-bold mb-4">Settings</h2>
          <p className="text-gray-600 mb-6">
            Connect your wallet to access settings
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
      <main className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">⚙️ Settings</h1>
          <p className="text-gray-600">Configure your risk monitoring preferences</p>
        </div>

        <div className="space-y-8">
          {/* Account Information */}
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-semibold mb-4">Account Information</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Connected Wallet
                </label>
                <div className="px-3 py-2 bg-gray-50 rounded border text-sm font-mono">
                  {address}
                </div>
              </div>
            </div>
          </div>

          {/* Notification Settings */}
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-semibold mb-4">Notification Settings</h3>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <label className="text-sm font-medium text-gray-700">
                    Browser Notifications
                  </label>
                  <p className="text-sm text-gray-500">
                    Receive real-time alerts in your browser
                  </p>
                </div>
                <button
                  onClick={() => setNotifications(!notifications)}
                  className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                    notifications ? 'bg-blue-600' : 'bg-gray-200'
                  }`}
                >
                  <span
                    className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                      notifications ? 'translate-x-6' : 'translate-x-1'
                    }`}
                  />
                </button>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <label className="text-sm font-medium text-gray-700">
                    Email Alerts
                  </label>
                  <p className="text-sm text-gray-500">
                    Get email notifications for critical events
                  </p>
                </div>
                <button
                  onClick={() => setEmailAlerts(!emailAlerts)}
                  className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                    emailAlerts ? 'bg-blue-600' : 'bg-gray-200'
                  }`}
                >
                  <span
                    className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                      emailAlerts ? 'translate-x-6' : 'translate-x-1'
                    }`}
                  />
                </button>
              </div>
            </div>
          </div>

          {/* Risk Settings */}
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-semibold mb-4">Risk Settings</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Risk Alert Threshold
                </label>
                <div className="flex items-center gap-4">
                  <input
                    type="range"
                    min="1.1"
                    max="2.0"
                    step="0.1"
                    value={riskThreshold}
                    onChange={(e) => setRiskThreshold(parseFloat(e.target.value))}
                    className="flex-1"
                  />
                  <span className="text-sm font-medium w-12">
                    {riskThreshold.toFixed(1)}
                  </span>
                </div>
                <p className="text-sm text-gray-500 mt-1">
                  Get alerts when health factor drops below this threshold
                </p>
              </div>
            </div>
          </div>

          {/* Advanced Settings */}
          <div className="bg-white p-6 rounded-lg shadow-sm">
            <h3 className="text-lg font-semibold mb-4">Advanced Settings</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Auto-Protection
                </label>
                <p className="text-sm text-gray-500 mb-2">
                  Automatically protect positions when health factor is critical
                </p>
                <div className="text-sm text-yellow-600 bg-yellow-50 p-3 rounded border">
                  ⚠️ Auto-protection is currently in development and not available yet.
                </div>
              </div>
            </div>
          </div>

          {/* Save Button */}
          <div className="flex justify-end">
            <button className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition">
              Save Settings
            </button>
          </div>
        </div>
      </main>
    </div>
  )
}