// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PositionVault.sol";
import "../src/mocks/MockERC20.sol";

contract PositionVaultTest is Test {
    PositionVault public vault;
    MockERC20 public collateralToken;
    MockERC20 public debtToken;

    address public owner = address(this);
    address public user = address(0x1);
    address public user2 = address(0x2);

    event PositionCreated(
        bytes32 indexed id,
        address indexed owner,
        uint256 collateralAmount,
        uint256 debtAmount
    );

    event PositionUpdated(
        bytes32 indexed id,
        uint256 newHealthFactor,
        uint256 previousHealthFactor,
        uint256 timestamp
    );

    function setUp() public {
        vault = new PositionVault();
        collateralToken = new MockERC20("Collateral", "COL", 18);
        debtToken = new MockERC20("Debt", "DBT", 18);
    }

    // E1.7.4: Test createPosition success case
    function testCreatePosition() public {
        vm.startPrank(user);

        bytes32 id = vault.createPosition(
            address(collateralToken),
            1000e18,
            address(debtToken),
            500e18
        );

        assertNotEq(id, bytes32(0), "Position ID should not be zero");

        PositionVault.Position memory pos = vault.getPosition(id);
        assertEq(pos.owner, user, "Owner should match");
        assertEq(pos.collateralAmount, 1000e18, "Collateral amount should match");
        assertEq(pos.debtAmount, 500e18, "Debt amount should match");
        assertEq(pos.collateralToken, address(collateralToken), "Collateral token should match");
        assertEq(pos.debtToken, address(debtToken), "Debt token should match");

        vm.stopPrank();
    }

    // E1.7.5: Test createPosition emits event
    function testCreatePositionEmitsEvent() public {
        vm.startPrank(user);

        vm.expectEmit(false, true, false, true);
        emit PositionCreated(bytes32(0), user, 1000e18, 500e18);

        vault.createPosition(
            address(collateralToken),
            1000e18,
            address(debtToken),
            500e18
        );

        vm.stopPrank();
    }

    // E1.7.6: Test getPosition returns correct data
    function testGetPositionReturnsCorrectData() public {
        vm.startPrank(user);

        bytes32 id = vault.createPosition(
            address(collateralToken),
            2000e18,
            address(debtToken),
            800e18
        );

        PositionVault.Position memory pos = vault.getPosition(id);

        assertEq(pos.id, id, "ID should match");
        assertEq(pos.owner, user, "Owner should match");
        assertEq(pos.collateralAmount, 2000e18, "Collateral should match");
        assertEq(pos.collateralToken, address(collateralToken), "Collateral token should match");
        assertEq(pos.debtAmount, 800e18, "Debt should match");
        assertEq(pos.debtToken, address(debtToken), "Debt token should match");
        assertGt(pos.healthFactor, 0, "Health factor should be > 0");
        assertEq(pos.lastUpdateTimestamp, block.timestamp, "Timestamp should match");

        vm.stopPrank();
    }

    // E1.7.7: Test getUserPositions returns IDs
    function testGetUserPositionsReturnsIDs() public {
        vm.startPrank(user);

        bytes32 id1 = vault.createPosition(
            address(collateralToken),
            1000e18,
            address(debtToken),
            500e18
        );

        bytes32 id2 = vault.createPosition(
            address(collateralToken),
            2000e18,
            address(debtToken),
            1000e18
        );

        bytes32 id3 = vault.createPosition(
            address(collateralToken),
            500e18,
            address(debtToken),
            200e18
        );

        bytes32[] memory userPositions = vault.getUserPositions(user);

        assertEq(userPositions.length, 3, "Should have 3 positions");
        assertEq(userPositions[0], id1, "First position should match");
        assertEq(userPositions[1], id2, "Second position should match");
        assertEq(userPositions[2], id3, "Third position should match");

        vm.stopPrank();
    }

    // E1.7.8: Test calculateHealthFactor formula
    function testCalculateHealthFactor() public {
        // HF = (collateral * price * 0.8) / (debt * price) * 10000
        // With 1000e18 collateral at 2000e8 price and 500e18 debt at 1000e8 price:
        // HF = (1000e18 * 2000e8 * 0.8) / (500e18 * 1000e8) * 10000
        // HF = (2000e26 * 0.8) / (500e26) * 10000 = 1600e26 / 500e26 * 10000 = 3.2 * 10000 = 32000

        uint256 hf = vault.calculateHealthFactor(
            1000e18, // collateral
            2000e8,  // collateral price ($2000)
            500e18,  // debt
            1000e8   // debt price ($1000)
        );

        assertEq(hf, 32000, "HF should be 3.2 (32000 with 4 decimals)");
    }

    // Test HF calculation with equal prices
    function testCalculateHealthFactorEqualPrices() public {
        // With 1:1 price ratio and 2:1 collateral:debt ratio
        // HF = (1000 * 1 * 0.8) / (500 * 1) * 10000 = 0.8 / 0.5 * 10000 = 1.6 * 10000 = 16000

        uint256 hf = vault.calculateHealthFactor(
            1000e18, // collateral
            1e8,     // $1 price
            500e18,  // debt
            1e8      // $1 price
        );

        assertEq(hf, 16000, "HF should be 1.6 (16000 with 4 decimals)");
    }

    // E1.7.9: Test updateHealthFactor changes HF
    function testUpdateHealthFactorChangesHF() public {
        vm.startPrank(user);

        bytes32 id = vault.createPosition(
            address(collateralToken),
            1000e18,
            address(debtToken),
            500e18
        );

        vm.stopPrank();

        // Set initial prices (collateral=$1, debt=$1)
        vault.updateHealthFactor(id, 1e8, 1e8);
        
        PositionVault.Position memory posBefore = vault.getPosition(id);
        uint256 hfBefore = posBefore.healthFactor;

        // Simulate price change (collateral price drops)
        vault.updateHealthFactor(id, 50e6, 1e8); // Collateral now $0.50, debt still $1

        PositionVault.Position memory posAfter = vault.getPosition(id);
        uint256 hfAfter = posAfter.healthFactor;

        assertLt(hfAfter, hfBefore, "HF should decrease after collateral price drop");
    }

    // E1.7.10: Test pause prevents createPosition
    function testPausePreventsCreate() public {
        vault.pause();

        vm.startPrank(user);
        vm.expectRevert();
        vault.createPosition(
            address(collateralToken),
            1000e18,
            address(debtToken),
            500e18
        );
        vm.stopPrank();
    }

    // E1.7.12: Test zero address validation
    function testZeroAddressValidation() public {
        vm.startPrank(user);

        vm.expectRevert("Invalid collateral token");
        vault.createPosition(
            address(0),
            1000e18,
            address(debtToken),
            500e18
        );

        vm.expectRevert("Invalid debt token");
        vault.createPosition(
            address(collateralToken),
            1000e18,
            address(0),
            500e18
        );

        vm.stopPrank();
    }

    // Test zero amount validation
    function testZeroAmountValidation() public {
        vm.startPrank(user);

        vm.expectRevert("Collateral must be > 0");
        vault.createPosition(
            address(collateralToken),
            0,
            address(debtToken),
            500e18
        );

        vm.expectRevert("Debt must be > 0");
        vault.createPosition(
            address(collateralToken),
            1000e18,
            address(debtToken),
            0
        );

        vm.stopPrank();
    }

    // Test HF with zero debt
    function testCalculateHealthFactorZeroDebt() public {
        uint256 hf = vault.calculateHealthFactor(
            1000e18,
            2000e8,
            0,
            1000e8
        );

        assertEq(hf, type(uint256).max, "HF should be max uint256 with zero debt");
    }

    // Test pause/unpause functionality
    function testPauseUnpause() public {
        vault.pause();
        assertTrue(vault.paused(), "Contract should be paused");

        vault.unpause();
        assertFalse(vault.paused(), "Contract should be unpaused");
    }

    // Test only owner can pause
    function testOnlyOwnerCanPause() public {
        vm.startPrank(user);
        vm.expectRevert();
        vault.pause();
        vm.stopPrank();
    }

    // Test only owner can unpause
    function testOnlyOwnerCanUnpause() public {
        vault.pause();

        vm.startPrank(user);
        vm.expectRevert();
        vault.unpause();
        vm.stopPrank();
    }

    // Test position count increments
    function testPositionCountIncrements() public {
        assertEq(vault.positionCount(), 0, "Initial count should be 0");

        vm.startPrank(user);
        vault.createPosition(address(collateralToken), 1000e18, address(debtToken), 500e18);
        assertEq(vault.positionCount(), 1, "Count should be 1");

        vault.createPosition(address(collateralToken), 2000e18, address(debtToken), 1000e18);
        assertEq(vault.positionCount(), 2, "Count should be 2");

        vm.stopPrank();
    }

    // Test get nonexistent position reverts
    function testGetNonexistentPositionReverts() public {
        vm.expectRevert("Position does not exist");
        vault.getPosition(bytes32(uint256(999)));
    }

    // Test updateCollateralAmount
    function testUpdateCollateralAmount() public {
        vm.startPrank(user);
        bytes32 id = vault.createPosition(
            address(collateralToken),
            1000e18,
            address(debtToken),
            500e18
        );
        vm.stopPrank();

        vault.updateCollateralAmount(id, 1500e18);

        PositionVault.Position memory pos = vault.getPosition(id);
        assertEq(pos.collateralAmount, 1500e18, "Collateral should be updated");
    }
}
