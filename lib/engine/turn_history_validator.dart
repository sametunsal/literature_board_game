import '../models/turn_result.dart';
import '../models/turn_history.dart';
import 'turn_replay_engine.dart';

/// ============================================================================
/// TURN HISTORY VALIDATOR - Sequential Validation Tool
/// ============================================================================
///
/// This utility provides sequential validation of entire TurnHistory
/// by replaying each turn and checking consistency.
///
/// USE CASES:
/// - Validate entire game history in one call
/// - Debug unexpected game state corruption
/// - Verify turn transcript integrity
/// - Developer/debug tool for game correctness
///
/// ARCHITECTURE:
/// - Pure Dart (no Flutter, no Riverpod, no providers)
/// - Sequential validation (stop on first failure)
/// - Uses existing TurnReplayEngine for turn validation
/// - Does NOT modify gameplay logic
///
/// DESIGN PHILOSOPHY:
/// - TurnHistory is the TRUTH source
/// - TurnReplayEngine validates each turn
/// - ValidationReport provides detailed feedback
///
/// This is a developer/debug tool only.

/// Detailed validation report for TurnHistory
///
/// Provides count of passed turns, first failure index,
/// and detailed error message if validation fails.
class ValidationReport {
  /// Total number of turns validated (passed + failed)
  final int totalValidated;

  /// Number of turns that passed validation
  final int passedCount;

  /// Index of first failed turn (null if all passed)
  final int? failedIndex;

  /// Error message for first failure (null if all passed)
  final String? errorMessage;

  /// Overall validation status
  final bool isAllValid;

  const ValidationReport({
    required this.totalValidated,
    required this.passedCount,
    this.failedIndex,
    this.errorMessage,
    required this.isAllValid,
  });

  /// Create a success report (all turns passed)
  factory ValidationReport.success({required int totalValidated}) {
    return ValidationReport(
      totalValidated: totalValidated,
      passedCount: totalValidated,
      failedIndex: null,
      errorMessage: null,
      isAllValid: true,
    );
  }

  /// Create a failure report (validation stopped on error)
  factory ValidationReport.failure({
    required int totalValidated,
    required int passedCount,
    required int failedIndex,
    required String errorMessage,
  }) {
    return ValidationReport(
      totalValidated: totalValidated,
      passedCount: passedCount,
      failedIndex: failedIndex,
      errorMessage: errorMessage,
      isAllValid: false,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('ValidationReport:');
    buffer.writeln('  Total validated: $totalValidated');
    buffer.writeln('  Passed: $passedCount');

    if (isAllValid) {
      buffer.writeln('  Status: ✅ ALL VALID');
    } else {
      buffer.writeln('  Status: ❌ FAILED');
      buffer.writeln('  Failed at index: $failedIndex');
      buffer.writeln('  Error: $errorMessage');
    }

    return buffer.toString();
  }
}

/// Turn history validator
///
/// Validates TurnHistory by sequentially replaying each turn
/// and checking consistency with TurnReplayEngine.
///
/// Stops on first failure and returns detailed report.
class TurnHistoryValidator {
  /// Validate a single turn result
  ///
  /// Takes a [TurnResult] and optional [TurnSnapshot],
  /// replays the turn using [TurnReplayEngine], and returns
  /// validation result.
  ///
  /// If [snapshot] is not provided, it will be reconstructed
  /// from the turn result by calculating start stars from
  /// the transcript events (reverse calculation).
  ///
  /// Returns [ReplayValidationResult] with validation outcome.
  static ReplayValidationResult validateTurn(
    TurnResult turnResult, [
    TurnSnapshot? snapshot,
  ]) {
    // If snapshot is not provided, reconstruct it
    final validationSnapshot = snapshot ?? _reconstructSnapshot(turnResult);

    // Use TurnReplayEngine to validate the turn
    return TurnReplayEngine.replayAndValidate(
      turnResult: turnResult,
      turnSnapshot: validationSnapshot,
      throwOnError: false,
    );
  }

