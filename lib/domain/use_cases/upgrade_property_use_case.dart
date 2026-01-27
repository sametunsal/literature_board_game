/// Use case for property upgrade logic.
/// Pure Dart - no Flutter dependencies.

import '../entities/board_tile.dart';
import '../entities/player.dart';
import '../entities/game_enums.dart';

class UpgradePropertyUseCase {
  /// Checks if a tile can be 'upgraded' (Next difficulty level).
  bool canUpgrade(BoardTile tile) {
    return tile.difficulty != Difficulty.hard;
  }

  /// Checks if a player can afford to increase difficulty (Formerly upgrade).
  bool canAffordUpgrade(Player player, BoardTile tile) {
    final cost = calculateUpgradeCost(tile);
    return player.stars >= cost;
  }

  /// Calculates the cost of increasing difficulty.
  int calculateUpgradeCost(BoardTile tile) {
    return switch (tile.difficulty) {
      Difficulty.easy => 20, // To medium
      Difficulty.medium => 50, // To hard
      Difficulty.hard => 0,
    };
  }

  /// Calculates the new stars after difficulty increase.
  int calculateNewBalanceAfterUpgrade(Player player, BoardTile tile) {
    final cost = calculateUpgradeCost(tile);
    return player.stars - cost;
  }

  /// Calculates the next difficulty level.
  Difficulty calculateNextDifficulty(BoardTile tile) {
    return switch (tile.difficulty) {
      Difficulty.easy => Difficulty.medium,
      Difficulty.medium => Difficulty.hard,
      Difficulty.hard => Difficulty.hard,
    };
  }

  /// Checks if the property is at max difficulty.
  bool isMaxUpgradeLevel(BoardTile tile) {
    return tile.difficulty == Difficulty.hard;
  }

  /// Gets the upgrade details for logging.
  UpgradeDetails getUpgradeDetails(Player player, BoardTile tile) {
    final cost = calculateUpgradeCost(tile);
    return UpgradeDetails(
      playerName: player.name,
      tileTitle: tile.title,
      currentLevel: tile.difficulty.index,
      newLevel: calculateNextDifficulty(tile).index,
      cost: cost,
      canAfford: player.stars >= cost,
    );
  }

  /// Gets the difficulty name for display.
  String getUpgradeLevelName(Difficulty difficulty) {
    return difficulty.name.toUpperCase();
  }
}

/// Details about property upgrade.
class UpgradeDetails {
  final String playerName;
  final String tileTitle;
  final int currentLevel;
  final int newLevel;
  final int cost;
  final bool canAfford;

  const UpgradeDetails({
    required this.playerName,
    required this.tileTitle,
    required this.currentLevel,
    required this.newLevel,
    required this.cost,
    required this.canAfford,
  });

  /// Gets the success message.
  String getSuccessMessage() {
    return 'Geliştirme başarılı! (Seviye $newLevel)';
  }

  /// Gets the insufficient stars message.
  String getInsufficientBalanceMessage(int currentStars) {
    return 'Yetersiz Yıldız! (Gereken: $cost, Mevcut: $currentStars)';
  }

  /// Gets the max difficulty message.
  String getMaxUpgradeMessage() {
    return 'Daha fazla zorlaştırılamaz (Hard).';
  }
}
