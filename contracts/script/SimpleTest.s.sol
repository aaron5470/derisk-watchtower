// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

/// @title SimpleTest
/// @notice Simple test contract to generate events
contract SimpleTest is Script {
    
    event TestEvent(address indexed user, uint256 amount, string message);
    
    function run() external {
        // Use a fixed private key for local testing
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy a simple contract that emits events
        SimpleEventEmitter emitter = new SimpleEventEmitter();
        console.log("SimpleEventEmitter deployed at:", address(emitter));

        // Generate some test events
        emitter.emitEvent("Hello World", 100);
        emitter.emitEvent("Test Event 1", 200);
        emitter.emitEvent("Test Event 2", 300);

        // Stop broadcasting
        vm.stopBroadcast();

        console.log("Test events generated successfully");
    }
}

contract SimpleEventEmitter {
    event TestEvent(address indexed user, uint256 amount, string message);
    
    function emitEvent(string memory message, uint256 amount) external {
        emit TestEvent(msg.sender, amount, message);
    }
}