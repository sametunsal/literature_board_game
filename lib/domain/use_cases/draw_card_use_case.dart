/// Use case for drawing chance/fate cards.
/// Pure Dart - no Flutter dependencies.
library;

import 'dart:math';
import '../../core/constants/game_constants.dart';
import '../../models/game_card.dart';
import '../../models/player.dart';
import '../../models/tile_type.dart';

class DrawCardUseCase {
  final Random _random = Random();

  /// Draws a random card from the specified deck.
  GameCard drawCard(TileType cardType, List<GameCard> deck) {
    return deck[_random.nextInt(deck.length)];
  }

  /// Calculates the effect of a card on a player.
  CardEffectResult calculateCardEffect(
    GameCard card,
    Player currentPlayer,
    List<Player> allPlayers,
    int diceTotal,
  ) {
    switch (card.effectType) {
      case CardEffectType.moneyChange:
        final newStars = currentPlayer.stars + card.value;
        return StarChangeEffect(
          newStars: newStars,
          amount: card.value,
          isPositive: card.value > 0,
        );

      case CardEffectType.move:
        int targetPos = card.value % GameConstants.boardSize;
        bool passedStart = targetPos < currentPlayer.position;

        // Give passing start bonus if passed start
        int newStars = currentPlayer.stars;
        if (passedStart && targetPos != GameConstants.startPosition) {
          newStars += GameConstants.passingStartBonus;
        }

        return MoveEffect(
          targetPosition: targetPos,
          newStars: newStars,
          passedStart: passedStart,
        );

      case CardEffectType.jail:
        return JailEffect(
          newPosition: GameConstants.jailPosition,
          turnsToSkip: GameConstants.jailTurns,
        );

      case CardEffectType.globalMoney:
        // Collect from or pay to all other players
        int totalTransfer = 0;
        List<int> playerStars = List.from(allPlayers.map((p) => p.stars));

        for (int i = 0; i < allPlayers.length; i++) {
          if (allPlayers[i].id != currentPlayer.id) {
            if (card.value > 0) {
              // Current player receives from others
              int amount = card.value;
              if (playerStars[i] < amount) {
                amount = playerStars[i] > 0 ? playerStars[i] : 0;
              }
              playerStars[i] -= amount;
              totalTransfer += amount;
            } else {
              // Current player pays to others
              int amount = -card.value;
              playerStars[i] += amount;
              totalTransfer += amount;
            }
          }
        }

        // Update current player
        int finalStars = card.value > 0
            ? currentPlayer.stars + totalTransfer
            : currentPlayer.stars - totalTransfer;
        playerStars[allPlayers.indexOf(currentPlayer)] = finalStars;

        return GlobalStarEffect(
          playerStars: playerStars,
          totalTransfer: totalTransfer,
          isReceiving: card.value > 0,
        );
    }
  }

  /// Checks if a card movement should give passing start bonus.
  bool shouldGivePassingStartBonus(int currentPosition, int targetPosition) {
    return targetPosition < currentPosition &&
        targetPosition != GameConstants.startPosition;
  }

  /// Calculates the passing start bonus amount.
  int getPassingStartBonus() {
    return GameConstants.passingStartBonus;
  }

  /// Gets the jail position.
  int getJailPosition() {
    return GameConstants.jailPosition;
  }

  /// Gets the jail turns.
  int getJailTurns() {
    return GameConstants.jailTurns;
  }
}

/// Result of a card effect.
sealed class CardEffectResult {
  const CardEffectResult();
}

/// Star change effect.
class StarChangeEffect extends CardEffectResult {
  final int newStars;
  final int amount;
  final bool isPositive;

  const StarChangeEffect({
    required this.newStars,
    required this.amount,
    required this.isPositive,
  });
}

/// Move effect.
class MoveEffect extends CardEffectResult {
  final int targetPosition;
  final int newStars;
  final bool passedStart;

  const MoveEffect({
    required this.targetPosition,
    required this.newStars,
    required this.passedStart,
  });
}

/// Jail effect.
class JailEffect extends CardEffectResult {
  final int newPosition;
  final int turnsToSkip;

  const JailEffect({required this.newPosition, required this.turnsToSkip});
}

/// Global star effect.
class GlobalStarEffect extends CardEffectResult {
  final List<int> playerStars;
  final int totalTransfer;
  final bool isReceiving;

  const GlobalStarEffect({
    required this.playerStars,
    required this.totalTransfer,
    required this.isReceiving,
  });
}
