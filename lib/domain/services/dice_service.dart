/// Domain service for dice rolling.
/// Pure Dart - no Flutter dependencies.
library;

import 'dart:math';
import '../value_objects/dice_roll.dart';

abstract class DiceService {
  /// Rolls two dice and returns the result.
  DiceRollResult rollDice();

  /// Rolls a single die (1-6).
  int rollDie();
}

/// Default implementation of DiceService using Random.
class RandomDiceService implements DiceService {
  final Random _random = Random();

  @override
  DiceRollResult rollDice() {
    final int d1 = rollDie();
    final int d2 = rollDie();
    final bool isDouble = d1 == d2;

    return DiceRollResult(
      dice1: d1,
      dice2: d2,
      total: d1 + d2,
      isDouble: isDouble,
    );
  }

  @override
  int rollDie() {
    return _random.nextInt(6) + 1;
  }
}

/// Testable implementation of DiceService that allows setting the dice values.
class FixedDiceService implements DiceService {
  final List<int> _diceValues;
  int _currentIndex = 0;

  FixedDiceService(this._diceValues);

  @override
  DiceRollResult rollDice() {
    if (_currentIndex >= _diceValues.length) {
      _currentIndex = 0;
    }

    final int value = _diceValues[_currentIndex];
    _currentIndex++;

    // Split the value into two dice (e.g., 7 -> 3 and 4)
    final int d1 = (value / 2).ceil();
    final int d2 = (value / 2).floor();
    final bool isDouble = d1 == d2;

    return DiceRollResult(
      dice1: d1,
      dice2: d2,
      total: value,
      isDouble: isDouble,
    );
  }

  @override
  int rollDie() {
    if (_currentIndex >= _diceValues.length) {
      _currentIndex = 0;
    }

    final int value = _diceValues[_currentIndex];
    _currentIndex++;
    return value;
  }

  /// Resets the index to start from the beginning.
  void reset() {
    _currentIndex = 0;
  }
}
