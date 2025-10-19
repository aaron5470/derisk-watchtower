// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PositionVault.sol";
import "../src/DemoEscrow.sol";
import "../src/Protector.sol";
import "../src/mocks/MockPriceFeed.sol";

/// @title TestAutomation
/// @notice Script to test the complete automation workflow
/// @dev Creates test positions and verifies automation functionality
contract TestAutomation is Script {
    
    // Contract addresses from local deployment
    PositionVault constant positionVault = PositionVault(0x5FbDB2315678afecb367f032d93F642f64180aa3);
    DemoEscrow constant escrow = DemoEscrow(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
    Protector constant protector = Protector(0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9);
    MockPriceFeed constant collateralPriceFeed = MockPriceFeed(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0);
    MockPriceFeed constant debtPriceFeed = MockPriceFeed(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9);

    // Test user private key (from Anvil default accounts)
    uint256 constant TEST_USER_PRIVATE_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    address constant TEST_USER = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function run() external {
        console.log("=== Testing Automation Workflow ===");
        
        vm.startBroadcast(TEST_USER_PRIVATE_KEY);
        
        // Step 1: Create a test position
        console.log("\n1. Creating test position...");
        bytes32 positionId = createTestPosition();
        console.log("Created position ID:");
        console.logBytes32(positionId);
        
        // Step 2: Deposit collateral to escrow
        console.log("\n2. Depositing collateral to escrow...");
        depositCollateralToEscrow(positionId);
        
        // Step 3: Test checkUpkeep with the new position
        console.log("\n3. Testing checkUpkeep...");
        testCheckUpkeep(positionId);
        
        // Step 4: Simulate price drop to trigger protection
        console.log("\n4. Simulating price drop...");
        simulatePriceDrop();
        
        // Step 5: Test checkUpkeep again (should need upkeep now)
        console.log("\n5. Testing checkUpkeep after price drop...");
        testCheckUpkeepAfterPriceDrop(positionId);
        
        // Step 6: Test manual performUpkeep
        console.log("\n6. Testing manual performUpkeep...");
        testPerformUpkeep(positionId);
        
        vm.stopBroadcast();
        
        console.log("\n=== Automation Test Complete ===");
    }
    
    function createTestPosition() internal returns (bytes32 positionId) {
        // Create a position with some collateral and debt
        address collateralToken = address(0x1); // Mock collateral token address
        uint256 collateralAmount = 1 ether; // 1 ETH worth of collateral
        address debtToken = address(0x2); // Mock debt token address
        uint256 debtAmount = 1000e18; // 1000 debt tokens
        
        positionId = positionVault.createPosition(
            collateralToken,
            collateralAmount,
            debtToken,
            debtAmount
        );
        
        console.log("Position created with:");
        console.log("- Collateral:", collateralAmount);
        console.log("- Debt:", debtAmount);
        
        return positionId;
    }
    
    function depositCollateralToEscrow(bytes32 positionId) internal {
        // Deposit some collateral to escrow for protection
        uint256 escrowAmount = 0.5 ether; // 0.5 ETH for protection
        
        // In a real scenario, user would approve and transfer tokens
        // For testing, we'll simulate this
        console.log("Depositing", escrowAmount, "to escrow for position protection");
        
        // Note: In production, this would involve actual token transfers
        // For testing, we assume the escrow has sufficient balance
    }
    
    function testCheckUpkeep(bytes32 positionId) internal view {
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = positionId;
        bytes memory checkData = abi.encode(positions);
        
        (bool upkeepNeeded, bytes memory performData) = protector.checkUpkeep(checkData);
        
        console.log("checkUpkeep result:");
        console.log("- Upkeep needed:", upkeepNeeded);
        
        if (upkeepNeeded) {
            bytes32 needsProtectionId = abi.decode(performData, (bytes32));
            console.log("- Position needing protection:");
            console.logBytes32(needsProtectionId);
        }
    }
    
    function simulatePriceDrop() internal {
        // Simulate a significant price drop in collateral
        // This should make the health factor drop below the threshold
        
        console.log("Current collateral price:", collateralPriceFeed.price());
        
        // Drop collateral price by 40% (from 2000 to 1200)
        int256 newPrice = 1200e8; // $1200 with 8 decimals
        collateralPriceFeed.setPrice(newPrice);
        
        console.log("New collateral price:", collateralPriceFeed.price());
        console.log("Price dropped by 40% - should trigger protection need");
    }
    
    function testCheckUpkeepAfterPriceDrop(bytes32 positionId) internal view {
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = positionId;
        bytes memory checkData = abi.encode(positions);
        
        (bool upkeepNeeded, bytes memory performData) = protector.checkUpkeep(checkData);
        
        console.log("checkUpkeep after price drop:");
        console.log("- Upkeep needed:", upkeepNeeded);
        
        if (upkeepNeeded) {
            bytes32 needsProtectionId = abi.decode(performData, (bytes32));
            console.log("- Position needing protection:");
            console.logBytes32(needsProtectionId);
            console.log("SUCCESS: Automation correctly detected position needing protection!");
        } else {
            console.log("WARNING: Position should need protection but checkUpkeep returned false");
        }
    }
    
    function testPerformUpkeep(bytes32 positionId) internal {
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = positionId;
        bytes memory checkData = abi.encode(positions);
        
        (bool upkeepNeeded, bytes memory performData) = protector.checkUpkeep(checkData);
        
        if (upkeepNeeded) {
            console.log("Executing performUpkeep...");
            
            try protector.performUpkeep(performData) {
                console.log("SUCCESS: performUpkeep executed successfully!");
                console.log("Position should now be protected");
                
                // Verify the position is now safe
                verifyPositionProtected(positionId);
            } catch Error(string memory reason) {
                console.log("performUpkeep failed with reason:", reason);
            } catch {
                console.log("performUpkeep failed with unknown error");
            }
        } else {
            console.log("No upkeep needed, skipping performUpkeep test");
        }
    }
    
    function verifyPositionProtected(bytes32 positionId) internal view {
        // Check if the position's health factor improved
        console.log("Verifying position protection...");
        
        // In a real implementation, we would check:
        // 1. Position's health factor is now >= 1.5
        // 2. Collateral was transferred from escrow to position
        // 3. Protection event was emitted
        
        console.log("Position verification complete");
        console.log("(In production, this would check actual health factor and collateral balances)");
    }
}