/// Use case for property upgrade logic.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';
import '../entities/board_tile.dart';
import '../entities/player.dart';

class UpgradePropertyUseCase {
  /// Checks if a property can be upgraded.
  bool canUpgrade(BoardTile tile) {
    return !tile.isUtility && tile.upgradeLevel < GameConstants.maxUpgradeLevel;
  }

  /// Checks if a player can afford to upgrade a property.
  bool canAffordUpgrade(Player player, BoardTile tile) {
    final cost = calculateUpgradeCost(tile);
    return player.balance >= cost;
  }

  /// Calculates the cost of upgrading a property.
  int calculateUpgradeCost(BoardTile tile) {
    final propertyPrice = tile.price ?? GameConstants.defaultPropertyPrice;

    // Final upgrade (Cilt) costs more
    if (tile.upgradeLevel == GameConstants.finalUpgradeLevel) {
      return (propertyPrice * GameConstants.finalUpgradeCostMultiplier).floor();
    }

    // Normal upgrade costs half of property price
    return (propertyPrice * GameConstants.upgradeCostMultiplier).floor();
  }

  /// Calculates the new balance after upgrading.
  int calculateNewBalanceAfterUpgrade(Player player, BoardTile tile) {
    final cost = calculateUpgradeCost(tile);
    return player.balance - cost;
  }

  /// Calculates the new upgrade level.
  int calculateNewUpgradeLevel(BoardTile tile) {
    return tile.upgradeLevel + 1;
  }

  /// Checks if this is the final upgrade (Cilt).
  bool isFinalUpgrade(BoardTile tile) {
    return tile.upgradeLevel == GameConstants.finalUpgradeLevel;
  }

  /// Checks if the property is at max upgrade level.
  bool isMaxUpgradeLevel(BoardTile tile) {
    return tile.upgradeLevel >= GameConstants.maxUpgradeLevel;
  }

  /// Gets the upgrade details for logging.
  UpgradeDetails getUpgradeDetails(Player player, BoardTile tile) {
    final cost = calculateUpgradeCost(tile);
    final newLevel = calculateNewUpgradeLevel(tile);
    return UpgradeDetails(
      playerName: player.name,
      tileTitle: tile.title,
      currentLevel: tile.upgradeLevel,
      newLevel: newLevel,
      cost: cost,
      canAfford: player.balance >= cost,
    );
  }

  /// Gets the upgrade level name for display.
  String getUpgradeLevelName(int level) {
    switch (level) {
      case 0:
        return 'Temel';
      case 1:
        return '1. Baskı';
      case 2:
        return '2. Baskı';
      case 3:
        return '3. Baskı';
      case 4:
        return 'Cilt';
      default:
        return 'Bilinmeyen';
    }
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

  /// Gets the insufficient balance message.
  String getInsufficientBalanceMessage(int currentBalance) {
    return 'Yetersiz bakiye! (Gereken: $cost, Mevcut: $currentBalance)';
  }

  /// Gets the max upgrade message.
  String getMaxUpgradeMessage() {
    return 'Telif Hakkı Zirvede (Full Upgrade).';
  }
}
