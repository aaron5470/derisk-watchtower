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