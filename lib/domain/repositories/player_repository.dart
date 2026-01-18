/// Repository interface for player data access.
/// Pure Dart - no Flutter dependencies.

import '../entities/player.dart';
import '../entities/board_tile.dart';

abstract class PlayerRepository {
  /// Gets all players.
  Future<List<Player>> getPlayers();

  /// Updates a player's data.
  Future<void> updatePlayer(Player player);

  /// Gets a player by ID.
  Future<Player?> getPlayer(String id);

  /// Gets the current player by index.
  Future<Player?> getCurrentPlayer(int index);

  /// Gets the player who owns a specific tile.
  Future<Player?> getTileOwner(int tileId, List<Player> players);

  /// Calculates a player's net worth (balance + assets).
  Future<int> calculateNetWorth(Player player, List<BoardTile> allTiles);
}
