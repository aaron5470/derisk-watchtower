// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Protector.sol";
import "../src/PositionVault.sol";
import "../src/DemoEscrow.sol";
import "../src/mocks/MockPriceFeed.sol";
import "../src/mocks/MockERC20.sol";

/// @title ProtectorAutomationTest
/// @notice Tests for Chainlink Automation integration with Protector contract
/// @dev Covers E3.2 test requirements from E3-automation.md
contract ProtectorAutomationTest is Test {
    Protector public protector;
    PositionVault public vault;
    DemoEscrow public escrow;
    MockPriceFeed public collateralFeed;
    MockPriceFeed public debtFeed;
    MockERC20 public collateral;
    MockERC20 public debt;

    address public user = address(0x1);
    address public keeper = address(0x2);

    event AutomationTriggered(
        bytes32 indexed positionId,
        uint256 healthFactor,
        address indexed keeper
    );

    function setUp() public {
        // Deploy vault and escrow
        vault = new PositionVault();
        escrow = new DemoEscrow();

        // Deploy mock tokens
        collateral = new MockERC20("Collateral", "COL", 18);
        debt = new MockERC20("Debt", "DBT", 18);

        // Deploy mock price feeds
        collateralFeed = new MockPriceFeed(8, "COL/USD", 2000e8); // $2000
        debtFeed = new MockPriceFeed(8, "DBT/USD", 1000e8); // $1000

        // Deploy protector with price feeds
        protector = new Protector(
            address(vault),
            address(escrow),
            address(collateralFeed),
            address(debtFeed)
        );

        // Fund escrow with very large amount of collateral for testing
        collateral.mint(address(this), 100000000e18); // 100 million tokens
        collateral.approve(address(escrow), 100000000e18);
        escrow.fund(address(collateral), 100000000e18);

        // Authorize protector to withdraw from escrow
        escrow.authorizeProtector(address(protector));
    }

    /// @notice Helper function to create a test position with specified collateral and debt
    /// @param collateralAmount Amount of collateral in position
    /// @param debtAmount Amount of debt in position
    /// @return posId The created position ID
    function createTestPosition(uint256 collateralAmount, uint256 debtAmount)
        internal
        returns (bytes32 posId)
    {
        vm.startPrank(user);
        posId = vault.createPosition(
            address(collateral),
            collateralAmount,
            address(debt),
            debtAmount
        );
        vm.stopPrank();

        // Update HF with current prices
        uint256 colPrice = uint256(collateralFeed.price());
        uint256 dbtPrice = uint256(debtFeed.price());
        vault.updateHealthFactor(posId, colPrice, dbtPrice);

        return posId;
    }

    /// @notice Helper function to get position health factor
    /// @param posId Position ID
    /// @return Health factor of the position
    function getPositionHF(bytes32 posId) internal view returns (uint256) {
        return protector.getPositionHF(posId);
    }

    // ============================================
    // E3.2.3: Test checkUpkeep returns false for healthy position
    // ============================================
    function testCheckUpkeepHealthyPosition() public {
        // Create position with HF > 1.3
        // With collateral=$2000, debt=$1000: 1000e18 collateral, 400e18 debt
        // HF = (1000 * 2000 * 0.8) / (400 * 1000) = 4.0
        bytes32 posId = createTestPosition(1000e18, 400e18);

        bytes32[] memory positions = new bytes32[](1);
        positions[0] = posId;
        bytes memory checkData = abi.encode(positions);

        (bool upkeepNeeded,) = protector.checkUpkeep(checkData);
        assertFalse(upkeepNeeded, "Should not need upkeep for healthy position");
    }

    // ============================================
    // E3.2.4: Test checkUpkeep returns true for critical position
    // ============================================
    function testCheckUpkeepCriticalPosition() public {
        // Create position with HF < 1.3
        // With collateral=$2000, debt=$1000: 1000e18 collateral, 1230e18 debt
        // HF = (1000 * 2000 * 0.8) / (1230 * 1000) = 1.30 (borderline)
        // Use 1250e18 debt to ensure HF < 1.3
        bytes32 posId = createTestPosition(1000e18, 1250e18);

        bytes32[] memory positions = new bytes32[](1);
        positions[0] = posId;
        bytes memory checkData = abi.encode(positions);

        (bool upkeepNeeded, bytes memory performData) = protector.checkUpkeep(checkData);

        assertTrue(upkeepNeeded, "Should need upkeep for critical position");
        assertEq(abi.decode(performData, (bytes32)), posId, "performData should contain position ID");
    }

    // ============================================
    // E3.2.5: Test performUpkeep executes protection
    // ============================================
    function testPerformUpkeepExecutesProtection() public {
        // Create position with HF < 1.3
        bytes32 posId = createTestPosition(1000e18, 1250e18);
        bytes memory performData = abi.encode(posId);

        uint256 beforeHF = getPositionHF(posId);
        assertLt(beforeHF, 13000, "Position should be below critical threshold");

        vm.prank(keeper);
        protector.performUpkeep(performData);

        uint256 afterHF = getPositionHF(posId);
        assertGt(afterHF, beforeHF, "HF should improve after protection");
        assertGt(afterHF, 15000, "HF should be restored to safe level (1.5)");
    }

    // ============================================
    // E3.2.6: Test performUpkeep emits AutomationTriggered
    // ============================================
    function testPerformUpkeepEmitsEvent() public {
        bytes32 posId = createTestPosition(1000e18, 1250e18);
        bytes memory performData = abi.encode(posId);

        uint256 beforeHF = getPositionHF(posId);

        vm.expectEmit(true, true, false, true);
        emit AutomationTriggered(posId, beforeHF, keeper);

        vm.prank(keeper);
        protector.performUpkeep(performData);
    }

    // ============================================
    // E3.2.7: Test performUpkeep reverts if HF above threshold
    // ============================================
    function testPerformUpkeepRevertsIfHealthy() public {
        // Create healthy position with HF > 1.3
        bytes32 posId = createTestPosition(1000e18, 400e18);
        bytes memory performData = abi.encode(posId);

        vm.prank(keeper);
        vm.expectRevert("HF above threshold");
        protector.performUpkeep(performData);
    }

    // ============================================
    // E3.2.8: Test calculateCollateralNeeded accuracy
    // ============================================
    function testCalculateCollateralNeeded() public {
        // Create position with HF = 1.25
        // With collateral=$2000, debt=$1000: 1000e18 collateral, 1280e18 debt
        // HF = (1000 * 2000 * 0.8) / (1280 * 1000) = 1.25
        bytes32 posId = createTestPosition(1000e18, 1280e18);

        uint256 beforeHF = getPositionHF(posId);
        assertLt(beforeHF, 13000, "Position should be below critical threshold");

        // Perform upkeep to trigger calculateCollateralNeeded internally
        bytes memory performData = abi.encode(posId);
        vm.prank(keeper);
        protector.performUpkeep(performData);

        // Verify HF is significantly improved and above critical threshold
        uint256 afterHF = getPositionHF(posId);

        // HF should be improved to at least the target level (1.5 = 15000)
        assertGt(afterHF, beforeHF, "HF should improve after protection");
        assertGe(afterHF, 15000, "HF should be at or above target (1.5)");
    }

    // ============================================
    // Additional Tests: Edge Cases
    // ============================================

    /// @notice Test checkUpkeep with multiple positions, only one critical
    function testCheckUpkeepMultiplePositionsOneCritical() public {
        bytes32 healthyPos = createTestPosition(1000e18, 400e18); // HF > 1.3
        bytes32 criticalPos = createTestPosition(1000e18, 1250e18); // HF < 1.3

        bytes32[] memory positions = new bytes32[](2);
        positions[0] = healthyPos;
        positions[1] = criticalPos;
        bytes memory checkData = abi.encode(positions);

        (bool upkeepNeeded, bytes memory performData) = protector.checkUpkeep(checkData);

        assertTrue(upkeepNeeded, "Should need upkeep when at least one position is critical");
        assertEq(abi.decode(performData, (bytes32)), criticalPos, "Should return first critical position");
    }

    /// @notice Test checkUpkeep with nonexistent position (should handle gracefully)
    function testCheckUpkeepNonexistentPosition() public {
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = bytes32(uint256(999)); // Nonexistent position
        bytes memory checkData = abi.encode(positions);

        (bool upkeepNeeded,) = protector.checkUpkeep(checkData);
        assertFalse(upkeepNeeded, "Should return false for nonexistent position");
    }

    /// @notice Test performUpkeep updates automation metrics
    function testPerformUpkeepUpdatesMetrics() public {
        bytes32 posId = createTestPosition(1000e18, 1250e18);
        bytes memory performData = abi.encode(posId);

        // Check metrics before
        (uint256 beforeTriggers,,) = protector.getAutomationStats();

        vm.prank(keeper);
        protector.performUpkeep(performData);

        // Check metrics after
        (uint256 afterTriggers, uint256 lastTrigger, uint256 timeSince) = protector.getAutomationStats();

        assertEq(afterTriggers, beforeTriggers + 1, "Total triggers should increment");
        assertEq(lastTrigger, block.timestamp, "Last trigger timestamp should be current block");
        assertEq(timeSince, 0, "Time since last trigger should be 0 immediately after");
    }

    /// @notice Test getPositionAutomationHistory tracks position-specific triggers
    function testPositionAutomationHistory() public {
        bytes32 posId = createTestPosition(1000e18, 1250e18);
        bytes memory performData = abi.encode(posId);

        uint256 beforeCount = protector.getPositionAutomationHistory(posId);
        assertEq(beforeCount, 0, "Initial automation count should be 0");

        vm.prank(keeper);
        protector.performUpkeep(performData);

        uint256 afterCount = protector.getPositionAutomationHistory(posId);
        assertEq(afterCount, 1, "Automation count should increment to 1");
    }

    /// @notice Test performUpkeep with extremely low HF (near liquidation)
    function testPerformUpkeepNearLiquidation() public {
        // Create position very close to liquidation
        // HF = 1.05 requires debt = (1000 * 2000 * 0.8) / 1.05 = 1523809.5
        bytes32 posId = createTestPosition(1000e18, 1520e18);

        uint256 beforeHF = getPositionHF(posId);
        assertLt(beforeHF, 11000, "Position should be very critical (HF < 1.1)");

        bytes memory performData = abi.encode(posId);
        vm.prank(keeper);
        protector.performUpkeep(performData);

        uint256 afterHF = getPositionHF(posId);
        assertGt(afterHF, 15000, "Even near-liquidation positions should be rescued to safe level");
    }

    /// @notice Test that checkUpkeep stops at first critical position (gas optimization)
    function testCheckUpkeepStopsAtFirstCritical() public {
        bytes32 critical1 = createTestPosition(1000e18, 1250e18); // First critical
        bytes32 critical2 = createTestPosition(1000e18, 1250e18); // Second critical

        bytes32[] memory positions = new bytes32[](2);
        positions[0] = critical1;
        positions[1] = critical2;
        bytes memory checkData = abi.encode(positions);

        (, bytes memory performData) = protector.checkUpkeep(checkData);

        // Should return first critical position (gas optimization via break)
        assertEq(abi.decode(performData, (bytes32)), critical1, "Should return first critical position");
    }

    /// @notice Test performUpkeep reverts for nonexistent position
    function testPerformUpkeepRevertsNonexistent() public {
        bytes memory performData = abi.encode(bytes32(uint256(999)));

        vm.prank(keeper);
        vm.expectRevert("Position does not exist");
        protector.performUpkeep(performData);
    }

    /// @notice Test price feed integration in checkUpkeep
    function testCheckUpkeepUsesLivePrices() public {
        bytes32 posId = createTestPosition(1000e18, 1000e18);

        // Initially position should be healthy with collateral=$2000, debt=$1000
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = posId;
        (bool upkeepNeeded,) = protector.checkUpkeep(abi.encode(positions));
        assertFalse(upkeepNeeded, "Should be healthy initially");

        // Drop collateral price to make position critical
        // Need HF < 1.3: (1000 * price * 0.8) / (1000 * 1000) < 1.3
        // price < 1625
        collateralFeed.setPrice(1600e8); // Collateral drops to $1600

        (upkeepNeeded,) = protector.checkUpkeep(abi.encode(positions));
        assertTrue(upkeepNeeded, "Should become critical after price drop");
    }
}
