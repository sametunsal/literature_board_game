import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/turn_result.dart';

/// ============================================================================
/// TURN REPLAY ENGINE - Deterministic Validation Tool
/// ============================================================================
///
/// This engine provides UI-free, deterministic replay of turn transcripts
/// to validate that turn results are accurate and consistent.
///
/// USE CASES:
/// - Validate TurnResult correctness by replaying events
/// - Debug unexpected turn outcomes
/// - Test edge cases and corner scenarios
/// - Verify transcript completeness
///
/// ARCHITECTURE:
/// - Pure Dart (no Flutter, no Riverpod, no providers)
/// - Deterministic replay (same events → same outcome)
/// - Minimal state reconstruction (only what's needed)
/// - Extensible event handling (switch on TurnEventType)
///
/// DESIGN PHILOSOPHY:
/// - The replay engine is TRUTH: it calculates what SHOULD happen
/// - TurnResult is CLAIM: it records what ACTUALLY happened
/// - Validation compares TRUTH vs CLAIM to detect inconsistencies
///
/// This is a validation/debugging tool, NOT production gameplay logic.

/// Minimal player state for replay
///
/// Only tracks fields that change during a turn.
/// Extensible if needed (e.g., for bankruptcy, flags, etc.)
class ReplayPlayerState {
  final int position;
  final int stars;
  final int startPosition;
  final int startStars;

  const ReplayPlayerState({
    required this.position,
    required this.stars,
    required this.startPosition,
    required this.startStars,
  });

  /// Calculate position delta (end - start)
  int get positionDelta => position - startPosition;

  /// Calculate stars delta (end - start)
  int get starsDelta => stars - startStars;

  ReplayPlayerState copyWith({int? position, int? stars}) {
    return ReplayPlayerState(
      position: position ?? this.position,
      stars: stars ?? this.stars,
      startPosition: startPosition,
      startStars: startStars,
    );
  }

  @override
  String toString() {
    return 'ReplayPlayerState(position=$position, stars=$stars, '
        'startPosition=$startPosition, startStars=$startStars)';
  }
}

/// Types of invariant violations detected during replay
///
/// These represent consistency checks on transcript semantics,
/// not gameplay logic implementation.
enum ReplayInvariantViolation {
  /// cardDrawn event without corresponding cardApplied event
  missingCardApplied,

  /// bankruptcy event but player still has stars in replay
  bankruptcyWithStars,

  /// tileResolved with tile type that should have follow-up events
  /// but no such events found (e.g., card tile without cardApplied)
  missingTileFollowUp,

  /// tileResolved indicates star/position effect but none was applied
  tileEffectMismatch,
}

/// Result of replay validation
///
/// Contains validation outcome and detailed mismatch information.
class ReplayValidationResult {
  final bool isValid;
  final bool positionMatch;
  final bool starsMatch;
  final String? errorMessage;
  final ReplayInvariantViolation? invariantViolation;

  const ReplayValidationResult({
    required this.isValid,
    required this.positionMatch,
    required this.starsMatch,
    this.errorMessage,
    this.invariantViolation,
  });

  @override
  String toString() {
    return 'ReplayValidationResult(isValid=$isValid, '
        'positionMatch=$positionMatch, starsMatch=$starsMatch, '
        'errorMessage=$errorMessage, '
        'invariantViolation=$invariantViolation)';
  }
}

/// Helper class for invariant error results
class _InvariantError {
  final ReplayInvariantViolation violation;
  final String message;

  const _InvariantError({required this.violation, required this.message});
}

