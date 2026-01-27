/// Use case for player movement logic.
/// Pure Dart - no Flutter dependencies.

import '../../core/constants/game_constants.dart';
import '../../models/player.dart';
import '../value_objects/position.dart';

class MovePlayerUseCase {
  /// Moves a player forward by the given number of steps.
  /// Returns the new position and whether start was passed.
  MoveResult movePlayer(Player player, int steps) {
    final Position currentPos = Position(player.position);
    final bool passedStart = currentPos.wouldPassStart(steps);
    final Position newPos = currentPos.moveForward(steps);

    return MoveResult(newPosition: newPos.value, passedStart: passedStart);
  }

  /// Moves a player directly to a specific position.
  /// Returns whether start was passed.
  bool movePlayerToPosition(Player player, int targetPosition) {
    final int currentPos = player.position;
    final bool passedStart =
        targetPosition < currentPos &&
        targetPosition != GameConstants.startPosition;
    return passedStart;
  }

  /// Sends a player to jail.
  JailResult sendToJail(Player player) {
    return JailResult(
      newPosition: GameConstants.jailPosition,
      turnsToSkip: GameConstants.jailTurns,
    );
  }

  /// Checks if a player is in jail.
  bool isInJail(Player player) {
    return player.inJail || player.turnsToSkip > 0;
  }

  /// Decrements the player's turns to skip.
  int decrementTurnsToSkip(Player player) {
    return (player.turnsToSkip - 1).clamp(0, GameConstants.jailTurns);
  }

  /// Checks if a player has completed their jail sentence.
  bool hasCompletedJailSentence(Player player) {
    return player.turnsToSkip <= 0;
  }

  /// Calculates the passing start bonus.
  int getPassingStartBonus() {
    return GameConstants.passingStartBonus;
  }
}

/// Result of a move operation.
class MoveResult {
  final int newPosition;
  final bool passedStart;

  const MoveResult({required this.newPosition, required this.passedStart});
}

/// Result of sending to jail.
class JailResult {
  final int newPosition;
  final int turnsToSkip;

  const JailResult({required this.newPosition, required this.turnsToSkip});
}
