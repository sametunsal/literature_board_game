/// Repository interface for game state persistence.
/// Pure Dart - no Flutter dependencies.
library;

import '../../models/player.dart';
import '../../models/board_tile.dart';
import '../../models/game_enums.dart';

abstract class GameRepository {
  /// Saves the current game state.
  Future<void> saveGameState({
    required List<Player> players,
    required List<BoardTile> tiles,
    required int currentPlayerIndex,
    required GamePhase phase,
  });

  /// Loads the current game state.
  Future<GameStateData?> loadGameState();

  /// Clears the saved game state.
  Future<void> clearGameState();

  /// Checks if a saved game state exists.
  Future<bool> hasSavedGame();
}

/// Data class for game state.
class GameStateData {
  final List<Player> players;
  final List<BoardTile> tiles;
  final int currentPlayerIndex;
  final GamePhase phase;

  const GameStateData({
    required this.players,
    required this.tiles,
    required this.currentPlayerIndex,
    required this.phase,
  });
}
