import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  group('GameNotifier debug helpers', () {
    test('debug jump sets current player position and currentTile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );

      notifier.updateState(
        GameState(
          players: const [
            Player(id: 'p1', name: 'Player 1', color: Colors.red, iconIndex: 0),
          ],
          tiles: BoardConfig.tiles,
          phase: GamePhase.playerTurn,
        ),
      );

      notifier.debugJumpCurrentPlayerToPosition(book.tilePosition);

      final state = container.read(gameProvider);
      expect(state.currentPlayer.position, book.tilePosition);
      expect(state.currentTile, tile);
      expect(
        state.logs.any(
          (log) => log.contains('DEBUG') && log.contains('jumped'),
        ),
        isTrue,
      );
    });

    test('debug Cilt prep sets current player position and currentTile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );

      notifier.updateState(_stateFor());

      notifier.debugPrepareBookForCiltTest(book.tilePosition);

      final state = container.read(gameProvider);
      expect(state.currentPlayer.position, book.tilePosition);
      expect(state.currentTile, tile);
    });

    test('debug Cilt prep sets category mastery to Kalfa if lower', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;

      notifier.updateState(_stateFor());

      notifier.debugPrepareBookForCiltTest(book.tilePosition);

      expect(
        container
            .read(gameProvider)
            .currentPlayer
            .categoryLevels[book.category.name],
        MasteryLevel.kalfa.value,
      );
    });

    test('debug Cilt prep preserves Usta mastery', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;

      notifier.updateState(
        _stateFor(
          categoryLevels: {book.category.name: MasteryLevel.usta.value},
        ),
      );

      notifier.debugPrepareBookForCiltTest(book.tilePosition);

      expect(
        container
            .read(gameProvider)
            .currentPlayer
            .categoryLevels[book.category.name],
        MasteryLevel.usta.value,
      );
    });

    test('debug Cilt prep sets selected book to current player Baski', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;

      notifier.updateState(_stateFor());

      notifier.debugPrepareBookForCiltTest(book.tilePosition);

      final ownership = container.read(gameProvider).bookOwnerships[book.id];
      expect(ownership, isNotNull);
      expect(ownership!.ownerPlayerId, 'p1');
      expect(ownership.level, BookLevel.baski);
    });

    test('debug Cilt prep tops Akce up to Cilt cost', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;

      notifier.updateState(_stateFor(akce: 1));

      notifier.debugPrepareBookForCiltTest(book.tilePosition);

      expect(
        container.read(gameProvider).currentPlayer.akce,
        book.ciltCostAkce,
      );
    });

    test('debug Cilt prep does not reduce existing Akce', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final initialAkce = book.ciltCostAkce + 5;

      notifier.updateState(_stateFor(akce: initialAkce));

      notifier.debugPrepareBookForCiltTest(book.tilePosition);

      expect(container.read(gameProvider).currentPlayer.akce, initialAkce);
    });

    test('debug Cilt prep does not seed Cilt directly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;

      notifier.updateState(_stateFor());

      notifier.debugPrepareBookForCiltTest(book.tilePosition);

      expect(
        container.read(gameProvider).bookOwnerships[book.id]?.level,
        isNot(BookLevel.cilt),
      );
    });
  });
}

GameState _stateFor({
  int akce = 0,
  Map<String, int> categoryLevels = const {},
}) {
  return GameState(
    players: [
      Player(
        id: 'p1',
        name: 'Player 1',
        color: Colors.red,
        iconIndex: 0,
        stars: akce,
        categoryLevels: categoryLevels,
      ),
    ],
    tiles: BoardConfig.tiles,
    phase: GamePhase.playerTurn,
  );
}
