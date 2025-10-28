package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/derisk-watchtower/backend/internal/services"
)

// AutomationHandler handles automation-related API requests
type AutomationHandler struct {
	automationService *services.AutomationService
}

// NewAutomationHandler creates a new automation handler
func NewAutomationHandler(automationService *services.AutomationService) *AutomationHandler {
	return &AutomationHandler{
		automationService: automationService,
	}
}

// AutomationStatusResponse represents the automation status API response
type AutomationStatusResponse struct {
	TotalTriggers uint64 `json:"total_triggers"`
	LastTriggerAt uint64 `json:"last_trigger_at"`
	DelaySeconds  uint64 `json:"delay_seconds"`
	IsHealthy     bool   `json:"is_healthy"`
}

// GetAutomationStatus returns the current automation health status
// GET /api/automation/status
func (h *AutomationHandler) GetAutomationStatus(w http.ResponseWriter, r *http.Request) {
	stats, err := h.automationService.CheckUpkeepStatus(r.Context())
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response := AutomationStatusResponse{
		TotalTriggers: stats.TotalTriggers,
		LastTriggerAt: stats.LastTrigger,
		DelaySeconds:  stats.TimeSinceLastTrigger,
		IsHealthy:     stats.TimeSinceLastTrigger < 600, // Healthy if delay < 10 minutes
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
