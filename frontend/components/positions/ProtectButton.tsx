'use client'

import { useProtect } from '@/hooks/useProtect'
import { useState } from 'react'

interface ProtectButtonProps {
  positionId: string
}

export function ProtectButton({ positionId }: ProtectButtonProps) {
  const { protectPosition, isProtecting, isSuccess, error } = useProtect()
  const [showSuccess, setShowSuccess] = useState(false)

  const handleProtect = async () => {
    try {
      await protectPosition(positionId)
      setShowSuccess(true)
      setTimeout(() => setShowSuccess(false), 3000)
    } catch (err) {
      console.error('Protection failed:', err)
    }
  }

  if (showSuccess || isSuccess) {
    return (
      <div className="p-3 bg-green-100 border border-green-500 rounded-lg text-center">
        <div className="text-green-800 font-medium">✅ Position Protected!</div>
        <div className="text-sm text-green-600 mt-1">
          Protection transaction submitted
        </div>
      </div>
    )
  }

  return (
    <div>
      <button
        onClick={handleProtect}
        disabled={isProtecting}
        className={`w-full px-4 py-3 rounded-lg font-medium transition ${
          isProtecting
            ? 'bg-gray-400 cursor-not-allowed'
            : 'bg-red-600 hover:bg-red-700 text-white animate-pulse-glow'
        }`}
      >
        {isProtecting ? (
          <div className="flex items-center justify-center gap-2">
            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
            Protecting...
          </div>
        ) : (
          '🛡️ Protect Position'
        )}
      </button>

      {error && (
        <div className="mt-2 p-2 bg-red-100 border border-red-300 rounded text-sm text-red-700">
          Protection failed: {error.message}
        </div>
      )}
    </div>
  )
}