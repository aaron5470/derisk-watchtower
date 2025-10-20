package services

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"strconv"
	"time"

	"github.com/derisk-watchtower/backend/internal/models"
)

type SubgraphClient struct {
	endpoint string
	client   *http.Client
}

func NewSubgraphClient(endpoint string) *SubgraphClient {
	return &SubgraphClient{
		endpoint: endpoint,
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

func (s *SubgraphClient) GetPositionsByOwner(ctx context.Context, owner string) ([]*models.Position, error) {
	query := `
		query PositionsByOwner($owner: Bytes!) {
			positions(where: { owner: $owner }) {
				id
				owner
				collateralAmount
				collateralToken
				debtAmount
				debtToken
				healthFactor
				lastUpdateTimestamp
				createdAt
			}
		}
	`

	variables := map[string]interface{}{
		"owner": owner,
	}

	var response struct {
		Data struct {
			Positions []struct {
				ID                  string `json:"id"`
				Owner               string `json:"owner"`
				CollateralAmount    string `json:"collateralAmount"`
				CollateralToken     string `json:"collateralToken"`
				DebtAmount          string `json:"debtAmount"`
				DebtToken           string `json:"debtToken"`
				HealthFactor        string `json:"healthFactor"`
				LastUpdateTimestamp string `json:"lastUpdateTimestamp"`
				CreatedAt           string `json:"createdAt"`
			} `json:"positions"`
		} `json:"data"`
	}

	if err := s.executeQuery(ctx, query, variables, &response); err != nil {
		return nil, err
	}

	// Convert to models.Position
	positions := make([]*models.Position, 0, len(response.Data.Positions))
	for _, p := range response.Data.Positions {
		position := convertToPosition(p)
		positions = append(positions, position)
	}

	return positions, nil
}

func (s *SubgraphClient) executeQuery(ctx context.Context, query string, variables map[string]interface{}, result interface{}) error {
	body := map[string]interface{}{
		"query":     query,
		"variables": variables,
	}

	jsonBody, err := json.Marshal(body)
	if err != nil {
		return err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", s.endpoint, bytes.NewBuffer(jsonBody))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := s.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("subgraph query failed: %s", resp.Status)
	}

	return json.NewDecoder(resp.Body).Decode(result)
}

func (s *SubgraphClient) CheckStaleness(ctx context.Context) (bool, int64, error) {
	query := `
		query CheckSync {
			_meta {
				block {
					number
					timestamp
				}
			}
		}
	`

	var response struct {
		Data struct {
			Meta struct {
				Block struct {
					Timestamp int64 `json:"timestamp"`
				} `json:"block"`
			} `json:"_meta"`
		} `json:"data"`
	}

	if err := s.executeQuery(ctx, query, nil, &response); err != nil {
		return false, 0, err
	}

	lastSync := response.Data.Meta.Block.Timestamp
	now := time.Now().Unix()
	isStale := (now - lastSync) > 60 // >60s = stale

	return isStale, lastSync, nil
}

func convertToPosition(p struct {
	ID                  string `json:"id"`
	Owner               string `json:"owner"`
	CollateralAmount    string `json:"collateralAmount"`
	CollateralToken     string `json:"collateralToken"`
	DebtAmount          string `json:"debtAmount"`
	DebtToken           string `json:"debtToken"`
	HealthFactor        string `json:"healthFactor"`
	LastUpdateTimestamp string `json:"lastUpdateTimestamp"`
	CreatedAt           string `json:"createdAt"`
}) *models.Position {
	collateralAmount, _ := new(big.Int).SetString(p.CollateralAmount, 10)
	debtAmount, _ := new(big.Int).SetString(p.DebtAmount, 10)
	healthFactor, _ := strconv.ParseFloat(p.HealthFactor, 64)
	lastUpdate, _ := strconv.ParseInt(p.LastUpdateTimestamp, 10, 64)
	createdAt, _ := strconv.ParseInt(p.CreatedAt, 10, 64)

	return &models.Position{
		ID:               p.ID,
		Owner:            p.Owner,
		CollateralAmount: collateralAmount,
		DebtAmount:       debtAmount,
		HealthFactor:     healthFactor,
		LastUpdateAt:     time.Unix(lastUpdate, 0),
		CreatedAt:        time.Unix(createdAt, 0),
	}
}