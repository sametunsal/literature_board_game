import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/turn_phase.dart';
import '../models/player_type.dart';
import '../models/player.dart';
import 'game_state_manager.dart';
import 'game_rules_engine.dart';
import 'bot_ai_controller.dart';

/// Callback definitions for turn orchestration
typedef OnRollDice = void Function();
typedef OnMovePlayer = void Function(int diceTotal);
typedef OnResolveTile = void Function();
typedef OnBotAnswer = void Function();
typedef OnApplyCard = void Function();
typedef OnHandleCopyrightDecision = void Function();
typedef OnEndTurn = void Function();
typedef OnStartNextTurn = void Function();

/// Oyun tur akışını ve faz geçişlerini yönetir
class TurnOrchestrator {
  final GameStateManager stateManager;
  final GameRulesEngine rulesEngine;
  final BotAIController botAI;

  // Configurable delays
  final Duration diceAnimationDelay;
  final Duration botThinkDelay;
  final Duration movementDelay;

  // Callbacks for turn actions
  final OnRollDice onRollDice;
  final OnMovePlayer onMovePlayer;
  final OnResolveTile onResolveTile;
  final OnBotAnswer onBotAnswer;
  final OnApplyCard onApplyCard;
  final OnHandleCopyrightDecision onHandleCopyrightDecision;
  final OnEndTurn onEndTurn;
  final OnStartNextTurn onStartNextTurn;

  TurnOrchestrator({
    required this.stateManager,
    required this.rulesEngine,
    required this.botAI,
    required this.onRollDice,
    required this.onMovePlayer,
    required this.onResolveTile,
    required this.onBotAnswer,
    required this.onApplyCard,
    required this.onHandleCopyrightDecision,
    required this.onEndTurn,
    required this.onStartNextTurn,
    this.diceAnimationDelay = const Duration(milliseconds: 1500),
    this.botThinkDelay = const Duration(seconds: 1),
    this.movementDelay = const Duration(milliseconds: 500),
  });

  /// Execute turn logic based on current phase and player type
  /// This method contains the switch-case logic for turn orchestration
  Future<void> executeTurnLogic({
    required TurnPhase currentPhase,
    required Player? currentPlayer,
  }) async {
    // Eğer oyun bittiyse dur
    if (currentPlayer == null) return;

    switch (currentPhase) {
      case TurnPhase.start:
        // Bot ise otomatik zar at
        if (currentPlayer.type == PlayerType.bot) {
          await Future.delayed(botThinkDelay);
          onRollDice();
        }
        // İnsan oyuncu: UI üzerinden rollDice() çağrılmasını bekle
        break;

      case TurnPhase.diceRolled:
        debugPrint('🎲 Dice rolled. Waiting for animation...');
        await Future.delayed(diceAnimationDelay); // Allow UI to show dice
        // Get the last dice roll total from state manager
        final lastRoll = stateManager.state.lastDiceRoll;
        if (onMovePlayer != null) {
          debugPrint('🚀 Triggering onMovePlayer callback...');
          if (lastRoll != null) {
            onMovePlayer!(lastRoll.total); // EXECUTE THE CALLBACK
          }
        } else {
          debugPrint('❌ CRITICAL ERROR: onMovePlayer callback is null!');
        }
        break;

      case TurnPhase.moved:
        // Hareket bitti, Tile çözümle
        await Future.delayed(movementDelay);
        onResolveTile();
        break;

      case TurnPhase.questionWaiting:
        // Bot ise cevap ver
        if (currentPlayer.type == PlayerType.bot) {
          await Future.delayed(botThinkDelay);
          onBotAnswer();
        }
        break;

      case TurnPhase.cardWaiting:
        // Bot ise kart çek (UI açılmadan)
        if (currentPlayer.type == PlayerType.bot) {
          await Future.delayed(botThinkDelay);
          onApplyCard();
        }
        break;

      case TurnPhase.questionResolved:
        // Soru çözüldü, satın alma kararı veya tur sonu
        if (currentPlayer.type == PlayerType.bot) {
          await Future.delayed(botThinkDelay);
          onHandleCopyrightDecision();
        }
        break;

      case TurnPhase.turnEnded:
        debugPrint('🏁 Turn ended. Next player: ${currentPlayer.name}');
        // Sonraki oyuncunun turunu başlat
        onStartNextTurn();
        break;

      default:
        break;
    }
  }

  /// UI için otomatik ilerleme talimatı (Auto-advance)
  String? getAutoAdvanceDirective(TurnPhase phase, PlayerType playerType) {
    final isBot = playerType == PlayerType.bot;

    switch (phase) {
      case TurnPhase.start:
        return isBot ? 'rollDice' : null;
      case TurnPhase.diceRolled:
        return 'movePlayer';
      case TurnPhase.moved:
        return 'resolveTile';
      case TurnPhase.tileResolved:
        return 'handleTileEffect';
      case TurnPhase.cardWaiting:
        // HARD BLOCK: applyCard ONLY when ALL conditions are met
        return isBot ? 'applyCard' : null;
      case TurnPhase.questionWaiting:
        // Bots auto-answer questions, humans wait for input
        return isBot ? 'answerQuestion' : null;
      case TurnPhase.cardApplied:
      case TurnPhase.questionResolved:
      case TurnPhase.taxResolved:
        return 'endTurn';
      case TurnPhase.copyrightPurchased:
        // Bots auto-decide on copyright purchase, humans wait for dialog
        return isBot ? 'handleCopyrightDecision' : null;
      case TurnPhase.turnEnded:
        // CRITICAL FIX: Bots auto-advance to next turn, humans wait for summary button
        return isBot ? 'nextTurn' : null;
    }
  }
}
