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
  group('GameNotifier Publishing Baski upgrade', () {
    test('own Telif + correct + enough Akce upgrades to Baski', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: book.baskiCostAkce,
          bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.telif),
        ),
      );

      await notifier.answerQuestion(true);

      expect(
        container.read(gameProvider).bookOwnerships[book.id]?.level,
        BookLevel.baski,
      );
    });

    test('Baski upgrade subtracts book Baski cost Akce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.firstWhere(
        (book) => book.baskiCostAkce > 5,
      );
      final tile = _tileForBook(book.tilePosition);
      final initialAkce = book.baskiCostAkce;

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: initialAkce,
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p1',
            level: BookLevel.telif,
          ),
        ),
      );

      await notifier.answerQuestion(true);

      final player = container.read(gameProvider).players.single;
      expect(
        player.akce,
        initialAkce + GameConstants.rewardEasy - book.baskiCostAkce,
      );
    });

    test(
      'exact Baski cost upgrades and leaves only correct-answer reward Akce',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = BookConfig.books.first;
        final tile = _tileForBook(book.tilePosition);

        notifier.updateState(
          _stateFor(
            tile: tile,
            playerAkce: book.baskiCostAkce,
            bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.telif),
          ),
        );

        await notifier.answerQuestion(true);

        final state = container.read(gameProvider);
        expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
        expect(state.players.single.akce, GameConstants.rewardEasy);
      },
    );

    test(
      'Baski upgrade shows feedback without duplicate Telif feedback',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = BookConfig.books.first;
        final tile = _tileForBook(book.tilePosition);

        notifier.updateState(
          _stateFor(
            tile: tile,
            playerAkce: book.baskiCostAkce,
            bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.telif),
          ),
        );

        await notifier.answerQuestion(true);

        final state = container.read(gameProvider);
        expect(_logsContaining(state, 'Baski'), isNotEmpty);
        expect(_logsContaining(state, 'Telif'), isEmpty);
        // Duplicate toast removed: only the richer progression celebration
        // remains, and no floating toast is emitted for the upgrade.
        expect(state.progressionCelebration, isNotNull);
        expect(state.progressionCelebration!.bookTitle, book.title);
        expect(state.floatingEffect, isNull);
      },
    );

    test('Baski upgrade surfaces the progression celebration', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: book.baskiCostAkce,
          bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.telif),
        ),
      );

      await notifier.answerQuestion(true);

      final celebration = container.read(gameProvider).progressionCelebration;
      expect(celebration, isNotNull);
      expect(celebration!.levelLabel, 'Baskı');
      expect(celebration.toLevel, BookLevel.baski);
      expect(celebration.bookTitle, book.title);
      expect(celebration.royaltyBefore, 2);
      expect(celebration.royaltyAfter, 4);
      expect(celebration.ciltCount, 0);
      expect(
        celebration.ciltTarget,
        GameConstants.publishingCiltBooksToWin,
      );
    });

    test('wrong answer does not upgrade or spend', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book.tilePosition);
      final initialAkce = book.baskiCostAkce + 3;

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: initialAkce,
          bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.telif),
        ),
      );

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.telif);
      expect(state.players.single.akce, initialAkce);
    });

    test('insufficient Akce does not upgrade or spend', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book.tilePosition);
      const initialAkce = 1;

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: initialAkce,
          bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.telif),
        ),
      );

      await notifier.answerQuestion(true);

      final state = container.read(gameProvider);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.telif);
      expect(state.players.single.akce, initialAkce + GameConstants.rewardEasy);
      expect(_logsContaining(state, 'Yetersiz Akce'), isNotEmpty);
    });

    test('own Baski + correct does not upgrade to Cilt in Phase 9A', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: book.ciltCostAkce,
          bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.baski),
        ),
      );

      await notifier.answerQuestion(true);

      expect(
        container.read(gameProvider).bookOwnerships[book.id]?.level,
        BookLevel.baski,
      );
    });

    test(
      'own Baski + enough Cilt cost does not emit Cilt provider effects',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = BookConfig.books.first;
        final tile = _tileForBook(book.tilePosition);

        notifier.updateState(
          _stateFor(
            tile: tile,
            playerAkce: book.ciltCostAkce,
            bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.baski),
          ),
        );

        await notifier.answerQuestion(true);

        final state = container.read(gameProvider);
        expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
        expect(_logsContaining(state, 'Cilt'), isEmpty);
        expect(state.floatingEffect?.text.contains('Cilt') ?? false, isFalse);
      },
    );

    test('opponent-owned book pays royalty after wrong answer', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: 5,
          otherPlayerAkce: 10,
          bookOwnerships: _ownedBy(playerId: 'p2', level: BookLevel.telif),
        ),
      );

      await notifier.answerQuestion(false);

      final players = container.read(gameProvider).players;
      expect(players[0].akce, 3);
      expect(players[1].akce, 12);
      expect(
        container.read(gameProvider).bookOwnerships[book.id]?.level,
        BookLevel.telif,
      );
    });

    test(
      'own Baski + hard question + Kalfa + enough Akce upgrades to Cilt',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = _bookWithTileDifficulty(Difficulty.medium);
        final tile = _tileForBook(book.tilePosition);

        notifier.updateState(
          _stateFor(
            tile: tile,
            playerAkce: book.ciltCostAkce,
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
        expect(_logsContaining(state, 'Cilt yukseltildi'), isNotEmpty);
        // Duplicate toast removed: the upgrade surfaces the progression
        // celebration, not a floating toast.
        expect(state.progressionCelebration, isNotNull);
        expect(state.progressionCelebration!.bookTitle, book.title);
      },
    );

    test('Cilt upgrade surfaces the progression celebration', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.medium);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: book.ciltCostAkce,
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

      final celebration = container.read(gameProvider).progressionCelebration;
      expect(celebration, isNotNull);
      expect(celebration!.levelLabel, 'Cilt');
      expect(celebration.toLevel, BookLevel.cilt);
      expect(celebration.royaltyBefore, 4);
      expect(celebration.royaltyAfter, 6);
      expect(celebration.ciltCount, 1);
    });

    test('own Baski + hard question + Usta upgrades to Cilt', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: book.ciltCostAkce,
          currentPlayerCategoryLevels: {
            book.category.name: MasteryLevel.usta.value,
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

      expect(
        container.read(gameProvider).bookOwnerships[book.id]?.level,
        BookLevel.cilt,
      );
    });

    test('Cilt upgrade subtracts configured Cilt cost Akce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book.tilePosition);
      final initialAkce = book.ciltCostAkce;

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: initialAkce,
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
      expect(state.players.single.akce, GameConstants.rewardHard);
    });

    test('own Baski + hard question + insufficient Akce stays Baski', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book.tilePosition);
      const initialAkce = 1;

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: initialAkce,
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
      expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
      expect(state.players.single.akce, initialAkce + GameConstants.rewardHard);
      expect(_logsContaining(state, 'Yetersiz Akce'), isNotEmpty);
      expect(state.floatingEffect?.text, 'Yetersiz Akce');
    });

    test(
      'own Baski + non-Hard question + Kalfa + enough Akce does not spend',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = _bookWithTileDifficulty(Difficulty.hard);
        final tile = _tileForBook(book.tilePosition);
        final initialAkce = book.ciltCostAkce + 3;

        notifier.updateState(
          _stateFor(
            tile: tile,
            playerAkce: initialAkce,
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
        _showQuestion(container, book: book, difficulty: 'medium');

        await notifier.answerQuestion(true);

        final state = container.read(gameProvider);
        expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
        // Reward follows the DISPLAYED (medium) question, not the hard tile.
        expect(
          state.players.single.akce,
          initialAkce + GameConstants.rewardMedium,
        );
        expect(_logsContaining(state, 'Cilt'), isEmpty);
      },
    );

    test(
      'own Baski + hard question + below Kalfa + enough Akce does not spend',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = _bookWithTileDifficulty(Difficulty.hard);
        final tile = _tileForBook(book.tilePosition);
        final initialAkce = book.ciltCostAkce + 3;

        notifier.updateState(
          _stateFor(
            tile: tile,
            playerAkce: initialAkce,
            currentPlayerCategoryLevels: {
              book.category.name: MasteryLevel.cirak.value,
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
        expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
        expect(
          state.players.single.akce,
          initialAkce + GameConstants.rewardHard,
        );
        expect(_logsContaining(state, 'Cilt'), isEmpty);
      },
    );

    test(
      'own Baski + hard wrong answer + Kalfa + enough Akce does not spend',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = _bookWithTileDifficulty(Difficulty.hard);
        final tile = _tileForBook(book.tilePosition);
        final initialAkce = book.ciltCostAkce + 3;

        notifier.updateState(
          _stateFor(
            tile: tile,
            playerAkce: initialAkce,
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

        await notifier.answerQuestion(false);

        final state = container.read(gameProvider);
        expect(state.bookOwnerships[book.id]?.level, BookLevel.baski);
        expect(state.players.single.akce, initialAkce);
        expect(_logsContaining(state, 'Cilt'), isEmpty);
      },
    );

    test('opponent-owned Cilt pays royalty through GameNotifier', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(
        _stateFor(
          tile: tile,
          playerAkce: 8,
          otherPlayerAkce: 10,
          currentPlayerCategoryLevels: {
            book.category.name: MasteryLevel.kalfa.value,
          },
          bookOwnerships: _ownedBy(
            bookId: book.id,
            playerId: 'p2',
            level: BookLevel.cilt,
          ),
        ),
      );
      _showQuestion(container, book: book, difficulty: 'hard');

      await notifier.answerQuestion(false);

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 2);
      expect(state.players[1].akce, 16);
      expect(state.bookOwnerships[book.id]?.level, BookLevel.cilt);
      expect(_logsContaining(state, 'Royalty odendi'), isNotEmpty);
    });

    test(
      'star reward behavior remains unchanged after Baski upgrade',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        final book = BookConfig.books.first;
        final tile = _tileForBook(book.tilePosition);
        final initialAkce = book.baskiCostAkce + 4;

        notifier.updateState(
          _stateFor(
            tile: tile,
            playerAkce: initialAkce,
            bookOwnerships: _ownedBy(playerId: 'p1', level: BookLevel.telif),
          ),
        );

        await notifier.answerQuestion(true);

        final player = container.read(gameProvider).players.single;
        expect(
          player.stars,
          initialAkce + GameConstants.rewardEasy - book.baskiCostAkce,
        );
        expect(player.collectedQuotes, isEmpty);
      },
    );
  });

  // Regression: reward, progress and promotion must follow the question the
  // player actually saw (mastery-based), not the tile's fixed difficulty.
  // Single-player setup => no catch-up bonuses, so the answer reward is
  // isolated.
  group('mastery difficulty follows the displayed question, not the tile', () {
    const baseAkce = 40;

    test('Novice on a hard tile is paid for the easy question shown', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(_stateFor(
        tile: tile,
        playerAkce: baseAkce,
        currentPlayerCategoryLevels: {
          book.category.name: MasteryLevel.novice.value,
        },
      ));
      _showQuestion(container, book: book, difficulty: 'easy');

      await notifier.answerQuestion(true);

      final player = container.read(gameProvider).players.single;
      expect(player.akce, baseAkce + GameConstants.rewardEasy);
      // Progress is recorded against the displayed (easy) difficulty.
      expect(player.categoryProgress[book.category.name]?['easy'], 1);
      expect(player.categoryProgress[book.category.name]?['hard'], isNull);
    });

    test('Çırak on an easy tile is paid for the medium question shown', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.easy);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(_stateFor(
        tile: tile,
        playerAkce: baseAkce,
        currentPlayerCategoryLevels: {
          book.category.name: MasteryLevel.cirak.value,
        },
      ));
      _showQuestion(container, book: book, difficulty: 'medium');

      await notifier.answerQuestion(true);

      final player = container.read(gameProvider).players.single;
      expect(player.akce, baseAkce + GameConstants.rewardMedium);
    });

    test('Kalfa on an easy tile is paid for the hard question shown', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.easy);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(_stateFor(
        tile: tile,
        playerAkce: baseAkce,
        currentPlayerCategoryLevels: {
          book.category.name: MasteryLevel.kalfa.value,
        },
      ));
      _showQuestion(container, book: book, difficulty: 'hard');

      await notifier.answerQuestion(true);

      final player = container.read(gameProvider).players.single;
      expect(player.akce, baseAkce + GameConstants.rewardHard);
    });

    test('Novice promotes to Çırak via the easy question on a hard tile', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.hard);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(_stateFor(
        tile: tile,
        playerAkce: baseAkce,
        currentPlayerCategoryLevels: {
          book.category.name: MasteryLevel.novice.value,
        },
        currentPlayerCategoryProgress: {
          book.category.name: {'easy': 2},
        },
      ));
      _showQuestion(container, book: book, difficulty: 'easy');

      await notifier.answerQuestion(true);

      final player = container.read(gameProvider).players.single;
      expect(
        player.categoryLevels[book.category.name],
        MasteryLevel.cirak.value,
      );
    });

    test('Çırak promotes to Kalfa via the medium question on an easy tile', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.easy);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(_stateFor(
        tile: tile,
        playerAkce: baseAkce,
        currentPlayerCategoryLevels: {
          book.category.name: MasteryLevel.cirak.value,
        },
        currentPlayerCategoryProgress: {
          book.category.name: {'medium': 2},
        },
      ));
      _showQuestion(container, book: book, difficulty: 'medium');

      await notifier.answerQuestion(true);

      final player = container.read(gameProvider).players.single;
      expect(
        player.categoryLevels[book.category.name],
        MasteryLevel.kalfa.value,
      );
    });

    test('Kalfa promotes to Usta via the hard question on an easy tile', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = _bookWithTileDifficulty(Difficulty.easy);
      final tile = _tileForBook(book.tilePosition);

      notifier.updateState(_stateFor(
        tile: tile,
        playerAkce: baseAkce,
        currentPlayerCategoryLevels: {
          book.category.name: MasteryLevel.kalfa.value,
        },
        currentPlayerCategoryProgress: {
          book.category.name: {'hard': 2},
        },
      ));
      _showQuestion(container, book: book, difficulty: 'hard');

      await notifier.answerQuestion(true);

      final player = container.read(gameProvider).players.single;
      expect(
        player.categoryLevels[book.category.name],
        MasteryLevel.usta.value,
      );
    });
  });
}

