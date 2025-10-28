// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title DemoEscrow
/// @notice Simple escrow contract for holding collateral used in protection operations
/// @dev FOR TESTNET DEMONSTRATION ONLY - Not audited for production use
/// @dev [owner=ai] [review=WK] [tool=Claude] [date=2025-10-16] [scope=file] [notes=init events]
contract DemoEscrow is Ownable {
    using SafeERC20 for IERC20;

    /// @notice Mapping of authorized protector contracts
    mapping(address => bool) public authorizedProtectors;

    /// @notice Emitted when escrow is funded with tokens
    /// @param token Address of the token funded
    /// @param amount Amount of tokens deposited
    /// @param funder Address that funded the escrow
    event EscrowFunded(
        address indexed token,
        uint256 amount,
        address indexed funder
    );

    /// @notice Emitted when a protector is authorized
    /// @param protector Address of the authorized protector
    event ProtectorAuthorized(address indexed protector);

    /// @notice Emitted when a protector is deauthorized
    /// @param protector Address of the deauthorized protector
    event ProtectorDeauthorized(address indexed protector);

    /// @notice Emitted when tokens are withdrawn
    /// @param token Address of the token withdrawn
    /// @param to Recipient address
    /// @param amount Amount withdrawn
    /// @param withdrawer Address that initiated the withdrawal
    event TokensWithdrawn(
        address indexed token,
        address indexed to,
        uint256 amount,
        address indexed withdrawer
    );

    constructor() Ownable(msg.sender) {}

    /// @notice Funds the escrow with tokens
    /// @param token Address of the ERC20 token
    /// @param amount Amount of tokens to deposit
    function fund(address token, uint256 amount) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be > 0");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit EscrowFunded(token, amount, msg.sender);
    }

    /// @notice Authorizes a protector contract to withdraw funds
    /// @param protector Address of the protector contract
    function authorizeProtector(address protector) external onlyOwner {
        require(protector != address(0), "Invalid protector address");
        require(!authorizedProtectors[protector], "Already authorized");

        authorizedProtectors[protector] = true;

        emit ProtectorAuthorized(protector);
    }

    /// @notice Deauthorizes a protector contract
    /// @param protector Address of the protector contract
    function deauthorizeProtector(address protector) external onlyOwner {
        require(authorizedProtectors[protector], "Not authorized");

        authorizedProtectors[protector] = false;

        emit ProtectorDeauthorized(protector);
    }

    /// @notice Withdraws tokens from escrow (only authorized protectors)
    /// @param token Address of the token to withdraw
    /// @param to Recipient address
    /// @param amount Amount to withdraw
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external {
        require(authorizedProtectors[msg.sender], "Not authorized");
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be > 0");

        IERC20(token).safeTransfer(to, amount);

        emit TokensWithdrawn(token, to, amount, msg.sender);
    }

    /// @notice Emergency withdrawal by owner
    /// @param token Address of the token to withdraw
    /// @param to Recipient address
    /// @param amount Amount to withdraw
    function emergencyWithdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be > 0");

        IERC20(token).safeTransfer(to, amount);

        emit TokensWithdrawn(token, to, amount, msg.sender);
    }

    /// @notice Gets the balance of a specific token in the escrow
    /// @param token Address of the token
    /// @return Balance of the token in the escrow
    function getBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /// @notice Checks if an address is an authorized protector
    /// @param protector Address to check
    /// @return True if authorized, false otherwise
    function isAuthorized(address protector) external view returns (bool) {
        return authorizedProtectors[protector];
    }
}
