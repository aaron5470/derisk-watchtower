import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { PROTECTOR_ADDRESS, PROTECTOR_ABI } from '@/lib/contracts'
import { useState } from 'react'

export function useProtect() {
  const [isProtecting, setIsProtecting] = useState(false)
  
  const {
    writeContract,
    data: hash,
    error: writeError,
    isPending: isWritePending,
  } = useWriteContract()

  const {
    isLoading: isConfirming,
    isSuccess: isConfirmed,
    error: confirmError,
  } = useWaitForTransactionReceipt({
    hash,
  })

  const protectPosition = async (positionId: string) => {
    try {
      setIsProtecting(true)
      
      await writeContract({
        address: PROTECTOR_ADDRESS,
        abi: PROTECTOR_ABI,
        functionName: 'protectPosition',
        args: [positionId as `0x${string}`],
      })
    } catch (error) {
      console.error('Failed to protect position:', error)
      setIsProtecting(false)
    }
  }

  // Reset protecting state when transaction is confirmed or fails
  if ((isConfirmed || confirmError) && isProtecting) {
    setIsProtecting(false)
  }

  return {
    protectPosition,
    isProtecting: isProtecting || isWritePending || isConfirming,
    isSuccess: isConfirmed,
    error: writeError || confirmError,
    hash,
  }
}