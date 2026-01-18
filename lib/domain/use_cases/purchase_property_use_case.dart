/// Use case for property purchase logic.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';
import '../entities/board_tile.dart';
import '../entities/player.dart';

class PurchasePropertyUseCase {
  /// Checks if a player can afford to purchase a property.
  bool canAffordProperty(Player player, BoardTile tile) {
    final price = tile.price ?? 0;
    return player.balance >= price;
  }

  /// Calculates the cost of purchasing a property.
  int getPurchasePrice(BoardTile tile) {
    return tile.price ?? 0;
  }

  /// Calculates the new balance after purchasing a property.
  int calculateNewBalanceAfterPurchase(Player player, BoardTile tile) {
    final price = tile.price ?? 0;
    return player.balance - price;
  }

  /// Adds a tile to a player's owned tiles.
  List<int> addTileToOwnedTiles(Player player, int tileId) {
    return List<int>.from(player.ownedTiles)..add(tileId);
  }

  /// Checks if a property is purchasable (not already owned).
  bool isPurchasable(BoardTile tile, List<Player> allPlayers) {
    // Check if any player owns this tile
    for (final player in allPlayers) {
      if (player.ownedTiles.contains(tile.id)) {
        return false;
      }
    }
    return true;
  }

  /// Gets the purchase details for logging.
  PurchaseDetails getPurchaseDetails(Player player, BoardTile tile) {
    final price = tile.price ?? 0;
    return PurchaseDetails(
      playerName: player.name,
      tileTitle: tile.title,
      price: price,
      canAfford: player.balance >= price,
    );
  }

  /// Gets the default property price if not specified.
  int getDefaultPropertyPrice() {
    return GameConstants.defaultPropertyPrice;
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

  /// Gets the message for insufficient balance.
  String getInsufficientBalanceMessage(int currentBalance) {
    return 'Yetersiz bakiye! (Gereken: $price, Mevcut: $currentBalance)';
  }

  /// Gets the success message.
  String getSuccessMessage() {
    return "$playerName '$tileTitle' satın aldı! (-$price)";
  }
}
