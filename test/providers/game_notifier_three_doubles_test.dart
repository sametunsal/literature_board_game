import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/constants/game_constants.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/providers/dialog_provider.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  test(
    'third consecutive double shows warning, then sends the player to Library',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameProvider.notifier);

      notifier.updateState(
        GameState(
          players: const [
            Player(
              id: 'p1',
              name: 'P1',
              color: Colors.red,
              iconIndex: 0,
            ),
          ],
          tiles: BoardConfig.tiles,
          phase: GamePhase.playerTurn,
          consecutiveDoubles: 2,
        ),
      );

      // Trigger the third consecutive double (human path).
      final future = notifier.handleMovementRollForTest(4, 4, 8, true);

      // The warning must be open BEFORE the pawn moves — no unexplained
      // teleport.
      await Future.delayed(const Duration(milliseconds: 50));
      expect(
        container.read(dialogProvider).showThreeDoublesWarning,
        isTrue,
      );

      // Dismiss it, exactly as a human would via the dialog button.
      notifier.closeThreeDoublesWarning();

      await future;

      final state = container.read(gameProvider);
      expect(state.currentPlayer.position, BoardConfig.libraryPosition);
      expect(state.currentPlayer.turnsToSkip, GameConstants.jailTurns);
      expect(state.consecutiveDoubles, 0);
      expect(
        container.read(dialogProvider).showThreeDoublesWarning,
        isFalse,
      );
    },
  );
}
