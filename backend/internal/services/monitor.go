package services

import (
	"context"
	"log"
	"sync"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
)

type MonitorService struct {
	subgraph    *SubgraphClient
	rpcClient   *RPCClient
	alerter     *AlerterService
	interval    time.Duration
	mu          sync.RWMutex
	positions   map[string]*models.Position
	stopCh      chan struct{}
}

func NewMonitorService(
	subgraph *SubgraphClient,
	rpcClient *RPCClient,
	alerter *AlerterService,
) *MonitorService {
	return &MonitorService{
		subgraph:  subgraph,
		rpcClient: rpcClient,
		alerter:   alerter,
		interval:  5 * time.Second,
		positions: make(map[string]*models.Position),
		stopCh:    make(chan struct{}),
	}
}

func (m *MonitorService) Start(ctx context.Context) {
	ticker := time.NewTicker(m.interval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			if err := m.checkAllPositions(ctx); err != nil {
				log.Printf("Monitor error: %v", err)
			}
		case <-m.stopCh:
			return
		case <-ctx.Done():
			return
		}
	}
}

func (m *MonitorService) Stop() {
	close(m.stopCh)
}

func (m *MonitorService) checkAllPositions(ctx context.Context) error {
	m.mu.RLock()
	positions := make([]*models.Position, 0, len(m.positions))
	for _, p := range m.positions {
		positions = append(positions, p)
	}
	m.mu.RUnlock()

	for _, position := range positions {
		if err := m.checkPosition(ctx, position); err != nil {
			log.Printf("Error checking position %s: %v", position.ID, err)
			continue
		}
	}

	return nil
}

func (m *MonitorService) checkPosition(ctx context.Context, position *models.Position) error {
	// Check if HF crossed threshold
	if position.IsCritical() {
		alert := models.NewRiskAlert(
			position.ID,
			position.HealthFactor,
			1.3,
		)
		m.alerter.BroadcastAlert(alert)
	}

	return nil
}

func (m *MonitorService) RegisterPosition(position *models.Position) {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.positions[position.ID] = position
	log.Printf("Registered position: %s (HF: %.4f)", position.ID, position.HealthFactor)
}

func (m *MonitorService) UnregisterPosition(positionID string) {
	m.mu.Lock()
	defer m.mu.Unlock()

	delete(m.positions, positionID)
	log.Printf("Unregistered position: %s", positionID)
}

func (m *MonitorService) GetMonitoredCount() int {
	m.mu.RLock()
	defer m.mu.RUnlock()

	return len(m.positions)
}