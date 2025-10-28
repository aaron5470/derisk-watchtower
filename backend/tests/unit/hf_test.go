package unit

import (
	"testing"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
	"github.com/stretchr/testify/assert"
)

func TestPosition_IsHealthy(t *testing.T) {
	tests := []struct {
		name     string
		hf       float64
		expected bool
	}{
		{"Safe", 1.6, true},
		{"Borderline", 1.5, false},
		{"Warning", 1.4, false},
		{"Critical", 1.2, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			position := &models.Position{
				HealthFactor: tt.hf,
				LastUpdateAt: time.Now(),
			}
			assert.Equal(t, tt.expected, position.IsHealthy())
		})
	}
}

func TestPosition_IsCritical(t *testing.T) {
	tests := []struct {
		name     string
		hf       float64
		expected bool
	}{
		{"Safe", 1.6, false},
		{"Warning", 1.4, false},
		{"Threshold", 1.3, true},
		{"Critical", 1.2, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			position := &models.Position{
				HealthFactor: tt.hf,
				LastUpdateAt: time.Now(),
			}
			assert.Equal(t, tt.expected, position.IsCritical())
		})
	}
}