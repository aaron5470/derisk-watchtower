package models

import (
	"math/big"
	"time"
)

type ProtectionActionType string

const (
	AddCollateral ProtectionActionType = "AddCollateral"
	RepayDebt     ProtectionActionType = "RepayDebt"
)

type ProtectionAction struct {
	ID              string               `json:"id"`
	PositionID      string               `json:"position_id"`
	ActionType      ProtectionActionType `json:"action_type"`
	BeforeHF        float64              `json:"before_hf"`
	AfterHF         float64              `json:"after_hf"`
	CollateralDelta *big.Int             `json:"collateral_delta"`
	DebtDelta       *big.Int             `json:"debt_delta"`
	TxHash          string               `json:"tx_hash"`
	Timestamp       time.Time            `json:"timestamp"`
	Executor        string               `json:"executor"`
}