/// Use case for turn management.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';
import '../entities/player.dart';
import '../entities/board_tile.dart';

class EndTurnUseCase {
  /// Calculates the next player index.
  int calculateNextPlayerIndex(int currentIndex, int totalPlayers) {
    return (currentIndex + 1) % totalPlayers;
  }

  /// Checks if a player gets an extra turn (double rolled).
  bool shouldGetExtraTurn(
    bool isDouble,
    bool inJail,
    int turnsToSkip,
    int dice1,
    int dice2,
  ) {
    return isDouble &&
        !inJail &&
        turnsToSkip == 0 &&
        dice1 != 0 &&
        dice1 == dice2;
  }

  /// Checks if a player is bankrupt.
  bool isBankrupt(Player player) {
    return player.balance < 0;
  }

  /// Checks if the game is over (only one or zero players left).
  bool isGameOver(List<Player> players) {
    return players.length <= 1;
  }

  /// Calculates a player's net worth (balance + assets).
  int calculateNetWorth(Player player, List<BoardTile> allTiles) {
    int assetValue = 0;

    for (final tileId in player.ownedTiles) {
      final tile = _getTileById(tileId, allTiles);
      if (tile != null && tile.price != null) {
        // Assets valued at 1.5x purchase price
        assetValue += (tile.price! * 1.5).round();
      }
    }

    return player.balance + assetValue;
  }

  /// Finds the winner based on net worth.
  Player? findWinner(List<Player> players, List<BoardTile> allTiles) {
    if (players.isEmpty) return null;

    return players.reduce(
      (curr, next) =>
          calculateNetWorth(curr, allTiles) > calculateNetWorth(next, allTiles)
          ? curr
          : next,
    );
  }

  /// Checks if a player should be skipped (has turns to skip).
  bool shouldSkipTurn(Player player) {
    return player.turnsToSkip > 0;
  }

  /// Decrements a player's turns to skip.
  int decrementTurnsToSkip(Player player) {
    return (player.turnsToSkip - 1).clamp(0, GameConstants.jailTurns);
  }

  /// Removes a bankrupt player from the list.
  List<Player> removeBankruptPlayer(
    List<Player> players,
    Player bankruptPlayer,
  ) {
    return List<Player>.from(players)..remove(bankruptPlayer);
  }

  /// Gets the asset value of a player's properties.
  int calculateAssetValue(Player player, List<BoardTile> allTiles) {
    int assetValue = 0;

    for (final tileId in player.ownedTiles) {
      final tile = _getTileById(tileId, allTiles);
      if (tile != null && tile.price != null) {
        assetValue += (tile.price! * 1.5).round();
      }
    }

    return assetValue;
  }

  /// Helper method to get tile by ID.
  BoardTile? _getTileById(int id, List<BoardTile> allTiles) {
    try {
      return allTiles.firstWhere((tile) => tile.id == id);
    } catch (e) {
      return null;
    }
  }
}
