// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IAutomationCompatible.sol";
import "./interfaces/IChainlinkPriceFeed.sol";

/// @notice Position structure (matches PositionVault)
struct Position {
    bytes32 id;
    address owner;
    uint256 collateralAmount;
    address collateralToken;
    uint256 debtAmount;
    address debtToken;
    uint256 healthFactor;
    uint256 lastUpdateTimestamp;
}

/// @notice Interface for PositionVault contract
interface IPositionVault {
        function getPosition(bytes32 id) external view returns (Position memory);
        function updateHealthFactor(bytes32 id, uint256 collateralPrice, uint256 debtPrice) external;
        function updateCollateralAmount(bytes32 id, uint256 newCollateralAmount) external;
        function calculateHealthFactor(
            uint256 collateralAmount,
            uint256 collateralPrice,
            uint256 debtAmount,
            uint256 debtPrice
        ) external pure returns (uint256);
    }

/// @notice Interface for DemoEscrow contract
interface IDemoEscrow {
    function withdraw(address token, address to, uint256 amount) external;
}

/// @title Protector
/// @notice Executes protection strategies for at-risk DeFi positions
/// @dev Adds collateral from escrow to improve position health factors
contract Protector is ReentrancyGuard, IAutomationCompatible {
    using SafeERC20 for IERC20;

    /// @notice PositionVault contract reference
    IPositionVault public immutable positionVault;

    /// @notice Escrow contract address
    address public immutable escrow;

    /// @notice Chainlink price feed for collateral token
    address public immutable collateralPriceFeed;

    /// @notice Chainlink price feed for debt token
    address public immutable debtPriceFeed;

    /// @notice Critical health factor threshold (1.3 = 13000 with 4 decimals)
    uint256 public constant CRITICAL_THRESHOLD = 13000;

    /// @notice Target health factor after protection (1.5 = 15000 with 4 decimals)
    uint256 public constant TARGET_HF = 15000;

    /// @notice Total number of automation triggers
    uint256 public totalAutomationTriggers;

    /// @notice Timestamp of last automation trigger
    uint256 public lastAutomationTimestamp;

    /// @notice Automation trigger count per position
    mapping(bytes32 => uint256) public positionAutomationCount;

    /// @notice Emitted when protection is executed for a position
    /// @param positionId Position identifier
    /// @param beforeHF Health factor before protection
    /// @param afterHF Health factor after protection
    /// @param collateralAdded Amount of collateral added
    /// @param executor Address that executed the protection
    event ProtectionExecuted(
        bytes32 indexed positionId,
        uint256 beforeHF,
        uint256 afterHF,
        uint256 collateralAdded,
        address indexed executor
    );

    /// @notice Emitted when Chainlink Automation triggers protection
    /// @param positionId Position identifier
    /// @param healthFactor Health factor at time of trigger
    /// @param keeper Address of the Chainlink keeper
    event AutomationTriggered(
        bytes32 indexed positionId,
        uint256 healthFactor,
        address indexed keeper
    );

    /// @notice Constructor
    /// @param _vault Address of PositionVault contract
    /// @param _escrow Address of DemoEscrow contract
    /// @param _collateralPriceFeed Address of Chainlink price feed for collateral
    /// @param _debtPriceFeed Address of Chainlink price feed for debt
    constructor(
        address _vault,
        address _escrow,
        address _collateralPriceFeed,
        address _debtPriceFeed
    ) {
        require(_vault != address(0), "Invalid vault address");
        require(_escrow != address(0), "Invalid escrow address");
        require(_collateralPriceFeed != address(0), "Invalid collateral price feed");
        require(_debtPriceFeed != address(0), "Invalid debt price feed");

        positionVault = IPositionVault(_vault);
        escrow = _escrow;
        collateralPriceFeed = _collateralPriceFeed;
        debtPriceFeed = _debtPriceFeed;
    }

    /// @notice Protects a position by adding collateral from escrow
    /// @param positionId Position identifier
    /// @param collateralToAdd Amount of collateral to add from escrow
    /// @param collateralPrice Current price of collateral token
    /// @param debtPrice Current price of debt token
    /// @return newHF New health factor after protection
    function protect(
        bytes32 positionId,
        uint256 collateralToAdd,
        uint256 collateralPrice,
        uint256 debtPrice
    ) public nonReentrant returns (uint256 newHF) {
        require(collateralToAdd > 0, "Collateral to add must be > 0");

        // Fetch position from vault
        Position memory pos = positionVault.getPosition(positionId);
        require(pos.owner != address(0), "Position does not exist");

        // Calculate current health factor
        uint256 currentHF = positionVault.calculateHealthFactor(
            pos.collateralAmount,
            collateralPrice,
            pos.debtAmount,
            debtPrice
        );

        // Transfer collateral from escrow to vault
        // In production, this would transfer to the actual lending protocol
        IDemoEscrow(escrow).withdraw(
            pos.collateralToken,
            address(this),
            collateralToAdd
        );

        // Calculate new collateral amount
        uint256 newCollateralAmount = pos.collateralAmount + collateralToAdd;

        // Calculate new health factor
        newHF = positionVault.calculateHealthFactor(
            newCollateralAmount,
            collateralPrice,
            pos.debtAmount,
            debtPrice
        );

        // Ensure protection improved the health factor
        require(newHF > currentHF, "Protection did not improve HF");

        // Update position in vault
        positionVault.updateCollateralAmount(positionId, newCollateralAmount);
        positionVault.updateHealthFactor(positionId, collateralPrice, debtPrice);

        emit ProtectionExecuted(
            positionId,
            currentHF,
            newHF,
            collateralToAdd,
            msg.sender
        );

        return newHF;
    }

    /// @notice Chainlink Automation: Checks if upkeep is needed
    /// @param checkData ABI-encoded array of position IDs to check
    /// @return upkeepNeeded True if any position needs protection
    /// @return performData ABI-encoded position ID that needs protection
    function checkUpkeep(bytes calldata checkData)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        bytes32[] memory positionIds = abi.decode(checkData, (bytes32[]));

        for (uint256 i = 0; i < positionIds.length; i++) {
            // Use try-catch to handle non-existent positions gracefully
            try positionVault.getPosition(positionIds[i]) returns (Position memory pos) {
                // Skip invalid positions
                if (pos.owner == address(0)) {
                    continue;
                }

                // Calculate current health factor with live prices
                uint256 collateralPrice = getCollateralPrice();
                uint256 debtPrice = getDebtPrice();
                uint256 hf = positionVault.calculateHealthFactor(
                    pos.collateralAmount,
                    collateralPrice,
                    pos.debtAmount,
                    debtPrice
                );

                // If HF below critical threshold, trigger upkeep
                if (hf <= CRITICAL_THRESHOLD) {
                    upkeepNeeded = true;
                    performData = abi.encode(positionIds[i]);
                    break;
                }
            } catch {
                // Position doesn't exist or error occurred - skip it
                continue;
            }
        }
    }

    /// @notice Chainlink Automation: Performs upkeep (protection)
    /// @param performData ABI-encoded position ID to protect
    function performUpkeep(bytes calldata performData) external override nonReentrant {
        bytes32 positionId = abi.decode(performData, (bytes32));

        // Fetch position
        Position memory pos = positionVault.getPosition(positionId);
        require(pos.owner != address(0), "Position does not exist");

        // Get live prices
        uint256 collateralPrice = getCollateralPrice();
        uint256 debtPrice = getDebtPrice();

        // Revalidate condition
        uint256 currentHF = positionVault.calculateHealthFactor(
            pos.collateralAmount,
            collateralPrice,
            pos.debtAmount,
            debtPrice
        );
        require(currentHF <= CRITICAL_THRESHOLD, "HF above threshold");

        // Calculate collateral needed to restore to safe level (HF = 1.5)
        uint256 collateralToAdd = calculateCollateralNeeded(
            pos,
            collateralPrice,
            debtPrice
        );

        // Execute protection
        uint256 beforeHF = currentHF;
        protect(positionId, collateralToAdd, collateralPrice, debtPrice);

        // Update automation metrics
        totalAutomationTriggers++;
        lastAutomationTimestamp = block.timestamp;
        positionAutomationCount[positionId]++;

        emit AutomationTriggered(positionId, beforeHF, msg.sender);
    }

    /// @notice Calculates collateral needed to restore HF to target level
    /// @param pos Position to protect
    /// @param collateralPrice Current collateral price
    /// @param debtPrice Current debt price
    /// @return Amount of collateral needed
    function calculateCollateralNeeded(
        Position memory pos,
        uint256 collateralPrice,
        uint256 debtPrice
    ) internal pure returns (uint256) {
        // Current collateral value
        uint256 currentCollateralValue = pos.collateralAmount * collateralPrice;
        uint256 debtValue = pos.debtAmount * debtPrice;

        // Target: HF = 1.5 = (collateral * 0.8) / debt
        // Solving for needed collateral:
        // 1.5 = ((currentCollateral + needed) * 0.8) / debt
        // 1.5 * debt = (currentCollateral + needed) * 0.8
        // (1.5 * debt) / 0.8 = currentCollateral + needed
        // needed = (1.5 * debt / 0.8) - currentCollateral
        // needed = (TARGET_HF * debt * 10000 / 8000) - currentCollateral

        uint256 neededValue = (TARGET_HF * debtValue * 10000) / 8000 - currentCollateralValue;
        uint256 neededAmount = neededValue / collateralPrice;

        return neededAmount;
    }

    /// @notice Gets current collateral price from Chainlink
    /// @return price Current price with 8 decimals
    function getCollateralPrice() internal view returns (uint256 price) {
        IChainlinkPriceFeed feed = IChainlinkPriceFeed(collateralPriceFeed);
        (, int256 answer,,,) = feed.latestRoundData();
        require(answer > 0, "Invalid collateral price");
        return uint256(answer);
    }

    /// @notice Gets current debt price from Chainlink
    /// @return price Current price with 8 decimals
    function getDebtPrice() internal view returns (uint256 price) {
        IChainlinkPriceFeed feed = IChainlinkPriceFeed(debtPriceFeed);
        (, int256 answer,,,) = feed.latestRoundData();
        require(answer > 0, "Invalid debt price");
        return uint256(answer);
    }

    /// @notice Gets automation statistics
    /// @return totalTriggers Total number of automation triggers
    /// @return lastTrigger Timestamp of last trigger
    /// @return timeSinceLastTrigger Seconds since last trigger
    function getAutomationStats()
        external
        view
        returns (
            uint256 totalTriggers,
            uint256 lastTrigger,
            uint256 timeSinceLastTrigger
        )
    {
        return (
            totalAutomationTriggers,
            lastAutomationTimestamp,
            lastAutomationTimestamp == 0 ? 0 : block.timestamp - lastAutomationTimestamp
        );
    }

    /// @notice Gets automation history for a specific position
    /// @param positionId Position identifier
    /// @return triggerCount Number of times automation protected this position
    function getPositionAutomationHistory(bytes32 positionId)
        external
        view
        returns (uint256 triggerCount)
    {
        return positionAutomationCount[positionId];
    }

    /// @notice Gets the health factor of a position
    /// @param positionId Position identifier
    /// @return healthFactor Current health factor
    function getPositionHF(bytes32 positionId) public view returns (uint256 healthFactor) {
        Position memory pos = positionVault.getPosition(positionId);
        return pos.healthFactor;
    }

    /// @notice Modifier to ensure health factor is below threshold
    /// @param positionId Position identifier
    /// @param threshold Health factor threshold
    modifier requireHealthFactorBelow(bytes32 positionId, uint256 threshold) {
        uint256 hf = getPositionHF(positionId);
        require(hf < threshold, "HF above threshold");
        _;
    }
}
