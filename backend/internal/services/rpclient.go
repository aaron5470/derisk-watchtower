package services

import (
	"context"
	"fmt"
	"math/big"
	"math/rand"
	"sync"
	"time"

	"github.com/ethereum/go-ethereum/ethclient"
)

type RPCClient struct {
	client          *ethclient.Client
	endpoint        string
	circuitBreaker  *CircuitBreaker
}

type CircuitBreaker struct {
	failures      int
	lastFailTime  time.Time
	state         string // "closed", "open", "half-open"
	failThreshold int
	resetTimeout  time.Duration
	mu            sync.Mutex
}

func NewCircuitBreaker() *CircuitBreaker {
	return &CircuitBreaker{
		failThreshold: 5,
		resetTimeout:  60 * time.Second,
		state:         "closed",
	}
}

func (cb *CircuitBreaker) Call(fn func() error) error {
	cb.mu.Lock()
	defer cb.mu.Unlock()

	if cb.state == "open" {
		if time.Since(cb.lastFailTime) > cb.resetTimeout {
			cb.state = "half-open"
			cb.failures = 0
		} else {
			return fmt.Errorf("circuit breaker open")
		}
	}

	err := fn()
	if err != nil {
		cb.failures++
		cb.lastFailTime = time.Now()

		if cb.failures >= cb.failThreshold {
			cb.state = "open"
		}
		return err
	}

	if cb.state == "half-open" {
		cb.state = "closed"
		cb.failures = 0
	}

	return nil
}

func NewRPCClient(endpoint string) (*RPCClient, error) {
	client, err := ethclient.Dial(endpoint)
	if err != nil {
		return nil, err
	}

	return &RPCClient{
		client:         client,
		endpoint:       endpoint,
		circuitBreaker: NewCircuitBreaker(),
	}, nil
}

func (r *RPCClient) GetBlockNumber(ctx context.Context) (*big.Int, error) {
	var result *big.Int
	var err error

	cbErr := r.circuitBreaker.Call(func() error {
		result, err = r.retryOperation(func() (*big.Int, error) {
			blockNum, blockErr := r.client.BlockNumber(ctx)
			if blockErr != nil {
				return nil, blockErr
			}
			return new(big.Int).SetUint64(blockNum), nil
		})
		return err
	})

	if cbErr != nil {
		return nil, cbErr
	}

	return result, err
}

func (r *RPCClient) retryOperation(op func() (*big.Int, error)) (*big.Int, error) {
	const (
		initialDelay = 500 * time.Millisecond
		multiplier   = 2.0
		maxAttempts  = 5
		maxDelay     = 8 * time.Second
	)

	delay := initialDelay
	for attempt := 1; attempt <= maxAttempts; attempt++ {
		result, err := op()
		if err == nil {
			return result, nil
		}

		if attempt == maxAttempts {
			return nil, err
		}

		// Add jitter (±20%)
		jitter := time.Duration(float64(delay) * 0.2 * (2*rand.Float64() - 1))
		sleepTime := delay + jitter

		time.Sleep(sleepTime)

		delay = time.Duration(float64(delay) * multiplier)
		if delay > maxDelay {
			delay = maxDelay
		}
	}

	return nil, fmt.Errorf("max retries exceeded")
}

func (r *RPCClient) Close() {
	if r.client != nil {
		r.client.Close()
	}
}