/**
 * DeRisk Watchtower Subgraph - Event Handlers
 *
 * This file contains all event handlers for indexing position management,
 * protection actions, and risk events from the DeRisk Watchtower contracts.
 */

import { BigInt, Bytes, log, store, Address } from "@graphprotocol/graph-ts";
import {
  PositionCreated as PositionCreatedEvent,
  PositionUpdated as PositionUpdatedEvent,
} from "../generated/PositionVault/PositionVault";
import {
  ProtectionExecuted as ProtectionExecutedEvent,
} from "../generated/Protector/Protector";
import {
  EscrowFunded as EscrowFundedEvent,
  TokensWithdrawn as TokensWithdrawnEvent,
  ProtectorAuthorized as ProtectorAuthorizedEvent,
  ProtectorDeauthorized as ProtectorDeauthorizedEvent,
} from "../generated/DemoEscrow/DemoEscrow";
import {
  Position,
  User,
  Token,
  RiskEvent,
  ProtectionAction,
  GlobalStats,
  DailyStats,
} from "../generated/schema";

// Constants
const ZERO_BI = BigInt.fromI32(0);
const ONE_BI = BigInt.fromI32(1);
const GLOBAL_STATS_ID = "1";

// Health factor thresholds (4 decimal precision)
const HF_CRITICAL = BigInt.fromI32(13000); // 1.3
const HF_WARNING = BigInt.fromI32(15000); // 1.5

/**
 * Get or create GlobalStats singleton entity
 */
function getOrCreateGlobalStats(): GlobalStats {
  let stats = GlobalStats.load(GLOBAL_STATS_ID);
  if (stats == null) {
    stats = new GlobalStats(GLOBAL_STATS_ID);
    stats.totalPositions = ZERO_BI;
    stats.activePositions = ZERO_BI;
    stats.criticalPositions = ZERO_BI;
    stats.warningPositions = ZERO_BI;
    stats.safePositions = ZERO_BI;
    stats.totalProtections = ZERO_BI;
    stats.totalCollateralAddedViaProtection = ZERO_BI;
    stats.successfulProtections = ZERO_BI;
    stats.totalRiskEvents = ZERO_BI;
    stats.totalCriticalEvents = ZERO_BI;
    stats.totalWarningEvents = ZERO_BI;
    stats.totalCollateralDeposited = ZERO_BI;
    stats.totalDebtTaken = ZERO_BI;
    stats.lastUpdatedAt = ZERO_BI;
    stats.lastUpdatedAtBlock = ZERO_BI;
    stats.save();
  }
  return stats;
}

/**
 * Get or create User entity
 */
function getOrCreateUser(address: Bytes, timestamp: BigInt): User {
  let user = User.load(address.toHexString());
  if (user == null) {
    user = new User(address.toHexString());
    user.address = address;
    user.totalPositions = ZERO_BI;
    user.activePositions = ZERO_BI;
    user.totalProtectionsReceived = ZERO_BI;
    user.totalCollateralAddedViaProtection = ZERO_BI;
    user.currentCriticalPositions = ZERO_BI;
    user.currentWarningPositions = ZERO_BI;
    user.currentSafePositions = ZERO_BI;
    user.firstPositionAt = timestamp;
    user.lastActivityAt = timestamp;
    user.save();
  }
  return user;
}

/**
 * Get or create Token entity
 */
function getOrCreateToken(
  address: Bytes,
  timestamp: BigInt,
  symbol: string,
  name: string,
  decimals: i32
): Token {
  let token = Token.load(address.toHexString());
  if (token == null) {
    token = new Token(address.toHexString());
    token.address = address;
    token.symbol = symbol;
    token.name = name;
    token.decimals = decimals;
    token.totalCollateralVolume = ZERO_BI;
    token.totalDebtVolume = ZERO_BI;
    token.positionCount = ZERO_BI;
    token.firstSeenAt = timestamp;
    token.lastSeenAt = timestamp;
    token.save();
  }
  return token;
}

/**
 * Get or create DailyStats entity for a given date
 */
