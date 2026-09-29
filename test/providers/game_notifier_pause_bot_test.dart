import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:literature_board_game/core/services/bot_callbacks.dart';
import 'package:literature_board_game/core/services/bot_controller.dart';
import 'package:literature_board_game/core/services/card_effect_service.dart';
import 'package:literature_board_game/core/services/economy_service.dart';
import 'package:literature_board_game/core/services/question_flow_service.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

/// Pause × bot safety: while the game is paused, bot timers (turn schedule,
/// dialog auto-close) and both watchdogs must not advance or mutate the
/// game. After resume, the scheduled bot turn continues; a bot disabled
/// during pause must not restart; game-over still stops the bot.
void main() {
  // The resumed bot path plays real SFX through AudioManager. Constructing
  // its players kicks off audioplayers' global init, which would surface as
  // an unhandled MissingPluginException in a plain test; answer that channel
  // with a no-op mock (per-call SFX failures are already swallowed by
  // playSfx's try/catch).
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final channel in const [
    'xyz.luan/audioplayers.global',
    'xyz.luan/audioplayers',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      MethodChannel(channel),
      (call) async => null,
    );
  }

  late ProviderContainer container;
  late GameNotifier notifier;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        gameProvider.overrideWith((ref) {
          final notifier = GameNotifier(ref);
          notifier.updateState(_initialState());
          return notifier;
        }),
      ],
    );
    notifier = container.read(gameProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  /// Stops the bot, ends the game and lets any in-flight bot flow (dice /
  /// movement / turn-change delays) drain against the disabled-bot and
  /// game-over guards, so nothing touches the notifier after dispose.
  Future<void> quietDown() async {
    notifier.toggleBotMode(); // disable (cancels timers, resets flags)
    if (container.read(gameProvider).isGamePaused) {
      notifier.resumeGame();
    }
    notifier.updateState(
      container.read(gameProvider).copyWith(phase: GamePhase.gameOver),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  test('TEST 1: bot turn timer fires while paused - game does not advance', () async {
    notifier.toggleBotMode(); // activates + schedules the 800ms turn timer
    notifier.pauseGame();

    // Timer deadline passes while paused.
    await Future.delayed(const Duration(milliseconds: 1400));

    final state = container.read(gameProvider);
    expect(state.isDiceRolling, isFalse, reason: 'dice started while paused');
    expect(state.isDiceRolled, isFalse, reason: 'roll resolved while paused');
    expect(state.currentPlayerIndex, 0, reason: 'turn advanced while paused');
    expect(state.phase, GamePhase.playerTurn);

    await quietDown();
  });

  test('TEST 2: bot dialog auto-close timer must not end the turn while paused', () async {
    notifier.toggleBotMode();
    notifier.pauseGame();

    // Land the (current) player on the Library tile in bot mode: the bot
    // path arms a 300ms auto-close timer for the penalty dialog, whose
    // close callback applies the penalty bookkeeping AND ends the turn.
    notifier.debugJumpCurrentPlayerToPosition(BoardConfig.libraryPosition);
    await notifier.debugTriggerCurrentTile();

    await Future.delayed(const Duration(milliseconds: 800));

    final state = container.read(gameProvider);
    expect(
      state.currentPlayerIndex,
      0,
      reason: 'dialog auto-close ended the turn while paused',
    );
    expect(state.phase, GamePhase.playerTurn);

    await quietDown();
  });

  test('TEST 3: pause -> resume - bot continues its scheduled turn', () async {
    notifier.toggleBotMode();
    notifier.pauseGame();

    // Let the scheduled timer fire while paused (it parks on the pause poll).
    await Future.delayed(const Duration(milliseconds: 900));

    final before = container.read(gameProvider);
    expect(before.isDiceRolled, isFalse);

    notifier.resumeGame();

    // Poll wakeup (<=500ms) + rollDice + dice animation (500ms) + movement.
    await Future.delayed(const Duration(milliseconds: 1600));

    final state = container.read(gameProvider);
    final progressed =
        state.isDiceRolled ||
        state.isDiceRolling ||
        state.currentPlayerIndex != 0 ||
        state.players[0].position != 0;
    expect(progressed, isTrue, reason: 'bot did not continue after resume');

    await quietDown();
  });

  test('TEST 4: pause -> disable bot -> resume - bot must not restart', () async {
    notifier.toggleBotMode();
    notifier.pauseGame();

    await Future.delayed(const Duration(milliseconds: 900));

    notifier.toggleBotMode(); // disable while paused
    notifier.resumeGame();

    await Future.delayed(const Duration(milliseconds: 1200));

    final state = container.read(gameProvider);
    expect(state.isDiceRolling, isFalse);
    expect(state.isDiceRolled, isFalse);
    expect(state.currentPlayerIndex, 0);
    expect(state.players[0].position, 0);
  });

  test('TEST 5: pending bot timer does not start a turn after game over', () async {
    notifier.toggleBotMode(); // schedules the 800ms turn timer

    notifier.updateState(
      container.read(gameProvider).copyWith(phase: GamePhase.gameOver),
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    final state = container.read(gameProvider);
    expect(state.isDiceRolling, isFalse);
    expect(state.isDiceRolled, isFalse);
  });

  test('BotController watchdog performs no recovery while paused', () {
    fakeAsync((async) {
      var paused = true;
      var rollDiceCalls = 0;
      var setProcessingCalls = 0;

      const economy = EconomyService();
      final callbacks = BotCallbacks(
        rollDice: () => rollDiceCalls++,
        endTurn: () {},
        addLog: (_, {type = 'info'}) {},
        applyAnswerResult: (_) {},
        applyCardEffectResult: (_) {},
        checkWinCondition: () {},
        closeCardDialog: () {},
        closeLibraryPenaltyDialog: () {},
        closeImzaGunuDialog: () {},
        closePrinterIssueDialog: () {},
        closeKiraathaneDialog: () {},
        closeShopDialog: () {},
        closeTurnOrderDialog: () {},
        closeTurnSkippedDialog: () {},
        closeThreeDoublesWarning: () {},
        answerQuestion: (_) {},
        readDialogState: () => const BotDialogSnapshot(),
        readIsDiceRolling: () => false,
        readIsProcessing: () => false,
        setProcessing: (v) => setProcessingCalls++,
        readGamePhase: () => GamePhase.playerTurn,
        readIsPaused: () => paused,
      );
      final controller = BotController(
        callbacks: callbacks,
        cardEffectService: const CardEffectService(economy),
        questionFlowService: const QuestionFlowService(economy),
      );

      controller.toggle(); // activate
      controller.startWatchdogForTest();

      async.elapse(const Duration(seconds: 5));
      expect(rollDiceCalls, 0, reason: 'watchdog rolled while paused');
      expect(setProcessingCalls, 0, reason: 'watchdog reset lock while paused');

      paused = false;
      controller.dispose();
    });
  });
}

GameState _initialState() {
  return GameState(
    players: const [
      Player(id: 'p1', name: 'Player 1', color: Colors.red, iconIndex: 0),
      Player(id: 'p2', name: 'Player 2', color: Colors.blue, iconIndex: 1),
    ],
    tiles: BoardConfig.tiles,
    phase: GamePhase.playerTurn,
  );
}
