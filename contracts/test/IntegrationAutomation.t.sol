// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PositionVault.sol";
import "../src/Protector.sol";
import "../src/DemoEscrow.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockPriceFeed.sol";

/**
 * @title IntegrationAutomationTest
 * @notice Integration tests for the complete Chainlink Automation flow
 * @dev Tests the full end-to-end automation process:
 *      1. Position creation with healthy HF
 *      2. Price drop causing critical HF
 *      3. checkUpkeep returns true
 *      4. performUpkeep executes protection
 *      5. HF restored to safe level
 *      6. Events emitted correctly
 *      7. Metrics updated properly
 */
contract IntegrationAutomationTest is Test {
    // Core contracts
    PositionVault public vault;
    Protector public protector;
    DemoEscrow public escrow;
    
    // Mock tokens and price feeds
    MockERC20 public collateralToken;
    MockERC20 public debtToken;
    MockPriceFeed public collateralPriceFeed;
    MockPriceFeed public debtPriceFeed;
    
    // Test accounts
    address public user = makeAddr("user");
    address public keeper = makeAddr("keeper");
    address public protectorOwner = makeAddr("protectorOwner");
    
    // Test constants
    uint256 public constant INITIAL_COLLATERAL = 1000e18; // 1000 tokens
    uint256 public constant INITIAL_DEBT = 500e18; // 500 tokens
    uint256 public constant INITIAL_COLLATERAL_PRICE = 2000e8; // $2000 per token
    uint256 public constant INITIAL_DEBT_PRICE = 1e8; // $1 per token
    uint256 public constant CRITICAL_THRESHOLD = 13000; // 1.3 with 4 decimals
    uint256 public constant TARGET_HF = 15000; // 1.5 with 4 decimals
    
    // Position tracking
    bytes32 public testPositionId;
    
    event PositionCreated(bytes32 indexed positionId, address indexed owner, uint256 collateralAmount, uint256 debtAmount);
    event AutomationTriggered(bytes32 indexed positionId, uint256 healthFactor, address indexed keeper);
    event ProtectionExecuted(bytes32 indexed positionId, uint256 collateralAdded, uint256 healthFactorBefore, uint256 healthFactorAfter, address indexed protector);

    function setUp() public {
        // Deploy mock tokens
        collateralToken = new MockERC20("Collateral Token", "COLL", 18);
        debtToken = new MockERC20("Debt Token", "DEBT", 18);
        
        // Deploy mock price feeds
        collateralPriceFeed = new MockPriceFeed(8, "Collateral Price Feed", int256(INITIAL_COLLATERAL_PRICE));
        debtPriceFeed = new MockPriceFeed(8, "Debt Price Feed", int256(INITIAL_DEBT_PRICE));
        
        // Deploy core contracts
        vault = new PositionVault();
        escrow = new DemoEscrow();
        
        vm.startPrank(protectorOwner);
        protector = new Protector(
            address(vault),
            address(escrow),
            address(collateralPriceFeed),
            address(debtPriceFeed)
        );
        vm.stopPrank();
        
        // Authorize protector in escrow
        escrow.authorizeProtector(address(protector));
        
        // Setup user with tokens
        collateralToken.mint(user, INITIAL_COLLATERAL * 10); // Extra for escrow funding
        debtToken.mint(user, INITIAL_DEBT);
        
        // Setup escrow with collateral tokens for protection
        collateralToken.mint(address(this), INITIAL_COLLATERAL * 5);
        collateralToken.approve(address(escrow), INITIAL_COLLATERAL * 5);
        escrow.fund(address(collateralToken), INITIAL_COLLATERAL * 5);
        
        console.log("=== Setup Complete ===");
        console.log("Collateral Token:", address(collateralToken));
        console.log("Debt Token:", address(debtToken));
        console.log("Vault:", address(vault));
        console.log("Protector:", address(protector));
        console.log("Escrow:", address(escrow));
    }

    /**
     * @notice Test the complete automation flow from healthy position to protection
     * @dev This is the main integration test that covers:
     *      - Position creation with healthy HF (> 1.5)
     *      - Price manipulation to create critical HF (< 1.3)
     *      - checkUpkeep validation
     *      - performUpkeep execution
     *      - HF restoration and event emission
     */
    function testCompleteAutomationFlow() public {
        console.log("\n=== Starting Complete Automation Flow Test ===");
        
        // Step 1: Create position with healthy HF
        _createHealthyPosition();
        
        // Step 2: Verify initial state
        _verifyInitialHealthyState();
        
        // Step 3: Simulate price drop to create critical position
        _simulatePriceDrop();
        
        // Step 4: Verify critical state
        _verifyCriticalState();
        
        // Step 5: Test checkUpkeep returns true
        _testCheckUpkeepCritical();
        
        // Step 6: Execute performUpkeep
        _executePerformUpkeep();
        
        // Step 7: Verify protection results
        _verifyProtectionResults();
        
        // Step 8: Verify automation metrics
        _verifyAutomationMetrics();
        
        console.log("=== Complete Automation Flow Test PASSED ===\n");
    }

    /**
     * @notice Test automation with multiple positions (only one critical)
     */
    function testAutomationWithMultiplePositions() public {
        console.log("\n=== Testing Automation with Multiple Positions ===");
        
        // Create first position (will become critical)
        _createHealthyPosition();
        bytes32 firstPositionId = testPositionId;
        
        // Create second position (will remain healthy)
        vm.startPrank(user);
        collateralToken.approve(address(vault), INITIAL_COLLATERAL);
        debtToken.approve(address(vault), INITIAL_DEBT / 2); // Less debt = higher HF
        
        bytes32 secondPositionId = vault.createPosition(
            address(collateralToken),
            INITIAL_COLLATERAL,
            address(debtToken),
            INITIAL_DEBT / 2
        );
        vm.stopPrank();
        
        // Simulate price drop (affects both positions)
        collateralPriceFeed.setPrice(int256(INITIAL_COLLATERAL_PRICE * 60 / 100)); // 40% drop
        
        // Check HFs
        uint256 firstHF = protector.getPositionHF(firstPositionId);
        uint256 secondHF = protector.getPositionHF(secondPositionId);
        
        console.log("First Position HF:", firstHF);
        console.log("Second Position HF:", secondHF);
        
        assertLt(firstHF, CRITICAL_THRESHOLD, "First position should be critical");
        assertGt(secondHF, CRITICAL_THRESHOLD, "Second position should remain healthy");
        
        // Test checkUpkeep with multiple positions
        bytes32[] memory positions = new bytes32[](2);
        positions[0] = firstPositionId;
        positions[1] = secondPositionId;
        
        bytes memory checkData = abi.encode(positions);
        (bool upkeepNeeded, bytes memory performData) = protector.checkUpkeep(checkData);
        
        assertTrue(upkeepNeeded, "Upkeep should be needed for critical position");
        
        bytes32 criticalPositionId = abi.decode(performData, (bytes32));
        assertEq(criticalPositionId, firstPositionId, "Should identify first position as critical");
        
        console.log("Multiple Positions Test PASSED");
    }

    /**
     * @notice Test automation failure scenarios
     */
    function testAutomationFailureScenarios() public {
        console.log("\n=== Testing Automation Failure Scenarios ===");
        
        // Test 1: checkUpkeep with empty positions array
        bytes32[] memory emptyPositions = new bytes32[](0);
        bytes memory emptyCheckData = abi.encode(emptyPositions);
        (bool upkeepNeeded,) = protector.checkUpkeep(emptyCheckData);
        assertFalse(upkeepNeeded, "Should not need upkeep with empty positions");
        
        // Test 2: performUpkeep with nonexistent position
        bytes32 fakePositionId = keccak256("fake");
        bytes memory fakePerformData = abi.encode(fakePositionId);
        
        vm.expectRevert("Position does not exist");
        protector.performUpkeep(fakePerformData);
        
        // Test 3: performUpkeep with healthy position
        _createHealthyPosition();
        bytes memory healthyPerformData = abi.encode(testPositionId);
        
        vm.expectRevert("Position is not critical");
        protector.performUpkeep(healthyPerformData);
        
        console.log("Failure Scenarios Test PASSED");
    }

    /**
     * @notice Test automation metrics and history tracking
     */
    function testAutomationMetricsAndHistory() public {
        console.log("\n=== Testing Automation Metrics and History ===");
        
        // Get initial metrics
        (uint256 initialTriggers, uint256 initialTimestamp, uint256 initialDelay) = protector.getAutomationStats();
        assertEq(initialTriggers, 0, "Initial triggers should be 0");
        
        // Create and protect position
        _createHealthyPosition();
        _simulatePriceDrop();
        
        // Execute automation
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = testPositionId;
        bytes memory checkData = abi.encode(positions);
        
        (, bytes memory performData) = protector.checkUpkeep(checkData);
        
        vm.prank(keeper);
        protector.performUpkeep(performData);
        
        // Check updated metrics
        (uint256 finalTriggers, uint256 finalTimestamp, uint256 finalDelay) = protector.getAutomationStats();
        assertEq(finalTriggers, 1, "Should have 1 trigger");
        assertGt(finalTimestamp, initialTimestamp, "Timestamp should be updated");
        
        // Check position-specific history
        uint256 positionTriggers = protector.getPositionAutomationHistory(testPositionId);
        assertEq(positionTriggers, 1, "Position should have 1 automation trigger");
        
        console.log("Metrics and History Test PASSED");
    }

    // ============================================================================
    // Helper Functions
    // ============================================================================

    function _createHealthyPosition() internal {
        console.log("Creating healthy position...");
        
        vm.startPrank(user);
        collateralToken.approve(address(vault), INITIAL_COLLATERAL);
        debtToken.approve(address(vault), INITIAL_DEBT);
        
        vm.expectEmit(true, true, false, true);
        emit PositionCreated(bytes32(0), user, INITIAL_COLLATERAL, INITIAL_DEBT);
        
        testPositionId = vault.createPosition(
            address(collateralToken),
            INITIAL_COLLATERAL,
            address(debtToken),
            INITIAL_DEBT
        );
        vm.stopPrank();
        
        console.log("Position created with ID:", vm.toString(testPositionId));
    }

    function _verifyInitialHealthyState() internal view {
        uint256 healthFactor = protector.getPositionHF(testPositionId);
        console.log("Initial Health Factor:", healthFactor);
        
        assertGt(healthFactor, TARGET_HF, "Position should start with healthy HF");
        
        // Initial HF calculation:
        // Collateral Value = 1000 * $2000 = $2,000,000
        // Debt Value = 500 * $1 = $500
        // HF = (2,000,000 * 0.8) / 500 = 3200 (320.0 with 4 decimals)
        uint256 expectedHF = (INITIAL_COLLATERAL * INITIAL_COLLATERAL_PRICE * 8000) / (INITIAL_DEBT * INITIAL_DEBT_PRICE * 100);
        assertEq(healthFactor, expectedHF, "Health factor should match calculation");
    }

    function _simulatePriceDrop() internal {
        console.log("Simulating price drop...");
        
        // Drop collateral price by 50% to create critical position
        uint256 newPrice = INITIAL_COLLATERAL_PRICE * 50 / 100;
        collateralPriceFeed.setPrice(int256(newPrice));
        
        console.log("Collateral price dropped to:", newPrice);
    }

    function _verifyCriticalState() internal view {
        uint256 healthFactor = protector.getPositionHF(testPositionId);
        console.log("Health Factor after price drop:", healthFactor);
        
        assertLt(healthFactor, CRITICAL_THRESHOLD, "Position should be critical after price drop");
        
        // New HF calculation:
        // Collateral Value = 1000 * $1000 = $1,000,000
        // Debt Value = 500 * $1 = $500
        // HF = (1,000,000 * 0.8) / 500 = 1600 (160.0 with 4 decimals) - way below 1.3
    }

    function _testCheckUpkeepCritical() internal view {
        console.log("Testing checkUpkeep with critical position...");
        
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = testPositionId;
        bytes memory checkData = abi.encode(positions);
        
        (bool upkeepNeeded, bytes memory performData) = protector.checkUpkeep(checkData);
        
        assertTrue(upkeepNeeded, "checkUpkeep should return true for critical position");
        
        bytes32 returnedPositionId = abi.decode(performData, (bytes32));
        assertEq(returnedPositionId, testPositionId, "Should return correct position ID");
        
        console.log("checkUpkeep validation PASSED");
    }

    function _executePerformUpkeep() internal {
        console.log("Executing performUpkeep...");
        
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = testPositionId;
        bytes memory checkData = abi.encode(positions);
        
        (, bytes memory performData) = protector.checkUpkeep(checkData);
        
        uint256 hfBefore = protector.getPositionHF(testPositionId);
        
        vm.expectEmit(true, false, false, true);
        emit AutomationTriggered(testPositionId, hfBefore, keeper);
        
        vm.expectEmit(true, false, false, false);
        emit ProtectionExecuted(testPositionId, 0, hfBefore, 0, address(protector));
        
        vm.prank(keeper);
        protector.performUpkeep(performData);
        
        console.log("performUpkeep executed successfully");
    }

    function _verifyProtectionResults() internal view {
        console.log("Verifying protection results...");
        
        uint256 finalHF = protector.getPositionHF(testPositionId);
        console.log("Final Health Factor:", finalHF);
        
        assertGe(finalHF, TARGET_HF, "Health factor should be restored to target level");
        
        console.log("Protection results verified");
    }

    function _verifyAutomationMetrics() internal view {
        console.log("Verifying automation metrics...");
        
        (uint256 totalTriggers, uint256 lastTimestamp, uint256 timeSinceLastTrigger) = protector.getAutomationStats();
        
        assertEq(totalTriggers, 1, "Should have 1 automation trigger");
        assertGt(lastTimestamp, 0, "Last trigger timestamp should be set");
        assertLt(timeSinceLastTrigger, 60, "Time since last trigger should be recent");
        
        uint256 positionTriggers = protector.getPositionAutomationHistory(testPositionId);
        assertEq(positionTriggers, 1, "Position should have 1 automation trigger");
        
        console.log("Automation metrics verified");
    }

    /**
     * @notice Helper to get position details for debugging
     */
    function _getPositionDetails(bytes32 positionId) internal view returns (
        address owner,
        uint256 collateralAmount,
        address collateralToken_,
        uint256 debtAmount,
        address debtToken_,
        uint256 healthFactor
    ) {
        PositionVault.Position memory position = vault.getPosition(positionId);
        owner = position.owner;
        collateralAmount = position.collateralAmount;
        collateralToken_ = position.collateralToken;
        debtAmount = position.debtAmount;
        debtToken_ = position.debtToken;
        healthFactor = protector.getPositionHF(positionId);
    }

    /**
     * @notice Test helper to print position state
     */
    function _logPositionState(bytes32 positionId, string memory label) internal view {
        (
            address owner,
            uint256 collateralAmount,
            address collateralToken_,
            uint256 debtAmount,
            address debtToken_,
            uint256 healthFactor
        ) = _getPositionDetails(positionId);
        
        console.log("=== Position State:", label, "===");
        console.log("Owner:", owner);
        console.log("Collateral Amount:", collateralAmount);
        console.log("Collateral Token:", collateralToken_);
        console.log("Debt Amount:", debtAmount);
        console.log("Debt Token:", debtToken_);
        console.log("Health Factor:", healthFactor);
        console.log("Is Critical:", healthFactor < CRITICAL_THRESHOLD);
    }
}