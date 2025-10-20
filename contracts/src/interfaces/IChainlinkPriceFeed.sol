// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IChainlinkPriceFeed
/// @notice Interface for Chainlink price feed oracles
/// @dev Based on Chainlink AggregatorV3Interface
interface IChainlinkPriceFeed {
    /// @notice Get the latest price data from the oracle
    /// @return roundId The round ID
    /// @return answer The price (with decimals specified by decimals())
    /// @return startedAt Timestamp when the round started
    /// @return updatedAt Timestamp when the round was updated
    /// @return answeredInRound The round ID in which the answer was computed
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    /// @notice Get the number of decimals in the price
    /// @return Number of decimals (typically 8 for Chainlink USD feeds)
    function decimals() external view returns (uint8);

    /// @notice Get a description of the price feed
    /// @return Description string
    function description() external view returns (string memory);

    /// @notice Get the version of the aggregator
    /// @return Version number
    function version() external view returns (uint256);
}
