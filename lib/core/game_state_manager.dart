import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/turn_phase.dart';
import '../models/dice_roll.dart';
import '../models/question.dart';
import '../models/card.dart' as game_card;
import '../models/turn_event.dart';
import '../models/turn_result.dart';

/// State change listener callback type
typedef StateChangeListener =
    void Function(GameState oldState, GameState newState);

/// Durum değişiklikleri ve güncellemeler (Tek doğruluk kaynağı)
class GameStateManager {
  GameState _state;
  final List<StateChangeListener> _listeners = [];

  GameStateManager(GameState initialState) : _state = initialState;

  /// Mevcut durumu getir
  GameState get state => _state;

  /// Add a state change listener
  void addListener(StateChangeListener listener) {
    _listeners.add(listener);
  }

  /// Remove a state change listener
  void removeListener(StateChangeListener listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of state change
  void _notifyListeners(GameState oldState, GameState newState) {
    for (final listener in _listeners) {
      listener(oldState, newState);
    }
  }

  /// Durumu manuel güncelle (Gerekirse)
  void updateState(GameState newState) {
    final oldState = _state;
    _state = newState;
    _notifyListeners(oldState, _state);
  }

  // --- Oyuncu Güncellemeleri ---

  // Bir oyuncuyu listede güncelle
  void updatePlayer(Player updatedPlayer) {
    if (!_state.players.any((p) => p.id == updatedPlayer.id)) {
      throw ArgumentError('Player not found in state');
    }
    final oldState = _state;
    final updatedPlayers = _state.players
        .map((p) => p.id == updatedPlayer.id ? updatedPlayer : p)
        .toList();
    _state = _state.copyWith(players: updatedPlayers);
    _notifyListeners(oldState, _state);
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