function getOrCreateDailyStats(timestamp: BigInt): DailyStats {
  let dayTimestamp = timestamp.toI32() - (timestamp.toI32() % 86400);
  let dayId = BigInt.fromI32(dayTimestamp).toString();

  let stats = DailyStats.load(dayId);
  if (stats == null) {
    stats = new DailyStats(dayId);
    stats.date = dayTimestamp;
    stats.newPositions = ZERO_BI;
    stats.protectionsExecuted = ZERO_BI;
    stats.riskEventsTriggered = ZERO_BI;
    stats.collateralDeposited = ZERO_BI;
    stats.debtTaken = ZERO_BI;
    stats.collateralAddedViaProtection = ZERO_BI;
    stats.totalActivePositions = ZERO_BI;
    stats.criticalPositionsCount = ZERO_BI;
    stats.warningPositionsCount = ZERO_BI;
    stats.averageHealthFactor = ZERO_BI;
    stats.totalGasUsed = ZERO_BI;
    stats.averageGasPerProtection = ZERO_BI;
    stats.save();
  }
  return stats;
}

/**
 * Determine risk event type based on health factor
 */
function getRiskEventType(healthFactor: BigInt): string {
  if (healthFactor.lt(HF_CRITICAL)) {
    return "CRITICAL";
  } else if (healthFactor.lt(HF_WARNING)) {
    return "WARNING";
  } else {
    return "RECOVERED";
  }
}

/**
 * Update user risk position counts based on health factor
 */
function updateUserRiskCounts(user: User, oldHF: BigInt, newHF: BigInt): void {
  // Decrement old category
  if (oldHF.lt(HF_CRITICAL)) {
    user.currentCriticalPositions = user.currentCriticalPositions.minus(ONE_BI);
  } else if (oldHF.lt(HF_WARNING)) {
    user.currentWarningPositions = user.currentWarningPositions.minus(ONE_BI);
  } else {
    user.currentSafePositions = user.currentSafePositions.minus(ONE_BI);
  }

  // Increment new category
  if (newHF.lt(HF_CRITICAL)) {
    user.currentCriticalPositions = user.currentCriticalPositions.plus(ONE_BI);
  } else if (newHF.lt(HF_WARNING)) {
    user.currentWarningPositions = user.currentWarningPositions.plus(ONE_BI);
  } else {
    user.currentSafePositions = user.currentSafePositions.plus(ONE_BI);
  }

  user.save();
}

/**
 * Update global risk position counts based on health factor change
 */
function updateGlobalRiskCounts(stats: GlobalStats, oldHF: BigInt, newHF: BigInt): void {
  // Decrement old category
  if (oldHF.lt(HF_CRITICAL)) {
    stats.criticalPositions = stats.criticalPositions.minus(ONE_BI);
  } else if (oldHF.lt(HF_WARNING)) {
    stats.warningPositions = stats.warningPositions.minus(ONE_BI);
  } else {
    stats.safePositions = stats.safePositions.minus(ONE_BI);
  }

  // Increment new category
  if (newHF.lt(HF_CRITICAL)) {
    stats.criticalPositions = stats.criticalPositions.plus(ONE_BI);
  } else if (newHF.lt(HF_WARNING)) {
    stats.warningPositions = stats.warningPositions.plus(ONE_BI);
  } else {
    stats.safePositions = stats.safePositions.plus(ONE_BI);
  }

  stats.save();
}

// ============================================================================
// PositionVault Event Handlers
// ============================================================================

/**
 * Handle PositionCreated event
 * Event signature: PositionCreated(bytes32 indexed id, address indexed owner,
 *                                   uint256 collateralAmount, uint256 debtAmount)
 */
