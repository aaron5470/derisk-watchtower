// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PositionVault.sol";
import "../src/Protector.sol";
import "../src/DemoEscrow.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockPriceFeed.sol";

contract IntegrationTest is Test {
    PositionVault public vault;
    DemoEscrow public escrow;
    Protector public protector;
    MockERC20 public collateral;
    MockERC20 public debt;
    MockPriceFeed public collateralFeed;
    MockPriceFeed public debtFeed;

    address public owner = address(this);
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public keeper = address(0x3);

    // Events for testing
    event PositionCreated(
        bytes32 indexed id,
        address indexed owner,
        uint256 collateralAmount,
        uint256 debtAmount
    );

    event ProtectionExecuted(
        bytes32 indexed positionId,
        uint256 beforeHF,
        uint256 afterHF,
        uint256 collateralAdded,
        address indexed executor
    );

    function setUp() public {
        // Deploy contracts
        vault = new PositionVault();
        escrow = new DemoEscrow();

        // Deploy mock tokens
        collateral = new MockERC20("Wrapped ETH", "WETH", 18);
        debt = new MockERC20("USD Coin", "USDC", 6);

        // Deploy mock price feeds
        collateralFeed = new MockPriceFeed(8, "ETH/USD", 2000e8); // $2000
        debtFeed = new MockPriceFeed(8, "USDC/USD", 1e8); // $1

        // Deploy protector with price feeds
        protector = new Protector(
            address(vault),
            address(escrow),
            address(collateralFeed),
            address(debtFeed)
        );

        // Fund escrow
        collateral.mint(address(this), 100000e18);
        collateral.approve(address(escrow), 100000e18);
        escrow.fund(address(collateral), 100000e18);

        // Authorize protector
        escrow.authorizeProtector(address(protector));
    }

    // E1.9.2: Test full flow: create → drop HF → protect
    function testFullProtectionFlow() public {
        // 1. User creates a position
        vm.startPrank(user1);
        bytes32 posId = vault.createPosition(
            address(collateral),
            10e18,  // 10 ETH collateral
            address(debt),
            8000e18 // $8000 debt
        );
        vm.stopPrank();

        // Update HF with actual prices (ETH=$2000, USDC=$1)
        vault.updateHealthFactor(posId, 2000e8, 1e8);

        // Verify initial HF is healthy
        PositionVault.Position memory initialPos = vault.getPosition(posId);
        assertGt(initialPos.healthFactor, 13000, "Initial HF should be > 1.3");

        // 2. Simulate price drop (ETH drops from $2000 to $1000)
        collateralFeed.setPrice(1000e8);

        // Update HF in vault with new price
        vault.updateHealthFactor(posId, 1000e8, 1e8);

        PositionVault.Position memory dropPos = vault.getPosition(posId);
        assertLt(dropPos.healthFactor, 13000, "HF should drop below 1.3 after price drop");

        // 3. Keeper executes protection
        uint256 escrowBalanceBefore = escrow.getBalance(address(collateral));

        vm.prank(keeper);
        uint256 finalHF = protector.protect(posId, 5e18, 1000e8, 1e8); // Add 5 ETH

        // 4. Verify HF restored above threshold
        assertGt(finalHF, 13000, "HF should be restored above 1.3");

        // Verify escrow balance decreased
        uint256 escrowBalanceAfter = escrow.getBalance(address(collateral));
        assertEq(escrowBalanceAfter, escrowBalanceBefore - 5e18, "Escrow should decrease by 5 ETH");

        // Verify position updated
        PositionVault.Position memory finalPos = vault.getPosition(posId);
        assertEq(finalPos.collateralAmount, 15e18, "Collateral should be 15 ETH");
        assertGt(finalPos.healthFactor, 13000, "Final HF should be > 1.3");
    }

    // E1.9.3: Test multiple positions protection
    function testMultiplePositionsProtection() public {
        // Create 3 positions
        vm.startPrank(user1);
        bytes32 pos1 = vault.createPosition(address(collateral), 10e18, address(debt), 8000e18);
        vm.stopPrank();

        vm.startPrank(user2);
        bytes32 pos2 = vault.createPosition(address(collateral), 5e18, address(debt), 4000e18);
        bytes32 pos3 = vault.createPosition(address(collateral), 20e18, address(debt), 16000e18);
        vm.stopPrank();

        // Update HF with actual prices (ETH=$2000, USDC=$1)
        vault.updateHealthFactor(pos1, 2000e8, 1e8);
        vault.updateHealthFactor(pos2, 2000e8, 1e8);
        vault.updateHealthFactor(pos3, 2000e8, 1e8);

        // Simulate price drop
        collateralFeed.setPrice(1000e8);
        vault.updateHealthFactor(pos1, 1000e8, 1e8);
        vault.updateHealthFactor(pos2, 1000e8, 1e8);
        vault.updateHealthFactor(pos3, 1000e8, 1e8);

        // Protect each position with sufficient collateral
        vm.startPrank(keeper);
        protector.protect(pos1, 30e18, 1000e8, 1e8); // Need more collateral for HF > 1.3
        protector.protect(pos2, 15e18, 1000e8, 1e8); // Need more collateral for HF > 1.3
        protector.protect(pos3, 60e18, 1000e8, 1e8); // Need more collateral for HF > 1.3
        vm.stopPrank();

        // Verify all positions are healthy
        assertGt(vault.getPosition(pos1).healthFactor, 13000, "Pos1 should be healthy");
        assertGt(vault.getPosition(pos2).healthFactor, 13000, "Pos2 should be healthy");
        assertGt(vault.getPosition(pos3).healthFactor, 13000, "Pos3 should be healthy");
    }

    // E1.9.4: Test escrow funding and authorization
    function testEscrowFundingAndAuthorization() public {
        // Deploy new escrow and protector
        DemoEscrow newEscrow = new DemoEscrow();
        Protector newProtector = new Protector(
            address(vault),
            address(newEscrow),
            address(collateralFeed),
            address(debtFeed)
        );

        // Fund escrow
        collateral.mint(address(this), 1000e18);
        collateral.approve(address(newEscrow), 1000e18);
        newEscrow.fund(address(collateral), 1000e18);

        // Verify balance
        assertEq(newEscrow.getBalance(address(collateral)), 1000e18, "Escrow should have 1000 tokens");

        // Authorize protector
        newEscrow.authorizeProtector(address(newProtector));
        assertTrue(newEscrow.isAuthorized(address(newProtector)), "Protector should be authorized");

        // Test protection works
        vm.startPrank(user1);
        bytes32 posId = vault.createPosition(address(collateral), 10e18, address(debt), 8000e18);
        vm.stopPrank();

        vault.updateHealthFactor(posId, 1000e8, 1e8);

        vm.prank(keeper);
        newProtector.protect(posId, 5e18, 1000e8, 1e8);

        // Verify escrow balance decreased
        assertEq(newEscrow.getBalance(address(collateral)), 995e18, "Escrow should have 995 tokens");
    }

    // E1.9.5: Test vault pause prevents protection
    function testVaultPausePreventsProtection() public {
        // Create position
        vm.startPrank(user1);
        bytes32 posId = vault.createPosition(address(collateral), 10e18, address(debt), 8000e18);
        vm.stopPrank();

        // Update HF with actual prices (ETH=$2000, USDC=$1)
        vault.updateHealthFactor(posId, 2000e8, 1e8);

        // Simulate price drop
        collateralFeed.setPrice(1000e8);
        vault.updateHealthFactor(posId, 1000e8, 1e8);

        // Pause vault
        vault.pause();

        // Try to update HF (should revert)
        vm.expectRevert();
        vault.updateHealthFactor(posId, 1000e8, 1e8);
    }

    // E1.9.6: Test event sequence in full flow
    function testEventSequenceInFullFlow() public {
        vm.startPrank(user1);

        // Expect PositionCreated event
        vm.expectEmit(false, true, false, true);
        emit PositionCreated(bytes32(0), user1, 10e18, 8000e18);

        bytes32 posId = vault.createPosition(address(collateral), 10e18, address(debt), 8000e18);
        vm.stopPrank();

        // Update HF (should emit PositionUpdated if significant change)
        vault.updateHealthFactor(posId, 1000e8, 1e8);

        // Expect ProtectionExecuted event
        vm.expectEmit(true, false, false, false);
        emit ProtectionExecuted(posId, 0, 0, 5e18, keeper);

        vm.prank(keeper);
        protector.protect(posId, 5e18, 1e8, 1e8);
    }

    // Test complete lifecycle: create → drop → protect → recover → normal
    function testCompleteLifecycle() public {
        // 1. Create position
        vm.startPrank(user1);
        bytes32 posId = vault.createPosition(address(collateral), 10e18, address(debt), 8000e18);
        vm.stopPrank();

        // Update HF with actual prices (ETH=$2000, USDC=$1)
        vault.updateHealthFactor(posId, 2000e8, 1e8);

        uint256 hf1 = vault.getPosition(posId).healthFactor;
        assertGt(hf1, 13000, "Should start healthy");

        // 2. Price drops - critical
        collateralFeed.setPrice(1000e8);
        vault.updateHealthFactor(posId, 1000e8, 1e8);

        uint256 hf2 = vault.getPosition(posId).healthFactor;
        assertLt(hf2, 13000, "Should be critical");

        // Check upkeep with new Chainlink Automation interface
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = posId;
        (bool upkeepNeeded,) = protector.checkUpkeep(abi.encode(positions));
        assertTrue(upkeepNeeded, "Should need protection");

        // 3. Protect
        vm.prank(keeper);
        protector.protect(posId, 5e18, 1000e8, 1e8);

        uint256 hf3 = vault.getPosition(posId).healthFactor;
        assertGt(hf3, 13000, "Should be healthy after protection");

        // Check upkeep should return false now
        (bool upkeepNeeded2,) = protector.checkUpkeep(abi.encode(positions));
        assertFalse(upkeepNeeded2, "Should not need protection");

        // 4. Price recovers
        collateralFeed.setPrice(2000e8);
        vault.updateHealthFactor(posId, 2000e8, 1e8);

        uint256 hf4 = vault.getPosition(posId).healthFactor;
        assertGt(hf4, hf3, "Should be even healthier");
    }

    // Test emergency withdrawal from escrow
    function testEmergencyWithdrawal() public {
        uint256 initialBalance = escrow.getBalance(address(collateral));

        escrow.emergencyWithdraw(address(collateral), owner, 1000e18);

        assertEq(
            escrow.getBalance(address(collateral)),
            initialBalance - 1000e18,
            "Balance should decrease"
        );
        assertEq(collateral.balanceOf(owner), 1000e18, "Owner should receive tokens");
    }

    // Test deauthorize protector
    function testDeauthorizeProtector() public {
        escrow.deauthorizeProtector(address(protector));
        assertFalse(escrow.isAuthorized(address(protector)), "Should be deauthorized");

        vm.startPrank(user1);
        bytes32 posId = vault.createPosition(address(collateral), 10e18, address(debt), 8000e18);
        vm.stopPrank();

        vault.updateHealthFactor(posId, 1000e8, 1e8);

        vm.prank(keeper);
        vm.expectRevert("Not authorized");
        protector.protect(posId, 5e18, 1000e8, 1e8);
    }

    // Test user positions tracking
    function testUserPositionsTracking() public {
        vm.startPrank(user1);
        bytes32 pos1 = vault.createPosition(address(collateral), 10e18, address(debt), 8000e18);
        bytes32 pos2 = vault.createPosition(address(collateral), 5e18, address(debt), 4000e18);
        vm.stopPrank();

        bytes32[] memory positions = vault.getUserPositions(user1);
        assertEq(positions.length, 2, "Should have 2 positions");
        assertEq(positions[0], pos1, "First position should match");
        assertEq(positions[1], pos2, "Second position should match");
    }
}
