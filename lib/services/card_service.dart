import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../providers/game_provider.dart';
import '../data/cards.dart';

/// Service for managing card decks and applying card effects
class CardService {
  static final CardService _instance = CardService._internal();
  factory CardService() => _instance;
  CardService._internal();

  final Random _random = Random();

  /// Draw a random card of the specified type
  Card drawCard(CardType type) {
    final cards = GameCards.getCardsByType(type);
    final randomIndex = _random.nextInt(cards.length);
    return cards[randomIndex];
  }

  /// Apply card effect to game state
  /// Returns updated player indices if needed (for next player turn)
  ApplyCardResult applyCardEffect(Card card, GameState gameState) {
    final currentPlayer = gameState.players[gameState.currentPlayerIndex];
    List<Player> updatedPlayers = List.from(gameState.players);
    int nextPlayerIndex =
        (gameState.currentPlayerIndex + 1) % gameState.players.length;

    switch (card.effect) {
      // Personal positive effects
      case CardEffect.gainStars:
        if (card.starAmount != null && card.starAmount! > 0) {
          updatedPlayers[gameState.currentPlayerIndex] = currentPlayer.copyWith(
            stars: currentPlayer.stars + card.starAmount!,
          );
        }
        break;

      // Personal negative effects
      case CardEffect.loseStars:
        if (card.starAmount != null && card.starAmount! < 0) {
          updatedPlayers[gameState.currentPlayerIndex] = currentPlayer.copyWith(
            stars:
                currentPlayer.stars + card.starAmount!, // Adding negative value
          );
        } else if (card.starAmount == 0) {
          // Movement penalty (return to start)
          updatedPlayers[gameState.currentPlayerIndex] = currentPlayer.copyWith(
            position: 0, // Return to start
          );
        }
        break;

      // Skip next tax
      case CardEffect.skipNextTax:
        // This would require a flag on the player
        // For now, we'll just add a note (implement in Phase 5)
        break;

      // Free turn (skip current player)
      case CardEffect.freeTurn:
        nextPlayerIndex =
            (gameState.currentPlayerIndex + 1) % gameState.players.length;
        break;

      // Easy question next
      case CardEffect.easyQuestionNext:
        // This would require a flag on the player
        // For now, we'll just add a note (implement in Phase 5)
        break;

      // Global positive effects
      case CardEffect.allPlayersGainStars:
        if (card.starAmount != null && card.starAmount! > 0) {
          for (int i = 0; i < updatedPlayers.length; i++) {
            updatedPlayers[i] = updatedPlayers[i].copyWith(
              stars: updatedPlayers[i].stars + card.starAmount!,
            );
          }
        }
        break;

      // Global negative effects
      case CardEffect.allPlayersLoseStars:
        if (card.starAmount != null && card.starAmount! < 0) {
          for (int i = 0; i < updatedPlayers.length; i++) {
            updatedPlayers[i] = updatedPlayers[i].copyWith(
              stars: updatedPlayers[i].stars + card.starAmount!,
            );
          }
        }
        break;

      // Publisher owners lose stars
      case CardEffect.publisherOwnersLose:
        if (card.starAmount != null && card.starAmount! < 0) {
          for (int i = 0; i < updatedPlayers.length; i++) {
            // Check if player owns any publisher tiles
            bool ownsPublisher = gameState.tiles.any(
              (tile) =>
                  tile.type == TileType.publisher &&
                  tile.owner == updatedPlayers[i].name,
            );

            if (ownsPublisher) {
              updatedPlayers[i] = updatedPlayers[i].copyWith(
                stars: updatedPlayers[i].stars + card.starAmount!,
              );
            }
          }
        }
        break;

      // Tax waiver for everyone
      case CardEffect.taxWaiver:
        // This would require a global flag
        // For now, we'll just add a note (implement in Phase 5)
        break;

      // Rich player pays
      case CardEffect.richPlayerPays:
        if (card.starAmount != null && card.starAmount! < 0) {
          // Find the richest player
          Player richest = updatedPlayers.reduce(
            (a, b) => a.stars > b.stars ? a : b,
          );

          int richestIndex = updatedPlayers.indexWhere(
            (p) => p.name == richest.name,
          );
          if (richestIndex != -1) {
            updatedPlayers[richestIndex] = richest.copyWith(
              stars: richest.stars + card.starAmount!,
            );
          }
        }
        break;

      // All players get easy question next
      case CardEffect.allPlayersEasyQuestion:
        // This would require a flag on all players
        // For now, we'll just add a note (implement in Phase 5)
        break;
    }

    return ApplyCardResult(
      updatedPlayers: updatedPlayers,
      nextPlayerIndex: nextPlayerIndex,
    );
  }
}

/// Result of applying a card effect
class ApplyCardResult {
  final List<Player> updatedPlayers;
  final int nextPlayerIndex;

  ApplyCardResult({
    required this.updatedPlayers,
    required this.nextPlayerIndex,
  });
}
