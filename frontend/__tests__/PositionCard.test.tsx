import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import { PositionCard } from '@/components/positions/PositionCard'
import { Position } from '@/lib/api'

// Mock the ProtectButton component
vi.mock('@/components/positions/ProtectButton', () => ({
  ProtectButton: ({ positionId }: { positionId: string }) => (
    <div data-testid="protect-button">Protect Button for {positionId}</div>
  ),
}))

const mockPosition: Position = {
  id: '0x1234567890abcdef1234567890abcdef12345678',
  owner: '0xabcdef1234567890abcdef1234567890abcdef12',
  collateral_amount: '5000000000000000000', // 5 ETH in wei
  debt_amount: '2000000000000000000000', // 2000 USDC in wei
  health_factor: 2.5,
  last_update_at: 1704067200,
}

const criticalPosition: Position = {
  ...mockPosition,
  health_factor: 1.2,
}

const warningPosition: Position = {
  ...mockPosition,
  health_factor: 1.4,
}

describe('PositionCard', () => {
  it('renders position information correctly', () => {
    render(<PositionCard position={mockPosition} />)

    // Check if position ID is displayed (truncated)
    expect(screen.getByText(/Position 12345678.../)).toBeInTheDocument()

    // Check if owner address is displayed (formatted)
    expect(screen.getByText(/Owner: 0xabcd...ef12/)).toBeInTheDocument()

    // Check if health factor is displayed
    expect(screen.getByText('2.5000')).toBeInTheDocument()

    // Check if collateral amount is displayed
    expect(screen.getByText('5.0000 ETH')).toBeInTheDocument()

    // Check if debt amount is displayed
    expect(screen.getByText('2000.0000 USDC')).toBeInTheDocument()
  })

  it('displays healthy status for high health factor', () => {
    render(<PositionCard position={mockPosition} />)

    expect(screen.getByText('healthy')).toBeInTheDocument()
    
    // Check for green styling classes
    const card = screen.getByText(/Position 12345678.../).closest('div')
    expect(card).toHaveClass('bg-green-100', 'border-green-500', 'text-green-800')
  })

  it('displays warning status for medium health factor', () => {
    render(<PositionCard position={warningPosition} />)

    expect(screen.getByText('warning')).toBeInTheDocument()
    
    // Check for yellow styling classes
    const card = screen.getByText(/Position 12345678.../).closest('div')
    expect(card).toHaveClass('bg-yellow-100', 'border-yellow-500', 'text-yellow-800')

    // Should show warning message
    expect(screen.getByText(/Position approaching liquidation threshold/)).toBeInTheDocument()
  })

  it('displays critical status and protect button for low health factor', () => {
    render(<PositionCard position={criticalPosition} />)

    expect(screen.getByText('critical')).toBeInTheDocument()
    
    // Check for red styling classes
    const card = screen.getByText(/Position 12345678.../).closest('div')
    expect(card).toHaveClass('bg-red-100', 'border-red-500', 'text-red-800')

    // Should show protect button for critical positions
    expect(screen.getByTestId('protect-button')).toBeInTheDocument()
  })

  it('formats amounts correctly', () => {
    const positionWithLargeAmounts: Position = {
      ...mockPosition,
      collateral_amount: '1234567890123456789', // ~1.23 ETH
      debt_amount: '9876543210987654321098', // ~9876.54 USDC
    }

    render(<PositionCard position={positionWithLargeAmounts} />)

    expect(screen.getByText('1.2346 ETH')).toBeInTheDocument()
    expect(screen.getByText('9876.5432 USDC')).toBeInTheDocument()
  })

  it('formats timestamp correctly', () => {
    render(<PositionCard position={mockPosition} />)

    // The timestamp should be formatted as a locale string
    // 1704067200 = Mon Jan 01 2024 00:00:00 GMT+0000
    const formattedDate = new Date(1704067200 * 1000).toLocaleString()
    expect(screen.getByText(formattedDate)).toBeInTheDocument()
  })

  it('truncates addresses correctly', () => {
    render(<PositionCard position={mockPosition} />)

    // Position ID should be truncated to first 8 characters
    expect(screen.getByText(/Position 12345678.../)).toBeInTheDocument()

    // Owner address should be formatted as first 6 + last 4 characters
    expect(screen.getByText(/Owner: 0xabcd...ef12/)).toBeInTheDocument()
  })
})