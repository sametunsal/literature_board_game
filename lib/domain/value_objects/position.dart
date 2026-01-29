/// Value object for board position.
/// Pure Dart - no Flutter dependencies.
library;

import '../../core/constants/game_constants.dart';

class Position {
  final int value;

  const Position(this.value);

  /// Creates a Position at the start position.
  const Position.start() : value = GameConstants.startPosition;

  /// Creates a Position at the jail position.
  const Position.jail() : value = GameConstants.jailPosition;

  /// Validates that the position is within board bounds.
  bool get isValid => value >= 0 && value < GameConstants.boardSize;

  /// Returns true if this position is the start position.
  bool get isStart => value == GameConstants.startPosition;

  /// Returns true if this position is the jail position.
  bool get isJail => value == GameConstants.jailPosition;

  /// Moves forward by the given number of steps, wrapping around the board.
  Position moveForward(int steps) {
    return Position((value + steps) % GameConstants.boardSize);
  }

  /// Moves backward by the given number of steps, wrapping around the board.
  Position moveBackward(int steps) {
    int newPos = (value - steps) % GameConstants.boardSize;
    if (newPos < 0) newPos += GameConstants.boardSize;
    return Position(newPos);
  }

  /// Calculates the distance to another position (forward direction).
  int distanceTo(Position other) {
    if (other.value >= value) {
      return other.value - value;
    } else {
      return GameConstants.boardSize - value + other.value;
    }
  }

  /// Returns true if moving from this position by the given steps
  /// would pass the start position.
  bool wouldPassStart(int steps) {
    final currentPos = value;
    final targetPos = (currentPos + steps) % GameConstants.boardSize;
    return targetPos < currentPos && steps > 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Position($value)';
}
