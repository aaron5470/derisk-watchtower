'use client'

import { useRiskEvents } from '@/hooks/usePositions'

interface TimelineProps {
  positionId: string
}

export function Timeline({ positionId }: TimelineProps) {
  const { data: events, isLoading } = useRiskEvents(positionId)

  if (isLoading) {
    return (
      <div className="p-4 bg-white rounded-lg border">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 rounded mb-2"></div>
          <div className="h-4 bg-gray-200 rounded w-3/4"></div>
        </div>
      </div>
    )
  }

  if (!events || events.length === 0) {
    return (
      <div className="p-4 bg-white rounded-lg border text-center text-gray-500">
        No risk events recorded
      </div>
    )
  }

  return (
    <div className="p-4 bg-white rounded-lg border">
      <h3 className="font-semibold mb-4">Risk Event Timeline</h3>
      
      <div className="space-y-4 max-h-64 overflow-y-auto">
        {events.map((event) => (
          <div key={event.id} className="flex gap-3">
            <div className="flex-shrink-0">
              <div className={`w-3 h-3 rounded-full mt-1 ${
                event.event_type === 'risk_alert' ? 'bg-red-500' : 'bg-yellow-500'
              }`}></div>
            </div>
            
            <div className="flex-1 min-w-0">
              <div className="flex justify-between items-start">
                <div>
                  <p className="text-sm font-medium text-gray-900">
                    {event.event_type === 'risk_alert' ? '🚨 Risk Alert' : '⚠️ Warning'}
                  </p>
                  <p className="text-sm text-gray-600">
                    Health Factor: {event.health_factor.toFixed(4)} 
                    (Threshold: {event.threshold.toFixed(4)})
                  </p>
                </div>
                <time className="text-xs text-gray-500">
                  {new Date(event.timestamp * 1000).toLocaleTimeString()}
                </time>
              </div>
              
              {event.replayed && (
                <div className="mt-1 text-xs text-blue-600">
                  📼 Replayed event
                </div>
              )}
              
              {event.tx_hash && (
                <div className="mt-2 text-xs text-gray-500">
                  TX: {event.tx_hash.slice(0, 10)}...{event.tx_hash.slice(-8)}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}