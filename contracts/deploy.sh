#!/bin/bash
echo "Starting deployment..."
echo "Checking connection to anvil..."
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://anvil-testnet:8545
echo ""
echo "Running forge script..."
forge script script/LocalDeploy.s.sol --rpc-url http://anvil-testnet:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvv
echo "Deployment completed."