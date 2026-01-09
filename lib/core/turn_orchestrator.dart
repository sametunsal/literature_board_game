import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/turn_phase.dart';
import '../models/player.dart';
import 'game_state_manager.dart';
import 'game_rules_engine.dart';

/// Callback definitions for turn orchestration
typedef OnRollDice = void Function();
typedef OnMovePlayer = void Function(int diceTotal);
typedef OnResolveTile = void Function();
typedef OnApplyCard = void Function();
typedef OnHandleCopyrightDecision = void Function();
typedef OnEndTurn = void Function();
typedef OnStartNextTurn = void Function();

/// Oyun tur akışını ve faz geçişlerini yönetir
class TurnOrchestrator {
  final GameStateManager stateManager;
  final GameRulesEngine rulesEngine;

  // Configurable delays
  final Duration diceAnimationDelay;
  final Duration movementDelay;

  // Callbacks for turn actions
  final OnRollDice onRollDice;
  final OnMovePlayer onMovePlayer;
  final OnResolveTile onResolveTile;
  final OnApplyCard onApplyCard;
  final OnHandleCopyrightDecision onHandleCopyrightDecision;
  final OnEndTurn onEndTurn;
  final OnStartNextTurn onStartNextTurn;

  TurnOrchestrator({
    required this.stateManager,
    required this.rulesEngine,
    required this.onRollDice,
    required this.onMovePlayer,
    required this.onResolveTile,
    required this.onApplyCard,
    required this.onHandleCopyrightDecision,
    required this.onEndTurn,
    required this.onStartNextTurn,
    this.diceAnimationDelay = const Duration(milliseconds: 1500),
    this.movementDelay = const Duration(milliseconds: 500),
  });

  /// Execute turn logic based on current phase
  /// This method contains the switch-case logic for turn orchestration
  Future<void> executeTurnLogic({
    required TurnPhase currentPhase,
    required Player? currentPlayer,
  }) async {
    // Eğer oyun bittiyse dur
    if (currentPlayer == null) return;

    switch (currentPhase) {
      case TurnPhase.start:
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
        // İnsan oyuncu: UI üzerinden cevap vermesini bekle
        break;

      case TurnPhase.cardWaiting:
        // İnsan oyuncu: UI üzerinden kart uygulamasını bekle
        break;

      case TurnPhase.questionResolved:
        // İnsan oyuncu: UI üzerinden satın alma kararını bekle
        break;

      // --- EKLENECEK KISIM BURASI ---
      case TurnPhase.cardApplied:
      case TurnPhase.taxResolved:
        // Kart uygulandıysa veya vergi ödendiyse turu bitirmeye yönlendir
        debugPrint('🔄 Phase: $currentPhase -> Triggering EndTurn');
        onEndTurn();
        break;
      // -----------------------------

      case TurnPhase.turnEnded:
        debugPrint('🏁 Turn ended. Next player: ${currentPlayer.name}');
        // Humans wait for TurnSummaryOverlay button
        break;

      default:
        break;
    }
  }

  /// UI için otomatik ilerleme talimatı (Auto-advance)
  String? getAutoAdvanceDirective(TurnPhase phase) {
    switch (phase) {
      case TurnPhase.start:
        return null;
      case TurnPhase.diceRolled:
        return 'movePlayer';
      case TurnPhase.moved:
        return 'resolveTile';
      case TurnPhase.tileResolved:
        return 'handleTileEffect';
      case TurnPhase.cardWaiting:
        return null;
      case TurnPhase.questionWaiting:
        return null;
      case TurnPhase.cardApplied:
      case TurnPhase.questionResolved:
      case TurnPhase.taxResolved:
        return 'endTurn';
      case TurnPhase.copyrightPurchased:
        return null;
      case TurnPhase.turnEnded:
        return null;
    }
  }
}
