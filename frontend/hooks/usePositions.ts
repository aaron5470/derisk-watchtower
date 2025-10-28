import { useQuery } from '@tanstack/react-query'
import { useAccount } from 'wagmi'
import { apiClient, Position } from '@/lib/api'

export function usePositions(ownerAddress?: string) {
  const { address } = useAccount()
  const targetAddress = ownerAddress || address

  return useQuery({
    queryKey: ['positions', targetAddress],
    queryFn: () => apiClient.getPositions(targetAddress),
    enabled: !!targetAddress,
    refetchInterval: 3000, // Refresh every 3 seconds
    staleTime: 1000, // Consider data stale after 1 second
  })
}

export function usePosition(id: string) {
  return useQuery({
    queryKey: ['position', id],
    queryFn: () => apiClient.getPosition(id),
    enabled: !!id,
    refetchInterval: 3000,
    staleTime: 1000,
  })
}

export function useHealthFactor(positionId: string) {
  return useQuery({
    queryKey: ['healthFactor', positionId],
    queryFn: () => apiClient.getHealthFactor(positionId),
    enabled: !!positionId,
    refetchInterval: 3000,
    staleTime: 1000,
  })
}

export function useRiskEvents(positionId?: string) {
  return useQuery({
    queryKey: ['riskEvents', positionId],
    queryFn: () => apiClient.getRiskEvents(positionId),
    refetchInterval: 5000, // Refresh every 5 seconds
    staleTime: 2000,
  })
}