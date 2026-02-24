import 'dart:async';
import 'dart:math';
import '../constants/game_constants.dart';
import '../managers/audio_manager.dart';
import '../../models/game_enums.dart';
import '../../providers/game_notifier.dart';

/// Service responsible for handling dice rolls and doubles logic.
class DiceService {
  final Random _random = Random();

  /// Execute a dice roll
  Future<void> executeRoll({
    required GameNotifier notifier,
    required GameState state,
    required bool isBotPlaying,
    required Future<void> Function(int d1, int d2, int roll, bool isDouble)
    onMovementRoll,
  }) async {
    notifier.logBot('DiceService.executeRoll() START');

    // PAUSE GUARD
    await notifier.checkPauseStatus();

    // Generate two independent dice
    int d1 = _random.nextInt(6) + 1;
    int d2 = _random.nextInt(6) + 1;
    int roll = d1 + d2;
    bool isDouble = d1 == d2;

    notifier.logBot('Dice rolled: $d1 + $d2 = $roll (Double: $isDouble)');

    // Start dice rolling animation
    notifier.updateState(state.copyWith(isDiceRolling: true));
    AudioManager.instance.playSfx('audio/dice_roll.wav');

    // Wait for animation duration (faster in bot mode)
    final diceDelay = isBotPlaying
        ? const Duration(milliseconds: 500)
        : const Duration(milliseconds: GameConstants.diceAnimationDelay);
    await Future.delayed(diceDelay);

    // Stop rolling animation
    notifier.updateState(notifier.currentState.copyWith(isDiceRolling: false));

    // Handle based on game phase
    if (notifier.currentState.phase == GamePhase.playerTurn) {
      notifier.logBot('Phase: playerTurn - Delegating to movement logic');
      await onMovementRoll(d1, d2, roll, isDouble);
    } else {
      notifier.logBot(
        'WARNING: Unexpected phase ${notifier.currentState.phase} - ignoring dice roll',
      );
    }
  }
}
