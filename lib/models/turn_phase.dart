/// Turn Phase State Machine - Deterministic Turn Lifecycle
///
/// This enum tracks the current phase of a player's turn in the game.
/// The turn lifecycle progresses through these phases in order:
/// start → diceRolled → moved → tileResolved → (cardApplied | questionResolved | taxResolved) → turnEnded
///
/// Phase transitions are deterministic and always progress forward.
enum TurnPhase {
  /// Initial phase when a turn begins
  start,

  /// Phase after dice has been rolled
  diceRolled,

  /// Phase after player has moved to a new position
  moved,

  /// Phase after tile effects have been resolved
  tileResolved,

  /// Phase after a card effect has been applied
  cardApplied,

  /// Phase after a question has been answered (correct/wrong/skipped)
  questionResolved,

  /// Phase after tax has been paid or skipped
  taxResolved,

  /// Phase when the turn has ended and next player is being prepared
  turnEnded,
}
