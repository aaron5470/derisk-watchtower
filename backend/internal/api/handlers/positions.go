package handlers

import (
	"encoding/json"
	"net/http"

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

func (h *PositionsHandler) GetPositions(w http.ResponseWriter, r *http.Request) {
	owner := r.URL.Query().Get("owner")
	if owner == "" {
		http.Error(w, "owner parameter required", http.StatusBadRequest)
		return
	}

	positions, err := h.subgraph.GetPositionsByOwner(r.Context(), owner)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(positions)
}