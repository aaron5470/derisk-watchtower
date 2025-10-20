package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/derisk-watchtower/backend/internal/api"
	"github.com/derisk-watchtower/backend/internal/config"
	"github.com/derisk-watchtower/backend/internal/services"
	"github.com/ethereum/go-ethereum/common"
)

func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func main() {
	// Load configuration
	cfg := &config.Config{
		RPCEndpoint:       getEnvOrDefault("RPC_URL", "http://localhost:8545"),
		SubgraphEndpoint:  getEnvOrDefault("SUBGRAPH_ENDPOINT", "http://localhost:8000/subgraphs/name/derisk-watchtower"),
		ProtectorAddress:  os.Getenv("PROTECTOR_ADDRESS"),
	}

	if cfg.ProtectorAddress == "" {
		log.Fatal("PROTECTOR_ADDRESS environment variable is required")
	}

	// Initialize automation service
	automationService, err := services.NewAutomationService(cfg.RPCEndpoint, common.HexToAddress(cfg.ProtectorAddress))
	if err != nil {
		log.Fatalf("Failed to initialize automation service: %v", err)
	}
	defer automationService.Close()

	// Start background automation monitoring
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go automationService.StartMonitoring(ctx, 30*time.Second) // Monitor every 30 seconds

	// Setup router using our router configuration
	r := api.NewRouter(cfg)

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
