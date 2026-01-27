/// Data source for board configuration.
/// Wraps existing board_config.dart data.
/// Pure Dart - no Flutter dependencies.

import '../../domain/entities/board_tile.dart';

class BoardConfigDataSource {
  BoardConfigDataSource._();

  static final BoardConfigDataSource _instance = BoardConfigDataSource._();
  static BoardConfigDataSource get instance => _instance;

  /// Get all board tiles as domain entities
  List<BoardTile> getTiles() {
    // Convert existing board config tiles to domain entities
    // This will be used by the repository implementation
    // For now, return empty list - will be implemented with existing data
    return [];
  }

  /// Get a specific tile by ID
  BoardTile? getTile(int id) {
    final tiles = getTiles();
    for (var tile in tiles) {
      if (tile.id == id) return tile;
    }
    return null;
  }
}
