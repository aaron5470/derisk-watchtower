package integration

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/derisk-watchtower/backend/internal/api"
	"github.com/derisk-watchtower/backend/internal/config"
	"github.com/stretchr/testify/assert"
)

func TestHealthEndpoint(t *testing.T) {
	cfg := &config.Config{
		SubgraphEndpoint: "http://localhost:8000",
	}

	router := api.NewRouter(cfg)
	req := httptest.NewRequest("GET", "/healthz", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "ok")
}

func TestMetricsEndpoint(t *testing.T) {
	cfg := &config.Config{
		SubgraphEndpoint: "http://localhost:8000",
	}

	router := api.NewRouter(cfg)
	req := httptest.NewRequest("GET", "/metrics", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Header().Get("Content-Type"), "text/plain")
}