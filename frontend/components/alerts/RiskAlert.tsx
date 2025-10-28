'use client'

import { useWebSocket } from '@/hooks/useWebSocket'
import { useState, useEffect } from 'react'

interface RiskAlert {
  position_id: string
  health_factor: number
  threshold: number
  timestamp: number
  severity: 'critical' | 'warning'
}

export function RiskAlert() {
  const wsUrl = process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8080/ws/risk-stream'
  const { lastMessage, isConnected } = useWebSocket(wsUrl)
  const [alerts, setAlerts] = useState<RiskAlert[]>([])
  const [showAlert, setShowAlert] = useState(false)

  useEffect(() => {
    if (lastMessage) {
      const alert = lastMessage as RiskAlert
      setAlerts(prev => [alert, ...prev.slice(0, 4)]) // Keep last 5 alerts
      setShowAlert(true)
      
      // Auto-hide after 5 seconds
      const timer = setTimeout(() => setShowAlert(false), 5000)
      return () => clearTimeout(timer)
    }
  }, [lastMessage])

  const formatAddress = (positionId: string) => {
    return `${positionId.slice(0, 8)}...${positionId.slice(-6)}`
  }

  const getSeverityStyles = (severity: string) => {
    switch (severity) {
      case 'critical':
        return 'bg-red-100 border-red-500 text-red-800'
      case 'warning':
        return 'bg-yellow-100 border-yellow-500 text-yellow-800'
      default:
        return 'bg-gray-100 border-gray-500 text-gray-800'
    }
  }

  if (!isConnected) {
    return (
      <div className="fixed top-4 right-4 p-4 bg-gray-100 border border-gray-300 rounded-lg shadow-lg">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 bg-gray-400 rounded-full"></div>
          <span className="text-sm text-gray-600">WebSocket Disconnected</span>
        </div>
      </div>
    )
  }

  return (
    <div className="fixed top-4 right-4 space-y-2 z-50">
      {/* Connection Status */}
      <div className="p-2 bg-green-100 border border-green-300 rounded-lg shadow-lg">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
          <span className="text-sm text-green-700">Live Monitoring</span>
        </div>
      </div>

      {/* Latest Alert */}
      {showAlert && alerts.length > 0 && (
        <div className={`p-4 border-2 rounded-lg shadow-lg animate-slide-in ${getSeverityStyles(alerts[0].severity)}`}>
          <div className="flex justify-between items-start mb-2">
            <div className="font-semibold">
              {alerts[0].severity === 'critical' ? '🚨 Critical Alert' : '⚠️ Warning'}
            </div>
            <button
              onClick={() => setShowAlert(false)}
              className="text-gray-500 hover:text-gray-700"
            >
              ×
            </button>
          </div>
          
          <div className="text-sm space-y-1">
            <div>Position: {formatAddress(alerts[0].position_id)}</div>
            <div>Health Factor: {alerts[0].health_factor.toFixed(4)}</div>
            <div>Threshold: {alerts[0].threshold.toFixed(4)}</div>
            <div className="text-xs opacity-75">
              {new Date(alerts[0].timestamp * 1000).toLocaleTimeString()}
            </div>
          </div>
        </div>
      )}

      {/* Alert History */}
      {alerts.length > 1 && (
        <div className="p-3 bg-white border border-gray-200 rounded-lg shadow-lg max-w-sm">
          <div className="text-sm font-medium mb-2">Recent Alerts ({alerts.length - 1})</div>
          <div className="space-y-1 max-h-32 overflow-y-auto">
            {alerts.slice(1).map((alert, index) => (
              <div key={index} className="text-xs p-2 bg-gray-50 rounded">
                <div className="flex justify-between">
                  <span>{formatAddress(alert.position_id)}</span>
                  <span>{alert.health_factor.toFixed(3)}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}