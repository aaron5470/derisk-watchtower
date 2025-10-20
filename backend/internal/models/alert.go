package models

import "time"

type RiskAlert struct {
	Type       string    `json:"type"`
	PositionID string    `json:"position_id"`
	HF         float64   `json:"hf"`
	Threshold  float64   `json:"threshold"`
	TxHash     string    `json:"tx_hash,omitempty"`
	Timestamp  int64     `json:"timestamp"`
	Replayed   bool      `json:"replayed"`
}

func NewRiskAlert(positionID string, hf, threshold float64) *RiskAlert {
	return &RiskAlert{
		Type:       "RiskAlert",
		PositionID: positionID,
		HF:         hf,
		Threshold:  threshold,
		Timestamp:  time.Now().Unix(),
		Replayed:   false,
	}
}