import 'turn_phase.dart';

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

/// ============================================================================
/// TURN TRANSCRIPT - Event Tracking
/// ============================================================================

/// Types of events that can occur during a turn
enum TurnEventType {
  transition,
  diceRoll,
  move,
  tileInteraction,
  tileResolved,
  cardDrawn,
  cardApplied,
  questionAsked,
  questionAnswered,
  taxPaid,
  copyrightPurchased,
  rentPaid,
  bonusReceived,
  libraryWatch,
  jail,
  turnStart,
  turnEnd,
}

/// A single event during a turn
class TurnEvent {
  final TurnEventType type;
  final String? description;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  TurnEvent(this.type, {this.description, Map<String, dynamic>? data})
    : data = data ?? const {},
      timestamp = DateTime.now();
}

/// Complete transcript of a turn
///
/// Records all events that occurred during a turn in chronological order.
/// Built incrementally using copyWith pattern for immutability.
class TurnTranscript {
  final List<TurnEvent> events;
  final int playerIndex;
  final int starsDelta;
  final int positionDelta;

  const TurnTranscript({
    this.events = const [],
    required this.playerIndex,
    this.starsDelta = 0,
    this.positionDelta = 0,
  });

  TurnTranscript copyWith({
    List<TurnEvent>? events,
    int? playerIndex,
    int? starsDelta,
    int? positionDelta,
  }) {
    return TurnTranscript(
      events: events ?? this.events,
      playerIndex: playerIndex ?? this.playerIndex,
      starsDelta: starsDelta ?? this.starsDelta,
      positionDelta: positionDelta ?? this.positionDelta,
    );
  }

  /// Add an event to the transcript
  TurnTranscript addEvent(TurnEvent event) {
    return copyWith(events: [...events, event]);
  }

  /// Add a transition event
  TurnTranscript addTransition(String name, TurnPhase from, TurnPhase to) {
    return addEvent(
      TurnEvent(
        TurnEventType.diceRoll,
        description: '$name ($from → $to)',
        data: {
          'transitionName': name,
          'from': from.toString(),
          'to': to.toString(),
        },
      ),
    );
  }

  /// Add a dice roll event
  TurnTranscript addDiceRoll(int die1, int die2, int total, bool isDouble) {
    return addEvent(
      TurnEvent(
        TurnEventType.diceRoll,
        description:
            'Rolled $die1 + $die2 = $total${isDouble ? ' (DOUBLE!)' : ''}',
        data: {
          'die1': die1,
          'die2': die2,
          'total': total,
          'isDouble': isDouble,
        },
      ),
    );
  }

  /// Add a move event
  TurnTranscript addMove(int from, int to, bool passedStart) {
    return addEvent(
      TurnEvent(
        TurnEventType.move,
        description:
            'Moved from $from to $to${passedStart ? ' (passed START)' : ''}',
        data: {'from': from, 'to': to, 'passedStart': passedStart},
      ),
    );
  }

  /// Add a tile resolved event
  TurnTranscript addTileResolved(int tileId, String tileName, String tileType) {
    return addEvent(
      TurnEvent(
        TurnEventType.tileInteraction,
        description: 'Landed on tile $tileId: $tileName ($tileType)',
        data: {'tileId': tileId, 'tileName': tileName, 'tileType': tileType},
      ),
    );
  }

  /// Add a card drawn event
  TurnTranscript addCardDrawn(String cardType, String description) {
    return addEvent(
      TurnEvent(
        TurnEventType.cardDrawn,
        description: 'Drew $cardType card: $description',
        data: {'cardType': cardType, 'description': description},
      ),
    );
  }

  /// Add a card applied event
  TurnTranscript addCardApplied(
    String cardType,
    String description,
    int? starChange,
  ) {
    return addEvent(
      TurnEvent(
        TurnEventType.cardApplied,
        description:
            'Applied $cardType card: $description${starChange != null ? ' (${starChange > 0 ? '+' : ''}$starChange stars)' : ''}',
        data: {
          'cardType': cardType,
          'description': description,
          'starChange': starChange,
        },
      ),
    );
  }

  /// Add a question asked event
  TurnTranscript addQuestionAsked(String question, String category) {
    return addEvent(
      TurnEvent(
        TurnEventType.questionAsked,
        description: 'Question asked: $question',
        data: {'question': question, 'category': category},
      ),
    );
  }

  /// Add a question answered event
  TurnTranscript addQuestionAnswered(String answerResult, int starChange) {
    return addEvent(
      TurnEvent(
        TurnEventType.questionAnswered,
        description:
            'Answered $answerResult (${starChange > 0 ? '+' : ''}$starChange stars)',
        data: {'answerResult': answerResult, 'starChange': starChange},
      ),
    );
  }

  /// Add a tax paid event
  TurnTranscript addTaxPaid(String taxType, int amount) {
    return addEvent(
      TurnEvent(
        TurnEventType.taxPaid,
        description: 'Paid $taxType tax: $amount stars',
        data: {'taxType': taxType, 'amount': amount},
      ),
    );
  }

