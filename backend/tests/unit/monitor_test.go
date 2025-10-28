package unit

import (
	"testing"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/stretchr/testify/assert"
)

func TestMonitorService_RegisterPosition(t *testing.T) {
	alerter := services.NewAlerterService()
	monitor := services.NewMonitorService(nil, nil, alerter)

	position := &models.Position{
		ID:           "0x123",
		Owner:        "0xabc",
		HealthFactor: 1.5,
		LastUpdateAt: time.Now(),
	}

	monitor.RegisterPosition(position)

	assert.Equal(t, 1, monitor.GetMonitoredCount())
}

func TestMonitorService_UnregisterPosition(t *testing.T) {
	alerter := services.NewAlerterService()
	monitor := services.NewMonitorService(nil, nil, alerter)

	position := &models.Position{
		ID:           "0x123",
		Owner:        "0xabc",
		HealthFactor: 1.5,
		LastUpdateAt: time.Now(),
	}

	monitor.RegisterPosition(position)
	monitor.UnregisterPosition("0x123")

	assert.Equal(t, 0, monitor.GetMonitoredCount())
}