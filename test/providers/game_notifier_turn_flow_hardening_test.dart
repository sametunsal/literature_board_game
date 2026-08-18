import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:literature_board_game/core/managers/audio_manager.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/game_cards.dart';
import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/question.dart';
import 'package:literature_board_game/models/tile_type.dart';
import 'package:literature_board_game/providers/dialog_provider.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

/// Regression tests for the P0-3/P1-1 turn-flow hardening:
/// - rollDice must not start while a previous roll's result is resolving.
/// - A card-induced (chained) tile arrival owns the processing lock until
///   the destination tile event finishes — the outer dice-roll `finally`
///   blocks must not re-open a rapid-tap window mid-event.
/// - endTurn's turn-change scope must survive stale `finally` clears from
///   the movement flow that unwinds underneath it.
/// - closeCardDialog must recover (complete its completer, release locks,
///   end the turn) when applying a card effect throws.
void main() {
  // The exercised flows play SFX through AudioManager, which needs a
  // binding; route SFX to a no-op handler to keep tests quiet and fast.
  TestWidgetsFlutterBinding.ensureInitialized();
  AudioManager.debugSfxHandler = (_) {};

  // Question selection measures candidates with a Google Fonts style
  // (QuestionLineEstimator). Fonts are not bundled in the test config, so —
  // like the board golden test — allow fetching but route it to a client
  // that never completes: no unhandled async errors, no timers, no network.
  GoogleFonts.config.allowRuntimeFetching = true;
  HttpOverrides.global = _NeverCompletingHttpOverrides();
  final fontCacheDir = Directory.systemTemp.createTempSync(
    'literature_board_game_google_fonts_hardening_',
  );
  const pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
        if (methodCall.method == 'getApplicationSupportDirectory') {
          return fontCacheDir.path;
        }
        return null;
      });
  // Movement lazily constructs AudioManager, whose AudioPlayer constructor
  // awaits audioplayers' global-scope init channel; without this mock that
  // surfaces as an unhandled async MissingPluginException.
  const audioPlayersGlobalChannel = MethodChannel(
    'xyz.luan/audioplayers.global',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(audioPlayersGlobalChannel, (methodCall) async {
        return null;
      });
  const audioPlayersChannel = MethodChannel('xyz.luan/audioplayers');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(audioPlayersChannel, (methodCall) async {
        return null;
      });
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

  group('rollDice guards', () {
    test('rejected while the previous roll result is still resolving',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: [player('p1'), player('p2', color: Colors.blue)],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          dice1: 3,
          dice2: 4,
          diceTotal: 7,
          isDiceRolled: true,
          phase: GamePhase.playerTurn,
        ),
      );

      await notifier.rollDice();
      await Future.delayed(const Duration(milliseconds: 20));

      final state = container.read(gameProvider);
      expect(state.isDiceRolling, isFalse);
      expect(state.dice1, 3);
      expect(state.dice2, 4);
      expect(state.diceTotal, 7);
      expect(state.currentPlayerIndex, 0);
      expect(notifier.isProcessing, isFalse);
    });
  });

  group('chained card-movement tile arrival', () {
    test('keeps the turn locked until the destination tile event resolves',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      final destinationTile = BoardConfig.tiles[18];
      expect(destinationTile.type, TileType.category);
      expect(destinationTile.category, isNotNull);

      notifier.updateState(
        GameState(
          players: [
            player('p1', position: 17),
            player('p2', color: Colors.blue),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          phase: GamePhase.playerTurn,
        ),
      );

      notifier.debugSetCachedQuestions([
        Question(
          text: 'hardening chained arrival question',
          options: const ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          category: QuestionCategory.values.firstWhere(
            (c) => c.name == destinationTile.category,
          ),
          difficulty: 'easy',
        ),
      ]);

      final forwardCard = GameCards.sansCards.firstWhere(
        (card) => card.effectType == CardEffectType.moveRelative,
      );
      container.read(dialogProvider.notifier).showCard(forwardCard);

      notifier.closeCardDialog();

      // The card moved the pawn instantly; the chained tile event (a
      // question) now owns the turn while its dialog is open.
      await Future.delayed(const Duration(milliseconds: 300));
      final midState = container.read(gameProvider);
      expect(midState.currentPlayer.position, 18);
      expect(container.read(dialogProvider).showQuestionDialog, isTrue);
      // Locked while the chained event resolves — the old implementation
      // cleared _isProcessing here, leaving a rapid-tap window.
      expect(notifier.isProcessing, isTrue);

      // A roll attempt during the window must be rejected.
      await notifier.rollDice();
      expect(container.read(gameProvider).isDiceRolling, isFalse);
      expect(container.read(dialogProvider).showQuestionDialog, isTrue);

      // Answering completes the chained event and advances the turn.
      await notifier.answerQuestion(true);
      expect(container.read(dialogProvider).showQuestionDialog, isFalse);

      await Future.delayed(const Duration(milliseconds: 1500));
      final endState = container.read(gameProvider);
      expect(endState.currentPlayerIndex, 1);
      expect(notifier.isProcessing, isFalse);
    });

    test('keeps the turn locked through a chained start-tile landing',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: [
            player('p1', position: BoardConfig.boardSize - 1),
            player('p2', color: Colors.blue),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          phase: GamePhase.playerTurn,
        ),
      );

      final forwardCard = GameCards.sansCards.firstWhere(
        (card) => card.effectType == CardEffectType.moveRelative,
      );
      container.read(dialogProvider.notifier).showCard(forwardCard);

      notifier.closeCardDialog();

      // Start-tile landing holds the lock for its message delay before it
      // ends the turn. The old implementation was unlocked during this
      // window (card wrap bonus +5, then start salary +20).
      await Future.delayed(const Duration(milliseconds: 300));
      expect(container.read(gameProvider).currentPlayer.position, 0);
      expect(notifier.isProcessing, isTrue);

      await Future.delayed(const Duration(milliseconds: 3000));
      final endState = container.read(gameProvider);
      expect(endState.currentPlayerIndex, 1);
      expect(endState.players[0].stars, 25);
      expect(notifier.isProcessing, isFalse);
    });
  });

  group('processing scope survives stale clears', () {
    test(
        'movement-flow finally cannot unlock the turn-change window (start landing)',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: [
            player('p1', position: 22),
            player('p2', color: Colors.blue),
          ],
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
          phase: GamePhase.playerTurn,
        ),
      );

      // Non-double roll of 4 from tile 22 lands exactly on Start (0).
      final future = notifier.handleMovementRollForTest(1, 3, 4, false);
      await future;

      // The dice/movement flow has fully unwound by now and its finally
      // blocks have run — but endTurn's scope must survive them. The old
      // unconditional clears re-opened a rapid-tap window for the whole
      // turn-change delay.
      expect(notifier.isProcessing, isTrue);

      await Future.delayed(const Duration(milliseconds: 1500));
      final state = container.read(gameProvider);
      expect(state.currentPlayerIndex, 1);
      expect(state.isDiceRolled, isFalse);
      expect(notifier.isProcessing, isFalse);
      // Start landing salary (+20) went to the player who earned it; no
      // passing-start bonus is awarded when Start is the destination.
      expect(state.players[0].stars, 20);
    });
  });

  group('closeCardDialog failure recovery', () {
    test('recovers and releases locks when applying the effect throws',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: [player('p1'), player('p2', color: Colors.blue)],
          tiles: BoardConfig.tiles,
          // Out-of-range index makes CardEffectService.apply throw.
          currentPlayerIndex: 5,
          phase: GamePhase.playerTurn,
        ),
      );

      final card = GameCards.sansCards.firstWhere(
        (card) => card.effectType == CardEffectType.moneyChange,
      );
      container.read(dialogProvider.notifier).showCard(card);

      notifier.closeCardDialog();

      final state = container.read(gameProvider);
      expect(container.read(dialogProvider).showCardDialog, isFalse);
      expect(notifier.isProcessing, isFalse);
      expect(
        state.logs.any((log) => log.contains('hata oluştu')),
        isTrue,
      );
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
