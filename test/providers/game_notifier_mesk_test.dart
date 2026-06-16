import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/book_level.dart';
import 'package:literature_board_game/models/book_ownership.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/question.dart';
import 'package:literature_board_game/providers/dialog_provider.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Kiraathane Mesk MVP', () {
    test('landing on Kiraathane opens action dialog', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier.updateState(_stateFor(players: [_player(akce: 5)]));

      final openFuture = notifier.handleKiraathaneLanding();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(dialogProvider).showKiraathaneDialog, isTrue);
      expect(container.read(dialogProvider).showShopDialog, isFalse);

      notifier.cancelKiraathane();
      await openFuture;
      await _waitForTurnEnd();
    });

    test('Alisveris opens existing shop dialog', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier.updateState(_stateFor(players: [_player(akce: 5)]));

      final kiraathaneFuture = notifier.openKiraathaneDialog();
      await Future<void>.delayed(Duration.zero);
      final shopFuture = notifier.openKiraathaneShop();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(dialogProvider).showKiraathaneDialog, isFalse);
      expect(container.read(dialogProvider).showShopDialog, isTrue);

      notifier.closeShopDialog();
      await shopFuture;
      await kiraathaneFuture;
      await _waitForTurnEnd();
    });

    test('Vazgec closes Kiraathane and ends turn', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier.updateState(
        _stateFor(
          players: [
            _player(id: 'p1', akce: 5),
            _player(id: 'p2', color: Colors.blue),
          ],
        ),
      );

      final openFuture = notifier.openKiraathaneDialog();
      await Future<void>.delayed(Duration.zero);
      notifier.cancelKiraathane();
      await openFuture;
      await _waitForTurnEnd();

      final state = container.read(gameProvider);
      expect(container.read(dialogProvider).showKiraathaneDialog, isFalse);
      expect(state.currentPlayer.id, 'p2');
    });

    test('Mesk is rejected below 3 Akce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier
        ..updateState(_stateFor(players: [_player(akce: 2)]))
        ..debugSetCachedQuestions(_questionsFor(QuestionCategory.benKimim));

      await notifier.startMesk(QuestionCategory.benKimim);

      final state = container.read(gameProvider);
      expect(state.currentPlayer.akce, 2);
      expect(container.read(dialogProvider).showQuestionDialog, isFalse);
      expect(_logsContaining(state, 'yeterli Akçe'), isNotEmpty);
    });

    test('starting Mesk subtracts exactly 3 Akce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier
        ..updateState(_stateFor(players: [_player(akce: 7)]))
        ..debugSetCachedQuestions(_questionsFor(QuestionCategory.benKimim));

      final meskFuture = notifier.startMesk(QuestionCategory.benKimim);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(gameProvider).currentPlayer.akce,
        7 - GameConstants.meskCostAkce,
      );

      await notifier.answerQuestion(false);
      await meskFuture;
      await _waitForTurnEnd();
    });

    test('Mesk category selection uses mastery-based difficulty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier
        ..updateState(
          _stateFor(
            players: [
              _player(
                akce: 5,
                categoryLevels: {
                  QuestionCategory.edebiSanatlar.name: MasteryLevel.cirak.value,
                },
              ),
            ],
          ),
        )
        ..debugSetCachedQuestions(
          _questionsFor(QuestionCategory.edebiSanatlar),
        );

      final meskFuture = notifier.startMesk(QuestionCategory.edebiSanatlar);
      await Future<void>.delayed(Duration.zero);

      final question = container.read(dialogProvider).currentQuestion;
      expect(question, isNotNull);
      expect(question!.category, QuestionCategory.edebiSanatlar);
      expect(question.difficulty, 'medium');

      await notifier.answerQuestion(false);
      await meskFuture;
      await _waitForTurnEnd();
    });

    test('correct Mesk answer increments category progress', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier
        ..updateState(_stateFor(players: [_player(akce: 5)]))
        ..debugSetCachedQuestions(_questionsFor(QuestionCategory.benKimim));

      final meskFuture = notifier.startMesk(QuestionCategory.benKimim);
      await Future<void>.delayed(Duration.zero);
      await notifier.answerQuestion(true);
      await meskFuture;
      await _waitForTurnEnd();

      final player = container.read(gameProvider).players.first;
      expect(
        player.categoryProgress[QuestionCategory.benKimim.name]!['easy'],
        1,
      );
    });

    test('correct Mesk answer can promote mastery', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier
        ..updateState(
          _stateFor(
            players: [
              _player(
                akce: 5,
                categoryProgress: {
                  QuestionCategory.benKimim.name: {'easy': 2},
                },
              ),
            ],
          ),
        )
        ..debugSetCachedQuestions(_questionsFor(QuestionCategory.benKimim));

      final meskFuture = notifier.startMesk(QuestionCategory.benKimim);
      await Future<void>.delayed(Duration.zero);
      await notifier.answerQuestion(true);
      await meskFuture;
      await _waitForTurnEnd();

      final player = container.read(gameProvider).players.first;
      expect(
        player.categoryLevels[QuestionCategory.benKimim.name],
        MasteryLevel.cirak.value,
      );
    });

    test(
      'correct Mesk answer gives no Akce reward and creates no ownership',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);
        notifier
          ..updateState(_stateFor(players: [_player(akce: 10)]))
          ..debugSetCachedQuestions(_questionsFor(QuestionCategory.benKimim));

        final meskFuture = notifier.startMesk(QuestionCategory.benKimim);
        await Future<void>.delayed(Duration.zero);
        await notifier.answerQuestion(true);
        await meskFuture;
        await _waitForTurnEnd();

        final state = container.read(gameProvider);
        expect(state.currentPlayer.akce, 10 - GameConstants.meskCostAkce);
        expect(state.bookOwnerships, isEmpty);
        expect(state.currentPlayer.collectedQuotes, isEmpty);
      },
    );

    test('correct Mesk answer triggers no royalty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );
      notifier
        ..updateState(
          _stateFor(
            currentTile: tile,
            players: [
              _player(id: 'p1', akce: 10),
              _player(id: 'p2', color: Colors.blue, akce: 1),
            ],
            bookOwnerships: {
              book.id: BookOwnership(
                bookId: book.id,
                ownerPlayerId: 'p2',
                level: BookLevel.cilt,
              ),
            },
          ),
        )
        ..debugSetCachedQuestions(_questionsFor(QuestionCategory.benKimim));

      final meskFuture = notifier.startMesk(QuestionCategory.benKimim);
      await Future<void>.delayed(Duration.zero);
      await notifier.answerQuestion(true);
      await meskFuture;
      await _waitForTurnEnd();

      final state = container.read(gameProvider);
      expect(state.players[0].akce, 10 - GameConstants.meskCostAkce);
      expect(state.players[1].akce, 1);
      expect(_logsContaining(state, 'Royalty'), isEmpty);
    });

    test('wrong Mesk answer adds no progress and gives no reward', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);
      notifier
        ..updateState(_stateFor(players: [_player(akce: 8)]))
        ..debugSetCachedQuestions(_questionsFor(QuestionCategory.benKimim));

      final meskFuture = notifier.startMesk(QuestionCategory.benKimim);
      await Future<void>.delayed(Duration.zero);
      await notifier.answerQuestion(false);
      await meskFuture;
      await _waitForTurnEnd();

      final player = container.read(gameProvider).players.first;
      expect(player.akce, 8 - GameConstants.meskCostAkce);
      expect(player.categoryProgress[QuestionCategory.benKimim.name], isNull);
    });
  });
}

Player _player({
  String id = 'p1',
  Color color = Colors.red,
  int akce = 0,
  Map<String, int> categoryLevels = const {},
  Map<String, Map<String, int>> categoryProgress = const {},
}) {
  return Player(
    id: id,
    name: 'Player $id',
    color: color,
    iconIndex: 0,
    stars: akce,
    categoryLevels: categoryLevels,
    categoryProgress: categoryProgress,
  );
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

List<Question> _questionsFor(QuestionCategory category) {
  return [
    _question(category, 'easy'),
    _question(category, 'medium'),
    _question(category, 'hard'),
  ];
}

Question _question(QuestionCategory category, String difficulty) {
  return Question(
    text: '${category.name}_$difficulty',
    options: const ['A', 'B', 'C', 'D'],
    correctIndex: 0,
    category: category,
    difficulty: difficulty,
  );
}

List<String> _logsContaining(GameState state, String text) {
  return state.logs.where((log) => log.contains(text)).toList();
}

Future<void> _waitForTurnEnd() {
  return Future<void>.delayed(
    const Duration(milliseconds: GameConstants.turnChangeDelay + 50),
  );
}
