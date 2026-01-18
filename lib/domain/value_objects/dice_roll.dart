/// Value object for dice roll result.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';

class DiceRoll {
  final int dice1;
  final int dice2;

  const DiceRoll({required this.dice1, required this.dice2});

  /// Creates a DiceRoll with zero values (for initialization).
  const DiceRoll.zero() : dice1 = 0, dice2 = 0;

  /// Returns the total of both dice.
  int get total => dice1 + dice2;

  /// Returns true if both dice show the same value.
  bool get isDouble => dice1 == dice2;

  /// Returns true if this is a valid dice roll (1-6 for each die).
  bool get isValid => dice1 >= 1 && dice1 <= 6 && dice2 >= 1 && dice2 <= 6;

  /// Returns true if the total is within the valid range (2-12).
  bool get isTotalValid =>
      total >= GameConstants.diceMinRoll && total <= GameConstants.diceMaxRoll;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiceRoll && other.dice1 == dice1 && other.dice2 == dice2;
  }

  @override
  int get hashCode => Object.hash(dice1, dice2);

  @override
  String toString() {
    final doubleStr = isDouble ? ' (DOUBLE)' : '';
    return 'DiceRoll($dice1, $dice2) = $total$doubleStr';
  }
}

/// Result object for dice roll operations.
class DiceRollResult {
  final int dice1;
  final int dice2;
  final int total;
  final bool isDouble;

  const DiceRollResult({
    required this.dice1,
    required this.dice2,
    required this.total,
    required this.isDouble,
  });

  /// Creates a DiceRollResult from a DiceRoll.
  factory DiceRollResult.fromDiceRoll(DiceRoll roll) {
    return DiceRollResult(
      dice1: roll.dice1,
      dice2: roll.dice2,
      total: roll.total,
      isDouble: roll.isDouble,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiceRollResult &&
        other.dice1 == dice1 &&
        other.dice2 == dice2 &&
        other.total == total &&
        other.isDouble == isDouble;
  }

  @override
  int get hashCode => Object.hash(dice1, dice2, total, isDouble);

  @override
  String toString() {
    final doubleStr = isDouble ? ' (DOUBLE)' : '';
    return 'DiceRollResult($dice1, $dice2) = $total$doubleStr';
  }
}
