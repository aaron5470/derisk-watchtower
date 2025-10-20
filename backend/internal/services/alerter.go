package services

import (
	"log"
	"sync"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
	"github.com/gorilla/websocket"
)

type AlerterService struct {
	clients    map[*websocket.Conn]bool
	broadcast  chan *models.RiskAlert
	register   chan *websocket.Conn
	unregister chan *websocket.Conn
	mu         sync.RWMutex
	history    []*models.RiskAlert
	historyTTL time.Duration
}

func NewAlerterService() *AlerterService {
	return &AlerterService{
		clients:    make(map[*websocket.Conn]bool),
		broadcast:  make(chan *models.RiskAlert, 100),
		register:   make(chan *websocket.Conn),
		unregister: make(chan *websocket.Conn),
		history:    make([]*models.RiskAlert, 0),
		historyTTL: 60 * time.Second,
	}
}

func (a *AlerterService) Run() {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case conn := <-a.register:
			a.mu.Lock()
			a.clients[conn] = true
			a.mu.Unlock()
			log.Printf("WebSocket client connected. Total: %d", len(a.clients))

		case conn := <-a.unregister:
			a.mu.Lock()
			if _, ok := a.clients[conn]; ok {
				delete(a.clients, conn)
				conn.Close()
			}
			a.mu.Unlock()
			log.Printf("WebSocket client disconnected. Total: %d", len(a.clients))

		case alert := <-a.broadcast:
			a.addToHistory(alert)
			a.broadcastToClients(alert)

		case <-ticker.C:
			a.cleanHistory()
		}
	}
}

func (a *AlerterService) broadcastToClients(alert *models.RiskAlert) {
	a.mu.RLock()
	defer a.mu.RUnlock()

	for conn := range a.clients {
		if err := conn.WriteJSON(alert); err != nil {
			log.Printf("WebSocket write error: %v", err)
			conn.Close()
			delete(a.clients, conn)
		}
	}
}

func (a *AlerterService) BroadcastAlert(alert *models.RiskAlert) {
	select {
	case a.broadcast <- alert:
	default:
		log.Println("Broadcast channel full, dropping alert")
	}
}

func (a *AlerterService) addToHistory(alert *models.RiskAlert) {
	a.mu.Lock()
	defer a.mu.Unlock()

	a.history = append(a.history, alert)
}

func (a *AlerterService) cleanHistory() {
	a.mu.Lock()
	defer a.mu.Unlock()

	cutoff := time.Now().Add(-a.historyTTL).Unix()
	filtered := make([]*models.RiskAlert, 0)

	for _, alert := range a.history {
		if alert.Timestamp >= cutoff {
			filtered = append(filtered, alert)
		}
	}

	a.history = filtered
}

func (a *AlerterService) GetRecentAlerts(since int64) []*models.RiskAlert {
	a.mu.RLock()
	defer a.mu.RUnlock()

	recent := make([]*models.RiskAlert, 0)
	for _, alert := range a.history {
		if alert.Timestamp >= since {
			alert.Replayed = true
			recent = append(recent, alert)
		}
	}

	return recent
}

func (a *AlerterService) RegisterClient(conn *websocket.Conn) {
	a.register <- conn
}

func (a *AlerterService) UnregisterClient(conn *websocket.Conn) {
	a.unregister <- conn
}