  /// Validate all turns in TurnHistory sequentially
  ///
  /// Takes a [TurnHistory], validates each turn in order,
  /// and stops on the first failure.
  ///
  /// Returns [ValidationReport] with detailed results.
  ///
  /// If all turns pass, returns success report with total count.
  /// If validation fails, returns failure report with first error.
  static ValidationReport validateAll(TurnHistory turnHistory) {
    if (turnHistory.isEmpty) {
      return ValidationReport.success(totalValidated: 0);
    }

    final allTurns = turnHistory.all;
    int passedCount = 0;

    // Validate each turn sequentially
    for (int i = 0; i < allTurns.length; i++) {
      final turn = allTurns[i];

      final result = validateTurn(turn);

      if (result.isValid) {
        passedCount++;
      } else {
        // Stop on first failure
        return ValidationReport.failure(
          totalValidated: i + 1,
          passedCount: passedCount,
          failedIndex: i,
          errorMessage: result.errorMessage ?? 'Unknown validation error',
        );
      }
    }

    // All turns passed
    return ValidationReport.success(totalValidated: allTurns.length);
  }

  /// Reconstruct TurnSnapshot from TurnResult
  ///
  /// Calculates startStars by reverse-calculation from the transcript.
  ///
  /// Process:
  /// 1. Calculate end stars from position-based events (START bonus)
  /// 2. Apply star deltas from transcript in reverse order
  /// 3. Result is the start stars at turn beginning
  ///
  /// This is necessary because TurnResult only stores deltas,
  /// not the absolute start/end star counts.
  static TurnSnapshot _reconstructSnapshot(TurnResult turnResult) {
    // Calculate end stars by replaying events
    var endStars = 0;
    var startStarsCandidate = 0;

    // Calculate end stars from transcript events
    // We'll use the starsDelta from TurnResult as a base,
    // then verify it matches the calculated delta from events
    for (final event in turnResult.transcript.events) {
      switch (event.type) {
        case TurnEventType.move:
          final passedStart = event.data['passedStart'] as bool?;
          if (passedStart == true) {
            // Add START bonus (default value used in TurnReplayEngine)
            const startBonus = 50;
            endStars += startBonus;
          }
          break;

        case TurnEventType.cardApplied:
          final starChange = event.data['starChange'] as int?;
          if (starChange != null && starChange != 0) {
            endStars += starChange;
          }
          break;

        case TurnEventType.questionAnswered:
          final answerResult = event.data['answerResult'] as String;
          final starChange = event.data['starChange'] as int;

          if (answerResult == 'correct' || answerResult == 'wrong') {
            endStars += starChange;
          }
          break;

        case TurnEventType.taxPaid:
          final amount = event.data['amount'] as int;
          endStars -= amount;
          break;

        case TurnEventType.starChange:
          final delta = event.data['delta'] as int;
          endStars += delta;
          break;

        // Events that don't affect stars
        case TurnEventType.transition:
        case TurnEventType.tileResolved:
        case TurnEventType.cardDrawn:
        case TurnEventType.questionAsked:
        case TurnEventType.bankruptcy:
        case TurnEventType.diceRoll:
        case TurnEventType.copyrightPurchased:
        case TurnEventType.rentPaid:
        case TurnEventType.bonusReceived:
          break;
      }
    }

    // Calculate start stars from end stars and delta
    // starsDelta = endStars - startStars
    // Therefore: startStars = endStars - starsDelta
    startStarsCandidate = endStars - turnResult.starsDelta;

    // Create and return the reconstructed snapshot
    return TurnSnapshot(
      playerIndex: turnResult.playerIndex,
      startStars: startStarsCandidate,
      startPosition: turnResult.startPosition,
    );
  }
}

/// Extension to provide convenience methods for TurnHistory
extension TurnHistoryValidation on TurnHistory {
  /// Validate all turns in this history
  ///
  /// Convenience method to call [TurnHistoryValidator.validateAll]
  /// with this history.
  ValidationReport validate() {
    return TurnHistoryValidator.validateAll(this);
  }

  /// Quick check if all turns are valid
  ///
  /// Returns true if all turns pass validation,
  /// false otherwise.
  bool get isValid {
    final report = validate();
    return report.isAllValid;
  }
}

/// Extension to provide convenience methods for TurnResult
extension TurnResultValidation on TurnResult {
  /// Validate this turn result
  ///
  /// Convenience method to call [TurnHistoryValidator.validateTurn]
  /// with this turn result.
  ReplayValidationResult validate([TurnSnapshot? snapshot]) {
    return TurnHistoryValidator.validateTurn(this, snapshot);
  }

  /// Quick check if this turn is valid
  ///
  /// Returns true if turn passes validation,
  /// false otherwise.
  bool get isValid {
    final result = validate();
    return result.isValid;
  }
}
