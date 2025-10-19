// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PositionVault.sol";
import "../src/Protector.sol";
import "../src/DemoEscrow.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockPriceFeed.sol";

contract ProtectorTest is Test {
    PositionVault public vault;
    DemoEscrow public escrow;
    Protector public protector;
    MockERC20 public collateral;
    MockERC20 public debt;
    MockPriceFeed public collateralFeed;
    MockPriceFeed public debtFeed;

    address public owner = address(this);
    address public user = address(0x1);
    address public executor = address(0x2);

    event ProtectionExecuted(
        bytes32 indexed positionId,
        uint256 beforeHF,
        uint256 afterHF,
        uint256 collateralAdded,
        address indexed executor
    );

    function setUp() public {
        vault = new PositionVault();
        escrow = new DemoEscrow();
        collateral = new MockERC20("Collateral", "COL", 18);
        debt = new MockERC20("Debt", "DBT", 18);

        // Deploy mock price feeds
        collateralFeed = new MockPriceFeed(8, "COL/USD", 1e8); // $1
        debtFeed = new MockPriceFeed(8, "DBT/USD", 1e8); // $1

        // Deploy protector with price feeds
        protector = new Protector(
            address(vault),
            address(escrow),
            address(collateralFeed),
            address(debtFeed)
        );

        // Fund escrow with collateral
        collateral.mint(address(this), 10000e18);
        collateral.approve(address(escrow), 10000e18);
        escrow.fund(address(collateral), 10000e18);

        // Authorize protector
        escrow.authorizeProtector(address(protector));
    }

    function createTestPosition() internal returns (bytes32) {
        vm.startPrank(user);
        bytes32 id = vault.createPosition(
            address(collateral),
            1000e18,
            address(debt),
            500e18
        );
        vm.stopPrank();
        
        // Update HF with actual prices (collateral=$1, debt=$1)
        vault.updateHealthFactor(id, 1e8, 1e8);
        
        return id;
    }

    function getPositionHF(bytes32 posId) internal view returns (uint256) {
        PositionVault.Position memory pos = vault.getPosition(posId);
        return pos.healthFactor;
    }

    // E1.8.3: Test protect improves health factor
    function testProtectImprovesHF() public {
        bytes32 posId = createTestPosition();
        uint256 beforeHF = getPositionHF(posId);

        vm.prank(executor);
        uint256 afterHF = protector.protect(posId, 100e18, 1e8, 1e8);

        assertGt(afterHF, beforeHF, "HF should improve after protection");
    }

    // E1.8.4: Test protect emits ProtectionExecuted
    function testProtectEmitsEvent() public {
        bytes32 posId = createTestPosition();
        uint256 beforeHF = getPositionHF(posId);

        vm.expectEmit(true, false, false, false);
        emit ProtectionExecuted(posId, beforeHF, 0, 100e18, executor);

        vm.prank(executor);
        protector.protect(posId, 100e18, 1e8, 1e8);
    }

    // E1.8.5: Test protect reverts if HF unchanged
    function testProtectRevertsIfZeroCollateral() public {
        bytes32 posId = createTestPosition();

        vm.prank(executor);
        vm.expectRevert("Collateral to add must be > 0");
        protector.protect(posId, 0, 1e8, 1e8);
    }

    function testProtectRevertsIfNoImprovement() public {
        bytes32 posId = createTestPosition();

        vm.prank(executor);
        vm.expectRevert("Protection did not improve HF");
        protector.protect(posId, 1, 1e8, 1e8); // 1 wei won't improve HF due to rounding
    }

    // E1.8.6: Test protect transfers from escrow
    function testProtectTransfersFromEscrow() public {
        bytes32 posId = createTestPosition();
        uint256 escrowBalanceBefore = escrow.getBalance(address(collateral));

        vm.prank(executor);
        protector.protect(posId, 100e18, 1e8, 1e8);

        uint256 escrowBalanceAfter = escrow.getBalance(address(collateral));

        assertEq(
            escrowBalanceAfter,
            escrowBalanceBefore - 100e18,
            "Escrow balance should decrease"
        );
    }

    // E1.8.7: Test protect with unauthorized caller
    function testProtectWithUnauthorizedEscrow() public {
        // Create a new protector that's not authorized
        Protector unauthorizedProtector = new Protector(
            address(vault),
            address(escrow),
            address(collateralFeed),
            address(debtFeed)
        );
        bytes32 posId = createTestPosition();

        vm.prank(executor);
        vm.expectRevert("Not authorized");
        unauthorizedProtector.protect(posId, 100e18, 1e8, 1e8);
    }

    // E1.8.8: Test protect nonexistent position
    function testProtectNonexistentPosition() public {
        vm.prank(executor);
        vm.expectRevert("Position does not exist");
        protector.protect(bytes32(uint256(999)), 100e18, 1e8, 1e8);
    }

    // Test checkUpkeep returns true for critical positions
    function testCheckUpkeepReturnsTrueForCritical() public {
        bytes32 posId = createTestPosition();

        // Update position to have critical HF (below 1.3)
        // Need HF < 1.3, so adjustedCollateralValue / debtValue < 1.3
        // With 1000 collateral and 500 debt, need collateral price < 1.3 * 500 / (1000 * 0.8) = 0.8125
        collateralFeed.setPrice(80e6); // Collateral $0.80, debt $1 -> HF = 1.28

        bytes32[] memory positions = new bytes32[](1);
        positions[0] = posId;
        (bool upkeepNeeded,) = protector.checkUpkeep(abi.encode(positions));
        assertTrue(upkeepNeeded, "Should need protection");
    }

    // Test checkUpkeep returns false for healthy positions
    function testCheckUpkeepReturnsFalseForHealthy() public {
        bytes32 posId = createTestPosition();

        bytes32[] memory positions = new bytes32[](1);
        positions[0] = posId;
        (bool upkeepNeeded,) = protector.checkUpkeep(abi.encode(positions));
        assertFalse(upkeepNeeded, "Should not need protection for healthy position");
    }

    // Test getPositionHF returns correct value
    function testGetPositionHF() public {
        bytes32 posId = createTestPosition();
        uint256 hf = protector.getPositionHF(posId);

        assertGt(hf, 0, "HF should be > 0");
        assertGt(hf, 13000, "HF should be above critical threshold for new position");
    }

    // Test protection with large collateral addition
    function testProtectWithLargeCollateral() public {
        bytes32 posId = createTestPosition();
        uint256 beforeHF = getPositionHF(posId);

        vm.prank(executor);
        uint256 afterHF = protector.protect(posId, 1000e18, 1e8, 1e8); // Double the collateral

        assertGe(afterHF, beforeHF * 2, "HF should at least double");
    }

    // Test protection updates vault correctly
    function testProtectionUpdatesVault() public {
        bytes32 posId = createTestPosition();

        PositionVault.Position memory posBefore = vault.getPosition(posId);

        vm.prank(executor);
        protector.protect(posId, 200e18, 1e8, 1e8);

        PositionVault.Position memory posAfter = vault.getPosition(posId);

        assertEq(
            posAfter.collateralAmount,
            posBefore.collateralAmount + 200e18,
            "Collateral should be updated in vault"
        );
    }

    // Test checkUpkeep with nonexistent position
    function testCheckUpkeepNonexistentPosition() public {
        bytes32[] memory positions = new bytes32[](1);
        positions[0] = bytes32(uint256(999));
        (bool upkeepNeeded,) = protector.checkUpkeep(abi.encode(positions));
        assertFalse(upkeepNeeded, "Should return false for nonexistent position");
    }

    // Test immutable variables set correctly
    function testImmutableVariables() public {
        assertEq(address(protector.positionVault()), address(vault), "Vault address should match");
        assertEq(protector.escrow(), address(escrow), "Escrow address should match");
    }

    // Test critical threshold constant
    function testCriticalThreshold() public {
        assertEq(protector.CRITICAL_THRESHOLD(), 13000, "Critical threshold should be 1.3 (13000)");
    }

    // Test protection with minimum collateral
    function testProtectWithMinimumCollateral() public {
        bytes32 posId = createTestPosition();
        uint256 beforeHF = getPositionHF(posId);

        vm.prank(executor);
        uint256 afterHF = protector.protect(posId, 1e18, 1e8, 1e8); // 1 token minimum

        assertGt(afterHF, beforeHF, "Protection should improve HF");
    }
}
