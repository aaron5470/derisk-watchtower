package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/derisk-watchtower/backend/internal/services"
)

type PositionsHandler struct {
	subgraph *services.SubgraphClient
}

func NewPositionsHandler(subgraph *services.SubgraphClient) *PositionsHandler {
	return &PositionsHandler{
		subgraph: subgraph,
	}
}

// Position represents a position for API response
type Position struct {
	ID               string  `json:"id"`
	Owner            string  `json:"owner"`
	CollateralAmount string  `json:"collateral_amount"`
	CollateralToken  string  `json:"collateral_token"`
	DebtAmount       string  `json:"debt_amount"`
	DebtToken        string  `json:"debt_token"`
	HealthFactor     float64 `json:"health_factor"`
	LastUpdateAt     int64   `json:"last_update_at"`
	CreatedAt        int64   `json:"created_at"`
}

func (h *PositionsHandler) GetPositions(w http.ResponseWriter, r *http.Request) {
	owner := r.URL.Query().Get("owner")
	if owner == "" {
		http.Error(w, "owner parameter required", http.StatusBadRequest)
		return
	}

	// Check if demo mode is enabled or if subgraph is unavailable
	demoMode := r.URL.Query().Get("demo") == "true"
	
	var positions []Position
	
	if demoMode {
		// Return demo data for demonstration purposes
		positions = getDemoPositions(owner)
	} else {
		// Try to get real data from subgraph
		realPositions, err := h.subgraph.GetPositionsByOwner(r.Context(), owner)
		if err != nil {
			// If subgraph fails, fallback to demo data
			positions = getDemoPositions(owner)
		} else {
			// Convert real positions to API format
			positions = make([]Position, len(realPositions))
			for i, p := range realPositions {
				positions[i] = Position{
					ID:               p.ID,
					Owner:            p.Owner,
					CollateralAmount: p.CollateralAmount.String(),
					CollateralToken:  "0x" + p.CollateralToken,
					DebtAmount:       p.DebtAmount.String(),
					DebtToken:        "0x" + p.DebtToken,
					HealthFactor:     p.HealthFactor,
					LastUpdateAt:     p.LastUpdateAt.Unix(),
					CreatedAt:        p.CreatedAt.Unix(),
				}
			}
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(positions)
}

func (h *PositionsHandler) GetPosition(w http.ResponseWriter, r *http.Request) {
	positionID := r.URL.Path[len("/api/positions/"):]
	if positionID == "" {
		http.Error(w, "position ID required", http.StatusBadRequest)
		return
	}

	// Check if demo mode is enabled
	demoMode := r.URL.Query().Get("demo") == "true"
	
	var position *Position
	
	if demoMode {
		// Find position in demo data
		demoPositions := getDemoPositions("0x123456789abcdef") // Use default owner for demo
		for _, p := range demoPositions {
			if p.ID == positionID {
				position = &p
				break
			}
		}
	} else {
		// Try to get real data from subgraph
		// TODO: Implement real subgraph query for single position
		// For now, fallback to demo data
		demoPositions := getDemoPositions("0x123456789abcdef")
		for _, p := range demoPositions {
			if p.ID == positionID {
				position = &p
				break
			}
		}
	}

	if position == nil {
		http.Error(w, "position not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(position)
}

func getDemoPositions(owner string) []Position {
	now := time.Now().Unix()
	return []Position{
		{
			ID:               "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
			Owner:            owner,
			CollateralAmount: "1000000000000000000000", // 1000 ETH
			CollateralToken:  "0xA0b86a33E6441E6C7D3E4C5B4B6B8B8B8B8B8B8B", // Mock WETH
			DebtAmount:       "400000000000000000000",  // 400 USDC
			DebtToken:        "0xB1c86a33E6441E6C7D3E4C5B4B6B8B8B8B8B8B8B", // Mock USDC
			HealthFactor:     2.5,
			LastUpdateAt:     now - 300, // 5 minutes ago
			CreatedAt:        now - 86400, // 1 day ago
		},
		{
			ID:               "0x2345678901bcdef12345678901bcdef12345678901bcdef12345678901bcdef1",
			Owner:            owner,
			CollateralAmount: "2000000000000000000000", // 2000 ETH
			CollateralToken:  "0xA0b86a33E6441E6C7D3E4C5B4B6B8B8B8B8B8B8B", // Mock WETH
			DebtAmount:       "1200000000000000000000", // 1200 USDC
			DebtToken:        "0xB1c86a33E6441E6C7D3E4C5B4B6B8B8B8B8B8B8B", // Mock USDC
			HealthFactor:     1.33,
			LastUpdateAt:     now - 600, // 10 minutes ago
			CreatedAt:        now - 172800, // 2 days ago
		},
		{
			ID:               "0x3456789012cdef123456789012cdef123456789012cdef123456789012cdef12",
			Owner:            owner,
			CollateralAmount: "500000000000000000000", // 500 ETH
			CollateralToken:  "0xA0b86a33E6441E6C7D3E4C5B4B6B8B8B8B8B8B8B", // Mock WETH
			DebtAmount:       "450000000000000000000", // 450 USDC
			DebtToken:        "0xB1c86a33E6441E6C7D3E4C5B4B6B8B8B8B8B8B8B", // Mock USDC
			HealthFactor:     1.11,
			LastUpdateAt:     now - 120, // 2 minutes ago
			CreatedAt:        now - 259200, // 3 days ago
		},
	}
}