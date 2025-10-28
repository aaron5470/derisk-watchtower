// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Protector.sol";

/// @notice Chainlink Automation Registrar Interface
/// @dev Interface for registering upkeeps on Chainlink Automation
interface AutomationRegistrarInterface {
    function registerUpkeep(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source,
        address sender
    ) external;
}

/// @title RegisterUpkeep
/// @notice Script to register Chainlink Automation Upkeep for the Protector contract
/// @dev Implements E3.3 from E3-automation.md
contract RegisterUpkeep is Script {

    /// @notice Main execution function for registering the upkeep
    /// @dev Reads environment variables and registers the Protector contract with Chainlink Automation
    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address protectorAddress = vm.envAddress("PROTECTOR_ADDRESS");
        address linkToken = vm.envAddress("LINK_TOKEN_BASE_SEPOLIA");
        address registrar = vm.envAddress("AUTOMATION_REGISTRAR_BASE_SEPOLIA");

        console.log("=== Chainlink Automation Upkeep Registration ===");
        console.log("Protector Address:", protectorAddress);
        console.log("LINK Token:", linkToken);
        console.log("Registrar:", registrar);

        vm.startBroadcast(deployerPrivateKey);

        // Prepare checkData with monitored position IDs
        bytes32[] memory positions = loadMonitoredPositions();
        bytes memory checkData = abi.encode(positions);

        console.log("Monitoring", positions.length, "positions");
        console.log("CheckData length:", checkData.length, "bytes");

        // Register upkeep with Chainlink Automation
        AutomationRegistrarInterface(registrar).registerUpkeep(
            "DeRisk Watchtower Protection",  // name
            "",                               // encryptedEmail (empty for now)
            protectorAddress,                 // upkeepContract
            500000,                          // gasLimit (500k gas)
            msg.sender,                       // adminAddress
            checkData,                        // checkData (encoded position IDs)
            5 ether,                          // amount (5 LINK funding)
            0,                                // source (manual registration)
            msg.sender                        // sender
        );

        console.log("=== Upkeep Registration Successful ===");
        console.log("Upkeep registered for Protector:", protectorAddress);
        console.log("Name: DeRisk Watchtower Protection");
        console.log("Gas Limit: 500,000");
        console.log("Funding: 5 LINK");
        console.log("Admin:", msg.sender);

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
