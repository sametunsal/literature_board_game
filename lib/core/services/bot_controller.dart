import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../../models/board_tile.dart';
import '../../models/difficulty.dart';
import '../../models/game_card.dart';
import '../../models/game_enums.dart';
import '../../models/player.dart';
import '../../models/question.dart';
import '../constants/game_constants.dart';
import '../utils/logger.dart';
import 'bot_callbacks.dart';
import 'card_effect_service.dart';
import 'question_flow_service.dart';

class BotController {
  final BotCallbacks _cb;
  final CardEffectService _cardEffectService;
  final QuestionFlowService _questionFlowService;
  final Random _random;

  bool _isActive = false;
  bool get isActive => _isActive;

  Timer? _watchdog;
  final List<Timer> _activeTimers = [];

  BotController({
    required BotCallbacks callbacks,
    required CardEffectService cardEffectService,
    required QuestionFlowService questionFlowService,
    Random? random,
  })  : _cb = callbacks,
        _cardEffectService = cardEffectService,
        _questionFlowService = questionFlowService,
        _random = random ?? Random();

  @visibleForTesting
  void activateForTest() {
    _isActive = true;
  }

  @visibleForTesting
  void startWatchdogForTest() {
    _startWatchdog();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════════════

  /// Flip bot state and emit logs. Does NOT auto-schedule — the caller
  /// is responsible for triggering the first turn (e.g. via its own
  /// scheduling method). This keeps scheduling ownership with a single
  /// system during the GameNotifier transition period.
  bool toggle() {
    _isActive = !_isActive;
    if (_isActive) {
      _cb.addLog('🤖 Bot Modu AKTİF! Oyun otomatik oynanıyor...', type: 'info');
      log('=== BOT MODE ACTIVATED ===');
    } else {
      _cb.addLog('🤖 Bot Modu KAPALI. Manuel oynamaya dönüldü.', type: 'info');
      log('=== BOT MODE DEACTIVATED ===');
      _cancelWatchdog();
    }
    return _isActive;
  }

  Duration getDelay({required int humanMs, required int botMs}) {
    return Duration(milliseconds: _isActive ? botMs : humanMs);
  }

  void scheduleNextTurn() {
    log('scheduleNextTurn() called');
    if (!_isActive || _cb.readGamePhase() == GamePhase.gameOver) {
      log('scheduleNextTurn() ABORTED - active: $_isActive, phase: ${_cb.readGamePhase()}');
      return;
    }

    _startWatchdog();

    _activeTimers.add(
      Timer(
        const Duration(milliseconds: GameConstants.botTurnScheduleDelay),
        () {
          if (_isActive && _cb.readGamePhase() != GamePhase.gameOver) {
            log('scheduleNextTurn() executing check...');
            final dialog = _cb.readDialogState();
            if (!dialog.isAnyDialogOpen &&
                !_cb.readIsDiceRolling() &&
                !_cb.readIsProcessing()) {
              log('No dialogs/blockers, calling rollDice()');
              _cb.rollDice();
            } else if (_isActive) {
              log('Dialogs/blockers detected, handling them');
              _handleDialog();
            }
          }
        },
      ),
    );
  }

  Future<void> handleQuestionTile({
    required Question question,
    required BoardTile? currentTile,
    required List<Player> allPlayers,
    required int currentPlayerIndex,
    required int consecutiveDoubles,
  }) async {
    try {
      final categoryName = currentTile?.category;
      final difficulty = currentTile?.difficulty ?? Difficulty.medium;

      final isCorrect = _random.nextBool();
      _cb.addLog(
        '🤖 Bot: Soru cevaplandı (${question.category.name})',
        type: 'info',
      );

      final result = _questionFlowService.processAnswer(
        isCorrect: isCorrect,
        player: allPlayers[currentPlayerIndex],
        categoryName: categoryName,
        difficulty: difficulty,
        allPlayers: allPlayers,
        currentPlayerIndex: currentPlayerIndex,
        consecutiveDoubles: consecutiveDoubles,
        random: _random,
        isBot: true,
      );

      _cb.applyAnswerResult(result);

      if (result.checkWinCondition) {
        _cb.checkWinCondition();
      }

      await Future.delayed(const Duration(milliseconds: 500));
      _cb.endTurn();
    } catch (e, stackTrace) {
      safePrint('🚨 ERROR in BotController.handleQuestionTile: $e');
      safePrint('Stack trace: $stackTrace');
      _cb.endTurn();
    }
  }

  Future<void> handleCardEffect({
    required GameCard card,
    required List<Player> players,
    required int currentPlayerIndex,
  }) async {
    try {
      final result = _cardEffectService.apply(
        card: card,
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        isBot: true,
      );
      _cb.applyCardEffectResult(result);

      if (result.rollAgain) return;

      await Future.delayed(const Duration(milliseconds: 500));
      _cb.endTurn();
    } catch (e, stackTrace) {
      safePrint('🚨 ERROR in BotController.handleCardEffect: $e');
      safePrint('Stack trace: $stackTrace');
      _cb.endTurn();
    }
  }

  bool handleDialogTile(BotDialogType type) {
    if (!_isActive) return false;

    final int delayMs;
    final void Function() closeAction;

    switch (type) {
      case BotDialogType.library:
        delayMs = GameConstants.botPenaltyDialogAutoCloseDelay;
        closeAction = _cb.closeLibraryPenaltyDialog;
      case BotDialogType.signingDay:
        delayMs = GameConstants.botPenaltyDialogAutoCloseDelay;
        closeAction = _cb.closeImzaGunuDialog;
      case BotDialogType.shop:
        delayMs = GameConstants.botDialogAutoCloseDelay;
        closeAction = _cb.closeShopDialog;
    }

    _activeTimers.add(
      Timer(Duration(milliseconds: delayMs), closeAction),
    );
    return true;
  }

  void log(String message) {
    if (!_isActive) return;
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    safePrint('[BOT 🤖] $timestamp - $message');
  }

  void dispose() {
    _cancelWatchdog();
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERNALS
  // ═══════════════════════════════════════════════════════════════════════════

  void _startWatchdog() {
    if (!_isActive) return;
    _watchdog?.cancel();

    _watchdog = Timer(const Duration(seconds: 4), () {
      if (!_isActive) return;

      log('🚨 WATCHDOG: Bot stuck! Forcing recovery...');
      safePrint('[BOT 🤖] WATCHDOG TRIGGERED');

      _cb.setProcessing(false);

      final dialog = _cb.readDialogState();
      if (dialog.showQuestionDialog) {
        log('Watchdog: Closing stuck question dialog');
        _cb.answerQuestion(_random.nextBool());
      } else if (dialog.showCardDialog) {
        log('Watchdog: Closing stuck card dialog');
        _cb.closeCardDialog();
      } else if (dialog.showLibraryPenaltyDialog) {
        log('Watchdog: Closing stuck library dialog');
        _cb.closeLibraryPenaltyDialog();
      } else if (dialog.showImzaGunuDialog) {
        log('Watchdog: Closing stuck imza günü dialog');
        _cb.closeImzaGunuDialog();
      } else if (dialog.showPrinterIssueDialog) {
        log('Watchdog: Closing stuck printer issue dialog');
        _cb.closePrinterIssueDialog();
      } else if (dialog.showShopDialog) {
        log('Watchdog: Closing stuck shop dialog');
        _cb.closeShopDialog();
      } else if (dialog.showTurnOrderDialog) {
        log('Watchdog: Closing stuck turn order dialog');
        _cb.closeTurnOrderDialog();
        scheduleNextTurn();
      } else if (dialog.showTurnSkippedDialog) {
        log('Watchdog: Closing stuck turn skipped dialog');
        _cb.closeTurnSkippedDialog();
      } else {
        log('Watchdog: No dialog detected, attempting rollDice()');
        _cb.rollDice();
      }
    });

    log('Watchdog started (4s timeout)');
  }

  void _cancelWatchdog() {
    _watchdog?.cancel();
    _watchdog = null;
    log('Watchdog cancelled');
  }

  void _handleDialog() {
    if (!_isActive) return;

    log('_handleDialog() - checking dialogs...');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isActive) return;

      final dialog = _cb.readDialogState();
      if (dialog.showTurnOrderDialog) {
        log('Closing TurnOrderDialog');
        _cb.closeTurnOrderDialog();
        scheduleNextTurn();
      } else if (dialog.showLibraryPenaltyDialog) {
        log('Closing LibraryPenaltyDialog');
        _cb.closeLibraryPenaltyDialog();
      } else if (dialog.showImzaGunuDialog) {
        log('Closing ImzaGunuDialog');
        _cb.closeImzaGunuDialog();
      } else if (dialog.showPrinterIssueDialog) {
        log('Closing PrinterIssueDialog');
        _cb.closePrinterIssueDialog();
      } else if (dialog.showTurnSkippedDialog) {
        log('Closing TurnSkippedDialog');
        _cb.closeTurnSkippedDialog();
      } else if (dialog.showShopDialog) {
        log('Closing ShopDialog');
        _cb.closeShopDialog();
      } else if (dialog.showQuestionDialog) {
        log('Closing QuestionDialog with random answer');
        _cb.answerQuestion(_random.nextBool());
      } else if (dialog.showCardDialog) {
        log('Closing CardDialog');
        _cb.closeCardDialog();
      } else {
        log('No dialog found, but _isProcessing or isDiceRolling may be stuck');
        if (_cb.readIsProcessing() || _cb.readIsDiceRolling()) {
          log('Forcing reset of _isProcessing and isDiceRolling');
          _cb.setProcessing(false);
          scheduleNextTurn();
        }
      }
    });
  }
}
