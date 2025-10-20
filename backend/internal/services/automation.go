package services

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"os"
	"strings"
	"time"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

var (
	automationDelaySeconds = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "automation_delay_seconds",
		Help: "Seconds since last automation trigger",
	})

	automationTriggersTotal = promauto.NewCounter(prometheus.CounterOpts{
		Name: "automation_triggers_total",
		Help: "Total number of automation triggers",
	})

	automationHealthy = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "automation_healthy",
		Help: "1 if automation is healthy (delay < 10min), 0 otherwise",
	})
)

// AutomationStats represents the automation statistics from the contract
type AutomationStats struct {
	TotalTriggers        uint64
	LastTrigger          uint64
	TimeSinceLastTrigger uint64
}

// AutomationService monitors Chainlink Automation health
type AutomationService struct {
	protectorAddr common.Address
	client        *ethclient.Client
	contractABI   abi.ABI
}

// NewAutomationService creates a new automation monitoring service
func NewAutomationService(rpcURL string, protectorAddr common.Address) (*AutomationService, error) {
	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to Ethereum client: %w", err)
	}

	// Load Protector ABI
	abiFile, err := os.ReadFile("contracts/abis/Protector.json")
	if err != nil {
		return nil, fmt.Errorf("failed to read Protector ABI: %w", err)
	}

	var abiJSON struct {
		ABI json.RawMessage `json:"abi"`
	}
	if err := json.Unmarshal(abiFile, &abiJSON); err != nil {
		return nil, fmt.Errorf("failed to parse ABI JSON: %w", err)
	}

	contractABI, err := abi.JSON(strings.NewReader(string(abiJSON.ABI)))
	if err != nil {
		return nil, fmt.Errorf("failed to parse contract ABI: %w", err)
	}

	return &AutomationService{
		protectorAddr: protectorAddr,
		client:        client,
		contractABI:   contractABI,
	}, nil
}

// CheckUpkeepStatus queries the Protector contract for automation statistics
func (s *AutomationService) CheckUpkeepStatus(ctx context.Context) (*AutomationStats, error) {
	// Pack the getAutomationStats() call
	data, err := s.contractABI.Pack("getAutomationStats")
	if err != nil {
		return nil, fmt.Errorf("failed to pack getAutomationStats call: %w", err)
	}

	// Call the contract
	msg := ethereum.CallMsg{
		To:   &s.protectorAddr,
		Data: data,
	}

	result, err := s.client.CallContract(ctx, msg, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to call contract: %w", err)
	}

	// Unpack the result
	var out struct {
		TotalTriggers        *big.Int
		LastTrigger          *big.Int
		TimeSinceLastTrigger *big.Int
	}

	if err := s.contractABI.UnpackIntoInterface(&out, "getAutomationStats", result); err != nil {
		return nil, fmt.Errorf("failed to unpack result: %w", err)
	}

	return &AutomationStats{
		TotalTriggers:        out.TotalTriggers.Uint64(),
		LastTrigger:          out.LastTrigger.Uint64(),
		TimeSinceLastTrigger: out.TimeSinceLastTrigger.Uint64(),
	}, nil
}

// RecordDelay updates Prometheus metrics with current automation delay
func (s *AutomationService) RecordDelay(ctx context.Context) error {
	stats, err := s.CheckUpkeepStatus(ctx)
	if err != nil {
		return err
	}

	automationDelaySeconds.Set(float64(stats.TimeSinceLastTrigger))
	automationTriggersTotal.Add(0) // Initialize if not set

	// Set healthy status: 1 if delay < 10 minutes, 0 otherwise
	if stats.TimeSinceLastTrigger < 600 {
		automationHealthy.Set(1)
	} else {
		automationHealthy.Set(0)
	}

	return nil
}

// DetectAutomationFailure returns true if automation appears to have failed
// Failure criteria: no trigger in >10 minutes (600 seconds)
func (s *AutomationService) DetectAutomationFailure(ctx context.Context) bool {
	stats, err := s.CheckUpkeepStatus(ctx)
	if err != nil {
		return true // Assume failure if we can't query
	}

	// If no trigger in >10 minutes, flag as potential failure
	return stats.TimeSinceLastTrigger > 600
}

// StartMonitoring continuously monitors automation health
func (s *AutomationService) StartMonitoring(ctx context.Context, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := s.RecordDelay(ctx); err != nil {
				fmt.Printf("Error recording automation delay: %v\n", err)
			}
		}
	}
}

// Close closes the Ethereum client connection
func (s *AutomationService) Close() {
	if s.client != nil {
		s.client.Close()
	}
}
