// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title MockERC20
/// @notice Mock ERC20 token for testing purposes
/// @dev Allows anyone to mint tokens for testing
contract MockERC20 is ERC20 {
    uint8 private _decimals;

    /// @notice Constructor with optional custom decimals
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param decimals_ Number of decimals (defaults to 18 if 0)
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_
    ) ERC20(name, symbol) {
        _decimals = decimals_ == 0 ? 18 : decimals_;
    }

    /// @notice Mints tokens to a specified address
    /// @param to Recipient address
    /// @param amount Amount of tokens to mint
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    /// @notice Burns tokens from a specified address
    /// @param from Address to burn from
    /// @param amount Amount of tokens to burn
    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }

    /// @notice Returns the number of decimals
    /// @return Number of decimals
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
