package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/derisk-watchtower/backend/internal/api/handlers"
	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/ethereum/go-ethereum/common"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Version string `json:"version"`
	Now     int64  `json:"now"`
}

func main() {
	// Load configuration from environment
	rpcURL := os.Getenv("RPC_URL")
	if rpcURL == "" {
		rpcURL = "http://localhost:8545" // Default to local node
	}

	protectorAddr := os.Getenv("PROTECTOR_ADDRESS")
	if protectorAddr == "" {
		log.Fatal("PROTECTOR_ADDRESS environment variable is required")
	}

	// Initialize automation service
	automationService, err := services.NewAutomationService(rpcURL, common.HexToAddress(protectorAddr))
	if err != nil {
		log.Fatalf("Failed to initialize automation service: %v", err)
	}
	defer automationService.Close()

	// Start background automation monitoring
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go automationService.StartMonitoring(ctx, 30*time.Second) // Monitor every 30 seconds

	// Initialize handlers
	automationHandler := handlers.NewAutomationHandler(automationService)

	// Setup router
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(60 * time.Second))

	// Health check endpoint
	r.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(HealthResponse{
			Status:  "ok",
			Version: "0.1.0",
			Now:     time.Now().Unix(),
		})
	})

	// Prometheus metrics
	r.Handle("/metrics", promhttp.Handler())

	// API routes
	r.Route("/api", func(r chi.Router) {
		r.Route("/automation", func(r chi.Router) {
			r.Get("/status", automationHandler.GetAutomationStatus)
		})
	})

	port := os.Getenv("API_PORT")
	if port == "" {
		port = "8080"
	}

	// Setup graceful shutdown
	server := &http.Server{
		Addr:    ":" + port,
		Handler: r,
	}

	// Channel to listen for interrupt signals
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	// Start server in a goroutine
	go func() {
		log.Printf("Starting server on :%s", port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal
	<-stop
	log.Println("Shutting down server...")

	// Cancel background monitoring
	cancel()

	// Graceful shutdown with timeout
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutdownCancel()

	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server stopped")
}
