package handlers

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	RiskEventTriggerTotal = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "risk_event_trigger_total",
		Help: "Total number of risk events triggered",
	})

	ProtectSuccessTotal = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "protect_success_total",
		Help: "Total number of successful protection executions",
	})

	ProtectFailureTotal = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "protect_failure_total",
		Help: "Total number of failed protection executions",
	})

	AlertLatencySeconds = prometheus.NewHistogram(prometheus.HistogramOpts{
		Name:    "alert_latency_seconds",
		Help:    "Latency from detection to UI display in seconds",
		Buckets: []float64{0.5, 1, 2, 5, 10},
	})

	PositionsMonitored = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "positions_monitored",
		Help: "Current number of positions being monitored",
	})
)

func init() {
	prometheus.MustRegister(RiskEventTriggerTotal)
	prometheus.MustRegister(ProtectSuccessTotal)
	prometheus.MustRegister(ProtectFailureTotal)
	prometheus.MustRegister(AlertLatencySeconds)
	prometheus.MustRegister(PositionsMonitored)
}

func HandleMetrics() http.Handler {
	return promhttp.Handler()
}