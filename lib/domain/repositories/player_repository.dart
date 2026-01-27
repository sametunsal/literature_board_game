/// Repository interface for player data access.
/// Pure Dart - no Flutter dependencies.

import '../../models/player.dart';

abstract class PlayerRepository {
  /// Gets all players.
  Future<List<Player>> getPlayers();

  /// Updates a player's data.
  Future<void> updatePlayer(Player player);

  /// Gets a player by ID.
  Future<Player?> getPlayer(String id);

  /// Gets the current player by index.
  Future<Player?> getCurrentPlayer(int index);
}
