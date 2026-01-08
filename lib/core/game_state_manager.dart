import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/turn_phase.dart';
import '../models/dice_roll.dart';
import '../models/question.dart';
import '../models/card.dart' as game_card;
import '../models/turn_event.dart';
import '../models/turn_result.dart';

/// Durum değişiklikleri ve güncellemeler (Tek doğruluk kaynağı)
class GameStateManager {
  GameState _state;

  GameStateManager(GameState initialState) : _state = initialState;

  /// Mevcut durumu getir
  GameState get state => _state;

  /// Durumu manuel güncelle (Gerekirse)
  void updateState(GameState newState) {
    _state = newState;
  }

  // --- Oyuncu Güncellemeleri ---

  // Bir oyuncuyu listede güncelle
  void updatePlayer(Player updatedPlayer) {
    final updatedPlayers = _state.players
        .map((p) => p.id == updatedPlayer.id ? updatedPlayer : p)
        .toList();
    _state = _state.copyWith(players: updatedPlayers);
  }

  // --- Oyun Durumu Güncellemeleri ---

  void setTurnPhase(TurnPhase phase) {
    _state = _state.copyWith(turnPhase: phase);
  }

  void setLastDiceRoll(DiceRoll roll) {
    _state = _state.copyWith(lastDiceRoll: roll);
  }

  void setCurrentQuestion(Question? question) {
    _state = _state.copyWith(currentQuestion: question);
  }

  void setCurrentCard(game_card.Card? card, String? ownerId) {
    _state = _state.copyWith(currentCard: card, currentCardOwnerId: ownerId);
  }

  // --- Loglama ---

  void addLogMessage(String message) {
    _state = _state.withLogMessage(message);
  }
}
