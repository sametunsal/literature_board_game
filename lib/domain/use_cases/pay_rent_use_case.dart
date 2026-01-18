/// Use case for rent calculation and payment.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';
import '../entities/board_tile.dart';
import '../entities/player.dart';

class PayRentUseCase {
  /// Calculates the rent for a given tile.
  int calculateRent(BoardTile tile, int diceTotal) {
    if (tile.isUtility) {
      // Utility rent: dice total * multiplier
      return diceTotal * GameConstants.utilityRentMultiplier;
    } else {
      // Property rent: baseRent * (upgradeLevel + 1)
      int base = tile.baseRent ?? 20;
      int multiplier = tile.upgradeLevel + 1;

      // Special multiplier for max upgrade (Cilt)
      if (tile.upgradeLevel == GameConstants.maxUpgradeLevel) {
        multiplier =
            GameConstants.maxUpgradeRentMultiplier; // Cilt gives 10x rent
      }

      return base * multiplier;
    }
  }

  /// Calculates the amount the payer can afford to pay.
  int calculateAffordableRent(Player payer, int fullRent) {
    if (payer.balance < fullRent) {
      // Payer goes bankrupt - pay what they can
      return payer.balance > 0 ? payer.balance : 0;
    }
    return fullRent;
  }

  /// Checks if a player can afford to pay rent.
  bool canAffordRent(Player payer, int rent) {
    return payer.balance >= rent;
  }

  /// Checks if a player is bankrupt after paying rent.
  bool isBankruptAfterRent(Player payer, int rent) {
    return payer.balance - rent < 0;
  }

  /// Calculates the new balance after paying rent.
  int calculateNewBalanceAfterRent(Player payer, int rent) {
    return payer.balance - rent;
  }

  /// Calculates the owner's new balance after receiving rent.
  int calculateOwnerNewBalance(Player owner, int rent) {
    return owner.balance + rent;
  }

  /// Gets the rent calculation details for logging.
  RentDetails getRentDetails(BoardTile tile, int diceTotal) {
    if (tile.isUtility) {
      final int rent = diceTotal * GameConstants.utilityRentMultiplier;
      return RentDetails(
        rent: rent,
        description:
            'Yayınevi kirası: Zar($diceTotal) x ${GameConstants.utilityRentMultiplier} = $rent',
        isUtility: true,
      );
    } else {
      int base = tile.baseRent ?? 20;
      int multiplier = tile.upgradeLevel + 1;

      // Special multiplier for max upgrade (Cilt)
      if (tile.upgradeLevel == GameConstants.maxUpgradeLevel) {
        multiplier = GameConstants.maxUpgradeRentMultiplier;
      }

      final int rent = base * multiplier;
      return RentDetails(
        rent: rent,
        description: 'Kira: $base x $multiplier = $rent',
        isUtility: false,
      );
    }
  }
}

/// Details about rent calculation.
class RentDetails {
  final int rent;
  final String description;
  final bool isUtility;

  const RentDetails({
    required this.rent,
    required this.description,
    required this.isUtility,
  });
}
