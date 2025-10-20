package models

import (
	"time"
)

type RiskEventType string

const (
	ThresholdBreach     RiskEventType = "ThresholdBreach"
	ProtectionTriggered RiskEventType = "ProtectionTriggered"
	ManualAction        RiskEventType = "ManualAction"
)

type RiskEvent struct {
	ID         string        `json:"id"`
	PositionID string        `json:"position_id"`
	EventType  RiskEventType `json:"event_type"`
	PreviousHF float64       `json:"previous_hf"`
	NewHF      float64       `json:"new_hf"`
	DeltaHF    float64       `json:"delta_hf"`
	TxHash     string        `json:"tx_hash"`
	Timestamp  time.Time     `json:"timestamp"`
	Replayed   bool          `json:"replayed,omitempty"`
}