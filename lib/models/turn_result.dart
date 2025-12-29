import 'turn_phase.dart';

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

/// Types of events that can occur during a turn
enum TurnEventType {
  transition, // Phase transition executed
  diceRoll, // Dice rolled
  move, // Player moved
  tileResolved, // Tile effect resolved
  cardDrawn, // Card drawn from deck
  cardApplied, // Card effect applied
  questionAsked, // Question presented to player
  questionAnswered, // Question answered (correct/wrong/skipped)
  taxPaid, // Tax paid
  bankruptcy, // Bankruptcy occurred
  starChange, // Stars changed (from any source)
  copyrightPurchased, // Copyright purchased
  rentPaid, // Rent paid
  bonusReceived, // Bonus received
}

/// A single event during a turn
///
/// Combines human-readable description with structured data for analysis.
/// Events are immutable and are appended to build a complete turn narrative.
class TurnEvent {
  final TurnEventType type;
  final String? description;
  final Map<String, dynamic> data;

  const TurnEvent({required this.type, this.description, this.data = const {}});
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
        type: TurnEventType.transition,
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
        type: TurnEventType.diceRoll,
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
        type: TurnEventType.move,
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
        type: TurnEventType.tileResolved,
        description: 'Landed on tile $tileId: $tileName ($tileType)',
        data: {'tileId': tileId, 'tileName': tileName, 'tileType': tileType},
      ),
    );
  }

  /// Add a card drawn event
  TurnTranscript addCardDrawn(String cardType, String description) {
    return addEvent(
      TurnEvent(
        type: TurnEventType.cardDrawn,
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
        type: TurnEventType.cardApplied,
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
        type: TurnEventType.questionAsked,
        description: 'Question asked: $question',
        data: {'question': question, 'category': category},
      ),
    );
  }

  /// Add a question answered event
  TurnTranscript addQuestionAnswered(String answerResult, int starChange) {
    return addEvent(
      TurnEvent(
        type: TurnEventType.questionAnswered,
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
        type: TurnEventType.taxPaid,
        description: 'Paid $taxType tax: $amount stars',
        data: {'taxType': taxType, 'amount': amount},
      ),
    );
  }

  /// Add a bankruptcy event
  TurnTranscript addBankruptcy(String playerName) {
    return addEvent(
      TurnEvent(
        type: TurnEventType.bankruptcy,
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
        type: TurnEventType.copyrightPurchased,
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
        type: TurnEventType.rentPaid,
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
        type: TurnEventType.bonusReceived,
        description: 'Bonus from $tileName: +$amount stars',
        data: {'tileId': tileId, 'tileName': tileName, 'amount': amount},
      ),
    );
  }

  /// Add a star change event
  TurnTranscript addStarChange(String source, int delta) {
    return addEvent(
      TurnEvent(
        type: TurnEventType.starChange,
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

/// Represents a snapshot of a completed turn for UI feedback
///
/// Now includes a complete transcript of all events during the turn.
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
