import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/core/managers/audio_manager.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/game_cards.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/question.dart';
import 'package:literature_board_game/models/tile_type.dart';
import 'package:literature_board_game/providers/dialog_provider.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

/// Turn-flow integrity regression tests.
///
/// - P0: a double roll landing on the Library must produce exactly one
///   turn transition (the library close owns it; the CASE B fallback used
///   to stomp the in-flight transition and advance twice).
/// - P1: bare `endTurn()` calls made inside a held processing scope
///   (empty question pools, corner/collection tiles, bot question/card/
///   kıraathane paths) must defer to the scope's release instead of
///   no-oping and stranding the turn.
/// - P1: bot card movement must resolve the destination tile like the
///   human flow.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AudioManager.debugSfxHandler = (_) {};

  // Question selection measures candidates with a Google Fonts style
  // (QuestionLineEstimator); fonts are not bundled in the test config, so —
  // like the board golden test — allow fetching but route it to a client
  // that never completes: no unhandled async errors, no timers, no network.
  GoogleFonts.config.allowRuntimeFetching = true;
  HttpOverrides.global = _NeverCompletingHttpOverrides();
  final fontCacheDir = Directory.systemTemp.createTempSync(
    'lbg_google_fonts_integrity_',
  );
  const pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  const audioPlayersGlobalChannel = MethodChannel(
    'xyz.luan/audioplayers.global',
  );
  const audioPlayersChannel = MethodChannel('xyz.luan/audioplayers');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
        if (methodCall.method == 'getApplicationSupportDirectory') {
          return fontCacheDir.path;
        }
        return null;
      });
  void mockChannel(MethodChannel channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async => null);
  }
  mockChannel(audioPlayersGlobalChannel);
  mockChannel(audioPlayersChannel);
  tearDownAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioPlayersGlobalChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioPlayersChannel, null);
    if (fontCacheDir.existsSync()) {
      fontCacheDir.deleteSync(recursive: true);
    }
  });

  Player player(String id, {int position = 0, Color color = Colors.red}) =>
      Player(
        id: id,
        name: 'Player $id',
        color: color,
        iconIndex: 0,
        position: position,
      );

  final forwardCard = GameCards.sansCards.firstWhere(
    (card) => card.effectType == CardEffectType.moveRelative,
  );

  final printerCard = GameCards.kaderCards.firstWhere(
    (card) =>
        card.effectType == CardEffectType.skipTurn &&
        card.description.contains('Mürekkep'),
  );

  /// Counts completed turn transitions: endTurn logs exactly one of
  /// "Sıra X oyuncusunda." / "X cezalı! Tur atlanıyor." per transition
  /// (the re-roll branch logs a different sentence).
  int transitionCount(GameState state) => state.logs
      .where((log) => log.contains(' oyuncusunda.') || log.contains('cezalı!'))
      .length;

  group('P0: double roll landing on Library', () {
    test('human path: exactly one turn transition', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: [
            player('p1', position: 17),
            player('p2', color: Colors.blue),
            player('p3', color: Colors.green),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          phase: GamePhase.playerTurn,
        ),
      );

      // Double roll of 4 from tile 17 lands exactly on Library (21).
      final future = notifier.handleMovementRollForTest(2, 2, 4, true);

      // 1500ms roll delay + 4 hops x 450ms.
      await Future.delayed(const Duration(milliseconds: 3600));
      expect(
        container.read(dialogProvider).showLibraryPenaltyDialog,
        isTrue,
        reason: 'library penalty dialog must be open after the move',
      );

      // A rapid roll while the result is resolving must be rejected.
      await notifier.rollDice();
      expect(container.read(gameProvider).isDiceRolling, isFalse);
      expect(
        container.read(dialogProvider).showLibraryPenaltyDialog,
        isTrue,
      );

      // Dismiss exactly as a human would via the dialog button.
      notifier.closeLibraryPenaltyDialog();
      await future;
      await Future.delayed(const Duration(milliseconds: 1400));

      final state = container.read(gameProvider);
      expect(state.currentPlayerIndex, 1, reason: 'turn advances exactly once');
      expect(transitionCount(state), 1);
      expect(state.players[0].position, BoardConfig.libraryPosition);
      expect(state.players[0].turnsToSkip, GameConstants.jailTurns);
      expect(state.players[1].turnsToSkip, 0);
      expect(state.players[2].turnsToSkip, 0);
      expect(state.isDiceRolled, isFalse);
      expect(notifier.isProcessing, isFalse);
    });

    test('bot path: exactly one turn transition', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        final notifier = container.read(gameProvider.notifier);

        notifier.updateState(
          GameState(
            players: [
              player('p1', position: 17),
              player('p2', color: Colors.blue),
              player('p3', color: Colors.green),
            ],
            tiles: BoardConfig.tiles,
            currentPlayerIndex: 0,
            phase: GamePhase.playerTurn,
          ),
        );
        notifier.debugActivateBotWithoutScheduling();

        final future = notifier.handleMovementRollForTest(2, 2, 4, true);
        // Bot pacing: 300ms roll delay + 4x50ms hops, library close timer
        // 300ms, turn change 200ms. 1600ms stays before the next bot roll.
        async.elapse(const Duration(milliseconds: 1600));

        final state = container.read(gameProvider);
        expect(state.currentPlayerIndex, 1, reason: 'turn advances exactly once');
        expect(transitionCount(state), 1);
        expect(state.players[0].position, BoardConfig.libraryPosition);
        expect(state.players[0].turnsToSkip, GameConstants.jailTurns);
        expect(state.isDiceRolled, isFalse);
        expect(notifier.isProcessing, isFalse);
        expect(container.read(dialogProvider).showLibraryPenaltyDialog,
            isFalse);

        container.dispose();
        // Keep the future observable so failures surface.
        future.ignore();
      });
    });
  });

  group('P1: bare endTurn() paths inside a held scope', () {
    test('human landing with no questions available still advances', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: [
            player('p1', position: 14),
            player('p2', color: Colors.blue),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          phase: GamePhase.playerTurn,
        ),
      );
      // Empty question pool -> noQuestionsFound fallback.
      notifier.debugSetCachedQuestions(const []);

      await notifier.handleMovementRollForTest(1, 3, 4, false);
      await Future.delayed(const Duration(milliseconds: 1400));

      final state = container.read(gameProvider);
      expect(state.currentPlayerIndex, 1);
      expect(transitionCount(state), 1);
      expect(notifier.isProcessing, isFalse);
      expect(state.isDiceRolled, isFalse);
    });

    test('chained teşvik fallback with empty pool defers and ends once',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: [
            player('p1', position: 15),
            player('p2', color: Colors.blue),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          phase: GamePhase.playerTurn,
        ),
      );
      notifier.debugSetCachedQuestions(const []);

      container.read(dialogProvider.notifier).showCard(forwardCard);
      notifier.closeCardDialog();

      // Card moves instantly 15 -> 16 (teşvik); chained arrival runs in a
      // microtask, awards the fallback bonus exactly once and ends the
      // turn through the deferred request on scope release.
      await Future.delayed(const Duration(milliseconds: 2500));

      final state = container.read(gameProvider);
      expect(state.players[0].position, 16);
      expect(state.players[0].stars, 5, reason: 'teşvik bonus applied once');
      expect(state.currentPlayerIndex, 1);
      expect(transitionCount(state), 1);
      expect(notifier.isProcessing, isFalse);
    });

    for (final type in [TileType.corner, TileType.collection]) {
      test('chained arrival on $type tile ends the turn exactly once',
          () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(gameProvider.notifier);

        // Synthetic board: tile 18 behaves as the (otherwise ungenerated)
        // corner/collection tile so the bare-endTurn path is reachable.
        final tiles = List<BoardTile>.from(BoardConfig.tiles);
        tiles[18] = tiles[18].copyWith(type: type);

        notifier.updateState(
          GameState(
            players: [
              player('p1', position: 17),
              player('p2', color: Colors.blue),
            ],
            tiles: tiles,
            currentPlayerIndex: 0,
            phase: GamePhase.playerTurn,
          ),
        );

        container.read(dialogProvider.notifier).showCard(forwardCard);
        notifier.closeCardDialog();

        await Future.delayed(const Duration(milliseconds: 2500));

        final state = container.read(gameProvider);
        expect(state.players[0].position, 18);
        expect(state.currentPlayerIndex, 1);
        expect(transitionCount(state), 1);
        expect(notifier.isProcessing, isFalse);
      });
    }

    test('bot landing on Kıraathane passes and advances exactly once', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        final notifier = container.read(gameProvider.notifier);

        notifier.updateState(
          GameState(
            players: [
              player('p1', position: 9),
              player('p2', color: Colors.blue),
            ],
            tiles: BoardConfig.tiles,
            currentPlayerIndex: 0,
            phase: GamePhase.playerTurn,
          ),
        );
        notifier.debugActivateBotWithoutScheduling();

        final future = notifier.handleMovementRollForTest(1, 3, 4, false);
        // 300ms delay + 4x50ms hops + 200ms turn change.
        async.elapse(const Duration(milliseconds: 1200));

        final state = container.read(gameProvider);
        expect(state.logs.any((log) => log.contains('pas geçildi')), isTrue);
        expect(state.currentPlayerIndex, 1);
        expect(transitionCount(state), 1);
        expect(notifier.isProcessing, isFalse);

        container.dispose();
        future.ignore();
      });
    });

    test('normal human question flow still advances exactly once', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      final destinationTile = BoardConfig.tiles[18];
      notifier.updateState(
        GameState(
          players: [
            player('p1', position: 14),
            player('p2', color: Colors.blue),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          phase: GamePhase.playerTurn,
        ),
      );
      notifier.debugSetCachedQuestions([
        Question(
          text: 'integrity normal flow question',
          options: const ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          category: QuestionCategory.values.firstWhere(
            (c) => c.name == destinationTile.category,
          ),
          difficulty: 'easy',
        ),
      ]);

      final future = notifier.handleMovementRollForTest(1, 3, 4, false);
      await Future.delayed(const Duration(milliseconds: 3600));
      expect(container.read(dialogProvider).showQuestionDialog, isTrue);

      await notifier.answerQuestion(true);
      await future;
      await Future.delayed(const Duration(milliseconds: 1400));

      final state = container.read(gameProvider);
      expect(state.currentPlayerIndex, 1);
      expect(transitionCount(state), 1);
      expect(notifier.isProcessing, isFalse);
      expect(state.isDiceRolled, isFalse);
    });
  });

  group('P1: bot card movement parity', () {
    test('movement card resolves the destination tile exactly once', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        final notifier = container.read(gameProvider.notifier);

        final destinationTile = BoardConfig.tiles[18];
        expect(destinationTile.type, TileType.category);
        expect(destinationTile.category, isNotNull);

        notifier.updateState(
          GameState(
            players: [
              player('p1', position: 12),
              player('p2', color: Colors.blue),
            ],
            tiles: BoardConfig.tiles,
            currentPlayerIndex: 0,
            phase: GamePhase.playerTurn,
          ),
        );
        notifier.debugSetCachedQuestions([
          Question(
            text: 'integrity bot card parity question',
            options: const ['A', 'B', 'C', 'D'],
            correctIndex: 0,
            category: QuestionCategory.values.firstWhere(
              (c) => c.name == destinationTile.category,
            ),
            difficulty: 'easy',
          ),
        ]);
        notifier.debugActivateBotWithoutScheduling();
        notifier.debugOverrideNextCard(forwardCard);

        // Non-double 5 from tile 12 lands on Şans (17); the overridden card
        // moves the bot +1 to the category tile at 18.
        final future = notifier.handleMovementRollForTest(2, 3, 5, false);
        // 300 + 5x50 hops + 100 card + 500 question + 200 turn change.
        async.elapse(const Duration(milliseconds: 1600));

        final state = container.read(gameProvider);
        expect(state.players[0].position, 18);
        expect(
          state.logs
              .where((log) => log.contains('Soru cevaplandı'))
              .length,
          1,
          reason: 'destination tile event executed exactly once',
        );
        expect(state.currentPlayerIndex, 1);
        expect(transitionCount(state), 1);
        expect(notifier.isProcessing, isFalse);

        container.dispose();
        future.ignore();
      });
    });

    test('roll-again card keeps the bot rolling the same player', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        final notifier = container.read(gameProvider.notifier);

        notifier.updateState(
          GameState(
            players: [
              player('p1', position: 12),
              player('p2', color: Colors.blue),
            ],
            tiles: BoardConfig.tiles,
            currentPlayerIndex: 0,
            phase: GamePhase.playerTurn,
          ),
        );
        notifier.debugSetCachedQuestions(const []);
        notifier.debugActivateBotWithoutScheduling();
        notifier.debugOverrideNextCard(
          GameCards.sansCards.firstWhere(
            (card) => card.effectType == CardEffectType.rollAgain,
          ),
        );

        notifier.handleMovementRollForTest(2, 3, 5, false).ignore();
        // 300 + 250 hops + 100 card, scheduler 800ms, bot dice 500ms.
        async.elapse(const Duration(milliseconds: 2200));

        final state = container.read(gameProvider);
        expect(
          state.logs.any((log) => log.contains('tekrar zar atıyor')),
          isTrue,
          reason: 'roll-again card must arrange a re-roll',
        );
        // Dice-result log lines have the form "N (d-d) ..." — matched by
        // regex because the tail of that log string is mojibake-corrupted
        // in the source ("attÄ±").
        expect(
          state.logs
              .where((log) => RegExp(r'\d+ \(\d-\d\) ').hasMatch(log))
              .length,
          greaterThanOrEqualTo(2),
          reason: 'the same player must roll again',
        );
        expect(state.currentPlayerIndex, 0);
        expect(transitionCount(state), 0);

        container.dispose();
      });
    });
  });

  group('printer-issue card turn ownership', () {
    test('human: printer dialog close owns the single transition', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: [
            player('p1'),
            player('p2', color: Colors.blue),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          phase: GamePhase.playerTurn,
        ),
      );

      container.read(dialogProvider.notifier).showCard(printerCard);
      notifier.closeCardDialog();

      // The card dialog must NOT advance the turn — the printer dialog
      // applies the skip penalty on close and owns the transition.
      expect(container.read(gameProvider).currentPlayerIndex, 0);
      expect(
        container.read(dialogProvider).showPrinterIssueDialog,
        isTrue,
      );

      notifier.closePrinterIssueDialog();
      await Future.delayed(const Duration(milliseconds: 1400));

      final state = container.read(gameProvider);
      expect(state.currentPlayerIndex, 1);
      expect(transitionCount(state), 1);
      expect(state.players[0].turnsToSkip, 1,
          reason: 'skip lands on the player who drew the card');
      expect(state.players[1].turnsToSkip, 0);
      expect(notifier.isProcessing, isFalse);
    });

    test('bot: printer card closes the dialog and penalises the drawer', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        final notifier = container.read(gameProvider.notifier);

        notifier.updateState(
          GameState(
            players: [
              player('p1', position: 12),
              player('p2', color: Colors.blue),
            ],
            tiles: BoardConfig.tiles,
            currentPlayerIndex: 0,
            phase: GamePhase.playerTurn,
          ),
        );
        notifier.debugSetCachedQuestions(const []);
        notifier.debugActivateBotWithoutScheduling();
        notifier.debugOverrideNextCard(printerCard);

        notifier.handleMovementRollForTest(2, 3, 5, false).ignore();
        // 300 + 250 hops + 100 card + 500 printer close + 200 turn change.
        async.elapse(const Duration(milliseconds: 1600));

        final state = container.read(gameProvider);
        expect(state.players[0].turnsToSkip, 1);
        expect(state.players[1].turnsToSkip, 0);
        expect(state.currentPlayerIndex, 1);
        expect(transitionCount(state), 1);
        expect(
          container.read(dialogProvider).showPrinterIssueDialog,
          isFalse,
        );
        expect(notifier.isProcessing, isFalse);

        container.dispose();
      });
    });
  });

  group('bot integration', () {
    test('random bot game keeps cycling turns (no freeze)', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        final notifier = container.read(gameProvider.notifier);

        notifier.updateState(
          GameState(
            players: [
              player('p1'),
              player('p2', color: Colors.blue),
              player('p3', color: Colors.green),
            ],
            tiles: BoardConfig.tiles,
            currentPlayerIndex: 0,
            phase: GamePhase.playerTurn,
          ),
        );
        notifier.debugSetCachedQuestions(const []);

        notifier.toggleBotMode();
        async.elapse(const Duration(seconds: 60));

        final state = container.read(gameProvider);
        expect(
          transitionCount(state),
          greaterThanOrEqualTo(3),
          reason: 'bot mode must not freeze after the first tile event '
              '(regression: endTurn no-op inside processing scope)',
        );
        for (final p in state.players) {
          expect(
            state.logs.any(
              (log) => RegExp('${p.name} \\d+ \\(\\d-\\d\\) ').hasMatch(log),
            ),
            isTrue,
            reason: '${p.name} must get to roll',
          );
        }

        container.dispose();
      });
    });
  });
}

class _NeverCompletingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _NeverCompletingHttpClient();
}

/// An [HttpClient] whose requests never complete (see the board golden test
/// for the rationale: hanging requests create no sockets, no timers and no
/// unhandled errors).
class _NeverCompletingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) {
      return Completer<HttpClientRequest>().future;
    }
    return null;
  }
}