BoardTile _tileForBook(int tilePosition) {
  return BoardConfig.tiles.singleWhere((tile) => tile.position == tilePosition);
}

Book _bookWithTileDifficulty(Difficulty difficulty) {
  return BookConfig.books.firstWhere(
    (book) => _tileForBook(book.tilePosition).difficulty == difficulty,
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
  String? bookId,
  required String playerId,
  required BookLevel level,
}) {
  final book = BookConfig.books.first;
  final id = bookId ?? book.id;
  return {id: BookOwnership(bookId: id, ownerPlayerId: playerId, level: level)};
}

List<String> _logsContaining(GameState state, String text) {
  return state.logs.where((log) => log.contains(text)).toList();
}

GameState _stateFor({
  required BoardTile tile,
  required int playerAkce,
  int? otherPlayerAkce,
  Map<String, int> currentPlayerCategoryLevels = const {},
  Map<String, Map<String, int>> currentPlayerCategoryProgress = const {},
  Map<String, BookOwnership> bookOwnerships = const {},
}) {
  return GameState(
    players: [
      Player(
        id: 'p1',
        name: 'Player 1',
        color: Colors.red,
        iconIndex: 0,
        stars: playerAkce,
        categoryLevels: currentPlayerCategoryLevels,
        categoryProgress: currentPlayerCategoryProgress,
      ),
      if (otherPlayerAkce != null)
        Player(
          id: 'p2',
          name: 'Player 2',
          color: Colors.blue,
          iconIndex: 1,
          stars: otherPlayerAkce,
        ),
    ],
    tiles: BoardConfig.tiles,
    currentTile: tile,
    phase: GamePhase.gameOver,
    bookOwnerships: bookOwnerships,
  );
}
