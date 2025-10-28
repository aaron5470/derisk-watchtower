'use client'

import Link from 'next/link'
import { ConnectButton } from '@/components/wallet/ConnectButton'

export default function DocumentationPage() {
  return (
    <div className="min-h-screen bg-gray-50">
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

      <main className="max-w-4xl mx-auto px-6 py-8">
        <div className="bg-white rounded-lg shadow-sm p-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-8">Documentation</h1>
          
          <div className="space-y-8">
            <section>
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">Getting Started</h2>
              <div className="prose text-gray-600">
                <p>Welcome to DeRisk Watchtower! This guide will help you understand how to use our DeFi risk monitoring platform.</p>
                <ol className="list-decimal list-inside space-y-2 mt-4">
                  <li>Connect your wallet using the Connect Wallet button</li>
                  <li>View your positions on the dashboard</li>
                  <li>Monitor your health factor and risk levels</li>
                  <li>Set up alerts for risk events</li>
                </ol>
              </div>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">Understanding Health Factor</h2>
              <div className="prose text-gray-600">
                <p>The health factor is a crucial metric that indicates the safety of your DeFi positions:</p>
                <ul className="list-disc list-inside space-y-2 mt-4">
                  <li><strong>Health Factor &gt; 1.5:</strong> Safe position</li>
                  <li><strong>Health Factor 1.1-1.5:</strong> Moderate risk</li>
                  <li><strong>Health Factor &lt; 1.1:</strong> High risk of liquidation</li>
                </ul>
              </div>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">Protection Features</h2>
              <div className="prose text-gray-600">
                <p>Our platform offers several protection mechanisms:</p>
                <ul className="list-disc list-inside space-y-2 mt-4">
                  <li>Real-time risk monitoring</li>
                  <li>Automated alerts via WebSocket</li>
                  <li>Health factor tracking</li>
                  <li>Position analysis</li>
                </ul>
              </div>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">Supported Protocols</h2>
              <div className="prose text-gray-600">
                <p>Currently supported DeFi protocols:</p>
                <ul className="list-disc list-inside space-y-2 mt-4">
                  <li>Aave</li>
                  <li>Compound</li>
                  <li>MakerDAO</li>
                  <li>More protocols coming soon...</li>
                </ul>
              </div>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">FAQ</h2>
              <div className="space-y-4">
                <div>
                  <h3 className="font-semibold text-gray-800">What is a health factor?</h3>
                  <p className="text-gray-600 mt-1">The health factor represents the safety of your collateralized position. It's calculated based on your collateral value versus your borrowed amount.</p>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-800">How often is data updated?</h3>
                  <p className="text-gray-600 mt-1">Our system monitors your positions in real-time and updates data every few seconds.</p>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-800">What happens when my health factor is low?</h3>
                  <p className="text-gray-600 mt-1">You'll receive immediate alerts, and our system will suggest actions to improve your position safety.</p>
                </div>
              </div>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">Contact & Support</h2>
              <div className="prose text-gray-600">
                <p>Need help? Reach out to our team:</p>
                <ul className="list-disc list-inside space-y-2 mt-4">
                  <li>Email: support@derisk-watchtower.com</li>
                  <li>Discord: Join our community</li>
                  <li>GitHub: Report issues and contribute</li>
                </ul>
              </div>
            </section>
          </div>
        </div>
      </main>
    </div>
  )
}