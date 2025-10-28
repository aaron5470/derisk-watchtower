package models

import (
	"math/big"
	"time"
)

type Position struct {
	ID                string    `json:"id"`
	Owner             string    `json:"owner"`
	CollateralAmount  *big.Int  `json:"collateral_amount"`
	CollateralToken   string    `json:"collateral_token"`
	DebtAmount        *big.Int  `json:"debt_amount"`
	DebtToken         string    `json:"debt_token"`
	HealthFactor      float64   `json:"health_factor"`
	LastUpdateAt      time.Time `json:"last_update_at"`
	CreatedAt         time.Time `json:"created_at"`
}

func (p *Position) IsHealthy() bool {
	return p.HealthFactor > 1.5
}

func (p *Position) IsWarning() bool {
	return p.HealthFactor > 1.3 && p.HealthFactor <= 1.5
}

func (p *Position) IsCritical() bool {
	return p.HealthFactor <= 1.3
}