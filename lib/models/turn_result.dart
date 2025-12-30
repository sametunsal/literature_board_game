import 'turn_event.dart';
import 'turn_phase.dart';

/// ============================================================================
/// TURN RESULT - Completed Turn Snapshot
/// ============================================================================
///
/// Represents the summary of a completed turn for UI feedback.
///
/// ARCHITECTURE:
/// - Contains turn statistics (dice, movement, stars, questions)
/// - Contains TurnTranscript from turn_event.dart for detailed logging
/// - Immutable with copyWith pattern
///
/// DEPENDENCY LEVEL: 1 (Depends on turn_event.dart - foundational layer)

/// Represents the summary of a completed turn
class TurnResult {
  final int playerIndex;
  final DateTime? timestamp;
  final int startPosition;
  final int endPosition;

  // Statistics
  final int diceTotal;
  final bool isDouble;
  final int starsDelta;
  final bool? questionAnsweredCorrectly;
  final bool taxPaid;
  final String? tileType;

  // The detailed log
  final TurnTranscript transcript;

  const TurnResult({
    required this.playerIndex,
    required this.timestamp,
    required this.startPosition,
    required this.endPosition,
    this.diceTotal = 0,
    this.isDouble = false,
    this.starsDelta = 0,
    this.questionAnsweredCorrectly,
    this.taxPaid = false,
    this.tileType,
    this.transcript = const TurnTranscript.empty(),
  });

  /// Creates an empty/initial TurnResult
  static const empty = TurnResult(
    playerIndex: -1,
    timestamp: null,
    startPosition: 0,
    endPosition: 0,
  );

  TurnResult copyWith({
    int? playerIndex,
    DateTime? timestamp,
    int? startPosition,
    int? endPosition,
    int? diceTotal,
    bool? isDouble,
    int? starsDelta,
    bool? questionAnsweredCorrectly,
    bool? taxPaid,
    String? tileType,
    TurnTranscript? transcript,
  }) {
    return TurnResult(
      playerIndex: playerIndex ?? this.playerIndex,
      timestamp: timestamp ?? this.timestamp,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      diceTotal: diceTotal ?? this.diceTotal,
      isDouble: isDouble ?? this.isDouble,
      starsDelta: starsDelta ?? this.starsDelta,
      questionAnsweredCorrectly:
          questionAnsweredCorrectly ?? this.questionAnsweredCorrectly,
      taxPaid: taxPaid ?? this.taxPaid,
      tileType: tileType ?? this.tileType,
      transcript: transcript ?? this.transcript,
    );
  }
}
