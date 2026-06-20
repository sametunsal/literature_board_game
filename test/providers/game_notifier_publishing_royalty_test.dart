import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/book.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/question.dart';
import 'package:literature_board_game/providers/dialog_provider.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  group('GameNotifier Publishing Royalty', () {
    test('opponent Telif wrong answer pays 2 Akce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 5,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.telif,
          ),
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 3);
      expect(state.players[1].akce, 12);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.telif);
      expect(_logsContaining(state, 'Royalty odendi'), isNotEmpty);
      expect(state.floatingEffect?.text, 'Royalty: -2 Akce');
    });

    test('opponent Baski wrong answer pays 4 Akce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 5,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.baski,
          ),
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 1);
      expect(state.players[1].akce, 14);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
      expect(state.floatingEffect?.text, 'Royalty: -4 Akce');
    });

    test('opponent Cilt wrong answer pays 6 Akce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 8,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.cilt,
          ),
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 2);
      expect(state.players[1].akce, 16);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.cilt);
      expect(state.floatingEffect?.text, 'Royalty: -6 Akce');
    });

    test('royalty payment is capped by payer Akce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 1,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.cilt,
          ),
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 0);
      expect(state.players[1].akce, 11);
      expect(state.floatingEffect?.text, 'Royalty: -1 Akce');
    });

    test('royalty payer never goes negative', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 2,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.cilt,
          ),
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 0);
      expect(state.players[1].akce, 12);
      expect(state.players[0].akce, isNonNegative);
    });

    test('payer with 0 Akce shows no royalty floating feedback', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 0,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.cilt,
          ),
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 0);
      expect(state.players[1].akce, 10);
      expect(state.floatingEffect?.text.contains('Royalty') ?? false, isFalse);
      expect(_logsContaining(state, 'Royalty odendi'), isEmpty);
    });

    test('correct answer on opponent-owned book pays no royalty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);
      const initialAkce = 5;

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: initialAkce,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.cilt,
          ),
        ),
      );

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, initialAkce + GameConstants.rewardEasy);
      expect(state.players[1].akce, 10);
      expect(_logsContaining(state, 'Royalty odendi'), isEmpty);
      expect(state.floatingEffect?.text.contains('Royalty') ?? false, isFalse);
    });

    test('wrong answer on unowned book pays no royalty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(tile: tile, currentAkce: 5, ownerAkce: 10),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 5);
      expect(state.players[1].akce, 10);
      expect(_logsContaining(state, 'Royalty odendi'), isEmpty);
      expect(state.floatingEffect?.text.contains('Royalty') ?? false, isFalse);
    });

    test('wrong answer on own book pays no royalty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 5,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p1',
            level: BookLevel.baski,
          ),
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 5);
      expect(state.players[1].akce, 10);
      expect(_logsContaining(state, 'Royalty odendi'), isEmpty);
      expect(state.floatingEffect?.text.contains('Royalty') ?? false, isFalse);
    });

    test('royalty does not change ownership level', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 5,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.baski,
          ),
        ),
      );

      await notifier.answerQuestion(false);

      final ownership = container.read(gameProvider).bookOwnerships[book.id];
      expect(ownership?.ownerPlayerId, 'p2');
      expect(ownership?.level, BookLevel.baski);
    });

    test('own Baski upgrade emits no royalty behavior', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: book.baskiCostAkce,
          ownerAkce: 10,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p1',
            level: BookLevel.telif,
          ),
        ),
      );

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
      expect(_logsContaining(state, 'Royalty odendi'), isEmpty);
      expect(state.floatingEffect?.text.contains('Royalty') ?? false, isFalse);
    });

    test('own Cilt upgrade emits no royalty behavior', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: book.ciltCostAkce,
          ownerAkce: 10,
          currentPlayerCategoryLevels: {
            book.category.name: MasteryLevel.kalfa.value,
          },
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p1',
            level: BookLevel.baski,
          ),
        ),
      );
      _showQuestion(container, book: book, difficulty: 'hard');

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.cilt);
      expect(_logsContaining(state, 'Royalty odendi'), isEmpty);
      expect(state.floatingEffect?.text.contains('Royalty') ?? false, isFalse);
    });
  });
}

BoardTile _tileForBook(Book book) {
  return BoardConfig.tiles.singleWhere(
    (tile) => tile.position == book.tilePosition,
  );
}

Book _bookWithTileDifficulty(Difficulty difficulty) {
  return BookConfig.books.firstWhere(
    (book) => _tileForBook(book).difficulty == difficulty,
  );
}

void _showQuestion(
  ProviderContainer container, {
  required Book book,
  required String difficulty,
}) {
  container
      .read(dialogProvider.notifier)
      .showQuestion(
        Question(
          text: '${book.id}_$difficulty',
          options: const ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          category: book.category,
          difficulty: difficulty,
        ),
      );
}

Map<String, BookOwnership> _ownedBy({
  required String bookId,
  required String playerId,
  required BookLevel level,
}) {
  return {
    bookId: BookOwnership(
      bookId: bookId,
      ownerPlayerId: playerId,
      level: level,
    ),
  };
}

List<String> _logsContaining(GameState state, String text) {
  return state.logs.where((log) => log.contains(text)).toList();
}

GameState _stateFor({
  required BoardTile tile,
  required int currentAkce,
  required int ownerAkce,
  Map<String, int> currentPlayerCategoryLevels = const {},
  Map<String, BookOwnership> bookOwnerships = const {},
}) {
  return GameState(
    players: [
      Player(
        id: 'p1',
        name: 'Player 1',
        color: Colors.red,
        iconIndex: 0,
        stars: currentAkce,
        categoryLevels: currentPlayerCategoryLevels,
      ),
      Player(
        id: 'p2',
        name: 'Player 2',
        color: Colors.blue,
        iconIndex: 1,
        stars: ownerAkce,
      ),
    ],
    tiles: BoardConfig.tiles,
    currentTile: tile,
    phase: GamePhase.gameOver,
    bookOwnerships: bookOwnerships,
  );
}
