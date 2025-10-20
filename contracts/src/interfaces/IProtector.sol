// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IProtector
/// @notice Interface for Protector contract
interface IProtector {
    /// @notice Protects a position by adding collateral from escrow
    /// @param positionId Position identifier to protect
    /// @param collateralToAdd Amount of collateral to add from escrow
    /// @param collateralPrice Current price of collateral token
    /// @param debtPrice Current price of debt token
    /// @return newHF New health factor after protection
    function protect(bytes32 positionId, uint256 collateralToAdd, uint256 collateralPrice, uint256 debtPrice)
        external
        returns (uint256 newHF);

    /// @notice Checks if a position needs protection
    /// @param positionId Position identifier
    /// @return needsProtection True if health factor is below critical threshold
    function checkUpkeep(bytes32 positionId)
        external
        view
        returns (bool needsProtection);

    /// @notice Gets the health factor of a position
    /// @param positionId Position identifier
    /// @return healthFactor Current health factor
    function getPositionHF(bytes32 positionId)
        external
        view
        returns (uint256 healthFactor);
}
