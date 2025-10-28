// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title PositionVault
/// @notice Manages DeFi lending positions with health factor tracking
/// @dev Uses OpenZeppelin ReentrancyGuard and Pausable for security
contract PositionVault is ReentrancyGuard, Pausable, Ownable {
    /// @notice Position structure representing a lending position
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

    /// @notice Mapping of position ID to Position data
    mapping(bytes32 => Position) public positions;

    /// @notice Mapping of user address to their position IDs
    mapping(address => bytes32[]) public userPositions;

    /// @notice Total number of positions created
    uint256 public positionCount;

    /// @notice Liquidation threshold (80% = 8000 in basis points with 2 decimals)
    uint256 public constant LIQUIDATION_THRESHOLD = 8000;

    /// @notice Precision for health factor calculation (4 decimals)
    uint256 public constant HEALTH_FACTOR_PRECISION = 10000;

    /// @notice Emitted when a new position is created
    /// @param id Unique position identifier
    /// @param owner Address of the position owner
    /// @param collateralAmount Amount of collateral deposited
    /// @param debtAmount Amount of debt taken
    event PositionCreated(
        bytes32 indexed id,
        address indexed owner,
        uint256 collateralAmount,
        uint256 debtAmount
    );

    /// @notice Emitted when a position's health factor is updated
    /// @param id Position identifier
    /// @param newHealthFactor New health factor value
    /// @param previousHealthFactor Previous health factor value
    /// @param timestamp Update timestamp
    event PositionUpdated(
        bytes32 indexed id,
        uint256 newHealthFactor,
        uint256 previousHealthFactor,
        uint256 timestamp
    );

    constructor() Ownable(msg.sender) {}

    /// @notice Creates a new lending position
    /// @param collateralToken Address of collateral ERC20 token
    /// @param collateralAmount Amount of collateral to deposit
    /// @param debtToken Address of debt ERC20 token
    /// @param debtAmount Amount of debt to take
    /// @return id Unique position identifier
    function createPosition(
        address collateralToken,
        uint256 collateralAmount,
        address debtToken,
        uint256 debtAmount
    ) external nonReentrant whenNotPaused returns (bytes32) {
        require(collateralToken != address(0), "Invalid collateral token");
        require(debtToken != address(0), "Invalid debt token");
        require(collateralAmount > 0, "Collateral must be > 0");
        require(debtAmount > 0, "Debt must be > 0");

        // Generate unique position ID
        bytes32 positionId = keccak256(
            abi.encodePacked(
                msg.sender,
                collateralToken,
                debtToken,
                positionCount,
                block.timestamp
            )
        );

        // For initial creation, we assume 1:1 price ratio for simplicity
        // In production, this would fetch real prices from oracle
        uint256 initialHealthFactor = calculateHealthFactor(
            collateralAmount,
            1e8, // Assume $1 price with 8 decimals (Chainlink format)
            debtAmount,
            1e8  // Assume $1 price with 8 decimals
        );

        // Create position
        positions[positionId] = Position({
            id: positionId,
            owner: msg.sender,
            collateralAmount: collateralAmount,
            collateralToken: collateralToken,
            debtAmount: debtAmount,
            debtToken: debtToken,
            healthFactor: initialHealthFactor,
            lastUpdateTimestamp: block.timestamp
        });

        // Add to user's positions
        userPositions[msg.sender].push(positionId);

        // Increment position count
        positionCount++;

        emit PositionCreated(
            positionId,
            msg.sender,
            collateralAmount,
            debtAmount
        );

        return positionId;
    }

    /// @notice Calculates health factor for a position
    /// @dev HF = (collateral * price * liquidationThreshold) / (debt * price)
    /// @param collateralAmount Amount of collateral
    /// @param collateralPrice Price of collateral (8 decimals, Chainlink format)
    /// @param debtAmount Amount of debt
    /// @param debtPrice Price of debt token (8 decimals, Chainlink format)
    /// @return Health factor with 4 decimal precision (e.g., 13000 = 1.3)
    function calculateHealthFactor(
        uint256 collateralAmount,
        uint256 collateralPrice,
        uint256 debtAmount,
        uint256 debtPrice
    ) public pure returns (uint256) {
        if (debtAmount == 0) {
            return type(uint256).max; // No debt = infinite health factor
        }

        // Calculate collateral value in USD (with 8 decimals from price)
        uint256 collateralValue = (collateralAmount * collateralPrice) / 1e18;

        // Apply liquidation threshold (80%)
        uint256 adjustedCollateralValue = (collateralValue * 8000) / 10000;

        // Calculate debt value in USD (with 8 decimals from price)
        uint256 debtValue = (debtAmount * debtPrice) / 1e18;

        // Calculate health factor with 4 decimal precision
        // HF = (adjustedCollateralValue / debtValue) * 10000
        uint256 healthFactor = (adjustedCollateralValue * HEALTH_FACTOR_PRECISION) / debtValue;

        return healthFactor;
    }

    /// @notice Retrieves a position by its ID
    /// @param id Position identifier
    /// @return Position struct containing all position data
    function getPosition(bytes32 id) external view returns (Position memory) {
        require(positions[id].owner != address(0), "Position does not exist");
        return positions[id];
    }

    /// @notice Retrieves all position IDs for a user
    /// @param user Address of the user
    /// @return Array of position IDs owned by the user
    function getUserPositions(address user) external view returns (bytes32[] memory) {
        return userPositions[user];
    }

    /// @notice Updates the health factor of a position
    /// @param positionId Position identifier
    /// @param collateralPrice Current price of collateral token
    /// @param debtPrice Current price of debt token
    function updateHealthFactor(
        bytes32 positionId,
        uint256 collateralPrice,
        uint256 debtPrice
    ) external nonReentrant whenNotPaused {
        Position storage position = positions[positionId];
        require(position.owner != address(0), "Position does not exist");

        uint256 previousHF = position.healthFactor;

        uint256 newHF = calculateHealthFactor(
            position.collateralAmount,
            collateralPrice,
            position.debtAmount,
            debtPrice
        );

        // Update position
        position.healthFactor = newHF;
        position.lastUpdateTimestamp = block.timestamp;

        // Emit event only if HF changed significantly (> 1%)
        if (_hasSignificantChange(previousHF, newHF)) {
            emit PositionUpdated(
                positionId,
                newHF,
                previousHF,
                block.timestamp
            );
        }
    }

    /// @notice Updates collateral amount for a position (called by Protector)
    /// @param positionId Position identifier
    /// @param newCollateralAmount New collateral amount after protection
    function updateCollateralAmount(
        bytes32 positionId,
        uint256 newCollateralAmount
    ) external nonReentrant whenNotPaused {
        Position storage position = positions[positionId];
        require(position.owner != address(0), "Position does not exist");

        position.collateralAmount = newCollateralAmount;
        position.lastUpdateTimestamp = block.timestamp;
    }

    /// @notice Pauses the contract (only owner)
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses the contract (only owner)
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @dev Checks if health factor changed by more than 1%
    /// @param oldHF Previous health factor
    /// @param newHF New health factor
    /// @return True if change is significant
    function _hasSignificantChange(uint256 oldHF, uint256 newHF) private pure returns (bool) {
        if (oldHF == 0) return true;

        uint256 diff = oldHF > newHF ? oldHF - newHF : newHF - oldHF;
        uint256 percentChange = (diff * 10000) / oldHF;

        return percentChange > 100; // > 1%
    }
}
