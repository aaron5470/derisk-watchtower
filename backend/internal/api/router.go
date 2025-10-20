package api

import (
	"time"

	"github.com/derisk-watchtower/backend/internal/api/handlers"
	"github.com/derisk-watchtower/backend/internal/api/middleware"
	"github.com/derisk-watchtower/backend/internal/config"
	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
)

func NewRouter(cfg *config.Config) *chi.Mux {
	r := chi.NewRouter()

	// Middleware
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(chimiddleware.Timeout(60 * time.Second))
	r.Use(middleware.CORS())

	// Services
	subgraph := services.NewSubgraphClient(cfg.SubgraphEndpoint)
	alerter := services.NewAlerterService()
	go alerter.Run()

	// Handlers
	healthHandler := handlers.NewHealthHandler()
	positionsHandler := handlers.NewPositionsHandler(subgraph)
	hfHandler := handlers.NewHFHandler(subgraph)
	wsHandler := handlers.NewWSHandler(alerter)

	// Routes
	r.Get("/healthz", healthHandler.HandleHealth)
	r.Get("/metrics", handlers.HandleMetrics().ServeHTTP)

	r.Route("/api", func(r chi.Router) {
		r.Get("/positions", positionsHandler.GetPositions)
		r.Get("/hf/{address}", hfHandler.GetHealthFactor)
	})

	r.Get("/ws/risk-stream", wsHandler.HandleWebSocket)

	return r
}