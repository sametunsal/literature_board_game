import '../models/turn_result.dart';

/// Generates a concise text summary of a completed board game turn.
///
/// This is a pure function with no UI or provider dependencies.
///
/// [result] - The TurnResult containing turn data
/// [snapshot] - Optional TurnSnapshot with starting state (not currently used)
/// [playerName] - Optional player name (since TurnResult only has playerIndex)
/// [tileName] - Optional tile name (since TurnResult only has tileType)
///
/// Returns an English string summarizing the turn, e.g.:
/// "Samet rolled 8, moved from 12 to 20, landed on Tax and paid 2⭐."
/// "Player 2 rolled 6, moved from 5 to 11, landed on Book (answered correctly), +1⭐."
String generateTurnSummary(
  TurnResult result, {
  TurnSnapshot? snapshot,
  String? playerName,
  String? tileName,
}) {
  final parts = <String>[];

  // Player name or index
  final playerIdentifier = playerName ?? 'Player ${result.playerIndex + 1}';
  parts.add(playerIdentifier);

  // Dice roll
  String diceText = 'rolled ${result.diceTotal}';
  if (result.isDouble) {
    diceText += ' (double)';
  }
  parts.add(diceText);

  // Movement
  parts.add('moved from ${result.startPosition} to ${result.endPosition}');

  // Tile info
  final tileIdentifier = tileName ?? result.tileType;
  parts.add('landed on $tileIdentifier');

  // Question result
  if (result.questionAnsweredCorrectly != null) {
    final questionText = result.questionAnsweredCorrectly!
        ? 'answered correctly'
        : 'answered incorrectly';
    parts.add(questionText);
  }

  // Tax paid
  if (result.taxPaid == true) {
    parts.add('paid tax');
  }

  // Stars change
  if (result.starsDelta != 0) {
    final sign = result.starsDelta > 0 ? '+' : '';
    parts.add('$sign${result.starsDelta}⭐');
  }

  // Combine into summary
  final summary = parts.join(', ');

  // Fix capitalization and punctuation
  return '${summary.substring(0, 1).toUpperCase()}${summary.substring(1)}.';
}
