// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IAutomationCompatible
/// @notice Interface for Chainlink Automation compatibility
/// @dev Contracts implementing this interface can be automated by Chainlink Keepers
interface IAutomationCompatible {
    /// @notice Checks if upkeep is needed
    /// @param checkData Data passed to the check function
    /// @return upkeepNeeded True if upkeep should be performed
    /// @return performData Data to pass to performUpkeep
    function checkUpkeep(bytes calldata checkData)
        external
        returns (bool upkeepNeeded, bytes memory performData);

    /// @notice Performs the upkeep
    /// @param performData Data from checkUpkeep
    function performUpkeep(bytes calldata performData) external;
}
