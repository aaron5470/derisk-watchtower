import { Position, RiskEvent } from './api'

interface ReplayScenario {
  scenario: string
  description: string
  positions: Position[]
  events: RiskEvent[]
  websocket_messages: {
    timestamp: number
    message: any
  }[]
}

class ReplayService {
  private scenario: ReplayScenario | null = null
  private isReplaying = false
  private replaySpeed = 1000 // 1 second = 1 minute in replay
  private currentTime = 0
  private startTime = 0
  private callbacks: ((message: any) => void)[] = []

  async loadScenario(scenarioName: string): Promise<void> {
    try {
      const response = await fetch(`/fixtures/${scenarioName}.json`)
      if (!response.ok) {
        throw new Error(`Failed to load scenario: ${response.statusText}`)
      }
      this.scenario = await response.json()
      console.log(`Loaded replay scenario: ${this.scenario?.description}`)
    } catch (error) {
      console.error('Failed to load replay scenario:', error)
      throw error
    }
  }

  getPositions(): Position[] {
    return this.scenario?.positions || []
  }

  getEvents(positionId?: string): RiskEvent[] {
    if (!this.scenario) return []
    
    let events = this.scenario.events
    if (positionId) {
      events = events.filter(event => event.position_id === positionId)
    }
    
    return events.map(event => ({
      ...event,
      replayed: true
    }))
  }

  startReplay(): void {
    if (!this.scenario || this.isReplaying) return

    this.isReplaying = true
    this.startTime = Date.now()
    this.currentTime = 0

    console.log('Starting replay mode...')
    this.scheduleNextMessage()
  }

  stopReplay(): void {
    this.isReplaying = false
    console.log('Stopped replay mode')
  }

  onMessage(callback: (message: any) => void): void {
    this.callbacks.push(callback)
  }

  removeCallback(callback: (message: any) => void): void {
    const index = this.callbacks.indexOf(callback)
    if (index > -1) {
      this.callbacks.splice(index, 1)
    }
  }

  private scheduleNextMessage(): void {
    if (!this.scenario || !this.isReplaying) return

    const currentReplayTime = Date.now() - this.startTime
    const scaledTime = currentReplayTime * (60 / this.replaySpeed) // Scale to scenario time

    // Find next message to send
    const nextMessage = this.scenario.websocket_messages.find(
      msg => msg.timestamp * 1000 > this.scenario!.events[0]?.timestamp * 1000 + scaledTime
    )

    if (!nextMessage) {
      console.log('Replay completed')
      this.isReplaying = false
      return
    }

    // Calculate delay until next message
    const messageTime = nextMessage.timestamp * 1000 - this.scenario.events[0].timestamp * 1000
    const delay = Math.max(0, messageTime / (60 / this.replaySpeed) - currentReplayTime)

    setTimeout(() => {
      if (this.isReplaying) {
        // Send message to all callbacks
        this.callbacks.forEach(callback => {
          try {
            callback(nextMessage.message)
          } catch (error) {
            console.error('Error in replay callback:', error)
          }
        })

        // Schedule next message
        this.scheduleNextMessage()
      }
    }, delay)
  }

  isReplayMode(): boolean {
    return this.isReplaying
  }

  getScenarioInfo(): { name: string; description: string } | null {
    if (!this.scenario) return null
    return {
      name: this.scenario.scenario,
      description: this.scenario.description
    }
  }
}

// Singleton instance
export const replayService = new ReplayService()

// Mock API client for replay mode
export class ReplayApiClient {
  async getPositions(address?: string): Promise<Position[]> {
    // In replay mode, return all positions regardless of address
    return replayService.getPositions()
  }

  async getPosition(positionId: string): Promise<Position | null> {
    const positions = replayService.getPositions()
    return positions.find(p => p.id === positionId) || null
  }

  async getRiskEvents(positionId: string): Promise<RiskEvent[]> {
    return replayService.getEvents(positionId)
  }

  async getHealthFactor(positionId: string): Promise<number> {
    const position = await this.getPosition(positionId)
    return position?.health_factor || 0
  }
}

// Environment detection
export const isReplayMode = (): boolean => {
  return process.env.NODE_ENV === 'development' && 
         process.env.NEXT_PUBLIC_REPLAY_MODE === 'true'
}

// Auto-load scenario in replay mode
if (typeof window !== 'undefined' && isReplayMode()) {
  replayService.loadScenario('scenario-1-healthy').then(() => {
    console.log('Replay mode enabled - use replayService.startReplay() to begin')
  }).catch(console.error)
}