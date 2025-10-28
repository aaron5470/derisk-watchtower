// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PositionVault.sol";
import "../src/Protector.sol";
import "../src/DemoEscrow.sol";
import "../src/mocks/MockERC20.sol";

/// @title Seed
/// @notice Seed script to populate contracts with demo data
contract Seed is Script {
    function run() external {
        // Read deployer private key
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Read deployed contract addresses from environment or use defaults
        address vaultAddress = vm.envOr("POSITION_VAULT_ADDRESS", address(0));
        address escrowAddress = vm.envOr("DEMO_ESCROW_ADDRESS", address(0));
        address protectorAddress = vm.envOr("PROTECTOR_ADDRESS", address(0));

        require(vaultAddress != address(0), "PositionVault address not set");
        require(escrowAddress != address(0), "DemoEscrow address not set");
        require(protectorAddress != address(0), "Protector address not set");

        PositionVault vault = PositionVault(vaultAddress);
        DemoEscrow escrow = DemoEscrow(escrowAddress);
        Protector protector = Protector(protectorAddress);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy mock tokens for demo
        console.log("Deploying demo tokens...");
        MockERC20 collateral = new MockERC20("Demo Wrapped ETH", "DWETH", 18);
        MockERC20 debt = new MockERC20("Demo USDC", "DUSDC", 6);

        console.log("Demo Collateral Token (DWETH):", address(collateral));
        console.log("Demo Debt Token (DUSDC):", address(debt));

        // 2. Mint tokens to escrow
        console.log("\nMinting tokens to escrow...");
        uint256 escrowCollateralAmount = 10000e18; // 10,000 DWETH
        uint256 escrowDebtAmount = 5000e18; // 5,000 DUSDC

        collateral.mint(address(escrow), escrowCollateralAmount);
        debt.mint(address(escrow), escrowDebtAmount);

        console.log("Minted", escrowCollateralAmount / 1e18, "DWETH to escrow");
        console.log("Minted", escrowDebtAmount / 1e18, "DUSDC to escrow");

        // 3. Create demo user positions
        console.log("\nCreating demo positions...");

        // Position 1: Healthy position
        bytes32 pos1 = vault.createPosition(
            address(collateral),
            1000e18, // 1000 DWETH collateral
            address(debt),
            400e18   // 400 DUSDC debt
        );
        console.log("Position 1 (Healthy):", vm.toString(pos1));
        console.log("  Collateral: 1000 DWETH, Debt: 400 DUSDC");

        // Position 2: Warning level position
        bytes32 pos2 = vault.createPosition(
            address(collateral),
            2000e18, // 2000 DWETH collateral
            address(debt),
            1200e18  // 1200 DUSDC debt (HF ~1.33)
        );
        console.log("Position 2 (Warning):", vm.toString(pos2));
        console.log("  Collateral: 2000 DWETH, Debt: 1200 DUSDC");

        // Position 3: At-risk position
        bytes32 pos3 = vault.createPosition(
            address(collateral),
            500e18,  // 500 DWETH collateral
            address(debt),
            300e18   // 300 DUSDC debt
        );
        console.log("Position 3 (At-risk):", vm.toString(pos3));
        console.log("  Collateral: 500 DWETH, Debt: 300 DUSDC");

        // Get position count
        uint256 totalPositions = vault.positionCount();
        console.log("\nTotal positions created:", totalPositions);

        // Check final health factors
        console.log("\nHealth Factors:");
        console.log("Position 1 HF:", vault.getPosition(pos1).healthFactor);
        console.log("Position 2 HF:", vault.getPosition(pos2).healthFactor);
        console.log("Position 3 HF:", vault.getPosition(pos3).healthFactor);

        vm.stopBroadcast();

        // Save seed data
        console.log("\n=== Seed Data Summary ===");
        console.log("Deployer:", deployer);
        console.log("Collateral Token:", address(collateral));
        console.log("Debt Token:", address(debt));
        console.log("Position 1 ID:", vm.toString(pos1));
        console.log("Position 2 ID:", vm.toString(pos2));
        console.log("Position 3 ID:", vm.toString(pos3));
        console.log("========================\n");

        // Create JSON output
        string memory seedData = string(
            abi.encodePacked(
                '{\n',
                '  "collateralToken": "', vm.toString(address(collateral)), '",\n',
                '  "debtToken": "', vm.toString(address(debt)), '",\n',
                '  "positions": [\n',
                '    {"id": "', vm.toString(pos1), '", "type": "healthy"},\n',
                '    {"id": "', vm.toString(pos2), '", "type": "warning"},\n',
                '    {"id": "', vm.toString(pos3), '", "type": "at-risk"}\n',
                '  ],\n',
                '  "timestamp": ', vm.toString(block.timestamp), '\n',
                '}'
            )
        );

        console.log("\nSeed data JSON:");
        console.log(seedData);
    }
}
