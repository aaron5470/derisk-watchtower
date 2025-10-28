package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/derisk-watchtower/backend/internal/services"
)

type RiskEventsHandler struct {
	subgraph *services.SubgraphClient
}

func NewRiskEventsHandler(subgraph *services.SubgraphClient) *RiskEventsHandler {
	return &RiskEventsHandler{
		subgraph: subgraph,
	}
}

// RiskEvent represents a risk event for API response
type RiskEvent struct {
	ID          string  `json:"id"`
	PositionID  string  `json:"position_id"`
	EventType   string  `json:"event_type"`
	HealthFactor float64 `json:"health_factor"`
	Threshold   float64 `json:"threshold"`
	TxHash      string  `json:"tx_hash,omitempty"`
	BlockNumber int64   `json:"block_number"`
	Timestamp   int64   `json:"timestamp"`
	Replayed    bool    `json:"replayed"`
}

func (h *RiskEventsHandler) GetRiskEvents(w http.ResponseWriter, r *http.Request) {
	positionID := r.URL.Query().Get("position_id")
	demoMode := r.URL.Query().Get("demo") == "true"
	
	var events []RiskEvent
	
	if demoMode || true { // Always use demo data for now since subgraph might not be available
		events = getDemoRiskEvents(positionID)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(events)
}

func getDemoRiskEvents(positionID string) []RiskEvent {
	now := time.Now().Unix()
	
	// If specific position ID is requested, return events for that position
	if positionID != "" {
		return []RiskEvent{
			{
				ID:          "event_001",
				PositionID:  positionID,
				EventType:   "ThresholdBreach",
				HealthFactor: 1.25,
				Threshold:   1.3,
				TxHash:      "0xabc123def456789abc123def456789abc123def456789abc123def456789abc123",
				BlockNumber: 18500000,
				Timestamp:   now - 1800, // 30 minutes ago
				Replayed:    false,
			},
			{
				ID:          "event_002",
				PositionID:  positionID,
				EventType:   "ProtectionTriggered",
				HealthFactor: 1.15,
				Threshold:   1.2,
				TxHash:      "0xdef456789abc123def456789abc123def456789abc123def456789abc123def456",
				BlockNumber: 18500100,
				Timestamp:   now - 900, // 15 minutes ago
				Replayed:    true,
			},
		}
	}
	
	// Return all recent events
	return []RiskEvent{
		{
			ID:          "event_001",
			PositionID:  "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
			EventType:   "ThresholdBreach",
			HealthFactor: 2.1,
			Threshold:   2.0,
			TxHash:      "0xabc123def456789abc123def456789abc123def456789abc123def456789abc123",
			BlockNumber: 18500000,
			Timestamp:   now - 3600, // 1 hour ago
			Replayed:    false,
		},
		{
			ID:          "event_002",
			PositionID:  "0x2345678901bcdef12345678901bcdef12345678901bcdef12345678901bcdef1",
			EventType:   "ThresholdBreach",
			HealthFactor: 1.25,
			Threshold:   1.3,
			TxHash:      "0xdef456789abc123def456789abc123def456789abc123def456789abc123def456",
			BlockNumber: 18500100,
			Timestamp:   now - 1800, // 30 minutes ago
			Replayed:    false,
		},
		{
			ID:          "event_003",
			PositionID:  "0x3456789012cdef123456789012cdef123456789012cdef123456789012cdef12",
			EventType:   "ProtectionTriggered",
			HealthFactor: 1.05,
			Threshold:   1.1,
			TxHash:      "0x789abc123def456789abc123def456789abc123def456789abc123def456789abc",
			BlockNumber: 18500200,
			Timestamp:   now - 600, // 10 minutes ago
			Replayed:    true,
		},
		{
			ID:          "event_004",
			PositionID:  "0x3456789012cdef123456789012cdef123456789012cdef123456789012cdef12",
			EventType:   "ManualAction",
			HealthFactor: 1.15,
			Threshold:   1.1,
			TxHash:      "0x456789abc123def456789abc123def456789abc123def456789abc123def456789",
			BlockNumber: 18500250,
			Timestamp:   now - 300, // 5 minutes ago
			Replayed:    false,
		},
	}
}