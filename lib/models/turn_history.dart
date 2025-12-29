import 'turn_result.dart';

/// ============================================================================
/// TURN HISTORY - Immutable Turn Result Storage
/// ============================================================================
///
/// This class provides immutable storage for completed turn results.
/// Maintains a chronologically ordered list of TurnResult objects.
///
/// USE CASES:
/// - Store all completed turns for the game
/// - Query turn history by player
/// - Analyze game statistics
/// - Replay/audit past turns
///
/// ARCHITECTURE:
/// - Immutable (copyWith pattern)
/// - Chronologically ordered (oldest first)
/// - Player-based filtering
///
/// DESIGN PHILOSOPHY:
/// - Immutable for thread safety and predictability
/// - Minimal API (add, query, filter)
/// - No business logic (pure storage)

/// Immutable storage for turn results
///
/// Maintains a chronologically ordered list of completed turns.
class TurnHistory {
  final List<TurnResult> _turns;

  const TurnHistory._(this._turns);

  /// Create empty turn history
  const TurnHistory.empty() : _turns = const [];

  /// Create turn history from list of turn results
  TurnHistory.fromList(List<TurnResult> turns)
    : _turns = List.unmodifiable(turns);

  /// Add a turn result to history
  ///
  /// Returns a new TurnHistory instance with the turn appended.
  /// Original history is unchanged (immutable).
  TurnHistory add(TurnResult turn) {
    return TurnHistory._([..._turns, turn]);
  }

  /// Get the most recent turn result
  TurnResult? get last {
    if (_turns.isEmpty) return null;
    return _turns.last;
  }

  /// Get the first (oldest) turn result
  TurnResult? get first {
    if (_turns.isEmpty) return null;
    return _turns.first;
  }

  /// Get total number of turns in history
  int get totalTurns => _turns.length;

  /// Check if history is empty
  bool get isEmpty => _turns.isEmpty;

  /// Check if history is not empty
  bool get isNotEmpty => _turns.isNotEmpty;

  /// Get all turn results (immutable copy)
  List<TurnResult> get all => List.unmodifiable(_turns);

  /// Get turn results for a specific player
  ///
  /// Returns a new list containing all turns for the specified player.
  /// Returns empty list if player has no turns.
  List<TurnResult> filterByPlayer(int playerIndex) {
    return _turns.where((turn) => turn.playerIndex == playerIndex).toList();
  }

  /// Get turn results for a specific player (immutable)
  List<TurnResult> getTurnsForPlayer(int playerIndex) {
    return List.unmodifiable(filterByPlayer(playerIndex));
  }

  /// Get turn result by index
  TurnResult? getTurnAt(int index) {
    if (index < 0 || index >= _turns.length) return null;
    return _turns[index];
  }

  /// Get turn results within a range
  List<TurnResult> getTurnsInRange(int start, int end) {
    if (start < 0) start = 0;
    if (end > _turns.length) end = _turns.length;
    if (start >= end) return const [];
    return _turns.sublist(start, end);
  }

  /// Get the last N turns
  List<TurnResult> getLastTurns(int count) {
    if (count <= 0) return const [];
    if (count >= _turns.length) return List.unmodifiable(_turns);
    return _turns.sublist(_turns.length - count);
  }

  /// Calculate total stars gained across all turns
  int get totalStarsGained {
    return _turns.fold(
      0,
      (sum, turn) => sum + (turn.starsDelta > 0 ? turn.starsDelta : 0),
    );
  }

  /// Calculate total stars lost across all turns
  int get totalStarsLost {
    return _turns.fold(
      0,
      (sum, turn) => sum + (turn.starsDelta < 0 ? -turn.starsDelta : 0),
    );
  }

  /// Calculate net stars change across all turns
  int get netStarsChange {
    return _turns.fold(0, (sum, turn) => sum + turn.starsDelta);
  }

  /// Calculate total distance traveled across all turns
  int get totalDistanceTraveled {
    return _turns.fold(
      0,
      (sum, turn) => sum + (turn.endPosition - turn.startPosition).abs(),
    );
  }

  /// Count turns with correct answers
  int get correctAnswers {
    return _turns
        .where((turn) => turn.questionAnsweredCorrectly == true)
        .length;
  }

  /// Count turns with wrong answers
  int get wrongAnswers {
    return _turns
        .where((turn) => turn.questionAnsweredCorrectly == false)
        .length;
  }

  /// Count turns with tax payments
  int get taxPaid {
    return _turns.where((turn) => turn.taxPaid == true).length;
  }

  /// Count turns with double dice
  int get doubleDice {
    return _turns.where((turn) => turn.isDouble).length;
  }

  /// Get statistics for a specific player
  TurnPlayerStats getPlayerStats(int playerIndex) {
    final playerTurns = filterByPlayer(playerIndex);

    final totalStarsGained = playerTurns.fold(
      0,
      (sum, turn) => sum + (turn.starsDelta > 0 ? turn.starsDelta : 0),
    );

    final totalStarsLost = playerTurns.fold(
      0,
      (sum, turn) => sum + (turn.starsDelta < 0 ? -turn.starsDelta : 0),
    );

    final netStarsChange = playerTurns.fold(
      0,
      (sum, turn) => sum + turn.starsDelta,
    );

    final correctAnswers = playerTurns
        .where((turn) => turn.questionAnsweredCorrectly == true)
        .length;
    final wrongAnswers = playerTurns
        .where((turn) => turn.questionAnsweredCorrectly == false)
        .length;
    final doubleDice = playerTurns.where((turn) => turn.isDouble).length;

    return TurnPlayerStats(
      playerIndex: playerIndex,
      totalTurns: playerTurns.length,
      totalStarsGained: totalStarsGained,
      totalStarsLost: totalStarsLost,
      netStarsChange: netStarsChange,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      doubleDice: doubleDice,
    );
  }

  @override
  String toString() {
    return 'TurnHistory(totalTurns=$totalTurns, isEmpty=$isEmpty)';
  }
}

/// Statistics for a specific player
///
/// Aggregates turn data for analysis and display.
class TurnPlayerStats {
  final int playerIndex;
  final int totalTurns;
  final int totalStarsGained;
  final int totalStarsLost;
  final int netStarsChange;
  final int correctAnswers;
  final int wrongAnswers;
  final int doubleDice;

  const TurnPlayerStats({
    required this.playerIndex,
    required this.totalTurns,
    required this.totalStarsGained,
    required this.totalStarsLost,
    required this.netStarsChange,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.doubleDice,
  });

  /// Calculate answer accuracy (correct / total questions answered)
  double get answerAccuracy {
    final totalQuestions = correctAnswers + wrongAnswers;
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }

  /// Get answer accuracy as percentage
  String get answerAccuracyPercentage {
    return '${(answerAccuracy * 100).toStringAsFixed(1)}%';
  }

  /// Calculate double dice rate
  double get doubleDiceRate {
    if (totalTurns == 0) return 0.0;
    return doubleDice / totalTurns;
  }

  /// Get double dice rate as percentage
  String get doubleDiceRatePercentage {
    return '${(doubleDiceRate * 100).toStringAsFixed(1)}%';
  }

  @override
  String toString() {
    return 'TurnPlayerStats(playerIndex=$playerIndex, totalTurns=$totalTurns, '
        'netStarsChange=$netStarsChange, '
        'answerAccuracy=$answerAccuracyPercentage, '
        'doubleDiceRate=$doubleDiceRatePercentage)';
  }
}
