// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title MockPriceFeed
/// @notice Mock Chainlink price feed for testing
/// @dev Allows setting prices manually for testing purposes
contract MockPriceFeed {
    int256 public price;
    uint8 public decimals;
    string public description;
    uint256 public version;

    uint80 private roundId;
    uint256 private updatedAt;

    /// @notice Constructor
    /// @param _decimals Number of decimals for the price (typically 8)
    /// @param _description Description of the price feed
    /// @param _initialPrice Initial price to set
    constructor(uint8 _decimals, string memory _description, int256 _initialPrice) {
        decimals = _decimals;
        description = _description;
        price = _initialPrice;
        version = 1;
        roundId = 1;
        updatedAt = block.timestamp;
    }

    /// @notice Sets the price for testing
    /// @param _price New price to set
    function setPrice(int256 _price) external {
        price = _price;
        roundId++;
        updatedAt = block.timestamp;
    }

    /// @notice Gets the latest round data
    /// @return _roundId The round ID
    /// @return answer The current price
    /// @return startedAt Timestamp when the round started
    /// @return _updatedAt Timestamp when the round was updated
    /// @return answeredInRound The round ID in which the answer was computed
    function latestRoundData()
        external
        view
        returns (
            uint80 _roundId,
            int256 answer,
            uint256 startedAt,
            uint256 _updatedAt,
            uint80 answeredInRound
        )
    {
        return (roundId, price, updatedAt, updatedAt, roundId);
    }

    /// @notice Gets data for a specific round
    /// @param _roundId The round ID to query
    /// @return id The round ID
    /// @return answer The price for that round
    /// @return startedAt Timestamp when the round started
    /// @return _updatedAt Timestamp when the round was updated
    /// @return answeredInRound The round ID in which the answer was computed
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 id,
            int256 answer,
            uint256 startedAt,
            uint256 _updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, price, updatedAt, updatedAt, _roundId);
    }
}
