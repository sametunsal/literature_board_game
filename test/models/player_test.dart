import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/player_type.dart';

void main() {
  group('Player Model Tests', () {
    late Player player;

    setUp(() {
      player = Player(
        id: 'player1',
        name: 'Test Player',
        color: '#FF0000',
        type: PlayerType.human,
      );
    });

    group('Player Creation', () {
      test('should create a player with default values', () {
        expect(player.id, 'player1');
        expect(player.name, 'Test Player');
        expect(player.color, '#FF0000');
        expect(player.type, PlayerType.human);
        expect(player.stars, 150);
        expect(player.position, 1);
        expect(player.ownedTiles, isEmpty);
        expect(player.isInLibraryWatch, isFalse);
        expect(player.libraryWatchTurnsRemaining, 0);
        expect(player.doubleDiceCount, 0);
        expect(player.isBankrupt, isFalse);
        expect(player.skippedTurn, isFalse);
        expect(player.skipNextTax, isFalse);
        expect(player.easyQuestionNext, isFalse);
        expect(player.lastRoll, isNull);
      });

      test('should create a human player', () {
        final humanPlayer = Player(
          id: 'human1',
          name: 'Human Player',
          color: '#00FF00',
          type: PlayerType.human,
        );
        expect(humanPlayer.type, PlayerType.human);
      });

      test('should create a bot player', () {
        final botPlayer = Player(
          id: 'bot1',
          name: 'Bot Player',
          color: '#0000FF',
          type: PlayerType.bot,
        );
        expect(botPlayer.type, PlayerType.bot);
      });

      test('should create a player with custom initial values', () {
        final customPlayer = Player(
          id: 'custom1',
          name: 'Custom Player',
          color: '#FFFF00',
          type: PlayerType.bot,
          stars: 200,
          position: 5,
          ownedTiles: [1, 2, 3],
          isInLibraryWatch: true,
          libraryWatchTurnsRemaining: 2,
          doubleDiceCount: 1,
          isBankrupt: false,
          skippedTurn: true,
          skipNextTax: true,
          easyQuestionNext: true,
          lastRoll: 6,
        );
        expect(customPlayer.stars, 200);
        expect(customPlayer.position, 5);
        expect(customPlayer.ownedTiles, [1, 2, 3]);
        expect(customPlayer.isInLibraryWatch, isTrue);
        expect(customPlayer.libraryWatchTurnsRemaining, 2);
        expect(customPlayer.doubleDiceCount, 1);
        expect(customPlayer.skippedTurn, isTrue);
        expect(customPlayer.skipNextTax, isTrue);
        expect(customPlayer.easyQuestionNext, isTrue);
        expect(customPlayer.lastRoll, 6);
      });
    });

    group('Computed Properties', () {
      test('canPlay should return true when player can take a turn', () {
        expect(player.canPlay, isTrue);
      });

      test('canPlay should return false when player is bankrupt', () {
        final bankruptPlayer = player.copyWith(isBankrupt: true);
        expect(bankruptPlayer.canPlay, isFalse);
      });

      test('canPlay should return false when player is in library watch', () {
        final libraryWatchPlayer = player.copyWith(isInLibraryWatch: true);
        expect(libraryWatchPlayer.canPlay, isFalse);
      });

      test('canPlay should return false when player skipped turn', () {
        final skippedPlayer = player.copyWith(skippedTurn: true);
        expect(skippedPlayer.canPlay, isFalse);
      });

      test('canPlay should return false when multiple conditions are true', () {
        final multipleConditionsPlayer = player.copyWith(
          isBankrupt: true,
          isInLibraryWatch: true,
        );
        expect(multipleConditionsPlayer.canPlay, isFalse);
      });

      test('inPenalty should return false when player has no penalty', () {
        expect(player.inPenalty, isFalse);
      });

      test('inPenalty should return true when player is in library watch', () {
        final libraryWatchPlayer = player.copyWith(isInLibraryWatch: true);
        expect(libraryWatchPlayer.inPenalty, isTrue);
      });

      test('inPenalty should return true when player skipped turn', () {
        final skippedPlayer = player.copyWith(skippedTurn: true);
        expect(skippedPlayer.inPenalty, isTrue);
      });

      test('inPenalty should return true when both penalties are active', () {
        final bothPenaltiesPlayer = player.copyWith(
          isInLibraryWatch: true,
          skippedTurn: true,
        );
        expect(bothPenaltiesPlayer.inPenalty, isTrue);
      });

      test('totalCopyrightValue should return 0 (placeholder)', () {
        expect(player.totalCopyrightValue, 0);
      });
    });

    group('Tile Ownership', () {
      test('ownsTile should return false for unowned tiles', () {
        expect(player.ownsTile(1), isFalse);
        expect(player.ownsTile(5), isFalse);
      });

      test('ownsTile should return true for owned tiles', () {
        final playerWithTiles = player.copyWith(ownedTiles: [1, 3, 5]);
        expect(playerWithTiles.ownsTile(1), isTrue);
        expect(playerWithTiles.ownsTile(3), isTrue);
        expect(playerWithTiles.ownsTile(5), isTrue);
      });

      test('ownsTile should return false for tiles not in owned list', () {
        final playerWithTiles = player.copyWith(ownedTiles: [1, 3, 5]);
        expect(playerWithTiles.ownsTile(2), isFalse);
        expect(playerWithTiles.ownsTile(4), isFalse);
      });
    });

    group('copyWith Method', () {
      test('should create a copy with updated id', () {
        final updatedPlayer = player.copyWith(id: 'player2');
        expect(updatedPlayer.id, 'player2');
        expect(updatedPlayer.name, 'Test Player');
        expect(updatedPlayer.color, '#FF0000');
      });

      test('should create a copy with updated name', () {
        final updatedPlayer = player.copyWith(name: 'Updated Name');
        expect(updatedPlayer.name, 'Updated Name');
        expect(updatedPlayer.id, 'player1');
      });

      test('should create a copy with updated color', () {
        final updatedPlayer = player.copyWith(color: '#00FF00');
        expect(updatedPlayer.color, '#00FF00');
      });

      test('should create a copy with updated type', () {
        final updatedPlayer = player.copyWith(type: PlayerType.bot);
        expect(updatedPlayer.type, PlayerType.bot);
      });

      test('should create a copy with updated stars', () {
        final updatedPlayer = player.copyWith(stars: 250);
        expect(updatedPlayer.stars, 250);
      });

      test('should create a copy with updated position', () {
        final updatedPlayer = player.copyWith(position: 10);
        expect(updatedPlayer.position, 10);
      });

      test('should create a copy with updated ownedTiles', () {
        final updatedPlayer = player.copyWith(ownedTiles: [1, 2, 3]);
        expect(updatedPlayer.ownedTiles, [1, 2, 3]);
      });

      test('should create a copy with updated isInLibraryWatch', () {
        final updatedPlayer = player.copyWith(isInLibraryWatch: true);
        expect(updatedPlayer.isInLibraryWatch, isTrue);
      });

      test('should create a copy with updated libraryWatchTurnsRemaining', () {
        final updatedPlayer = player.copyWith(libraryWatchTurnsRemaining: 3);
        expect(updatedPlayer.libraryWatchTurnsRemaining, 3);
      });

      test('should create a copy with updated doubleDiceCount', () {
        final updatedPlayer = player.copyWith(doubleDiceCount: 2);
        expect(updatedPlayer.doubleDiceCount, 2);
      });

      test('should create a copy with updated isBankrupt', () {
        final updatedPlayer = player.copyWith(isBankrupt: true);
        expect(updatedPlayer.isBankrupt, isTrue);
      });

      test('should create a copy with updated skippedTurn', () {
        final updatedPlayer = player.copyWith(skippedTurn: true);
        expect(updatedPlayer.skippedTurn, isTrue);
      });

      test('should create a copy with updated skipNextTax', () {
        final updatedPlayer = player.copyWith(skipNextTax: true);
        expect(updatedPlayer.skipNextTax, isTrue);
      });

      test('should create a copy with updated easyQuestionNext', () {
        final updatedPlayer = player.copyWith(easyQuestionNext: true);
        expect(updatedPlayer.easyQuestionNext, isTrue);
      });

      test('should create a copy with updated lastRoll', () {
        final updatedPlayer = player.copyWith(lastRoll: 12);
        expect(updatedPlayer.lastRoll, 12);
      });

      test('should create a copy with multiple updates', () {
        final updatedPlayer = player.copyWith(
          name: 'New Name',
          stars: 300,
          position: 15,
          isBankrupt: true,
        );
        expect(updatedPlayer.name, 'New Name');
        expect(updatedPlayer.stars, 300);
        expect(updatedPlayer.position, 15);
        expect(updatedPlayer.isBankrupt, isTrue);
        expect(updatedPlayer.id, 'player1');
      });

      test('should create a copy with null values', () {
        // Note: Player.copyWith doesn't support nullable int for lastRoll
        // The implementation uses int? but copyWith expects int
        // This test demonstrates the current behavior
        final playerWithRoll = player.copyWith(lastRoll: 6);
        expect(playerWithRoll.lastRoll, 6);
        // To reset to null, we would need to create a new player
        final resetPlayer = Player(
          id: player.id,
          name: player.name,
          color: player.color,
          type: player.type,
        );
        expect(resetPlayer.lastRoll, isNull);
      });

      test('should not modify original player when copying', () {
        final originalStars = player.stars;
        final originalPosition = player.position;

        player.copyWith(stars: 200, position: 5);

        expect(player.stars, originalStars);
        expect(player.position, originalPosition);
      });
    });

    group('Position Updates', () {
      test('should update position using copyWith', () {
        final updatedPlayer = player.copyWith(position: 5);
        expect(updatedPlayer.position, 5);
      });

      test('should handle position updates from 1 to 20', () {
        for (int i = 1; i <= 20; i++) {
          final updatedPlayer = player.copyWith(position: i);
          expect(updatedPlayer.position, i);
        }
      });

      test('should handle position 0', () {
        final updatedPlayer = player.copyWith(position: 0);
        expect(updatedPlayer.position, 0);
      });

      test('should handle large position values', () {
        final updatedPlayer = player.copyWith(position: 100);
        expect(updatedPlayer.position, 100);
      });
    });

    group('Edge Cases', () {
      test('should handle empty ownedTiles list', () {
        final playerWithEmptyTiles = player.copyWith(ownedTiles: []);
        expect(playerWithEmptyTiles.ownedTiles, isEmpty);
        expect(playerWithEmptyTiles.ownsTile(1), isFalse);
      });

      test('should handle multiple owned tiles', () {
        final tiles = List.generate(10, (i) => i + 1);
        final playerWithManyTiles = player.copyWith(ownedTiles: tiles);
        expect(playerWithManyTiles.ownedTiles.length, 10);
        for (int i = 1; i <= 10; i++) {
          expect(playerWithManyTiles.ownsTile(i), isTrue);
        }
      });

      test('should handle negative stars', () {
        final playerWithNegativeStars = player.copyWith(stars: -50);
        expect(playerWithNegativeStars.stars, -50);
      });

      test('should handle zero stars', () {
        final playerWithZeroStars = player.copyWith(stars: 0);
        expect(playerWithZeroStars.stars, 0);
      });
    });
  });
}
