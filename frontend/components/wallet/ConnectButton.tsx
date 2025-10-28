'use client'

import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { useEffect, useState } from 'react'

export function ConnectButton() {
  const { address, isConnected } = useAccount()
  const { connect, connectors, isPending } = useConnect()
  const { disconnect } = useDisconnect()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return (
      <div className="px-4 py-2 bg-gray-200 text-gray-400 rounded-lg">
        Loading...
      </div>
    )
  }

  if (isConnected && address) {
    return (
      <div className="flex items-center gap-4">
        <div className="text-sm text-gray-600">
          {address.slice(0, 6)}...{address.slice(-4)}
        </div>
        <button
          onClick={() => disconnect()}
          className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition"
        >
          Disconnect
        </button>
      </div>
    )
  }

  return (
    <div className="flex gap-2">
      {connectors.map((connector) => (
        <button
          key={connector.uid}
          onClick={() => connect({ connector })}
          disabled={isPending}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition"
        >
          {isPending ? 'Connecting...' : `Connect ${connector.name}`}
        </button>
      ))}
    </div>
  )
}