package config

import (
	"os"
)

type Config struct {
	Port              string
	RPCEndpoint       string
	SubgraphEndpoint  string
	VaultAddress      string
	ProtectorAddress  string
	ChainID           int64
}

func Load() *Config {
	return &Config{
		Port:              getEnv("PORT", "8080"),
		RPCEndpoint:       getEnv("BASE_SEPOLIA_RPC", ""),
		SubgraphEndpoint:  getEnv("SUBGRAPH_ENDPOINT", ""),
		VaultAddress:      getEnv("VAULT_ADDRESS", ""),
		ProtectorAddress:  getEnv("PROTECTOR_ADDRESS", ""),
		ChainID:           84532, // Base Sepolia
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}