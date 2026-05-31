import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/tile_type.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  group('GameNotifier Publishing Telif acquisition', () {
    test(
      'correct answer on unowned book tile creates Telif ownership',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = BookConfig.books.first;
        final tile = BoardConfig.tiles.singleWhere(
          (tile) => tile.position == book.tilePosition,
        );

        notifier.updateState(_stateFor(tile: tile));

        await notifier.answerQuestion(true);

        final ownership = container.read(gameProvider).bookOwnerships[book.id];
        expect(ownership, isNotNull);
        expect(ownership!.bookId, book.id);
        expect(ownership.level, BookLevel.telif);
        expect(_telifLogs(container), hasLength(1));
      },
    );

    test('Telif acquisition log includes book title', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );

      notifier.updateState(_stateFor(tile: tile));

      await notifier.answerQuestion(true);

      final telifLogs = _telifLogs(container);
      expect(telifLogs, hasLength(1));
      expect(telifLogs.single, contains('Telif'));
      expect(telifLogs.single, contains(book.title));
    });

    test('Telif acquisition shows floating feedback with book title', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );

      notifier.updateState(_stateFor(tile: tile));

      await notifier.answerQuestion(true);

      final effect = container.read(gameProvider).floatingEffect;
      expect(effect, isNotNull);
      expect(effect!.text, contains('Telif'));
      expect(effect.text, contains(book.title));
    });

    test('ownership belongs to the current player', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );

      notifier.updateState(_stateFor(tile: tile));

      await notifier.answerQuestion(true);

      final ownership = container.read(gameProvider).bookOwnerships[book.id];
      expect(ownership!.ownerPlayerId, 'p1');
    });

    test('wrong answer does not create ownership', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );

      notifier.updateState(_stateFor(tile: tile));

      await notifier.answerQuestion(false);

      expect(container.read(gameProvider).bookOwnerships, isEmpty);
      expect(_telifLogs(container), isEmpty);
      expect(container.read(gameProvider).floatingEffect, isNull);
    });

    test('non-book special tile does not create ownership', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final tile = BoardConfig.tiles.firstWhere(
        (tile) => tile.type != TileType.category,
      );

      notifier.updateState(_stateFor(tile: tile));

      await notifier.answerQuestion(true);

      expect(container.read(gameProvider).bookOwnerships, isEmpty);
      expect(_telifLogs(container), isEmpty);
      expect(container.read(gameProvider).floatingEffect, isNull);
    });

    test('already-owned book is not replaced', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );
      const existingOwnership = BookOwnership(
        bookId: 'intibah',
        ownerPlayerId: 'p2',
        level: BookLevel.baski,
      );

      notifier.updateState(
        _stateFor(tile: tile, bookOwnerships: {book.id: existingOwnership}),
      );

      await notifier.answerQuestion(true);

      expect(
        container.read(gameProvider).bookOwnerships[book.id],
        same(existingOwnership),
      );
      expect(_telifLogs(container), isEmpty);
      expect(container.read(gameProvider).floatingEffect, isNull);
    });

    test('existing stars and quote behavior remains unchanged', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );

      notifier.updateState(_stateFor(tile: tile));

      await notifier.answerQuestion(true);

      final player = container.read(gameProvider).players.single;
      expect(player.stars, GameConstants.rewardEasy);
      expect(player.collectedQuotes, isEmpty);
    });
  });
}

List<String> _telifLogs(ProviderContainer container) {
  return container
      .read(gameProvider)
      .logs
      .where((log) => log.contains('Telif'))
      .toList();
}

GameState _stateFor({
  required BoardTile tile,
  Map<String, BookOwnership> bookOwnerships = const {},
}) {
  return GameState(
    players: const [
      Player(id: 'p1', name: 'Player 1', color: Colors.red, iconIndex: 0),
    ],
    tiles: BoardConfig.tiles,
    currentTile: tile,
    phase: GamePhase.gameOver,
    bookOwnerships: bookOwnerships,
  );
}