export function handlePositionCreated(event: PositionCreatedEvent): void {
  let positionId = event.params.id.toHexString();
  let position = new Position(positionId);

  // Default health factor to 1.0 (10000 with 4 decimal precision) since not provided in event
  let defaultHealthFactor = BigInt.fromI32(10000);

  // Use placeholder addresses for collateral and debt tokens since not provided in event
  let placeholderToken = Address.zero();

  position.user = event.params.owner.toHexString();
  position.userAddress = event.params.owner;
  position.collateralToken = placeholderToken;
  position.collateralAmount = event.params.collateralAmount;
  position.debtToken = placeholderToken;
  position.debtAmount = event.params.debtAmount;
  position.healthFactor = defaultHealthFactor;
  position.createdAt = event.block.timestamp;
  position.createdAtBlock = event.block.number;
  position.lastUpdatedAt = event.block.timestamp;
  position.lastUpdatedAtBlock = event.block.number;
  position.isActive = true;
  position.totalProtections = ZERO_BI;
  position.totalCollateralAdded = ZERO_BI;
  position.lowestHealthFactor = defaultHealthFactor;
  position.highestHealthFactor = defaultHealthFactor;

  position.save();

  // Update User entity
  let user = getOrCreateUser(event.params.owner, event.block.timestamp);
  user.totalPositions = user.totalPositions.plus(ONE_BI);
  user.activePositions = user.activePositions.plus(ONE_BI);
  user.lastActivityAt = event.block.timestamp;

  // Update user risk counts - start with safe position
  user.currentSafePositions = user.currentSafePositions.plus(ONE_BI);
  user.save();

  // Update GlobalStats
  let stats = getOrCreateGlobalStats();
  stats.totalPositions = stats.totalPositions.plus(ONE_BI);
  stats.activePositions = stats.activePositions.plus(ONE_BI);
  stats.totalCollateralDeposited = stats.totalCollateralDeposited.plus(event.params.collateralAmount);
  stats.totalDebtTaken = stats.totalDebtTaken.plus(event.params.debtAmount);
  stats.lastUpdatedAt = event.block.timestamp;
  stats.lastUpdatedAtBlock = event.block.number;

  // Start with safe position count
  stats.safePositions = stats.safePositions.plus(ONE_BI);
  stats.save();

  // Update DailyStats
  let dailyStats = getOrCreateDailyStats(event.block.timestamp);
  dailyStats.newPositions = dailyStats.newPositions.plus(ONE_BI);
  dailyStats.collateralDeposited = dailyStats.collateralDeposited.plus(event.params.collateralAmount);
  dailyStats.debtTaken = dailyStats.debtTaken.plus(event.params.debtAmount);
  dailyStats.save();

  log.info("Position created: {} by owner: {} with collateral: {} debt: {}", [
    positionId,
    event.params.owner.toHexString(),
    event.params.collateralAmount.toString(),
    event.params.debtAmount.toString(),
  ]);
}

/**
 * Handle PositionUpdated event
 * Event signature: PositionUpdated(bytes32 indexed id, uint256 newHealthFactor,
 *                                   uint256 previousHealthFactor, uint256 timestamp)
 */
export function handlePositionUpdated(event: PositionUpdatedEvent): void {
  let positionId = event.params.id.toHexString();
  let position = Position.load(positionId);

  if (position == null) {
    log.warning("Position not found for update: {}", [positionId]);
    return;
  }

  let oldHF = event.params.previousHealthFactor;
  let newHF = event.params.newHealthFactor;

  // Update health factor (collateralAmount and debtAmount are not provided in this event)
  position.healthFactor = newHF;
  position.lastUpdatedAt = event.block.timestamp;
  position.lastUpdatedAtBlock = event.block.number;

  // Update HF extremes
  if (newHF.lt(position.lowestHealthFactor)) {
    position.lowestHealthFactor = newHF;
  }
  if (newHF.gt(position.highestHealthFactor)) {
    position.highestHealthFactor = newHF;
  }

  position.save();

  // Update User risk counts
  let user = User.load(position.user);
  if (user != null) {
    updateUserRiskCounts(user, oldHF, newHF);
    user.lastActivityAt = event.block.timestamp;
    user.save();
  }

  // Update GlobalStats risk counts
  let stats = getOrCreateGlobalStats();
  updateGlobalRiskCounts(stats, oldHF, newHF);
  stats.lastUpdatedAt = event.block.timestamp;
  stats.lastUpdatedAtBlock = event.block.number;
  stats.save();

  log.info("Position updated: {} HF changed from {} to {}", [
    positionId,
    oldHF.toString(),
    newHF.toString(),
  ]);
}


// ============================================================================
// Protector Event Handlers
// ============================================================================

/**
 * Handle ProtectionExecuted event
 * Event signature: ProtectionExecuted(bytes32 indexed positionId, uint256 beforeHF,
 *                                      uint256 afterHF, uint256 collateralAdded, address indexed executor)
 */
