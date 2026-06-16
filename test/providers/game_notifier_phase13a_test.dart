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
  group('Phase 13A win condition', () {
    test('old quote win condition does not trigger game over', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        _stateFor(players: [_playerWithLegacyQuoteWinState(stars: 1)]),
      );

      notifier.purchaseQuote('quote_after_legacy_threshold', 1);

      final state = container.read(gameProvider);
      expect(state.currentPlayer.collectedQuotes, hasLength(21));
      expect(state.phase, GamePhase.playerTurn);
      expect(state.winner, isNull);
      expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
    });

    test('buying final old-threshold quote does not trigger game over', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        _stateFor(
          players: [
            _playerWithLegacyQuoteWinState(
              stars: 5,
              quoteCount: GameConstants.quotesToCollect - 1,
            ),
          ],
        ),
      );

      notifier.purchaseQuote('quote_reaches_legacy_threshold', 3);

      final state = container.read(gameProvider);
      expect(
        state.currentPlayer.collectedQuotes,
        hasLength(GameConstants.quotesToCollect),
      );
      expect(state.currentPlayer.stars, 2);
      expect(state.phase, GamePhase.playerTurn);
      expect(state.winner, isNull);
      expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
    });

    test('publishing third Cilt still triggers game over', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book);

      notifier.updateState(
        _stateFor(
          currentTile: tile,
          players: [
            _playerWithLegacyQuoteWinState(
              stars: book.ciltCostAkce,
              categoryLevels: {book.category.name: MasteryLevel.kalfa.value},
            ),
            _player(id: 'p2', color: Colors.blue),
          ],
          bookOwnerships: {
            ..._ciltOwnershipsFor('p1', count: 2, excludingBookId: book.id),
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
      expect(state.phase, GamePhase.gameOver);
      expect(state.winner?.id, 'p1');
      expect(_logsContaining(state, 'Yayincilik zaferi'), isNotEmpty);
    });

    test(
      'Kiraathane shop opens and purchases quotes without win effect',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);

        notifier.updateState(
          _stateFor(
            players: [
              _playerWithLegacyQuoteWinState(
                stars: 5,
                quoteCount: GameConstants.quotesToCollect - 1,
              ),
            ],
          ),
        );

        final openFuture = notifier.openShopDialog();
        await Future<void>.delayed(Duration.zero);

        expect(container.read(dialogProvider).showShopDialog, isTrue);

        notifier.purchaseQuote('shop_quote_reaches_legacy_threshold', 2);

        var state = container.read(gameProvider);
        expect(
          state.currentPlayer.collectedQuotes,
          hasLength(GameConstants.quotesToCollect),
        );
        expect(state.currentPlayer.stars, 3);
        expect(state.phase, GamePhase.playerTurn);
        expect(state.winner, isNull);
        expect(container.read(dialogProvider).showShopDialog, isTrue);

        notifier.closeShopDialog();
        await openFuture;

        expect(container.read(dialogProvider).showShopDialog, isFalse);
        state = container.read(gameProvider);
        expect(state.winner, isNull);
        expect(_logsContaining(state, 'Yayincilik zaferi'), isEmpty);
      },
    );
  });
}

Player _player({
  String id = 'p1',
  Color color = Colors.red,
  int stars = 0,
  List<String> collectedQuotes = const [],
  Map<String, int> categoryLevels = const {},
}) {
  return Player(
    id: id,
    name: 'Player $id',
    color: color,
    iconIndex: 0,
    stars: stars,
    collectedQuotes: collectedQuotes,
    categoryLevels: categoryLevels,
  );
}

Player _playerWithLegacyQuoteWinState({
  int stars = 0,
  int quoteCount = GameConstants.quotesToCollect,
  Map<String, int>? categoryLevels,
}) {
  return _player(
    stars: stars,
    collectedQuotes: List.generate(
      quoteCount,
      (index) => 'legacy_quote_$index',
    ),
    categoryLevels: categoryLevels ?? _legacyMasteryLevels(),
  );
}

Map<String, int> _legacyMasteryLevels() {
  return {
    for (final category in QuestionCategory.values.take(3))
      category.name: MasteryLevel.usta.value,
  };
}

GameState _stateFor({
  List<Player>? players,
  BoardTile? currentTile,
  Map<String, BookOwnership> bookOwnerships = const {},
}) {
  return GameState(
    players: players ?? [_player()],
    tiles: BoardConfig.tiles,
    currentTile: currentTile,
    phase: GamePhase.playerTurn,
    bookOwnerships: bookOwnerships,
  );
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
