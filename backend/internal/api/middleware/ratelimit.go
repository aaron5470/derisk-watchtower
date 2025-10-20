package middleware

import (
	"net/http"
	"sync"
	"time"
)

type RateLimiter struct {
	requests map[string][]time.Time
	mu       sync.Mutex
	limit    int
	window   time.Duration
}

func NewRateLimiter(limit int, window time.Duration) *RateLimiter {
	return &RateLimiter{
		requests: make(map[string][]time.Time),
		limit:    limit,
		window:   window,
	}
}

func (rl *RateLimiter) Middleware() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ip := r.RemoteAddr

			rl.mu.Lock()
			defer rl.mu.Unlock()

			now := time.Now()
			cutoff := now.Add(-rl.window)

			// Clean old requests
			if times, ok := rl.requests[ip]; ok {
				filtered := make([]time.Time, 0)
				for _, t := range times {
					if t.After(cutoff) {
						filtered = append(filtered, t)
					}
				}
				rl.requests[ip] = filtered
			}

			// Check limit
			if len(rl.requests[ip]) >= rl.limit {
				http.Error(w, "rate limit exceeded", http.StatusTooManyRequests)
				return
			}

			// Add current request
			rl.requests[ip] = append(rl.requests[ip], now)

			next.ServeHTTP(w, r)
		})
	}
}