/// Deterministic turn replay engine
///
/// Replays turn transcript events and validates final state.
class TurnReplayEngine {
  /// Replay a turn and validate the result
  ///
  /// Takes TurnResult (the claim) and TurnSnapshot (the start state),
  /// reconstructs minimal player state, replays all events in order,
  /// and validates that final state matches TurnResult.
  ///
  /// Returns [ReplayValidationResult] with validation outcome.
  ///
  /// Throws [StateError] in debug mode if validation fails.
  static ReplayValidationResult replayAndValidate({
    required TurnResult turnResult,
    required TurnSnapshot turnSnapshot,
    bool throwOnError = true,
  }) {
    // Validate input
    _validateInput(turnResult, turnSnapshot);

    // Step 1: Reconstruct initial player state from snapshot
    final initialState = ReplayPlayerState(
      position: turnSnapshot.startPosition,
      stars: turnSnapshot.startStars,
      startPosition: turnSnapshot.startPosition,
      startStars: turnSnapshot.startStars,
    );

    developer.log('🎮 Turn Replay Engine: Starting replay');
    developer.log('   Initial state: $initialState');
    developer.log(
      '   Claimed result: position=${turnResult.endPosition}, '
      'starsDelta=${turnResult.starsDelta}',
    );

    // Step 2: Replay all events in order
    var currentState = initialState;

    // Track events for invariant checking
    bool cardDrawnFound = false;
    bool cardAppliedFound = false;
    String? tileTypeResolved;
    bool bankruptcyFound = false;

    for (final event in turnResult.transcript.events) {
      developer.log('🔄 Replaying event: ${event.type}');

      // Track events for invariant checking
      switch (event.type) {
        case TurnEventType.cardDrawn:
          cardDrawnFound = true;
          break;

        case TurnEventType.cardApplied:
          cardAppliedFound = true;
          break;

        case TurnEventType.tileResolved:
          tileTypeResolved = event.data['tileType'] as String?;
          break;

        case TurnEventType.bankruptcy:
          bankruptcyFound = true;
          break;

        default:
          break;
      }

      try {
        currentState = _applyEvent(currentState, event);
        developer.log('   State after event: $currentState');
      } catch (e) {
        final error = 'Failed to apply event ${event.type}: $e';
        developer.log('❌ $error');
        return ReplayValidationResult(
          isValid: false,
          positionMatch: false,
          starsMatch: false,
          errorMessage: error,
        );
      }
    }

    // Step 2.5: Validate invariants
    final invariantError = _validateInvariants(
      cardDrawnFound,
      cardAppliedFound,
      tileTypeResolved,
      bankruptcyFound,
      currentState,
    );

    if (invariantError != null) {
      developer.log('❌ ${invariantError.message}');
      return ReplayValidationResult(
        isValid: false,
        positionMatch: false,
        starsMatch: false,
        errorMessage: invariantError.message,
        invariantViolation: invariantError.violation,
      );
    }

    // Step 3: Calculate expected deltas
    final expectedPositionDelta = currentState.positionDelta;
    final expectedStarsDelta = currentState.starsDelta;

    developer.log('📊 Replay complete');
    developer.log(
      '   Expected: positionDelta=$expectedPositionDelta, '
      'starsDelta=$expectedStarsDelta',
    );
    developer.log(
      '   Claimed: positionDelta=${turnResult.endPosition - turnResult.startPosition}, '
      'starsDelta=${turnResult.starsDelta}',
    );

    // Step 4: Validate against TurnResult
    final positionMatch = currentState.position == turnResult.endPosition;
    final starsMatch = currentState.starsDelta == turnResult.starsDelta;
    final isValid = positionMatch && starsMatch;

    if (!isValid) {
      final buffer = StringBuffer('❌ Replay Validation FAILED!\n');
      buffer.writeln('   Replay result does not match claimed result.');

      if (!positionMatch) {
        buffer.writeln('   Position mismatch:');
        buffer.writeln('     Expected (replay): ${turnResult.endPosition}');
        buffer.writeln('     Actual (replay): ${currentState.position}');
      }

      if (!starsMatch) {
        buffer.writeln('   Stars delta mismatch:');
        buffer.writeln('     Expected (claim): ${turnResult.starsDelta}');
        buffer.writeln('     Actual (replay): ${currentState.starsDelta}');
      }

      buffer.writeln('   Initial state: $initialState');
      buffer.writeln('   Final state: $currentState');
      buffer.writeln('   Claimed result: $turnResult');

      final errorMessage = buffer.toString();
      developer.log(errorMessage);

      if (throwOnError && kDebugMode) {
        throw StateError(errorMessage);
      }

      return ReplayValidationResult(
        isValid: false,
        positionMatch: positionMatch,
        starsMatch: starsMatch,
        errorMessage: errorMessage,
      );
    }

    developer.log('✅ Replay Validation PASSED!');
    developer.log('   Final state: $currentState');
    developer.log('   All deltas match claimed result.');

    return ReplayValidationResult(
      isValid: true,
      positionMatch: true,
      starsMatch: true,
    );
  }

  /// Validate input parameters
  static void _validateInput(TurnResult turnResult, TurnSnapshot turnSnapshot) {
    if (turnResult.playerIndex != turnSnapshot.playerIndex) {
      throw ArgumentError(
        'Player index mismatch: TurnResult.playerIndex=${turnResult.playerIndex}, '
        'TurnSnapshot.playerIndex=${turnSnapshot.playerIndex}',
      );
    }

    if (turnResult.startPosition != turnSnapshot.startPosition) {
      throw ArgumentError(
        'Start position mismatch: TurnResult.startPosition=${turnResult.startPosition}, '
        'TurnSnapshot.startPosition=${turnSnapshot.startPosition}',
      );
    }
  }

