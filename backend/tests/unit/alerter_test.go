package unit

import (
	"testing"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/stretchr/testify/assert"
)

func TestAlerterService_BroadcastAlert(t *testing.T) {
	alerter := services.NewAlerterService()
	go alerter.Run()

	alert := models.NewRiskAlert("0x123", 1.2, 1.3)

	alerter.BroadcastAlert(alert)

	// Allow time for processing
	time.Sleep(100 * time.Millisecond)

	recent := alerter.GetRecentAlerts(time.Now().Add(-1 * time.Minute).Unix())
	assert.Len(t, recent, 1)
	assert.Equal(t, "0x123", recent[0].PositionID)
}

func TestAlerterService_CleanHistory(t *testing.T) {
	alerter := services.NewAlerterService()

	// Add old alert
	oldAlert := models.NewRiskAlert("0x123", 1.2, 1.3)
	oldAlert.Timestamp = time.Now().Add(-2 * time.Minute).Unix()

	alerter.BroadcastAlert(oldAlert)

	// Clean history
	time.Sleep(100 * time.Millisecond)

	recent := alerter.GetRecentAlerts(time.Now().Add(-30 * time.Second).Unix())
	assert.Len(t, recent, 0)
}