/// Turn Phase State Machine - Deterministic Turn Lifecycle
///
/// This enum tracks the current phase of a player's turn in the game.
/// The turn lifecycle progresses through these phases in order:
/// start → diceRolled → moved → tileResolved → (cardApplied | questionResolved | taxResolved) → turnEnded
///
/// Phase transitions are deterministic and always progress forward.
enum TurnPhase {
  /// Turn has started, waiting for player to roll dice
  start,

  /// Dice has been rolled, waiting for player movement
  diceRolled,

  /// Player has moved, waiting for tile resolution
  moved,

  /// Tile has been resolved (corner/card/question/tax applied)
  tileResolved,

  /// Card has been drawn and effect applied
  cardApplied,

  /// Question has been asked and answered
  questionResolved,

  /// Copyright purchase option shown
  copyrightPurchased,

  /// Tax has been paid
  taxResolved,

  /// Turn has ended, waiting for next player
  turnEnded,
}
