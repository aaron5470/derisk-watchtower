/**
 * Prepare ABIs Script
 *
 * This script copies contract ABIs from the Foundry build output
 * to the subgraph/abis directory for use by The Graph.
 *
 * Usage:
 *   node scripts/prepare-abis.js
 */

const fs = require('fs');
const path = require('path');

// Contract build output paths (Foundry)
const CONTRACTS_OUT_DIR = path.join(__dirname, '../../contracts/out');

// Subgraph ABIs directory
const SUBGRAPH_ABIS_DIR = path.join(__dirname, '../abis');

// Contract names to copy
const CONTRACTS = ['PositionVault', 'Protector', 'DemoEscrow'];

function ensureDirectoryExists(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function extractAbi(contractPath) {
  if (!fs.existsSync(contractPath)) {
    console.error(`Error: Contract build not found at ${contractPath}`);
    console.error('Please build contracts first using: cd contracts && forge build');
    return null;
  }

  const buildData = JSON.parse(fs.readFileSync(contractPath, 'utf8'));

  // Foundry stores ABI directly in the JSON
  if (buildData.abi) {
    return buildData.abi;
  }

  console.error(`Error: No ABI found in ${contractPath}`);
  return null;
}

function copyAbi(contractName) {
  const sourcePath = path.join(
    CONTRACTS_OUT_DIR,
    `${contractName}.sol`,
    `${contractName}.json`
  );

  const abi = extractAbi(sourcePath);
  if (!abi) {
    return false;
  }

  const destPath = path.join(SUBGRAPH_ABIS_DIR, `${contractName}.json`);
  fs.writeFileSync(destPath, JSON.stringify(abi, null, 2), 'utf8');

  console.log(`✅ Copied ABI for ${contractName}`);
  return true;
}

function createPlaceholderAbi(contractName) {
  // Create minimal placeholder ABI for development
  const placeholderAbi = [
    {
      "anonymous": false,
      "inputs": [],
      "name": "Placeholder",
      "type": "event"
    }
  ];

  const destPath = path.join(SUBGRAPH_ABIS_DIR, `${contractName}.json`);
  fs.writeFileSync(destPath, JSON.stringify(placeholderAbi, null, 2), 'utf8');

  console.log(`⚠️  Created placeholder ABI for ${contractName} (contracts not built yet)`);
}

function main() {
  console.log('🔄 Preparing contract ABIs for subgraph...\n');

  // Ensure ABIs directory exists
  ensureDirectoryExists(SUBGRAPH_ABIS_DIR);

  // Check if contracts are built
  const contractsBuilt = fs.existsSync(CONTRACTS_OUT_DIR);

  if (!contractsBuilt) {
    console.log('⚠️  Contracts not built yet. Creating placeholder ABIs...\n');
    CONTRACTS.forEach(createPlaceholderAbi);
    console.log('\n⚠️  IMPORTANT: Build contracts and run this script again before deploying:');
    console.log('   cd contracts && forge build && cd ../subgraph && npm run prepare-abis');
    return;
  }

  // Copy ABIs
  let successCount = 0;
  for (const contractName of CONTRACTS) {
    if (copyAbi(contractName)) {
      successCount++;
    }
  }

  if (successCount === CONTRACTS.length) {
    console.log(`\n✅ Successfully prepared all ${successCount} ABIs`);
    console.log('\nNext steps:');
    console.log('  1. Run: npm run codegen');
    console.log('  2. Run: npm run build');
  } else {
    console.error(`\n❌ Failed to prepare some ABIs (${successCount}/${CONTRACTS.length} successful)`);
    process.exit(1);
  }
}

main();
