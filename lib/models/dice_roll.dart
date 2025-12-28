import 'dart:math';

class DiceRoll {
  final int die1;
  final int die2;

  const DiceRoll({required this.die1, required this.die2});

  // Calculate total of both dice
  int get total => die1 + die2;

  // Check if dice show same value (double)
  bool get isDouble => die1 == die2;

  // Check if die values are valid (1-6)
  bool get isValid => die1 >= 1 && die1 <= 6 && die2 >= 1 && die2 <= 6;

  // Check if this is the third consecutive double
  bool isThirdDouble(int currentDoubleCount) {
    return isDouble && currentDoubleCount == 2;
  }

  // Create a random dice roll
  factory DiceRoll.random() {
    final random = Random();
    final newDie1 = random.nextInt(6) + 1;
    final newDie2 = random.nextInt(6) + 1;
    return DiceRoll(die1: newDie1, die2: newDie2);
  }

  // Create a specific dice roll (for testing)
  factory DiceRoll.specific(int value1, int value2) {
    return DiceRoll(die1: value1, die2: value2);
  }

  // Create a copy with updated values
  DiceRoll copyWith({int? die1, int? die2}) {
    return DiceRoll(die1: die1 ?? this.die1, die2: die2 ?? this.die2);
  }

  @override
  String toString() {
    return 'DiceRoll($die1, $die2) - Total: $total${isDouble ? ' (DOUBLE!)' : ''}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiceRoll && other.die1 == die1 && other.die2 == die2;
  }

  @override
  int get hashCode => die1.hashCode ^ die2.hashCode;
}
