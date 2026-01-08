import '../models/player.dart';
import '../models/card.dart';
import 'game_state_manager.dart';
import 'game_rules_engine.dart';

/// Kart efektlerinin uygulanması
class CardEffectHandler {
  final GameStateManager stateManager;
  final GameRulesEngine rulesEngine;

  CardEffectHandler({required this.stateManager, required this.rulesEngine});

  /// Kart efektini uygula
  void applyCardEffect(Card card, Player currentPlayer) {
    // İleriki aşamalarda burası doldurulacak
    // Şu anlık GameNotifier içindeki mantık buraya taşınacak
  }
}
