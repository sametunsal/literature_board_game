/// Use case for turn management.
/// Pure Dart - no Flutter dependencies.
library;

import '../../core/constants/game_constants.dart';
import '../../models/player.dart';
import '../../models/board_tile.dart';

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

  /// Checks if a player is bankrupt (Out of stars).
  bool isBankrupt(Player player) {
    return player.stars < 0;
  }

  /// Checks if the game is over (only one or zero players left).
  bool isGameOver(List<Player> players) {
    return players.length <= 1;
  }

  /// Finds the winner based on stars.
  Player? findWinner(List<Player> players) {
    if (players.isEmpty) return null;

    return players.reduce(
      (curr, next) => curr.stars > next.stars ? curr : next,
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

  /// Assets are no longer used in RPG.
  int calculateAssetValue(Player player, List<BoardTile> allTiles) {
    return 0;
  }
}
