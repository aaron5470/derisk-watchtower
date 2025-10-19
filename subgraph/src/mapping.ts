/**
 * DeRisk Watchtower Subgraph - Event Handlers
 *
 * This file contains all event handlers for indexing position management,
 * protection actions, and risk events from the DeRisk Watchtower contracts.
 */

import { BigInt, Bytes, log, store } from "@graphprotocol/graph-ts";
import {
  PositionCreated as PositionCreatedEvent,
  PositionUpdated as PositionUpdatedEvent,
  HealthFactorUpdated as HealthFactorUpdatedEvent,
  CollateralAdded as CollateralAddedEvent,
  DebtRepaid as DebtRepaidEvent,
} from "../generated/PositionVault/PositionVault";
import {
  ProtectionExecuted as ProtectionExecutedEvent,
  ProtectionFailed as ProtectionFailedEvent,
} from "../generated/Protector/Protector";
import {
  Deposited as DepositedEvent,
  Withdrawn as WithdrawnEvent,
  ProtectorAuthorized as ProtectorAuthorizedEvent,
  ProtectorUnauthorized as ProtectorUnauthorizedEvent,
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
 * Event signature: PositionCreated(bytes32 indexed positionId, address indexed user,
 *                                   address collateralToken, uint256 collateralAmount,
 *                                   address debtToken, uint256 debtAmount, uint256 healthFactor)
 */
export function handlePositionCreated(event: PositionCreatedEvent): void {
  let positionId = event.params.positionId.toHexString();
  let position = new Position(positionId);

  position.user = event.params.user;
  position.collateralToken = event.params.collateralToken;
  position.collateralAmount = event.params.collateralAmount;
  position.debtToken = event.params.debtToken;
  position.debtAmount = event.params.debtAmount;
  position.healthFactor = event.params.healthFactor;
  position.createdAt = event.block.timestamp;
  position.createdAtBlock = event.block.number;
  position.lastUpdatedAt = event.block.timestamp;
  position.lastUpdatedAtBlock = event.block.number;
  position.isActive = true;
  position.totalProtections = ZERO_BI;
  position.totalCollateralAdded = ZERO_BI;
  position.lowestHealthFactor = event.params.healthFactor;
  position.highestHealthFactor = event.params.healthFactor;

  position.save();

  // Update User entity
  let user = getOrCreateUser(event.params.user, event.block.timestamp);
  user.totalPositions = user.totalPositions.plus(ONE_BI);
  user.activePositions = user.activePositions.plus(ONE_BI);
  user.lastActivityAt = event.block.timestamp;

  // Update user risk counts
  if (event.params.healthFactor.lt(HF_CRITICAL)) {
    user.currentCriticalPositions = user.currentCriticalPositions.plus(ONE_BI);
  } else if (event.params.healthFactor.lt(HF_WARNING)) {
    user.currentWarningPositions = user.currentWarningPositions.plus(ONE_BI);
  } else {
    user.currentSafePositions = user.currentSafePositions.plus(ONE_BI);
  }
  user.save();

  // Update Token entities (placeholder symbols/names - would need token contract calls for real data)
  let collateralToken = getOrCreateToken(
    event.params.collateralToken,
    event.block.timestamp,
    "TOKEN",
    "Token",
    18
  );
  collateralToken.totalCollateralVolume = collateralToken.totalCollateralVolume.plus(
    event.params.collateralAmount
  );
  collateralToken.positionCount = collateralToken.positionCount.plus(ONE_BI);
  collateralToken.lastSeenAt = event.block.timestamp;
  collateralToken.save();

  let debtToken = getOrCreateToken(
    event.params.debtToken,
    event.block.timestamp,
    "TOKEN",
    "Token",
    18
  );
  debtToken.totalDebtVolume = debtToken.totalDebtVolume.plus(event.params.debtAmount);
  debtToken.lastSeenAt = event.block.timestamp;
  debtToken.save();

  // Update GlobalStats
  let stats = getOrCreateGlobalStats();
  stats.totalPositions = stats.totalPositions.plus(ONE_BI);
  stats.activePositions = stats.activePositions.plus(ONE_BI);
  stats.totalCollateralDeposited = stats.totalCollateralDeposited.plus(event.params.collateralAmount);
  stats.totalDebtTaken = stats.totalDebtTaken.plus(event.params.debtAmount);
  stats.lastUpdatedAt = event.block.timestamp;
  stats.lastUpdatedAtBlock = event.block.number;

  // Update global risk counts
  if (event.params.healthFactor.lt(HF_CRITICAL)) {
    stats.criticalPositions = stats.criticalPositions.plus(ONE_BI);
  } else if (event.params.healthFactor.lt(HF_WARNING)) {
    stats.warningPositions = stats.warningPositions.plus(ONE_BI);
  } else {
    stats.safePositions = stats.safePositions.plus(ONE_BI);
  }
  stats.save();

  // Update DailyStats
  let dailyStats = getOrCreateDailyStats(event.block.timestamp);
  dailyStats.newPositions = dailyStats.newPositions.plus(ONE_BI);
  dailyStats.collateralDeposited = dailyStats.collateralDeposited.plus(event.params.collateralAmount);
  dailyStats.debtTaken = dailyStats.debtTaken.plus(event.params.debtAmount);
  dailyStats.save();

  log.info("Position created: {} by user: {} with HF: {}", [
    positionId,
    event.params.user.toHexString(),
    event.params.healthFactor.toString(),
  ]);
}

/**
 * Handle PositionUpdated event
 * Event signature: PositionUpdated(bytes32 indexed positionId, uint256 collateralAmount,
 *                                   uint256 debtAmount, uint256 healthFactor)
 */
export function handlePositionUpdated(event: PositionUpdatedEvent): void {
  let positionId = event.params.positionId.toHexString();
  let position = Position.load(positionId);

  if (position == null) {
    log.warning("Position not found for update: {}", [positionId]);
    return;
  }

  let oldHF = position.healthFactor;
  let newHF = event.params.healthFactor;

  position.collateralAmount = event.params.collateralAmount;
  position.debtAmount = event.params.debtAmount;
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
  let user = User.load(position.user.toHexString());
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

/**
 * Handle HealthFactorUpdated event
 * Event signature: HealthFactorUpdated(bytes32 indexed positionId, uint256 oldHF, uint256 newHF)
 */
export function handleHealthFactorUpdated(event: HealthFactorUpdatedEvent): void {
  let positionId = event.params.positionId.toHexString();
  let position = Position.load(positionId);

  if (position == null) {
    log.warning("Position not found for HF update: {}", [positionId]);
    return;
  }

  let oldHF = event.params.oldHF;
  let newHF = event.params.newHF;

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

  // Check if this HF change triggers a risk event
  let oldRiskType = getRiskEventType(oldHF);
  let newRiskType = getRiskEventType(newHF);

  if (oldRiskType != newRiskType) {
    // Create RiskEvent
    let riskEventId =
      positionId +
      "-" +
      event.block.number.toString() +
      "-" +
      event.logIndex.toString();
    let riskEvent = new RiskEvent(riskEventId);
    riskEvent.position = positionId;
    riskEvent.eventType = newRiskType;
    riskEvent.healthFactor = newHF;
    riskEvent.collateralAmount = position.collateralAmount;
    riskEvent.debtAmount = position.debtAmount;
    riskEvent.timestamp = event.block.timestamp;
    riskEvent.blockNumber = event.block.number;
    riskEvent.transactionHash = event.transaction.hash;
    riskEvent.save();

    // Update GlobalStats
    let stats = getOrCreateGlobalStats();
    stats.totalRiskEvents = stats.totalRiskEvents.plus(ONE_BI);
    if (newRiskType == "CRITICAL") {
      stats.totalCriticalEvents = stats.totalCriticalEvents.plus(ONE_BI);
    } else if (newRiskType == "WARNING") {
      stats.totalWarningEvents = stats.totalWarningEvents.plus(ONE_BI);
    }
    stats.save();

    // Update DailyStats
    let dailyStats = getOrCreateDailyStats(event.block.timestamp);
    dailyStats.riskEventsTriggered = dailyStats.riskEventsTriggered.plus(ONE_BI);
    dailyStats.save();

    log.info("Risk event: {} changed from {} to {}", [positionId, oldRiskType, newRiskType]);
  }

  // Update User and Global risk counts
  let user = User.load(position.user.toHexString());
  if (user != null) {
    updateUserRiskCounts(user, oldHF, newHF);
  }

  let stats = getOrCreateGlobalStats();
  updateGlobalRiskCounts(stats, oldHF, newHF);
}

/**
 * Handle CollateralAdded event
 * Event signature: CollateralAdded(bytes32 indexed positionId, uint256 amount, uint256 newHealthFactor)
 */
export function handleCollateralAdded(event: CollateralAddedEvent): void {
  let positionId = event.params.positionId.toHexString();
  let position = Position.load(positionId);

  if (position == null) {
    log.warning("Position not found for collateral add: {}", [positionId]);
    return;
  }

  let oldHF = position.healthFactor;
  let newHF = event.params.newHealthFactor;

  position.collateralAmount = position.collateralAmount.plus(event.params.amount);
  position.healthFactor = newHF;
  position.lastUpdatedAt = event.block.timestamp;
  position.lastUpdatedAtBlock = event.block.number;

  if (newHF.gt(position.highestHealthFactor)) {
    position.highestHealthFactor = newHF;
  }

  position.save();

  // Update User risk counts
  let user = User.load(position.user.toHexString());
  if (user != null) {
    updateUserRiskCounts(user, oldHF, newHF);
    user.lastActivityAt = event.block.timestamp;
    user.save();
  }

  // Update GlobalStats
  let stats = getOrCreateGlobalStats();
  updateGlobalRiskCounts(stats, oldHF, newHF);
  stats.totalCollateralDeposited = stats.totalCollateralDeposited.plus(event.params.amount);
  stats.save();

  log.info("Collateral added to position: {} amount: {} new HF: {}", [
    positionId,
    event.params.amount.toString(),
    newHF.toString(),
  ]);
}

/**
 * Handle DebtRepaid event
 * Event signature: DebtRepaid(bytes32 indexed positionId, uint256 amount, uint256 newHealthFactor)
 */
export function handleDebtRepaid(event: DebtRepaidEvent): void {
  let positionId = event.params.positionId.toHexString();
  let position = Position.load(positionId);

  if (position == null) {
    log.warning("Position not found for debt repay: {}", [positionId]);
    return;
  }

  let oldHF = position.healthFactor;
  let newHF = event.params.newHealthFactor;

  position.debtAmount = position.debtAmount.minus(event.params.amount);
  position.healthFactor = newHF;
  position.lastUpdatedAt = event.block.timestamp;
  position.lastUpdatedAtBlock = event.block.number;

  if (newHF.gt(position.highestHealthFactor)) {
    position.highestHealthFactor = newHF;
  }

  position.save();

  // Update User risk counts
  let user = User.load(position.user.toHexString());
  if (user != null) {
    updateUserRiskCounts(user, oldHF, newHF);
    user.lastActivityAt = event.block.timestamp;
    user.save();
  }

  // Update GlobalStats
  let stats = getOrCreateGlobalStats();
  updateGlobalRiskCounts(stats, oldHF, newHF);
  stats.save();

  log.info("Debt repaid for position: {} amount: {} new HF: {}", [
    positionId,
    event.params.amount.toString(),
    newHF.toString(),
  ]);
}

// ============================================================================
// Protector Event Handlers
// ============================================================================

/**
 * Handle ProtectionExecuted event
 * Event signature: ProtectionExecuted(bytes32 indexed positionId, uint256 collateralAdded,
 *                                      uint256 healthFactorBefore, uint256 healthFactorAfter)
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
  protection.healthFactorBefore = event.params.healthFactorBefore;
  protection.healthFactorAfter = event.params.healthFactorAfter;
  protection.protector = event.address;
  protection.timestamp = event.block.timestamp;
  protection.blockNumber = event.block.number;
  protection.transactionHash = event.transaction.hash;
  protection.gasUsed = event.transaction.gasUsed;
  protection.save();

  // Update Position
  let oldHF = position.healthFactor;
  let newHF = event.params.healthFactorAfter;

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
  let user = User.load(position.user.toHexString());
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
  if (newHF.gt(event.params.healthFactorBefore)) {
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
  dailyStats.totalGasUsed = dailyStats.totalGasUsed.plus(event.transaction.gasUsed);
  // Update average gas per protection
  if (dailyStats.protectionsExecuted.gt(ZERO_BI)) {
    dailyStats.averageGasPerProtection = dailyStats.totalGasUsed.div(
      dailyStats.protectionsExecuted
    );
  }
  dailyStats.save();

  log.info("Protection executed for position: {} collateral added: {} HF: {} -> {}", [
    positionId,
    event.params.collateralAdded.toString(),
    event.params.healthFactorBefore.toString(),
    event.params.healthFactorAfter.toString(),
  ]);
}

/**
 * Handle ProtectionFailed event
 * Event signature: ProtectionFailed(bytes32 indexed positionId, string reason)
 */
export function handleProtectionFailed(event: ProtectionFailedEvent): void {
  let positionId = event.params.positionId.toHexString();

  log.warning("Protection failed for position: {} reason: {}", [
    positionId,
    event.params.reason,
  ]);

  // Could create a ProtectionAction with failed status if schema is extended
  // For now, just log the failure
}

// ============================================================================
// DemoEscrow Event Handlers
// ============================================================================

/**
 * Handle Deposited event
 * Event signature: Deposited(address indexed token, address indexed depositor, uint256 amount)
 */
export function handleDeposited(event: DepositedEvent): void {
  log.info("Escrow deposit: token {} depositor {} amount {}", [
    event.params.token.toHexString(),
    event.params.depositor.toHexString(),
    event.params.amount.toString(),
  ]);

  // Update Token entity
  let token = getOrCreateToken(event.params.token, event.block.timestamp, "TOKEN", "Token", 18);
  token.lastSeenAt = event.block.timestamp;
  token.save();
}

/**
 * Handle Withdrawn event
 * Event signature: Withdrawn(address indexed token, address indexed protector, address to, uint256 amount)
 */
export function handleWithdrawn(event: WithdrawnEvent): void {
  log.info("Escrow withdrawal: token {} protector {} to {} amount {}", [
    event.params.token.toHexString(),
    event.params.protector.toHexString(),
    event.params.to.toHexString(),
    event.params.amount.toString(),
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
 * Handle ProtectorUnauthorized event
 * Event signature: ProtectorUnauthorized(address indexed protector)
 */
export function handleProtectorUnauthorized(event: ProtectorUnauthorizedEvent): void {
  log.info("Protector unauthorized: {}", [event.params.protector.toHexString()]);
}
