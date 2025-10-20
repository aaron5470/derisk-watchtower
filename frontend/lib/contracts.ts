import { Address } from 'viem'

// Contract addresses (will be updated with actual deployed addresses)
export const VAULT_ADDRESS = (process.env.NEXT_PUBLIC_VAULT_ADDRESS || '0x0000000000000000000000000000000000000000') as Address
export const PROTECTOR_ADDRESS = (process.env.NEXT_PUBLIC_PROTECTOR_ADDRESS || '0x0000000000000000000000000000000000000000') as Address

// Contract ABIs
export const VAULT_ABI = [
  {
    "inputs": [{"internalType": "address", "name": "user", "type": "address"}],
    "name": "getUserPositions",
    "outputs": [{"internalType": "bytes32[]", "name": "", "type": "bytes32[]"}],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "bytes32", "name": "positionId", "type": "bytes32"}],
    "name": "getPosition",
    "outputs": [
      {
        "components": [
          {"internalType": "address", "name": "owner", "type": "address"},
          {"internalType": "uint256", "name": "collateralAmount", "type": "uint256"},
          {"internalType": "address", "name": "collateralToken", "type": "address"},
          {"internalType": "uint256", "name": "debtAmount", "type": "uint256"},
          {"internalType": "address", "name": "debtToken", "type": "address"},
          {"internalType": "uint256", "name": "lastUpdateAt", "type": "uint256"},
          {"internalType": "uint256", "name": "createdAt", "type": "uint256"}
        ],
        "internalType": "struct PositionVault.Position",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const

export const PROTECTOR_ABI = [
  {
    "inputs": [{"internalType": "bytes32", "name": "positionId", "type": "bytes32"}],
    "name": "protectPosition",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
] as const