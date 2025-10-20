'use client'

import { useWebSocket } from '@/hooks/useWebSocket'
import { useAccount } from 'wagmi'

export function ConnectionStatus() {
  const wsUrl = process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8080/ws/risk-stream'
  const { isConnected: wsConnected, connectionError: error, reconnect } = useWebSocket(wsUrl)
  const { isConnected: walletConnected, address } = useAccount()

  return (
    <div className="p-4 bg-white border border-gray-200 rounded-lg">
      <h3 className="font-semibold mb-3">Connection Status</h3>
      
      <div className="space-y-3">
        {/* Wallet Connection */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className={`w-3 h-3 rounded-full ${
              walletConnected ? 'bg-green-500' : 'bg-red-500'
            }`}></div>
            <span className="text-sm">Wallet</span>
          </div>
          <div className="text-sm text-gray-600">
            {walletConnected ? (
              `${address?.slice(0, 6)}...${address?.slice(-4)}`
            ) : (
              'Not connected'
            )}
          </div>
        </div>

        {/* WebSocket Connection */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className={`w-3 h-3 rounded-full ${
              wsConnected ? 'bg-green-500 animate-pulse' : 'bg-red-500'
            }`}></div>
            <span className="text-sm">Live Updates</span>
          </div>
          <div className="text-sm text-gray-600">
            {wsConnected ? 'Connected' : 'Disconnected'}
          </div>
        </div>

        {/* Error Display */}
        {error && (
          <div className="p-2 bg-red-50 border border-red-200 rounded text-sm text-red-700">
            <div className="font-medium">Connection Error:</div>
            <div>{error}</div>
            <button
              onClick={reconnect}
              className="mt-2 px-3 py-1 bg-red-600 text-white rounded text-xs hover:bg-red-700"
            >
              Retry Connection
            </button>
          </div>
        )}

        {/* Reconnect Button */}
        {!wsConnected && !error && (
          <button
            onClick={reconnect}
            className="w-full px-3 py-2 bg-blue-600 text-white rounded text-sm hover:bg-blue-700"
          >
            Reconnect WebSocket
          </button>
        )}

        {/* Status Summary */}
        <div className="pt-2 border-t border-gray-200">
          <div className="text-xs text-gray-500">
            {walletConnected && wsConnected ? (
              '✅ All systems operational'
            ) : (
              '⚠️ Some services unavailable'
            )}
          </div>
        </div>
      </div>
    </div>
  )
}