  /// Add a bankruptcy event
  TurnTranscript addBankruptcy(String playerName) {
    return addEvent(
      TurnEvent(
        TurnEventType.jail,
        description: '$playerName went bankrupt!',
        data: {'playerName': playerName},
      ),
    );
  }

  /// Add a copyright purchased event
  TurnTranscript addCopyrightPurchased(
    int tileId,
    String tileName,
    int amount,
  ) {
    return addEvent(
      TurnEvent(
        TurnEventType.copyrightPurchased,
        description: 'Purchased $tileName: -$amount stars',
        data: {'tileId': tileId, 'tileName': tileName, 'amount': amount},
      ),
    );
  }

  /// Add a rent paid event
  TurnTranscript addRentPaid(
    int tileId,
    String tileName,
    String ownerName,
    int amount,
  ) {
    return addEvent(
      TurnEvent(
        TurnEventType.rentPaid,
        description: 'Rent paid for $tileName: -$amount stars → $ownerName',
        data: {
          'tileId': tileId,
          'tileName': tileName,
          'ownerName': ownerName,
          'amount': amount,
        },
      ),
    );
  }

  /// Add a bonus received event
  TurnTranscript addBonusReceived(int tileId, String tileName, int amount) {
    return addEvent(
      TurnEvent(
        TurnEventType.bonusReceived,
        description: 'Bonus from $tileName: +$amount stars',
        data: {'tileId': tileId, 'tileName': tileName, 'amount': amount},
      ),
    );
  }

  /// Add a star change event
  TurnTranscript addStarChange(String source, int delta) {
    return addEvent(
      TurnEvent(
        TurnEventType.turnStart,
        description: 'Stars ${delta > 0 ? '+' : ''}$delta from $source',
        data: {'source': source, 'delta': delta},
      ),
    );
  }

  /// Get a human-readable summary of the turn
  String getSummary() {
    if (events.isEmpty) {
      return 'No events recorded';
    }

    final buffer = StringBuffer();
    buffer.writeln('Turn Transcript (Player $playerIndex):');
    buffer.writeln('  Stars: ${starsDelta > 0 ? '+' : ''}$starsDelta');
    buffer.writeln('  Position: ${positionDelta > 0 ? '+' : ''}$positionDelta');
    buffer.writeln('  Events:');

    for (final event in events) {
      buffer.writeln('    - ${event.description ?? event.type}');
    }

    return buffer.toString();
  }

  /// Empty transcript
  static const empty = TurnTranscript(playerIndex: -1);
}

/// ============================================================================
/// TURN RESULT - Completed Turn Snapshot
/// ============================================================================

/// Lightweight snapshot of turn state at START phase
///
/// Used to calculate accurate starsDelta and positionDelta by comparing
/// start values with end values. This avoids double counting that would
/// occur if we inferred deltas from transcript events (e.g., card effect
/// might add stars, then passing START might add more stars).
class TurnSnapshot {
  final int playerIndex;
  final int startStars;
  final int startPosition;

  const TurnSnapshot({
    required this.playerIndex,
    required this.startStars,
    required this.startPosition,
  });
}

/// Represents a snapshot of a completed turn for UI feedback
///
/// Now includes a complete transcript of all events during a turn.
class TurnResult {
  final int playerIndex;
  final int startPosition;
  final int endPosition;
  final int diceTotal;
  final bool isDouble;
  final int starsDelta;
  final String tileType;
  final bool? questionAnsweredCorrectly;
  final bool? taxPaid;
  final TurnTranscript transcript;

  const TurnResult({
    required this.playerIndex,
    required this.startPosition,
    required this.endPosition,
    required this.diceTotal,
    required this.isDouble,
    required this.starsDelta,
    required this.tileType,
    this.questionAnsweredCorrectly,
    this.taxPaid,
    this.transcript = TurnTranscript.empty,
  });

  /// Creates an empty/initial TurnResult
  static const empty = TurnResult(
    playerIndex: -1,
    startPosition: 0,
    endPosition: 0,
    diceTotal: 0,
    isDouble: false,
    starsDelta: 0,
    tileType: '',
  );

  TurnResult copyWith({
    int? playerIndex,
    int? startPosition,
    int? endPosition,
    int? diceTotal,
    bool? isDouble,
    int? starsDelta,
    String? tileType,
    bool? questionAnsweredCorrectly,
    bool? taxPaid,
    TurnTranscript? transcript,
  }) {
    return TurnResult(
      playerIndex: playerIndex ?? this.playerIndex,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      diceTotal: diceTotal ?? this.diceTotal,
      isDouble: isDouble ?? this.isDouble,
      starsDelta: starsDelta ?? this.starsDelta,
      tileType: tileType ?? this.tileType,
      questionAnsweredCorrectly:
          questionAnsweredCorrectly ?? this.questionAnsweredCorrectly,
      taxPaid: taxPaid ?? this.taxPaid,
      transcript: transcript ?? this.transcript,
    );
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
