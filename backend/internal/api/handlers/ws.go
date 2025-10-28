package handlers

import (
	"log"
	"net/http"
	"strconv"

	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for demo
	},
}

type WSHandler struct {
	alerter *services.AlerterService
}

func NewWSHandler(alerter *services.AlerterService) *WSHandler {
	return &WSHandler{
		alerter: alerter,
	}
}

func (h *WSHandler) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade failed: %v", err)
		return
	}

	// Register client
	h.alerter.RegisterClient(conn)
	defer h.alerter.UnregisterClient(conn)

	// Check for replay request
	serverEventTs := r.URL.Query().Get("serverEventTs")
	if serverEventTs != "" {
		if ts, err := strconv.ParseInt(serverEventTs, 10, 64); err == nil {
			// Replay events since timestamp
			recentAlerts := h.alerter.GetRecentAlerts(ts)
			for _, alert := range recentAlerts {
				if err := conn.WriteJSON(alert); err != nil {
					log.Printf("Replay write error: %v", err)
					return
				}
			}
		}
	}

	// Keep connection alive
	for {
		if _, _, err := conn.ReadMessage(); err != nil {
			break
		}
	}
}