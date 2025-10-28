package main

import (
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// 自动化触发器总数
	automationTriggersTotal = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "automation_triggers_total",
		Help: "Total number of automation triggers",
	})

	// 警报延迟秒数（总和和计数）
	alertLatencySecondsSum = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "alert_latency_seconds_sum",
		Help: "Sum of alert latency in seconds",
	})

	alertLatencySecondsCount = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "alert_latency_seconds_count",
		Help: "Count of alert latency measurements",
	})

	// 自动化健康状态
	automationHealthy = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "automation_healthy",
		Help: "Automation system health status (1=healthy, 0=unhealthy)",
	})

	// 自动化延迟秒数
	automationDelaySeconds = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "automation_delay_seconds",
		Help: "Automation processing delay in seconds",
	})

	// 监控的仓位数量
	positionsMonitored = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "positions_monitored",
		Help: "Number of positions currently being monitored",
	})

	// 服务运行状态
	up = prometheus.NewGaugeVec(prometheus.GaugeOpts{
		Name: "up",
		Help: "Service uptime status",
	}, []string{"job"})
)

func init() {
	prometheus.MustRegister(automationTriggersTotal)
	prometheus.MustRegister(alertLatencySecondsSum)
	prometheus.MustRegister(alertLatencySecondsCount)
	prometheus.MustRegister(automationHealthy)
	prometheus.MustRegister(automationDelaySeconds)
	prometheus.MustRegister(positionsMonitored)
	prometheus.MustRegister(up)
}

func generateTestData() {
	// 随机生成一些测试数据
	rand.Seed(time.Now().UnixNano())

	// 增加自动化触发器计数
	automationTriggersTotal.Add(float64(rand.Intn(5) + 1))

	// 设置警报延迟数据
	latencySum := rand.Float64() * 10 // 0-10秒
	latencyCount := float64(rand.Intn(20) + 1)
	alertLatencySecondsSum.Set(latencySum)
	alertLatencySecondsCount.Set(latencyCount)

	// 设置自动化健康状态（80%概率为健康）
	if rand.Float64() < 0.8 {
		automationHealthy.Set(1)
	} else {
		automationHealthy.Set(0)
	}

	// 设置自动化延迟
	automationDelaySeconds.Set(rand.Float64() * 5) // 0-5秒延迟

	// 设置监控的仓位数量
	positionsMonitored.Set(float64(rand.Intn(50) + 10)) // 10-60个仓位

	// 设置服务状态
	up.WithLabelValues("watchtower").Set(1)
	up.WithLabelValues("prometheus").Set(1)
	up.WithLabelValues("grafana").Set(1)

	fmt.Printf("Generated test data at %s\n", time.Now().Format("15:04:05"))
}

func main() {
	// 启动时生成一次数据
	generateTestData()

	// 每30秒生成一次新数据
	ticker := time.NewTicker(30 * time.Second)
	go func() {
		for range ticker.C {
			generateTestData()
		}
	}()

	// 启动metrics服务器
	http.Handle("/metrics", promhttp.Handler())
	
	fmt.Println("Test data generator started on :8082/metrics")
	fmt.Println("Generating new data every 30 seconds...")
	
	if err := http.ListenAndServe(":8082", nil); err != nil {
		fmt.Printf("Error starting server: %v\n", err)
	}
}