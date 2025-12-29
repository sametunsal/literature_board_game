import '../models/turn_result.dart';
import '../utils/turn_summary_generator.dart';

/// Examples demonstrating the generateTurnSummary function
///
/// These examples show various turn scenarios:
/// - Regular tile with star gain
/// - Question tile with correct answer
/// - Question tile with wrong answer
/// - Tax tile with star loss
/// - Double dice roll
/// - Minimal data (no player/tile names)
void main() {
  // Example 1: Regular turn with star gain
  final result1 = const TurnResult(
    playerIndex: 0,
    startPosition: 12,
    endPosition: 20,
    diceTotal: 8,
    isDouble: false,
    starsDelta: 3,
    tileType: 'Publisher',
  );

  print('Example 1 - Regular turn:');
  print(
    generateTurnSummary(
      result1,
      playerName: 'Samet',
      tileName: 'Penguin Books',
    ),
  );
  print('');

  // Example 2: Question tile - answered correctly
  final result2 = const TurnResult(
    playerIndex: 1,
    startPosition: 5,
    endPosition: 11,
    diceTotal: 6,
    isDouble: false,
    starsDelta: 1,
    tileType: 'Book',
    questionAnsweredCorrectly: true,
  );

  print('Example 2 - Question correct:');
  print(
    generateTurnSummary(result2, playerName: 'Ahmet', tileName: 'Great Gatsby'),
  );
  print('');

  // Example 3: Question tile - answered incorrectly
  final result3 = const TurnResult(
    playerIndex: 1,
    startPosition: 11,
    endPosition: 15,
    diceTotal: 4,
    isDouble: false,
    starsDelta: -1,
    tileType: 'Book',
    questionAnsweredCorrectly: false,
  );

  print('Example 3 - Question incorrect:');
  print(generateTurnSummary(result3, playerName: 'Ahmet', tileName: '1984'));
  print('');

  // Example 4: Tax tile
  final result4 = const TurnResult(
    playerIndex: 2,
    startPosition: 18,
    endPosition: 22,
    diceTotal: 4,
    isDouble: false,
    starsDelta: -2,
    tileType: 'Tax',
    taxPaid: true,
  );

  print('Example 4 - Tax payment:');
  print(
    generateTurnSummary(result4, playerName: 'Mehmet', tileName: 'Income Tax'),
  );
  print('');

  // Example 5: Double dice roll
  final result5 = const TurnResult(
    playerIndex: 0,
    startPosition: 25,
    endPosition: 35,
    diceTotal: 10,
    isDouble: true,
    starsDelta: 0,
    tileType: 'Chance',
  );

  print('Example 5 - Double roll:');
  print(
    generateTurnSummary(result5, playerName: 'Samet', tileName: 'Lucky Draw'),
  );
  print('');

  // Example 6: Minimal data (no player/tile names)
  print('Example 6 - Minimal data:');
  print(
    generateTurnSummary(
      const TurnResult(
        playerIndex: 3,
        startPosition: 0,
        endPosition: 6,
        diceTotal: 6,
        isDouble: false,
        starsDelta: 2,
        tileType: 'Corner',
      ),
    ),
  );
  print('');

  // Example 7: Complex turn with question and tax
  final result7 = const TurnResult(
    playerIndex: 0,
    startPosition: 30,
    endPosition: 38,
    diceTotal: 8,
    isDouble: false,
    starsDelta: -3,
    tileType: 'Tax',
    questionAnsweredCorrectly: false,
    taxPaid: true,
  );

  print('Example 7 - Question wrong + tax:');
  print(
    generateTurnSummary(result7, playerName: 'Samet', tileName: 'Library Tax'),
  );
  print('');

  // Example 8: Star gain with question correct
  final result8 = const TurnResult(
    playerIndex: 1,
    startPosition: 8,
    endPosition: 14,
    diceTotal: 6,
    isDouble: false,
    starsDelta: 2,
    tileType: 'Book',
    questionAnsweredCorrectly: true,
  );

  print('Example 8 - Question correct + star gain:');
  print(
    generateTurnSummary(
      result8,
      playerName: 'Ayşe',
      tileName: 'To Kill a Mockingbird',
    ),
  );
}
