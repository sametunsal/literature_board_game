import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/screens/victory_screen.dart';
import 'package:literature_board_game/presentation/widgets/board_view.dart';
import 'package:literature_board_game/providers/game_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression test for the gameOver → VictoryScreen winner handoff.
///
/// The publishing win sets `state.winner` to the player who completed three
/// Cilt books. That player must reach the victory screen even when another
/// player holds more stars/Akçe — the stars sort is only a fallback for a
/// winnerless gameOver state.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'gameOver navigation uses state.winner over the stars leader',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final publishingWinner = _player('p1', 'Publisher', 30);
      final starsLeader = _player('p2', 'Rich Rival', 500);

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            final notifier = GameNotifier(ref);
            notifier.updateState(
              GameState(
                players: [publishingWinner, starsLeader],
                tiles: BoardConfig.tiles,
                phase: GamePhase.playerTurn,
              ),
            );
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BoardView()),
        ),
      );
      // Let the opening overlay and entrance animation finish (same session
      // pacing as board_view_layout_test).
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));

      // Publishing win: winner is the Cilt-completing player, not the
      // stars leader.
      container.read(gameProvider.notifier).updateState(
            container.read(gameProvider).copyWith(
                  winner: publishingWinner,
                  phase: GamePhase.gameOver,
                ),
          );
      await tester.pump();
      // Listener fires outside a frame; the postFrameCallback runs the
      // pushReplacement on the next frame; the page transition then needs
      // its 300ms to mount the victory screen. (No pumpAndSettle:
      // VictoryScreen repeats a particle animation forever.)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final screen = tester.widget(find.byType(VictoryScreen));
      expect(screen, isA<VictoryScreen>());
      expect((screen as VictoryScreen).winner.id, 'p1');
      expect(screen.winner.name, 'Publisher');

      // Let the entrance-animate delay timers (max 1.5s) fire so the test
      // ends without pending timers.
      await tester.pump(const Duration(seconds: 2));
    },
  );

  testWidgets(
    'gameOver navigation falls back to the stars leader when no winner is set',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final starsLeader = _player('p2', 'Rich Rival', 500);

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            final notifier = GameNotifier(ref);
            notifier.updateState(
              GameState(
                players: [_player('p1', 'Publisher', 30), starsLeader],
                tiles: BoardConfig.tiles,
                phase: GamePhase.playerTurn,
              ),
            );
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BoardView()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));

      container.read(gameProvider.notifier).updateState(
            container.read(gameProvider).copyWith(phase: GamePhase.gameOver),
          );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final screen = tester.widget(find.byType(VictoryScreen));
      expect((screen as VictoryScreen).winner.id, 'p2');

      await tester.pump(const Duration(seconds: 2));
    },
  );
}

Player _player(String id, String name, int stars) {
  return Player(
    id: id,
    name: name,
    color: Colors.red,
    iconIndex: 0,
    stars: stars,
  );
}
