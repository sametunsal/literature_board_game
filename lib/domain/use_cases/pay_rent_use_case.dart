/// Use case for rent calculation and payment.
/// Pure Dart - no Flutter dependencies.

import '../entities/board_tile.dart';
import '../entities/player.dart';
import '../entities/game_enums.dart';

class PayRentUseCase {
  /// Calculates the star cost/gain for a given tile.
  int calculateRent(BoardTile tile, int diceTotal) {
    // In RPG, 'rent' becomes 'contribution' or 'cost'
    // For now, let's use a base value based on difficulty
    int base = switch (tile.difficulty) {
      Difficulty.easy => 10,
      Difficulty.medium => 20,
      Difficulty.hard => 50,
    };
    return base;
  }

  /// Calculates the amount the payer can afford to pay.
  int calculateAffordableRent(Player payer, int fullRent) {
    if (payer.stars < fullRent) {
      // Payer goes bankrupt - pay what they can
      return payer.stars > 0 ? payer.stars : 0;
    }
    return fullRent;
  }

  /// Checks if a player can afford to pay stars.
  bool canAffordRent(Player payer, int rent) {
    return payer.stars >= rent;
  }

  /// Checks if a player is out of stars after paying.
  bool isBankruptAfterRent(Player payer, int rent) {
    return payer.stars - rent < 0;
  }

  /// Calculates the new stars after paying.
  int calculateNewBalanceAfterRent(Player payer, int rent) {
    return payer.stars - rent;
  }

  /// Calculates the owner's new stars after receiving.
  int calculateOwnerNewBalance(Player owner, int rent) {
    return owner.stars + rent;
  }

  /// Gets the rent calculation details for logging.
  RentDetails getRentDetails(BoardTile tile, int diceTotal) {
    int rent = calculateRent(tile, diceTotal);
    return RentDetails(
      rent: rent,
      description: 'Bedel: $rent Yıldız',
      isUtility: false,
    );
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
