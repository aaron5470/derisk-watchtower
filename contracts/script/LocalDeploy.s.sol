// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PositionVault.sol";
import "../src/Protector.sol";
import "../src/DemoEscrow.sol";
import "../src/mocks/MockPriceFeed.sol";

/// @title LocalDeploy
/// @notice Local deployment script for testing
contract LocalDeploy is Script {
    function run() external {
        // Use a fixed private key for local testing
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy PositionVault
        PositionVault vault = new PositionVault();
        console.log("PositionVault deployed at:", address(vault));

        // 2. Deploy DemoEscrow
        DemoEscrow escrow = new DemoEscrow();
        console.log("DemoEscrow deployed at:", address(escrow));

        // 3. Deploy Mock Price Feeds
        MockPriceFeed collateralFeed = new MockPriceFeed(8, "ETH/USD", 2000e8);
        console.log("Collateral Price Feed deployed at:", address(collateralFeed));

        MockPriceFeed debtFeed = new MockPriceFeed(8, "USDC/USD", 1e8);
        console.log("Debt Price Feed deployed at:", address(debtFeed));

        // 4. Deploy Protector
        Protector protector = new Protector(
            address(vault),
            address(escrow),
            address(collateralFeed),
            address(debtFeed)
        );
        console.log("Protector deployed at:", address(protector));

        // 5. Authorize Protector in Escrow
        escrow.authorizeProtector(address(protector));
        console.log("Protector authorized in Escrow");

        // Stop broadcasting
        vm.stopBroadcast();

        // Log deployment summary
        console.log("\n=== Local Deployment Summary ===");
        console.log("Chain ID:", block.chainid);
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("PositionVault:", address(vault));
        console.log("DemoEscrow:", address(escrow));
        console.log("Protector:", address(protector));
        console.log("================================\n");
    }
}