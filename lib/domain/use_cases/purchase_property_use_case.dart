/// Use case for property purchase logic.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';
import '../../models/board_tile.dart';
import '../../models/player.dart';
import '../../models/game_enums.dart';
import '../../models/difficulty.dart';

class PurchasePropertyUseCase {
  /// Checks if a player can afford the star cost for mastery.
  bool canAffordProperty(Player player, BoardTile tile) {
    // In RPG, price is derived from difficulty
    final price = _getPriceFromDifficulty(tile.difficulty);
    return player.stars >= price;
  }

  /// Calculates the cost of mastering a property.
  int getPurchasePrice(BoardTile tile) {
    return _getPriceFromDifficulty(tile.difficulty);
  }

  /// Calculates the new stars after mastering.
  int calculateNewBalanceAfterPurchase(Player player, BoardTile tile) {
    final price = _getPriceFromDifficulty(tile.difficulty);
    return player.stars - price;
  }

  /// Adds a tile to a player's collected quotes (Formerly ownership).
  List<String> addQuoteToCollected(Player player, String quote) {
    return List<String>.from(player.collectedQuotes)..add(quote);
  }

  /// Checks if a property is masterable (Looping allows re-entry, but mastery is tracked per category).
  bool isPurchasable(BoardTile tile, Player player) {
    // In RPG, properties can be revisited for quotes or training.
    // 'Ownership' as Monopoly is being phased out.
    return true;
  }

  /// Gets the purchase details for logging.
  PurchaseDetails getPurchaseDetails(Player player, BoardTile tile) {
    final price = _getPriceFromDifficulty(tile.difficulty);
    return PurchaseDetails(
      playerName: player.name,
      tileTitle: tile.name,
      price: price,
      canAfford: player.stars >= price,
    );
  }

  int _getPriceFromDifficulty(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.easy => 10,
      Difficulty.medium => 25,
      Difficulty.hard => 50,
    };
  }

  /// Gets the default property price if not specified.
  int getDefaultPropertyPrice() {
    return 25; // Default medium difficulty price
  }
}

/// Details about property purchase.
class PurchaseDetails {
  final String playerName;
  final String tileTitle;
  final int price;
  final bool canAfford;

  const PurchaseDetails({
    required this.playerName,
    required this.tileTitle,
    required this.price,
    required this.canAfford,
  });

  /// Gets the message for insufficient stars.
  String getInsufficientBalanceMessage(int currentStars) {
    return 'Yetersiz Yıldız! (Gereken: $price, Mevcut: $currentStars)';
  }

  /// Gets the success message.
  String getSuccessMessage() {
    return "$playerName '$tileTitle' seviyesini geçti! (-$price Yıldız)";
  }
}
