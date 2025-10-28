# DeRisk Watchtower Frontend

A Next.js 14 application for monitoring and protecting DeFi lending positions in real-time.

## Features

- 🔗 **Wallet Integration**: Connect with MetaMask, WalletConnect, and other Web3 wallets
- 📊 **Real-time Monitoring**: Live tracking of lending position health factors
- 🚨 **Risk Alerts**: Instant notifications when positions approach liquidation
- 🛡️ **One-click Protection**: Automated protection against liquidation events
- 📱 **Responsive Design**: Mobile-friendly interface with Tailwind CSS
- 🔄 **WebSocket Updates**: Real-time data streaming from backend services
- 🧪 **Offline Replay**: Test scenarios with simulated data

## Tech Stack

- **Framework**: Next.js 14 with App Router
- **Styling**: Tailwind CSS with custom animations
- **Web3**: wagmi v2 + viem for blockchain interactions
- **State Management**: TanStack Query for server state
- **WebSockets**: Native WebSocket API for real-time updates
- **Testing**: Vitest + Testing Library
- **TypeScript**: Full type safety

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn
- A Web3 wallet (MetaMask recommended)

### Installation

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Environment Setup**:
   ```bash
   cp .env.example .env.local
   ```

   Configure your environment variables:
   ```env
   NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id
   NEXT_PUBLIC_API_URL=http://localhost:8080
   NEXT_PUBLIC_WS_URL=ws://localhost:8080/ws
   NEXT_PUBLIC_VAULT_ADDRESS=0x...
   NEXT_PUBLIC_PROTECTOR_ADDRESS=0x...
   ```

3. **Start development server**:
   ```bash
   npm run dev
   ```

4. **Open your browser**:
   Navigate to [http://localhost:3000](http://localhost:3000)

## Project Structure

```
frontend/
├── app/                    # Next.js App Router pages
│   ├── dashboard/         # Dashboard page
│   ├── globals.css        # Global styles and animations
│   ├── layout.tsx         # Root layout
│   └── page.tsx          # Home page
├── components/            # React components
│   ├── alerts/           # Alert components
│   ├── positions/        # Position-related components
│   └── wallet/           # Wallet connection components
├── hooks/                # Custom React hooks
│   ├── usePositions.ts   # Position data hooks
│   ├── useProtect.ts     # Protection transaction hook
│   └── useWebSocket.ts   # WebSocket connection hook
├── lib/                  # Utility libraries
│   ├── api.ts           # API client
│   ├── contracts.ts     # Smart contract ABIs
│   ├── providers.tsx    # React providers
│   ├── replay.ts        # Offline replay service
│   └── wagmi.ts         # wagmi configuration
├── public/              # Static assets
│   └── fixtures/        # Test data for replay mode
└── __tests__/           # Test files
```

## Key Components

### Wallet Integration
- **ConnectButton**: Wallet connection interface
- **wagmi Configuration**: Multi-wallet support with Base Sepolia

### Position Monitoring
- **PositionCard**: Individual position display with health metrics
- **Timeline**: Historical events for positions
- **Dashboard**: Overview of all positions with risk assessment

### Real-time Alerts
- **RiskAlert**: Live notification system for position risks
- **ConnectionStatus**: WebSocket and wallet connection status
- **WebSocket Hook**: Manages real-time data streaming

### Protection System
- **ProtectButton**: One-click position protection
- **useProtect Hook**: Handles protection transactions
- **Smart Contract Integration**: Direct interaction with protection contracts

## Development Features

### Offline Replay Mode

Test the application with simulated scenarios:

```bash
# Enable replay mode
NEXT_PUBLIC_REPLAY_MODE=true npm run dev
```

Available scenarios:
- `scenario-1-healthy`: Healthy positions with gradual changes
- Custom scenarios can be added to `public/fixtures/`

### Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

### Code Quality

```bash
# Lint code
npm run lint

# Type checking
npm run type-check
```

## API Integration

The frontend integrates with the DeRisk Watchtower backend:

### REST Endpoints
- `GET /api/positions/:address` - Fetch user positions
- `GET /api/positions/:id` - Get specific position details
- `GET /api/health/:id` - Get position health factor
- `GET /api/events/:id` - Get position risk events

### WebSocket Events
- Real-time position updates
- Risk alerts and notifications
- Connection status monitoring

## Smart Contract Integration

### Supported Contracts
- **Vault Contract**: Position management and queries
- **Protector Contract**: Automated protection mechanisms

### Key Functions
- `getUserPositions(address)`: Fetch all user positions
- `getPosition(id)`: Get specific position data
- `protectPosition(id)`: Execute protection transaction

## Deployment

### Build for Production

```bash
npm run build
npm start
```

### Environment Variables

Required for production:
- `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`: WalletConnect project ID
- `NEXT_PUBLIC_API_URL`: Backend API URL
- `NEXT_PUBLIC_WS_URL`: WebSocket server URL
- `NEXT_PUBLIC_VAULT_ADDRESS`: Vault contract address
- `NEXT_PUBLIC_PROTECTOR_ADDRESS`: Protector contract address

### Docker Deployment

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines

- Use TypeScript for all new code
- Follow the existing component structure
- Add tests for new features
- Update documentation as needed
- Ensure responsive design compatibility

## Troubleshooting

### Common Issues

**Wallet Connection Issues**:
- Ensure MetaMask is installed and unlocked
- Check network configuration (Base Sepolia)
- Verify WalletConnect project ID

**WebSocket Connection Failures**:
- Check backend server status
- Verify WebSocket URL configuration
- Check browser console for connection errors

**Transaction Failures**:
- Ensure sufficient gas fees
- Check contract addresses
- Verify wallet has necessary permissions

### Debug Mode

Enable debug logging:
```bash
DEBUG=true npm run dev
```

## License

This project is part of the ETH Global 2025 hackathon submission.

## Support

For issues and questions:
- Check the [troubleshooting guide](#troubleshooting)
- Review the [API documentation](../backend/README.md)
- Open an issue on GitHub