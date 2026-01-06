import '../models/turn_event.dart';
import '../models/turn_result.dart';

class TurnSummaryGenerator {
  /// Generates a structured TurnResult object from transcript
  static TurnResult generateTurnResult({
    required int playerIndex,
    required TurnTranscript transcript,
    required int startPosition,
    required int endPosition,
    required int starsDelta,
  }) {
    // Scan transcript for key events
    bool isDouble = false;
    bool? questionCorrect;
    bool taxPaid = false;
    int diceTotal = 0;
    String tileType = "Normal";

    for (final event in transcript.events) {
      if (event.type == TurnEventType.diceRoll) {
        if (event.data['isDouble'] == true) isDouble = true;
        if (event.data['total'] != null) diceTotal = event.data['total'] as int;
      }
      if (event.type == TurnEventType.questionAnswered) {
        questionCorrect = event.data['isCorrect'] as bool?;
      }
      if (event.type == TurnEventType.taxPaid) {
        taxPaid = true;
      }
    }

    return TurnResult(
      playerIndex: playerIndex,
      timestamp: DateTime.now(),
      startPosition: startPosition,
      endPosition: endPosition,
      diceTotal: diceTotal,
      isDouble: isDouble,
      starsDelta: starsDelta,
      questionAnsweredCorrectly: questionCorrect,
      taxPaid: taxPaid,
      transcript: transcript,
      tileType: tileType,
    );
  }

  /// Generates a text summary string
  static String generateTurnSummary(
    TurnResult result, {
    String? playerName,
    String? tileName,
  }) {
    final parts = <String>[];

    if (playerName != null) parts.add(playerName);

    String diceText = 'zar attı: ${result.diceTotal}';
    if (result.isDouble) diceText += ' (ÇİFT)';
    parts.add(diceText);

    parts.add('${result.startPosition} -> ${result.endPosition}');

    if (result.starsDelta > 0) {
      parts.add('+${result.starsDelta} Yıldız');
    } else if (result.starsDelta < 0) {
      parts.add('${result.starsDelta} Yıldız');
    }

    return parts.join(', ');
  }
}
