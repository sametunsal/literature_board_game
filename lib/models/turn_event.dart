/// Types of events that can happen in a turn
enum TurnEventType {
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
  transition,
}

/// A single event record
class TurnEvent {
  final TurnEventType type;
  final String? description;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  TurnEvent(this.type, {this.description, Map<String, dynamic>? data})
    : data = data ?? const {},
      timestamp = DateTime.now();
}

/// The chronological log of a turn
///
/// Records all events that occurred during a turn in chronological order.
/// Built incrementally using immutable pattern.
class TurnTranscript {
  final List<TurnEvent> events;

  const TurnTranscript({required this.events});
  const TurnTranscript.empty() : events = const [];

  /// Add a new event to the transcript
  TurnTranscript add(
    TurnEventType type, {
    String? description,
    Map<String, dynamic>? data,
  }) {
    return TurnTranscript(
      events: [
        ...events,
        TurnEvent(type, description: description, data: data),
      ],
    );
  }

  /// Check if transcript is empty
  bool get isEmpty => events.isEmpty;

  /// Check if transcript has events
  bool get isNotEmpty => events.isNotEmpty;

  /// Get number of events
  int get eventCount => events.length;
}
