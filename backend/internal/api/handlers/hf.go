package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/go-chi/chi/v5"
)

type HFHandler struct {
	subgraph *services.SubgraphClient
}

func NewHFHandler(subgraph *services.SubgraphClient) *HFHandler {
	return &HFHandler{
		subgraph: subgraph,
	}
}

func (h *HFHandler) GetHealthFactor(w http.ResponseWriter, r *http.Request) {
	address := chi.URLParam(r, "address")
	
	// Check if demo mode is requested
	if r.URL.Query().Get("demo") == "true" {
		h.getDemoHealthFactor(w, r, address)
		return
	}

	// Fetch position from subgraph
	positions, err := h.subgraph.GetPositionsByOwner(r.Context(), address)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if len(positions) == 0 {
		http.Error(w, "position not found", http.StatusNotFound)
		return
	}

	position := positions[0]

	// Check staleness
	isStale, lastSync, _ := h.subgraph.CheckStaleness(r.Context())

	response := map[string]interface{}{
		"hf":             position.HealthFactor,
		"last_update_at": position.LastUpdateAt.Unix(),
		"is_stale":       isStale,
		"last_sync":      lastSync,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *HFHandler) getDemoHealthFactor(w http.ResponseWriter, r *http.Request, address string) {
	// Demo health factor data based on address
	var hf float64
	var riskLevel string
	
	// Use last character of address to determine health factor
	lastChar := address[len(address)-1:]
	
	switch lastChar {
	case "1":
		hf = 2.5
		riskLevel = "safe"
	case "2":
		hf = 1.33
		riskLevel = "moderate"
	case "3":
		hf = 1.11
		riskLevel = "risky"
	default:
		hf = 1.85
		riskLevel = "safe"
	}

	response := map[string]interface{}{
		"hf":             hf,
		"risk_level":     riskLevel,
		"last_update_at": 1704067200, // Fixed timestamp for demo
		"is_stale":       false,
		"last_sync":      1704067200,
		"demo_mode":      true,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}