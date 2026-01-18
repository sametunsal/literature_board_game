/// Use case for drawing chance/fate cards.
/// Pure Dart - no Flutter dependencies.

import 'dart:math';
import '../../core/constants/game_constants.dart';
import '../entities/game_card.dart';
import '../entities/game_enums.dart';
import '../entities/player.dart';

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
        final newBalance = currentPlayer.balance + card.value;
        return MoneyChangeEffect(
          newBalance: newBalance,
          amount: card.value,
          isPositive: card.value > 0,
        );

      case CardEffectType.move:
        int targetPos = card.value % GameConstants.boardSize;
        bool passedStart = targetPos < currentPlayer.position;

        // Give passing start bonus if passed start
        int newBalance = currentPlayer.balance;
        if (passedStart && targetPos != GameConstants.startPosition) {
          newBalance += GameConstants.passingStartBonus;
        }

        return MoveEffect(
          targetPosition: targetPos,
          newBalance: newBalance,
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
        List<int> playerBalances = List.from(allPlayers.map((p) => p.balance));

        for (int i = 0; i < allPlayers.length; i++) {
          if (allPlayers[i].id != currentPlayer.id) {
            if (card.value > 0) {
              // Current player receives from others
              int amount = card.value;
              if (playerBalances[i] < amount) {
                amount = playerBalances[i] > 0 ? playerBalances[i] : 0;
              }
              playerBalances[i] -= amount;
              totalTransfer += amount;
            } else {
              // Current player pays to others
              int amount = -card.value;
              playerBalances[i] += amount;
              totalTransfer += amount;
            }
          }
        }

        // Update current player
        int finalBalance = card.value > 0
            ? currentPlayer.balance + totalTransfer
            : currentPlayer.balance - totalTransfer;
        playerBalances[allPlayers.indexOf(currentPlayer)] = finalBalance;

        return GlobalMoneyEffect(
          playerBalances: playerBalances,
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

/// Money change effect.
class MoneyChangeEffect extends CardEffectResult {
  final int newBalance;
  final int amount;
  final bool isPositive;

  const MoneyChangeEffect({
    required this.newBalance,
    required this.amount,
    required this.isPositive,
  });
}

/// Move effect.
class MoveEffect extends CardEffectResult {
  final int targetPosition;
  final int newBalance;
  final bool passedStart;

  const MoveEffect({
    required this.targetPosition,
    required this.newBalance,
    required this.passedStart,
  });
}

/// Jail effect.
class JailEffect extends CardEffectResult {
  final int newPosition;
  final int turnsToSkip;

  const JailEffect({required this.newPosition, required this.turnsToSkip});
}

/// Global money effect.
class GlobalMoneyEffect extends CardEffectResult {
  final List<int> playerBalances;
  final int totalTransfer;
  final bool isReceiving;

  const GlobalMoneyEffect({
    required this.playerBalances,
    required this.totalTransfer,
    required this.isReceiving,
  });
}
