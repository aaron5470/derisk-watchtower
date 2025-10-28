import { useEffect, useRef, useState, useCallback } from 'react'

export interface RiskAlert {
  position_id: string
  hf: number
  threshold: number
  timestamp: number
  replayed: boolean
}

interface UseWebSocketOptions {
  reconnectInterval?: number
  maxReconnectAttempts?: number
  onOpen?: () => void
  onClose?: () => void
  onError?: (error: Event) => void
}

export function useWebSocket(url: string, options: UseWebSocketOptions = {}) {
  const {
    reconnectInterval = 3000,
    maxReconnectAttempts = 5,
    onOpen,
    onClose,
    onError,
  } = options

  const [isConnected, setIsConnected] = useState(false)
  const [lastMessage, setLastMessage] = useState<RiskAlert | null>(null)
  const [connectionError, setConnectionError] = useState<string | null>(null)
  
  const wsRef = useRef<WebSocket | null>(null)
  const reconnectAttemptsRef = useRef(0)
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null)

  const connect = useCallback(() => {
    try {
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        return
      }

      wsRef.current = new WebSocket(url)

      wsRef.current.onopen = () => {
        setIsConnected(true)
        setConnectionError(null)
        reconnectAttemptsRef.current = 0
        onOpen?.()
      }

      wsRef.current.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data) as RiskAlert
          setLastMessage(data)
        } catch (error) {
          console.error('Failed to parse WebSocket message:', error)
        }
      }

      wsRef.current.onclose = () => {
        setIsConnected(false)
        onClose?.()

        // Auto-reconnect logic
        if (reconnectAttemptsRef.current < maxReconnectAttempts) {
          reconnectAttemptsRef.current++
          reconnectTimeoutRef.current = setTimeout(() => {
            connect()
          }, reconnectInterval)
        } else {
          setConnectionError('Max reconnection attempts reached')
        }
      }

      wsRef.current.onerror = (error) => {
        setConnectionError('WebSocket connection error')
        onError?.(error)
      }
    } catch (error) {
      setConnectionError('Failed to create WebSocket connection')
      console.error('WebSocket connection error:', error)
    }
  }, [url, reconnectInterval, maxReconnectAttempts, onOpen, onClose, onError])

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current)
      reconnectTimeoutRef.current = null
    }
    
    if (wsRef.current) {
      wsRef.current.close()
      wsRef.current = null
    }
    
    setIsConnected(false)
    reconnectAttemptsRef.current = 0
  }, [])

  const sendMessage = useCallback((message: any) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify(message))
    } else {
      console.warn('WebSocket is not connected')
    }
  }, [])

  useEffect(() => {
    connect()

    return () => {
      disconnect()
    }
  }, [connect, disconnect])

  return {
    isConnected,
    lastMessage,
    connectionError,
    sendMessage,
    reconnect: connect,
    disconnect,
  }
}