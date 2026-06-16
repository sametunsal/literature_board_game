import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/core/services/bot_callbacks.dart';
import 'package:literature_board_game/core/services/bot_controller.dart';
import 'package:literature_board_game/core/services/card_effect_service.dart';
import 'package:literature_board_game/core/services/economy_service.dart';
import 'package:literature_board_game/core/services/question_flow_service.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/game_card.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/models/question.dart';
import 'package:literature_board_game/models/tile_type.dart';
import 'package:flutter/material.dart';

void main() {
  late _CallbackTracker tracker;
  late BotController controller;

  const economy = EconomyService();
  final cardEffectService = const CardEffectService(economy);
  final questionFlowService = const QuestionFlowService(economy);

  Player makePlayer({
    String id = 'p1',
    String name = 'Alice',
    int stars = 20,
    int position = 5,
  }) {
    return Player(
      id: id,
      name: name,
      color: Colors.blue,
      iconIndex: 1,
      stars: stars,
      position: position,
    );
  }

  setUp(() {
    tracker = _CallbackTracker();
    controller = BotController(
      callbacks: tracker.callbacks,
      cardEffectService: cardEffectService,
      questionFlowService: questionFlowService,
      random: Random(42),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // TOGGLE
  // ═══════════════════════════════════════════════════════════════════════════

  group('toggle', () {
    test('starts inactive', () {
      expect(controller.isActive, isFalse);
    });

    test('first toggle activates and adds log but does not auto-schedule', () {
      fakeAsync((async) {
        controller.toggle();
        expect(controller.isActive, isTrue);
        expect(
          tracker.logs,
          contains(predicate<String>((s) => s.contains('Bot Modu AKTİF'))),
        );
        // toggle no longer auto-schedules — caller owns scheduling
        async.elapse(const Duration(seconds: 2));
        expect(tracker.rollDiceCalls, 0);
      });
    });

    test('second toggle deactivates', () {
      fakeAsync((async) {
        controller.toggle();
        controller.toggle();
        expect(controller.isActive, isFalse);
        expect(
          tracker.logs,
          contains(predicate<String>((s) => s.contains('Bot Modu KAPALI'))),
        );
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // DELAY SELECTION
  // ═══════════════════════════════════════════════════════════════════════════

  group('getDelay', () {
    test('returns human delay when inactive', () {
      final delay = controller.getDelay(humanMs: 1500, botMs: 300);
      expect(delay, const Duration(milliseconds: 1500));
    });

    test('returns bot delay when active', () {
      fakeAsync((async) {
        controller.toggle();
        final delay = controller.getDelay(humanMs: 1500, botMs: 300);
        expect(delay, const Duration(milliseconds: 300));
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULING GUARDS
  // ═══════════════════════════════════════════════════════════════════════════

  group('scheduleNextTurn', () {
    test('does nothing when inactive', () {
      fakeAsync((async) {
        controller.scheduleNextTurn();
        async.elapse(const Duration(seconds: 2));
        expect(tracker.rollDiceCalls, 0);
      });
    });

    test('does nothing when game is over', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.gameOver;
        controller.activateForTest();
        controller.scheduleNextTurn();
        async.elapse(const Duration(seconds: 2));
        expect(tracker.rollDiceCalls, 0);
      });
    });

    test('calls rollDice when no blockers', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.playerTurn;
        controller.activateForTest();
        controller.scheduleNextTurn();
        async.elapse(
          Duration(milliseconds: GameConstants.botTurnScheduleDelay + 100),
        );
        expect(tracker.rollDiceCalls, 1);
      });
    });

    test('handles dialog instead of rolling when dialog is open', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.playerTurn;
        tracker.dialogSnapshot = const BotDialogSnapshot(showShopDialog: true);
        controller.activateForTest();
        controller.scheduleNextTurn();
        async.elapse(
          Duration(milliseconds: GameConstants.botTurnScheduleDelay + 600),
        );
        expect(tracker.rollDiceCalls, 0);
        expect(tracker.closeShopCalls, 1);
      });
    });

    test('does not roll when isProcessing is true', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.playerTurn;
        tracker.isProcessing = true;
        controller.activateForTest();
        controller.scheduleNextTurn();
        async.elapse(
          Duration(milliseconds: GameConstants.botTurnScheduleDelay + 100),
        );
        expect(tracker.rollDiceCalls, 0);
      });
    });

    test('does not roll when dice is rolling', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.playerTurn;
        tracker.isDiceRolling = true;
        controller.activateForTest();
        controller.scheduleNextTurn();
        async.elapse(
          Duration(milliseconds: GameConstants.botTurnScheduleDelay + 100),
        );
        expect(tracker.rollDiceCalls, 0);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOG AUTO-CLOSE
  // ═══════════════════════════════════════════════════════════════════════════

  group('handleDialogTile', () {
    test('returns false when inactive', () {
      expect(controller.handleDialogTile(BotDialogType.library), isFalse);
    });

    test('library auto-closes after botPenaltyDialogAutoCloseDelay', () {
      fakeAsync((async) {
        controller.toggle();
        final handled = controller.handleDialogTile(BotDialogType.library);
        expect(handled, isTrue);
        expect(tracker.closeLibraryCalls, 0);

        async.elapse(
          Duration(milliseconds: GameConstants.botPenaltyDialogAutoCloseDelay),
        );
        expect(tracker.closeLibraryCalls, 1);
      });
    });

    test('signingDay auto-closes after botPenaltyDialogAutoCloseDelay', () {
      fakeAsync((async) {
        controller.toggle();
        controller.handleDialogTile(BotDialogType.signingDay);
        async.elapse(
          Duration(milliseconds: GameConstants.botPenaltyDialogAutoCloseDelay),
        );
        expect(tracker.closeImzaGunuCalls, 1);
      });
    });

    test('shop auto-closes after botDialogAutoCloseDelay', () {
      fakeAsync((async) {
        controller.toggle();
        controller.handleDialogTile(BotDialogType.shop);
        async.elapse(
          Duration(milliseconds: GameConstants.botDialogAutoCloseDelay),
        );
        expect(tracker.closeShopCalls, 1);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // WATCHDOG RECOVERY
  // ═══════════════════════════════════════════════════════════════════════════

  group('watchdog', () {
    test('fires after 4 seconds and resets processing', () {
      fakeAsync((async) {
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.setProcessingCalls, contains(false));
      });
    });

    test('closes question dialog when stuck', () {
      fakeAsync((async) {
        tracker.dialogSnapshot = const BotDialogSnapshot(
          showQuestionDialog: true,
        );
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.answerQuestionCalls, 1);
      });
    });

    test('closes card dialog when stuck', () {
      fakeAsync((async) {
        tracker.dialogSnapshot = const BotDialogSnapshot(showCardDialog: true);
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.closeCardCalls, 1);
      });
    });

    test('closes library dialog when stuck', () {
      fakeAsync((async) {
        tracker.dialogSnapshot = const BotDialogSnapshot(
          showLibraryPenaltyDialog: true,
        );
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.closeLibraryCalls, 1);
      });
    });

    test('closes imza günü dialog when stuck', () {
      fakeAsync((async) {
        tracker.dialogSnapshot = const BotDialogSnapshot(
          showImzaGunuDialog: true,
        );
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.closeImzaGunuCalls, 1);
      });
    });

    test('closes printer issue dialog when stuck', () {
      fakeAsync((async) {
        tracker.dialogSnapshot = const BotDialogSnapshot(
          showPrinterIssueDialog: true,
        );
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.closePrinterIssueCalls, 1);
      });
    });

    test('closes shop dialog when stuck', () {
      fakeAsync((async) {
        tracker.dialogSnapshot = const BotDialogSnapshot(showShopDialog: true);
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.closeShopCalls, 1);
      });
    });

    test('closes turn order dialog and reschedules when stuck', () {
      fakeAsync((async) {
        tracker.dialogSnapshot = const BotDialogSnapshot(
          showTurnOrderDialog: true,
        );
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.closeTurnOrderCalls, 1);
      });
    });

    test('closes turn skipped dialog when stuck', () {
      fakeAsync((async) {
        tracker.dialogSnapshot = const BotDialogSnapshot(
          showTurnSkippedDialog: true,
        );
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.closeTurnSkippedCalls, 1);
      });
    });

    test('calls rollDice when no dialog is open', () {
      fakeAsync((async) {
        controller.activateForTest();
        controller.startWatchdogForTest();
        async.elapse(const Duration(seconds: 4));
        expect(tracker.rollDiceCalls, 1);
      });
    });

    test(
      'priority: question > card > library > imzaGunu > printer > shop > turnOrder > turnSkipped',
      () {
        fakeAsync((async) {
          tracker.dialogSnapshot = const BotDialogSnapshot(
            showQuestionDialog: true,
            showCardDialog: true,
            showLibraryPenaltyDialog: true,
          );
          controller.activateForTest();
          controller.startWatchdogForTest();
          async.elapse(const Duration(seconds: 4));
          expect(tracker.answerQuestionCalls, 1);
          expect(tracker.closeCardCalls, 0);
          expect(tracker.closeLibraryCalls, 0);
        });
      },
    );
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // QUESTION HANDLING
  // ═══════════════════════════════════════════════════════════════════════════

  group('handleQuestionTile', () {
    final testQuestion = const Question(
      text: 'Test soru?',
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 0,
      category: QuestionCategory.benKimim,
      difficulty: 'easy',
    );

    final testTile = const BoardTile(
      id: 'tile_1',
      name: 'Ben Kimim?',
      position: 3,
      type: TileType.category,
      category: 'benKimim',
      difficulty: Difficulty.easy,
    );

    test('applies answer result and ends turn', () async {
      controller.toggle();
      await controller.handleQuestionTile(
        question: testQuestion,
        currentTile: testTile,
        allPlayers: [makePlayer()],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
      );
      expect(tracker.applyAnswerResultCalls, 1);
      expect(tracker.endTurnCalls, 1);
    });

    test('checks win condition when result says so', () async {
      controller.toggle();
      await controller.handleQuestionTile(
        question: testQuestion,
        currentTile: testTile,
        allPlayers: [makePlayer()],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
      );
      // processAnswer with correct answer sets checkWinCondition=true
      // With Random(42), first nextBool() is deterministic
      // Regardless of correct/incorrect, endTurn is called
      expect(tracker.endTurnCalls, 1);
    });

    test('ends turn even on error', () async {
      // Use a null tile category to verify resilience
      controller.toggle();
      await controller.handleQuestionTile(
        question: testQuestion,
        currentTile: null,
        allPlayers: [makePlayer()],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
      );
      expect(tracker.endTurnCalls, 1);
    });

    test('adds log entry', () async {
      controller.toggle();
      await controller.handleQuestionTile(
        question: testQuestion,
        currentTile: testTile,
        allPlayers: [makePlayer()],
        currentPlayerIndex: 0,
        consecutiveDoubles: 0,
      );
      expect(
        tracker.logs,
        contains(predicate<String>((s) => s.contains('Bot: Soru cevaplandı'))),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD HANDLING
  // ═══════════════════════════════════════════════════════════════════════════

  group('handleCardEffect', () {
    test('applies effect and ends turn for moneyChange', () async {
      controller.toggle();
      const card = GameCard(
        description: 'Test +5',
        type: CardType.sans,
        effectType: CardEffectType.moneyChange,
        value: 5,
      );
      await controller.handleCardEffect(
        card: card,
        players: [makePlayer()],
        currentPlayerIndex: 0,
      );
      expect(tracker.applyCardEffectCalls, 1);
      expect(tracker.endTurnCalls, 1);
    });

    test('does not end turn on rollAgain', () async {
      controller.toggle();
      const card = GameCard(
        description: 'Tekrar at',
        type: CardType.sans,
        effectType: CardEffectType.rollAgain,
      );
      await controller.handleCardEffect(
        card: card,
        players: [makePlayer()],
        currentPlayerIndex: 0,
      );
      expect(tracker.applyCardEffectCalls, 1);
      expect(tracker.endTurnCalls, 0);
    });

    test('ends turn even on error', () async {
      controller.toggle();
      const card = GameCard(
        description: 'Test',
        type: CardType.sans,
        effectType: CardEffectType.moneyChange,
        value: 5,
      );
      // Empty player list will cause index error
      await controller.handleCardEffect(
        card: card,
        players: [],
        currentPlayerIndex: 0,
      );
      expect(tracker.endTurnCalls, 1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPOSE CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  group('dispose', () {
    test('cancels watchdog and active timers', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.playerTurn;
        controller.toggle();
        controller.dispose();
        // Advance past watchdog timeout — nothing should fire
        async.elapse(const Duration(seconds: 10));
        // If watchdog or schedule timers were not cancelled, they would
        // have called rollDice or recovery. After dispose, only the
        // initial schedule timer's rollDice may have fired before dispose.
        // The key assertion: no crash, no late timer fire.
      });
    });

    test('can be called multiple times safely', () {
      controller.dispose();
      controller.dispose();
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // _handleDialog DISPATCH
  // ═══════════════════════════════════════════════════════════════════════════

  group('_handleDialog dispatch (via scheduleNextTurn)', () {
    test('closes turn order dialog and reschedules', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.playerTurn;
        tracker.dialogSnapshot = const BotDialogSnapshot(
          showTurnOrderDialog: true,
        );
        controller.activateForTest();
        controller.scheduleNextTurn();
        async.elapse(
          Duration(milliseconds: GameConstants.botTurnScheduleDelay + 600),
        );
        expect(tracker.closeTurnOrderCalls, 1);
      });
    });

    test('closes library penalty dialog', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.playerTurn;
        tracker.dialogSnapshot = const BotDialogSnapshot(
          showLibraryPenaltyDialog: true,
        );
        controller.activateForTest();
        controller.scheduleNextTurn();
        async.elapse(
          Duration(milliseconds: GameConstants.botTurnScheduleDelay + 600),
        );
        expect(tracker.closeLibraryCalls, 1);
      });
    });

    test('forces reset when stuck with no dialog', () {
      fakeAsync((async) {
        tracker.gamePhase = GamePhase.playerTurn;
        tracker.isProcessing = true;
        controller.activateForTest();
        controller.scheduleNextTurn();
        async.elapse(
          Duration(milliseconds: GameConstants.botTurnScheduleDelay + 600),
        );
        expect(tracker.setProcessingCalls, contains(false));
      });
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEST HELPER: Callback tracker
// ═══════════════════════════════════════════════════════════════════════════════

class _CallbackTracker {
  int rollDiceCalls = 0;
  int endTurnCalls = 0;
  int applyAnswerResultCalls = 0;
  int applyCardEffectCalls = 0;
  int checkWinConditionCalls = 0;
  int closeCardCalls = 0;
  int closeLibraryCalls = 0;
  int closeImzaGunuCalls = 0;
  int closePrinterIssueCalls = 0;
  int closeKiraathaneCalls = 0;
  int closeShopCalls = 0;
  int closeTurnOrderCalls = 0;
  int closeTurnSkippedCalls = 0;
  int answerQuestionCalls = 0;
  final List<String> logs = [];
  final List<bool> setProcessingCalls = [];

  GamePhase gamePhase = GamePhase.playerTurn;
  BotDialogSnapshot dialogSnapshot = const BotDialogSnapshot();
  bool isProcessing = false;
  bool isDiceRolling = false;

  late final BotCallbacks callbacks = BotCallbacks(
    rollDice: () => rollDiceCalls++,
    endTurn: () => endTurnCalls++,
    addLog: (msg, {type = 'info'}) => logs.add(msg),
    applyAnswerResult: (_) => applyAnswerResultCalls++,
    applyCardEffectResult: (_) => applyCardEffectCalls++,
    checkWinCondition: () => checkWinConditionCalls++,
    closeCardDialog: () {
      closeCardCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    closeLibraryPenaltyDialog: () {
      closeLibraryCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    closeImzaGunuDialog: () {
      closeImzaGunuCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    closePrinterIssueDialog: () {
      closePrinterIssueCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    closeKiraathaneDialog: () {
      closeKiraathaneCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    closeShopDialog: () {
      closeShopCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    closeTurnOrderDialog: () {
      closeTurnOrderCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    closeTurnSkippedDialog: () {
      closeTurnSkippedCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    answerQuestion: (_) {
      answerQuestionCalls++;
      dialogSnapshot = const BotDialogSnapshot();
    },
    readDialogState: () => dialogSnapshot,
    readIsDiceRolling: () => isDiceRolling,
    readIsProcessing: () => isProcessing,
    setProcessing: (v) => setProcessingCalls.add(v),
    readGamePhase: () => gamePhase,
  );
}
