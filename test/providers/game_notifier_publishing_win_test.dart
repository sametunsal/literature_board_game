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
  group('GameNotifier Publishing win condition', () {
    test('player wins on third Cilt', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book);
      final ownerships = {
        ..._ciltOwnershipsFor('p1', count: 2, excludingBookId: book.id),
        book.id: BookOwnership(
          bookId: book.id,
          ownerPlayerId: 'p1',
          level: BookLevel.baski,
        ),
      };

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: book.ciltCostAkce,
          currentPlayerCategoryLevels: {
            book.category.name: MasteryLevel.kalfa.value,
          },
          bookOwnerships: ownerships,
        ),
      );
      _showQuestion(container, book: book, difficulty: 'hard');

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.cilt);
      expect(state.phase, GamePhase.gameOver);
      expect(state.winner?.id, 'p1');
      expect(_logsContaining(state, 'Yayincilik zaferi'), isNotEmpty);
    });

    test('player does not win on first Cilt', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: book.ciltCostAkce,
          currentPlayerCategoryLevels: {
            book.category.name: MasteryLevel.kalfa.value,
          },
          bookOwnerships: {
            book.id: BookOwnership(
              bookId: book.id,
              ownerPlayerId: 'p1',
              level: BookLevel.baski,
            ),
          },
        ),
      );
      _showQuestion(container, book: book, difficulty: 'hard');

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.cilt);
      expect(state.winner, isNull);
      expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
    });

    test('player does not win on second Cilt', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book);
      final ownerships = {
        ..._ciltOwnershipsFor('p1', count: 1, excludingBookId: book.id),
        book.id: BookOwnership(
          bookId: book.id,
          ownerPlayerId: 'p1',
          level: BookLevel.baski,
        ),
      };

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: book.ciltCostAkce,
          currentPlayerCategoryLevels: {
            book.category.name: MasteryLevel.kalfa.value,
          },
          bookOwnerships: ownerships,
        ),
      );
      _showQuestion(container, book: book, difficulty: 'hard');

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.cilt);
      expect(state.winner, isNull);
      expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
    });

    test('Telif and Baski do not count toward publishing victory', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book);
      final otherBooks = BookConfig.books
          .where((candidate) => candidate.id != book.id)
          .take(2)
          .toList();

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: book.ciltCostAkce,
          currentPlayerCategoryLevels: {
            book.category.name: MasteryLevel.kalfa.value,
          },
          bookOwnerships: {
            otherBooks[0].id: BookOwnership(
              bookId: otherBooks[0].id,
              ownerPlayerId: 'p1',
              level: BookLevel.telif,
            ),
            otherBooks[1].id: BookOwnership(
              bookId: otherBooks[1].id,
              ownerPlayerId: 'p1',
              level: BookLevel.baski,
            ),
            book.id: BookOwnership(
              bookId: book.id,
              ownerPlayerId: 'p1',
              level: BookLevel.baski,
            ),
          },
        ),
      );
      _showQuestion(container, book: book, difficulty: 'hard');

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.cilt);
      expect(state.winner, isNull);
      expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
    });

    test(
      'opponent Cilt books do not count toward publishing victory',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = _bookWithTileDifficulty(Difficulty.hard);
        final tile = _tileForBook(book);
        final ownerships = {
          ..._ciltOwnershipsFor('p2', count: 2, excludingBookId: book.id),
          book.id: BookOwnership(
            bookId: book.id,
            ownerPlayerId: 'p1',
            level: BookLevel.baski,
          ),
        };

        notifier.updateState(
          _stateFor(
            tile: tile,
            currentAkce: book.ciltCostAkce,
            currentPlayerCategoryLevels: {
              book.category.name: MasteryLevel.kalfa.value,
            },
            bookOwnerships: ownerships,
          ),
        );
        _showQuestion(container, book: book, difficulty: 'hard');

        await notifier.answerQuestion(true);

        final state = container.read(gameProvider);
        expect(state.bookOwnerships[book.id]?.level, BookLevel.cilt);
        expect(state.winner, isNull);
        expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
      },
    );

    test('royalty payment does not trigger publishing victory', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);
      final ownerships = {
        ..._ciltOwnershipsFor(
          'p1',
          count: GameConstants.publishingCiltBooksToWin,
          excludingBookId: book.id,
        ),
        book.id: BookOwnership(
          bookId: book.id,
          ownerPlayerId: 'p2',
          level: BookLevel.cilt,
        ),
      };

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 5,
          ownerAkce: 10,
          bookOwnerships: ownerships,
          phase: GamePhase.gameOver,
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 2);
      expect(state.players[1].akce, 13);
      expect(state.winner, isNull);
      expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
    });

    test('Telif acquisition does not trigger publishing victory', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: 0,
          bookOwnerships: _ciltOwnershipsFor(
            'p1',
            count: GameConstants.publishingCiltBooksToWin - 1,
            excludingBookId: book.id,
          ),
          phase: GamePhase.gameOver,
        ),
      );

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.telif);
      expect(state.winner, isNull);
      expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
    });

    test('Baski upgrade does not trigger publishing victory', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book);
      final ownerships = {
        ..._ciltOwnershipsFor(
          'p1',
          count: GameConstants.publishingCiltBooksToWin - 1,
          excludingBookId: book.id,
        ),
        book.id: BookOwnership(
          bookId: book.id,
          ownerPlayerId: 'p1',
          level: BookLevel.telif,
        ),
      };

      notifier.updateState(
        _stateFor(
          tile: tile,
          currentAkce: book.baskiCostAkce,
          bookOwnerships: ownerships,
          phase: GamePhase.gameOver,
        ),
      );

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
      expect(state.winner, isNull);
      expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
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

Map<String, BookOwnership> _ciltOwnershipsFor(
  String playerId, {
  required int count,
  String? excludingBookId,
}) {
  final books = BookConfig.books
      .where((book) => book.id != excludingBookId)
      .take(count)
      .toList();
  return {
    for (final book in books)
      book.id: BookOwnership(
        bookId: book.id,
        ownerPlayerId: playerId,
        level: BookLevel.cilt,
      ),
  };
}

List<String> _logsContaining(GameState state, String text) {
  return state.logs.where((log) => log.contains(text)).toList();
}

GameState _stateFor({
  required BoardTile tile,
  required int currentAkce,
  int ownerAkce = 0,
  Map<String, int> currentPlayerCategoryLevels = const {},
  Map<String, BookOwnership> bookOwnerships = const {},
  GamePhase phase = GamePhase.playerTurn,
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
    phase: phase,
    bookOwnerships: bookOwnerships,
  );
}
