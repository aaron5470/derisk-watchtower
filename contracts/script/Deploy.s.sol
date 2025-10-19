// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PositionVault.sol";
import "../src/Protector.sol";
import "../src/DemoEscrow.sol";
import "../src/mocks/MockPriceFeed.sol";

/// @title Deploy
/// @notice Deployment script for DeRisk Watchtower contracts
contract Deploy is Script {
    function run() external {
        // Read deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy PositionVault
        PositionVault vault = new PositionVault();
        console.log("PositionVault deployed at:", address(vault));

        // 2. Deploy DemoEscrow
        DemoEscrow escrow = new DemoEscrow();
        console.log("DemoEscrow deployed at:", address(escrow));

        // 3. Deploy Mock Price Feeds (for testnet only)
        // TODO: Replace with real Chainlink price feeds for mainnet
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
        console.log("\n=== Deployment Summary ===");
        console.log("Network:", block.chainid);
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("PositionVault:", address(vault));
        console.log("DemoEscrow:", address(escrow));
        console.log("Protector:", address(protector));
        console.log("==========================\n");

        // Save deployment addresses (would be done via additional script in production)
        string memory deploymentInfo = string(
            abi.encodePacked(
                '{\n',
                '  "chainId": ', vm.toString(block.chainid), ',\n',
                '  "positionVault": "', vm.toString(address(vault)), '",\n',
                '  "demoEscrow": "', vm.toString(address(escrow)), '",\n',
                '  "protector": "', vm.toString(address(protector)), '",\n',
                '  "timestamp": ', vm.toString(block.timestamp), '\n',
                '}'
            )
        );

        // Write to file (requires --ffi flag)
        string[] memory inputs = new string[](3);
        inputs[0] = "echo";
        inputs[1] = deploymentInfo;
        inputs[2] = ">";

        console.log("\nDeployment config:");
        console.log(deploymentInfo);
    }
}
