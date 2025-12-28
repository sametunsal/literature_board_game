/// Represents a snapshot of a completed turn for UI feedback
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
}
