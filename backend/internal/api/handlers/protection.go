package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/derisk-watchtower/backend/internal/services"
)

// ProtectionHandler handles manual protection-related API requests
type ProtectionHandler struct {
	protectionService *services.ProtectionService
}

// NewProtectionHandler creates a new protection handler
func NewProtectionHandler(protectionService *services.ProtectionService) *ProtectionHandler {
	return &ProtectionHandler{
		protectionService: protectionService,
	}
}

// ManualProtectRequest represents the request body for manual protection
type ManualProtectRequest struct {
	PositionID string `json:"position_id" validate:"required"`
}

// ManualProtectResponse represents the response for manual protection
type ManualProtectResponse struct {
	TxHash  string `json:"tx_hash"`
	Status  string `json:"status"`
	Message string `json:"message"`
}

// ManualProtect handles manual protection requests
// POST /api/protection/manual
//
// This endpoint allows users to manually trigger position protection
// when Chainlink Automation is delayed or unavailable.
//
// Request body:
//
//	{
//	  "position_id": "0x05160687fb252bb950f996cafae447c81269b909d6fb181b0fb7b293bec00aed"
//	}
//
// Response:
//
//	{
//	  "tx_hash": "0xabcd...",
//	  "status": "pending",
//	  "message": "Protection transaction submitted successfully"
//	}
func (h *ProtectionHandler) ManualProtect(w http.ResponseWriter, r *http.Request) {
	var req ManualProtectRequest

	// Decode request body
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body: "+err.Error(), http.StatusBadRequest)
		return
	}

	// Validate position ID
	if req.PositionID == "" {
		http.Error(w, "position_id is required", http.StatusBadRequest)
		return
	}

	// Execute manual protection via service
	txHash, err := h.protectionService.ExecuteManualProtection(r.Context(), req.PositionID)
	if err != nil {
		http.Error(w, "Protection failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Return success response
	response := ManualProtectResponse{
		TxHash:  txHash,
		Status:  "pending",
		Message: "Protection transaction submitted successfully",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
