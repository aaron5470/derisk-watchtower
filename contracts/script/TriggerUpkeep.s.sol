// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Protector.sol";

/// @title TriggerUpkeep
/// @notice Script to manually trigger Chainlink Automation upkeep for the Protector contract
/// @dev Implements E3.4.3 from E3-automation.md - Manual fallback mechanism
contract TriggerUpkeep is Script {

    /// @notice Main execution function for manually triggering upkeep
    /// @dev Checks if upkeep is needed and performs it if necessary
    function run() external {
        // Load environment variable
        address protectorAddress = vm.envAddress("PROTECTOR_ADDRESS");

        console.log("=== Manual Upkeep Trigger ===");
        console.log("Protector Address:", protectorAddress);

        Protector protector = Protector(protectorAddress);

        // Load positions to check
        bytes32[] memory positions = loadMonitoredPositions();
        bytes memory checkData = abi.encode(positions);

        console.log("Checking", positions.length, "positions for upkeep...");

        vm.startBroadcast();

        // Step 1: Check if upkeep is needed
        (bool upkeepNeeded, bytes memory performData) =
            protector.checkUpkeep(checkData);

        if (upkeepNeeded) {
            console.log("Upkeep needed! Executing performUpkeep...");

            // Decode position ID from performData
            bytes32 positionId = abi.decode(performData, (bytes32));
            console.log("Critical position detected:", vm.toString(positionId));

            // Get position HF before protection
            uint256 beforeHF = protector.getPositionHF(positionId);
            console.log("Health Factor before protection:", beforeHF);

            // Step 2: Perform upkeep
            protector.performUpkeep(performData);

            // Get position HF after protection
            uint256 afterHF = protector.getPositionHF(positionId);
            console.log("Health Factor after protection:", afterHF);

            console.log("=== Upkeep Performed Successfully ===");
            console.log("Position protected:", vm.toString(positionId));
            console.log("HF improved from", beforeHF, "to", afterHF);
        } else {
            console.log("=== No Upkeep Needed ===");
            console.log("All monitored positions are healthy (HF > 1.3)");
        }

        vm.stopBroadcast();
    }

    /// @notice Loads monitored position IDs from configuration
    /// @dev For demo/testing, returns a hardcoded array of position IDs
    /// @dev In production, this would read from a JSON file or on-chain registry
    /// @return positions Array of position IDs to monitor
    function loadMonitoredPositions() internal pure returns (bytes32[] memory positions) {
        // For demo purposes, return a small array of example position IDs
        // In production, this would be loaded from:
        // - JSON file: vm.readFile("contracts/deployments/monitored-positions.json")
        // - On-chain registry: query PositionVault for active positions
        // - Database: API call to backend to get active positions

        positions = new bytes32[](3);

        // Example position IDs (these would be replaced with actual position IDs)
        positions[0] = bytes32(uint256(1)); // Example position 1
        positions[1] = bytes32(uint256(2)); // Example position 2
        positions[2] = bytes32(uint256(3)); // Example position 3

        return positions;
    }

    /// @notice Alternative implementation: Load positions from JSON file
    /// @dev Uncomment and use this function if you have a monitored-positions.json file
    /// @return positions Array of position IDs from JSON file
    /*
    function loadMonitoredPositionsFromJSON() internal view returns (bytes32[] memory positions) {
        // Read JSON file
        string memory json = vm.readFile("contracts/deployments/monitored-positions.json");

        // Parse JSON structure (example structure):
        // {
        //   "positions": [
        //     "0x05160687fb252bb950f996cafae447c81269b909d6fb181b0fb7b293bec00aed",
        //     "0x15160687fb252bb950f996cafae447c81269b909d6fb181b0fb7b293bec00aed"
        //   ]
        // }

        // For now, using basic parsing - in production use vm.parseJson
        // This is a simplified example
        positions = new bytes32[](2);
        positions[0] = bytes32(vm.parseJsonBytes32(json, ".positions[0]"));
        positions[1] = bytes32(vm.parseJsonBytes32(json, ".positions[1]"));

        return positions;
    }
    */
}
