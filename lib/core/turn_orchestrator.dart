import '../models/turn_phase.dart';
import '../models/player_type.dart';
import 'game_state_manager.dart';
import 'game_rules_engine.dart';
import 'bot_ai_controller.dart';

/// Oyun tur akışını ve faz geçişlerini yönetir
class TurnOrchestrator {
  final GameStateManager stateManager;
  final GameRulesEngine rulesEngine;
  final BotAIController botAI;

  TurnOrchestrator({
    required this.stateManager,
    required this.rulesEngine,
    required this.botAI,
  });

  /// Mevcut faza göre bir sonraki adımı çalıştır
  void executeNextStep(TurnPhase currentPhase) {
    // İleriki aşamalarda burası doldurulacak
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
      // Diğer fazlar eklenecek...
      default:
        return null;
    }
  }
}
