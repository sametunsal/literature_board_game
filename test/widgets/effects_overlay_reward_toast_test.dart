import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literature_board_game/core/utils/board_layout_config.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/board/effects_overlay.dart';
import 'package:literature_board_game/presentation/widgets/reward_toast.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

/// A reward fires once but the board rebuilds many times while its toast is on
/// screen — hiding the question dialog, ending the turn, moving a pawn. The
/// toast is keyed by the [FloatingEffect] *instance*, so those rebuilds reuse
/// the same element and the entry animation plays exactly once. Keying it by
/// anything that changes per build (wall-clock time, for example) remounts the
/// toast and replays the animation, which reads to the player as the same
/// reward popping up twice.
void main() {
  final layout = BoardLayoutConfig(screenWidth: 1920, screenHeight: 1080);

  GameState stateWith(FloatingEffect? effect, {int currentPlayerIndex = 0}) {
    return GameState(
      players: const [
        Player(id: 'p1', name: 'Oyuncu 1', color: Colors.blue, iconIndex: 0),
        Player(id: 'p2', name: 'Oyuncu 2', color: Colors.red, iconIndex: 1),
      ],
      tiles: BoardConfig.tiles,
      currentPlayerIndex: currentPlayerIndex,
      floatingEffect: effect,
    );
  }

  FloatingEffect telifEffect() => FloatingEffect(
    'Telif: İntibah',
    Colors.amberAccent,
    title: 'TELİF ALINDI',
    icon: Icons.history_edu_rounded,
    anchorTilePosition: 0,
  );

  /// The toast's entry/hold/exit chain schedules timers; let it finish before
  /// tearing the tree down so the test doesn't trip the pending-timer check.
  Future<void> drain(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  Widget app(GameState state, ConfettiController controller) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              EffectsOverlay(
                state: state,
                layout: layout,
                confettiController: controller,
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('Telif acquisition renders exactly one reward toast', (
    tester,
  ) async {
    final controller = ConfettiController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(app(stateWith(telifEffect()), controller));
    await tester.pump();

    expect(find.byType(RewardToast), findsOneWidget);
    expect(find.text('TELİF ALINDI'), findsOneWidget);

    await drain(tester);
  });

  testWidgets('rebuilding while the Telif toast is visible does not remount it '
      '(one reward must not read as two popups)', (tester) async {
    final controller = ConfettiController();
    addTearDown(controller.dispose);

    // One reward fires: a single FloatingEffect instance, held in state.
    final effect = telifEffect();

    await tester.pumpWidget(app(stateWith(effect), controller));
    await tester.pump(const Duration(milliseconds: 120));

    final firstElement = tester.element(find.byType(RewardToast));
    final firstKey = tester.widget<RewardToast>(find.byType(RewardToast)).key;

    // Rebuilds that really happen right after a Telif acquisition: the
    // question dialog is torn down and the turn ends, both of which produce a
    // new GameState carrying the *same* effect instance.
    for (final index in const [1, 0, 1]) {
      await tester.pumpWidget(
        app(stateWith(effect, currentPlayerIndex: index), controller),
      );
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.byType(RewardToast), findsOneWidget);
      // Same element => same State => the entry animation was never restarted.
      expect(tester.element(find.byType(RewardToast)), same(firstElement));
      expect(
        tester.widget<RewardToast>(find.byType(RewardToast)).key,
        equals(firstKey),
      );
    }

    await drain(tester);
  });

  testWidgets('toast is keyed by the effect instance, not by build time', (
    tester,
  ) async {
    final controller = ConfettiController();
    addTearDown(controller.dispose);

    final effect = telifEffect();
    await tester.pumpWidget(app(stateWith(effect), controller));
    await tester.pump();

    expect(
      tester.widget<RewardToast>(find.byType(RewardToast)).key,
      ObjectKey(effect),
    );

    await drain(tester);
  });

  testWidgets('a genuinely new reward still gets a fresh toast element', (
    tester,
  ) async {
    final controller = ConfettiController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(app(stateWith(telifEffect()), controller));
    await tester.pump(const Duration(milliseconds: 120));
    final firstElement = tester.element(find.byType(RewardToast));

    // Back-to-back rewards (Telif then Baskı) must each animate in on their
    // own — the identity keying must not collapse distinct rewards into one.
    final baski = FloatingEffect(
      'Baski: İntibah',
      Colors.lightBlueAccent,
      title: 'BASKI YÜKSELTİLDİ',
      icon: Icons.print_rounded,
      anchorTilePosition: 0,
    );
    await tester.pumpWidget(app(stateWith(baski), controller));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byType(RewardToast), findsOneWidget);
    expect(tester.element(find.byType(RewardToast)), isNot(same(firstElement)));
    expect(find.text('BASKI YÜKSELTİLDİ'), findsOneWidget);

    await drain(tester);
  });

  testWidgets('no toast is rendered when there is no active reward', (
    tester,
  ) async {
    final controller = ConfettiController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(app(stateWith(null), controller));
    await tester.pump();

    expect(find.byType(RewardToast), findsNothing);

    await drain(tester);
  });
}