export function handleProtectionExecuted(event: ProtectionExecutedEvent): void {
  let positionId = event.params.positionId.toHexString();
  let position = Position.load(positionId);

  if (position == null) {
    log.warning("Position not found for protection: {}", [positionId]);
    return;
  }

  // Create ProtectionAction entity
  let protectionId =
    event.transaction.hash.toHexString() + "-" + event.logIndex.toString();
  let protection = new ProtectionAction(protectionId);
  protection.position = positionId;
  protection.actionType = "AUTOMATED_PROTECTION"; // Could be enhanced to detect type
  protection.collateralAdded = event.params.collateralAdded;
  protection.healthFactorBefore = event.params.beforeHF;
  protection.healthFactorAfter = event.params.afterHF;
  protection.protector = event.params.executor;
  protection.timestamp = event.block.timestamp;
  protection.blockNumber = event.block.number;
  protection.transactionHash = event.transaction.hash;
  protection.gasUsed = ZERO_BI; // Gas used not available in event
  protection.save();

  // Update Position
  let oldHF = position.healthFactor;
  let newHF = event.params.afterHF;

  position.collateralAmount = position.collateralAmount.plus(event.params.collateralAdded);
  position.healthFactor = newHF;
  position.totalProtections = position.totalProtections.plus(ONE_BI);
  position.totalCollateralAdded = position.totalCollateralAdded.plus(
    event.params.collateralAdded
  );
  position.lastUpdatedAt = event.block.timestamp;
  position.lastUpdatedAtBlock = event.block.number;

  if (newHF.gt(position.highestHealthFactor)) {
    position.highestHealthFactor = newHF;
  }

  position.save();

  // Update User
  let user = User.load(position.user);
  if (user != null) {
    user.totalProtectionsReceived = user.totalProtectionsReceived.plus(ONE_BI);
    user.totalCollateralAddedViaProtection = user.totalCollateralAddedViaProtection.plus(
      event.params.collateralAdded
    );
    updateUserRiskCounts(user, oldHF, newHF);
    user.lastActivityAt = event.block.timestamp;
    user.save();
  }

  // Update GlobalStats
  let stats = getOrCreateGlobalStats();
  stats.totalProtections = stats.totalProtections.plus(ONE_BI);
  stats.totalCollateralAddedViaProtection = stats.totalCollateralAddedViaProtection.plus(
    event.params.collateralAdded
  );
  if (newHF.gt(event.params.beforeHF)) {
    stats.successfulProtections = stats.successfulProtections.plus(ONE_BI);
  }
  updateGlobalRiskCounts(stats, oldHF, newHF);
  stats.lastUpdatedAt = event.block.timestamp;
  stats.lastUpdatedAtBlock = event.block.number;
  stats.save();

  // Update DailyStats
  let dailyStats = getOrCreateDailyStats(event.block.timestamp);
  dailyStats.protectionsExecuted = dailyStats.protectionsExecuted.plus(ONE_BI);
  dailyStats.collateralAddedViaProtection = dailyStats.collateralAddedViaProtection.plus(
    event.params.collateralAdded
  );
  // Note: Gas tracking removed as event.transaction.gasUsed may not be available
  dailyStats.save();

  log.info("Protection executed for position: {} collateral added: {} HF: {} -> {}", [
    positionId,
    event.params.collateralAdded.toString(),
    event.params.beforeHF.toString(),
    event.params.afterHF.toString(),
  ]);
}

// ============================================================================
// DemoEscrow Event Handlers
// ============================================================================

/**
 * Handle EscrowFunded event
 * Event signature: EscrowFunded(address indexed token, uint256 amount, address indexed funder)
 */
export function handleEscrowFunded(event: EscrowFundedEvent): void {
  log.info("Escrow funded: token {} funder {} amount {}", [
    event.params.token.toHexString(),
    event.params.funder.toHexString(),
    event.params.amount.toString(),
  ]);

  // Update Token entity
  let token = getOrCreateToken(event.params.token, event.block.timestamp, "TOKEN", "Token", 18);
  token.lastSeenAt = event.block.timestamp;
  token.save();
}

/**
 * Handle TokensWithdrawn event
 * Event signature: TokensWithdrawn(address indexed token, address indexed to, uint256 amount, address indexed withdrawer)
 */
export function handleTokensWithdrawn(event: TokensWithdrawnEvent): void {
  log.info("Escrow withdrawal: token {} to {} amount {} withdrawer {}", [
    event.params.token.toHexString(),
    event.params.to.toHexString(),
    event.params.amount.toString(),
    event.params.withdrawer.toHexString(),
  ]);
}

/**
 * Handle ProtectorAuthorized event
 * Event signature: ProtectorAuthorized(address indexed protector)
 */
export function handleProtectorAuthorized(event: ProtectorAuthorizedEvent): void {
  log.info("Protector authorized: {}", [event.params.protector.toHexString()]);
}

/**
 * Handle ProtectorDeauthorized event
 * Event signature: ProtectorDeauthorized(address indexed protector)
 */
export function handleProtectorDeauthorized(event: ProtectorDeauthorizedEvent): void {
  log.info("Protector deauthorized: {}", [event.params.protector.toHexString()]);
}
