/// Use case for rolling dice with doubles detection.
/// Pure Dart - no Flutter dependencies.
library;

import 'dart:math';
import '../../core/constants/game_constants.dart';
import '../value_objects/dice_roll.dart';

class RollDiceUseCase {
  final Random _random = Random();

  /// Rolls two dice and returns the result.
  DiceRollResult roll() {
    final int d1 = _random.nextInt(6) + 1;
    final int d2 = _random.nextInt(6) + 1;
    final bool isDouble = d1 == d2;

    return DiceRollResult(
      dice1: d1,
      dice2: d2,
      total: d1 + d2,
      isDouble: isDouble,
    );
  }

  /// Checks if the player should go to jail based on consecutive doubles.
  bool shouldGoToJail(int consecutiveDoubles) {
    return consecutiveDoubles >= GameConstants.maxConsecutiveDoubles;
  }

  /// Calculates the new consecutive doubles count.
  int calculateConsecutiveDoubles(int currentCount, bool isDouble) {
    return isDouble ? currentCount + 1 : 0;
  }

  /// Checks if the player gets an extra turn (double rolled).
  bool shouldGetExtraTurn(bool isDouble, bool inJail, int turnsToSkip) {
    return isDouble && !inJail && turnsToSkip == 0;
  }

  /// Creates a zero dice roll for initialization.
  DiceRollResult zeroRoll() {
    return const DiceRollResult(dice1: 0, dice2: 0, total: 0, isDouble: false);
  }
}
