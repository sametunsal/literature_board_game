import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/engine/turn_history_validator.dart';
import 'package:literature_board_game/engine/turn_replay_engine.dart';
import 'package:literature_board_game/models/turn_result.dart';
import 'package:literature_board_game/models/turn_history.dart';

void main() {
  group('TurnHistoryValidator', () {
    test('validateTurn should validate a valid turn', () {
      // Create a simple valid turn
      final transcript = TurnTranscript(
        playerIndex: 0,
        events: [
          const TurnEvent(
            type: TurnEventType.diceRoll,
            data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
          ),
          const TurnEvent(
            type: TurnEventType.move,
            data: {'from': 1, 'to': 8, 'passedStart': false},
          ),
        ],
      );

      final turnResult = TurnResult(
        playerIndex: 0,
        startPosition: 1,
        endPosition: 8,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.book',
        transcript: transcript,
      );

      // Validate the turn
      final result = TurnHistoryValidator.validateTurn(turnResult);

      // Should be valid
      expect(result.isValid, true);
      expect(result.positionMatch, true);
      expect(result.starsMatch, true);
      expect(result.errorMessage, isNull);
    });

    test('validateAll should validate multiple turns', () {
      // Create multiple valid turns
      final turn1 = TurnResult(
        playerIndex: 0,
        startPosition: 1,
        endPosition: 8,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.book',
        transcript: TurnTranscript(
          playerIndex: 0,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 1, 'to': 8, 'passedStart': false},
            ),
          ],
        ),
      );

      final turn2 = TurnResult(
        playerIndex: 1,
        startPosition: 1,
        endPosition: 5,
        diceTotal: 4,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.corner',
        transcript: TurnTranscript(
          playerIndex: 1,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 2, 'die2': 2, 'total': 4, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 1, 'to': 5, 'passedStart': false},
            ),
          ],
        ),
      );

      final turnHistory = TurnHistory.fromList([turn1, turn2]);

      // Validate all turns
      final report = TurnHistoryValidator.validateAll(turnHistory);

      // Should be all valid
      expect(report.isAllValid, true);
      expect(report.totalValidated, 2);
      expect(report.passedCount, 2);
      expect(report.failedIndex, isNull);
      expect(report.errorMessage, isNull);
    });

    test('validateAll should stop on first failure', () {
      // Create one valid turn and one invalid turn
      final validTurn = TurnResult(
        playerIndex: 0,
        startPosition: 1,
        endPosition: 8,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.book',
        transcript: TurnTranscript(
          playerIndex: 0,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 1, 'to': 8, 'passedStart': false},
            ),
          ],
        ),
      );

      // Invalid turn: starsDelta doesn't match events
      final invalidTurn = TurnResult(
        playerIndex: 0,
        startPosition: 8,
        endPosition: 15,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 100, // Wrong: should be 0 based on events
        tileType: 'TileType.book',
        transcript: TurnTranscript(
          playerIndex: 0,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 8, 'to': 15, 'passedStart': false},
            ),
          ],
        ),
      );

      final turnHistory = TurnHistory.fromList([validTurn, invalidTurn]);

      // Validate all turns
      final report = TurnHistoryValidator.validateAll(turnHistory);

      // Should fail at index 1 (second turn)
      expect(report.isAllValid, false);
      expect(report.totalValidated, 2);
      expect(report.passedCount, 1);
      expect(report.failedIndex, 1);
      expect(report.errorMessage, isNotNull);
      expect(report.errorMessage!.contains('Stars delta mismatch'), true);
    });

    test('validateAll should handle empty history', () {
      final turnHistory = const TurnHistory.empty();

      final report = TurnHistoryValidator.validateAll(turnHistory);

      expect(report.isAllValid, true);
      expect(report.totalValidated, 0);
      expect(report.passedCount, 0);
    });

    test('TurnHistory extension should work', () {
      final turn = TurnResult(
        playerIndex: 0,
        startPosition: 1,
        endPosition: 8,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.book',
        transcript: TurnTranscript(
          playerIndex: 0,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 1, 'to': 8, 'passedStart': false},
            ),
          ],
        ),
      );

      final turnHistory = TurnHistory.fromList([turn]);

      // Use extension method
      final report = turnHistory.validate();

      expect(report.isAllValid, true);
      expect(turnHistory.isValid, true);
    });

    test('TurnHistoryValidator extension on TurnResult should work', () {
      final turn = TurnResult(
        playerIndex: 0,
        startPosition: 1,
        endPosition: 8,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.book',
        transcript: TurnTranscript(
          playerIndex: 0,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 1, 'to': 8, 'passedStart': false},
            ),
          ],
        ),
      );

      // Use TurnHistoryValidator to validate
      final result = TurnHistoryValidator.validateTurn(turn);

      expect(result.isValid, true);
    });

    test('invariant violation: cardDrawn without cardApplied', () {
      // Create a turn with cardDrawn but no cardApplied
      final turn = TurnResult(
        playerIndex: 0,
        startPosition: 1,
        endPosition: 8,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.book',
        transcript: TurnTranscript(
          playerIndex: 0,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 1, 'to': 8, 'passedStart': false},
            ),
            const TurnEvent(
              type: TurnEventType.cardDrawn,
              data: {'cardType': 'ŞANS', 'description': 'Test card'},
            ),
            // Missing cardApplied event!
          ],
        ),
      );

      final result = TurnHistoryValidator.validateTurn(turn);

      expect(result.isValid, false);
      expect(
        result.invariantViolation,
        ReplayInvariantViolation.missingCardApplied,
      );
      expect(
        result.errorMessage,
        contains('cardDrawn event found but no cardApplied event followed'),
      );
    });

    test('invariant violation: bankruptcy with stars remaining', () {
      // Create a turn with bankruptcy but stars > 0
      final turn = TurnResult(
        playerIndex: 0,
        startPosition: 1,
        endPosition: 8,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.book',
        transcript: TurnTranscript(
          playerIndex: 0,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 1, 'to': 8, 'passedStart': false},
            ),
            const TurnEvent(
              type: TurnEventType.bankruptcy,
              data: {'playerName': 'Player 0'},
            ),
          ],
        ),
      );

      final result = TurnHistoryValidator.validateTurn(turn);

      expect(result.isValid, false);
      expect(
        result.invariantViolation,
        ReplayInvariantViolation.bankruptcyWithStars,
      );
      expect(
        result.errorMessage,
        contains('bankruptcy event found but player still has'),
      );
    });

    test('invariant violation: card tile without cardApplied', () {
      // Create a turn with chance tile but no cardApplied
      final turn = TurnResult(
        playerIndex: 0,
        startPosition: 1,
        endPosition: 8,
        diceTotal: 7,
        isDouble: false,
        starsDelta: 0,
        tileType: 'TileType.chance',
        transcript: TurnTranscript(
          playerIndex: 0,
          events: [
            const TurnEvent(
              type: TurnEventType.diceRoll,
              data: {'die1': 3, 'die2': 4, 'total': 7, 'isDouble': false},
            ),
            const TurnEvent(
              type: TurnEventType.move,
              data: {'from': 1, 'to': 8, 'passedStart': false},
            ),
            const TurnEvent(
              type: TurnEventType.tileResolved,
              data: {
                'tileId': 5,
                'tileName': 'ŞANS',
                'tileType': 'TileType.chance',
              },
            ),
            // Missing cardApplied event!
          ],
        ),
      );

      final result = TurnHistoryValidator.validateTurn(turn);

      expect(result.isValid, false);
      expect(
        result.invariantViolation,
        ReplayInvariantViolation.missingTileFollowUp,
      );
      expect(
        result.errorMessage,
        contains('card tile (TileType.chance) resolved'),
      );
      expect(result.errorMessage, contains('no cardApplied event found'));
    });

    test('ValidationReport toString should format correctly', () {
      final successReport = ValidationReport.success(totalValidated: 5);

      final successString = successReport.toString();
      expect(successString, contains('✅ ALL VALID'));
      expect(successString, contains('Total validated: 5'));
      expect(successString, contains('Passed: 5'));

      final failureReport = ValidationReport.failure(
        totalValidated: 3,
        passedCount: 2,
        failedIndex: 2,
        errorMessage: 'Test error',
      );

      final failureString = failureReport.toString();
      expect(failureString, contains('❌ FAILED'));
      expect(failureString, contains('Total validated: 3'));
      expect(failureString, contains('Passed: 2'));
      expect(failureString, contains('Failed at index: 2'));
      expect(failureString, contains('Error: Test error'));
    });
  });
}
