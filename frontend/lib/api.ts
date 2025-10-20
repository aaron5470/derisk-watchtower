const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'

export interface Position {
  id: string
  owner: string
  collateral_amount: string
  collateral_token: string
  debt_amount: string
  debt_token: string
  health_factor: number
  last_update_at: number
  created_at: number
}

export interface RiskEvent {
  id: string
  position_id: string
  event_type: string
  health_factor: number
  threshold: number
  tx_hash?: string
  block_number: number
  timestamp: number
  replayed: boolean
}

class ApiClient {
  private baseUrl: string

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl
  }

  async getPositions(address?: string): Promise<Position[]> {
    const url = new URL('/api/positions', this.baseUrl)
    if (address) {
      url.searchParams.set('owner', address)
    }
    // Add demo parameter for testing
    url.searchParams.set('demo', 'true')

    const response = await fetch(url.toString())
    if (!response.ok) {
      throw new Error(`Failed to fetch positions: ${response.statusText}`)
    }

    return response.json()
  }

  async getPosition(id: string): Promise<Position> {
    const response = await fetch(`${this.baseUrl}/api/positions/${id}`)
    if (!response.ok) {
      throw new Error(`Failed to fetch position: ${response.statusText}`)
    }

    return response.json()
  }

  async getRiskEvents(positionId?: string): Promise<RiskEvent[]> {
    const url = new URL('/api/risk-events', this.baseUrl)
    if (positionId) {
      url.searchParams.set('position_id', positionId)
    }
    // Add demo parameter for testing
    url.searchParams.set('demo', 'true')

    const response = await fetch(url.toString())
    if (!response.ok) {
      throw new Error(`Failed to fetch risk events: ${response.statusText}`)
    }

    return response.json()
  }

  async getHealthFactor(positionId: string): Promise<{ health_factor: number }> {
    const response = await fetch(`${this.baseUrl}/api/positions/${positionId}/health-factor`)
    if (!response.ok) {
      throw new Error(`Failed to fetch health factor: ${response.statusText}`)
    }

    return response.json()
  }
}

export const apiClient = new ApiClient()