  /// Validate transcript invariants
  ///
  /// Checks for semantic consistency in transcript events.
  /// Does NOT implement gameplay logic - only asserts consistency.
  ///
  /// Returns [_InvariantError] if violation found, null otherwise.
  static _InvariantError? _validateInvariants(
    bool cardDrawnFound,
    bool cardAppliedFound,
    String? tileTypeResolved,
    bool bankruptcyFound,
    ReplayPlayerState finalState,
  ) {
    // Check: cardDrawn without cardApplied
    if (cardDrawnFound && !cardAppliedFound) {
      return const _InvariantError(
        violation: ReplayInvariantViolation.missingCardApplied,
        message:
            'Invariant violation: cardDrawn event found '
            'but no cardApplied event followed. '
            'Transcript may be incomplete.',
      );
    }

    // Check: bankruptcy with stars remaining
    if (bankruptcyFound && finalState.stars > 0) {
      return _InvariantError(
        violation: ReplayInvariantViolation.bankruptcyWithStars,
        message:
            'Invariant violation: bankruptcy event found '
            'but player still has ${finalState.stars} stars. '
            'Bankruptcy should set stars to 0.',
      );
    }

    // Check: tile type follow-up events
    if (tileTypeResolved != null) {
      // Card tiles (chance, fate) should have cardApplied
      if (tileTypeResolved.contains('chance') ||
          tileTypeResolved.contains('fate')) {
        if (!cardAppliedFound) {
          return _InvariantError(
            violation: ReplayInvariantViolation.missingTileFollowUp,
            message:
                'Invariant violation: card tile ($tileTypeResolved) resolved '
                'but no cardApplied event found. '
                'Expected card to be drawn and applied.',
          );
        }
      }
    }

    return null;
  }

  /// Apply a single event to player state
  ///
  /// Returns updated [ReplayPlayerState].
  /// Throws [UnimplementedError] for event types not yet implemented.
  static ReplayPlayerState _applyEvent(
    ReplayPlayerState currentState,
    TurnEvent event,
  ) {
    switch (event.type) {
      case TurnEventType.diceRoll:
        // Dice rolls don't change state directly
        // Movement is tracked in move events
        return currentState;

      case TurnEventType.move:
        return _applyMove(currentState, event);

      case TurnEventType.cardApplied:
        return _applyCardEffect(currentState, event);

      case TurnEventType.questionAnswered:
        return _applyQuestionAnswered(currentState, event);

      case TurnEventType.taxPaid:
        return _applyTaxPaid(currentState, event);

      case TurnEventType.starChange:
        return _applyStarChange(currentState, event);

      // Events that don't affect player state
      case TurnEventType.transition:
      case TurnEventType.tileResolved:
      case TurnEventType.cardDrawn:
      case TurnEventType.questionAsked:
      case TurnEventType.bankruptcy:
      case TurnEventType.copyrightPurchased:
      case TurnEventType.rentPaid:
      case TurnEventType.bonusReceived:
        return currentState;
    }
  }

  /// Apply movement event
  static ReplayPlayerState _applyMove(
    ReplayPlayerState currentState,
    TurnEvent event,
  ) {
    final from = event.data['from'] as int;
    final to = event.data['to'] as int;
    final passedStart = event.data['passedStart'] as bool?;

    // Calculate position change
    final newPosition = to;

    // Add START bonus if passed START
    var newStars = currentState.stars;
    if (passedStart == true) {
      // Note: We don't have access to GameConstants here
      // In a real implementation, we'd need to pass constants
      // For now, we'll assume a fixed value or make this configurable
      const startBonus = 50; // Default START bonus
      newStars += startBonus;
    }

    return currentState.copyWith(position: newPosition, stars: newStars);
  }

  /// Apply card effect event
  static ReplayPlayerState _applyCardEffect(
    ReplayPlayerState currentState,
    TurnEvent event,
  ) {
    final starChange = event.data['starChange'] as int?;

    if (starChange != null && starChange != 0) {
      return currentState.copyWith(stars: currentState.stars + starChange);
    }

    return currentState;
  }

  /// Apply question answered event
  static ReplayPlayerState _applyQuestionAnswered(
    ReplayPlayerState currentState,
    TurnEvent event,
  ) {
    final answerResult = event.data['answerResult'] as String;
    final starChange = event.data['starChange'] as int;

    // Only apply star changes for answered questions (not skipped)
    if (answerResult == 'correct' || answerResult == 'wrong') {
      return currentState.copyWith(stars: currentState.stars + starChange);
    }

    return currentState;
  }

  /// Apply tax paid event
  static ReplayPlayerState _applyTaxPaid(
    ReplayPlayerState currentState,
    TurnEvent event,
  ) {
    final amount = event.data['amount'] as int;

    return currentState.copyWith(stars: currentState.stars - amount);
  }

  /// Apply generic star change event
  static ReplayPlayerState _applyStarChange(
    ReplayPlayerState currentState,
    TurnEvent event,
  ) {
    final delta = event.data['delta'] as int;

    return currentState.copyWith(stars: currentState.stars + delta);
  }
}
