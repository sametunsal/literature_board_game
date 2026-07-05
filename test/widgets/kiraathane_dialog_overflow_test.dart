import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/dialogs/kiraathane_dialog.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  Future<void> pumpDialog(
    WidgetTester tester,
    Size size, {
    int akce = 5,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(gameProvider.notifier)
        .updateState(
          GameState(
            players: [
              Player(
                id: 'p1',
                name: 'Oyuncu 1',
                color: Colors.red,
                iconIndex: 0,
                stars: akce,
              ),
            ],
            tiles: BoardConfig.tiles,
            phase: GamePhase.playerTurn,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: KiraathaneDialog())),
        ),
      ),
    );
    await tester.pump();
  }

  group('KiraathaneDialog overflow', () {
    testWidgets('renders without overflow at 800x360 landscape', (
      tester,
    ) async {
      await pumpDialog(tester, const Size(800, 360));

      expect(tester.takeException(), isNull);
      expect(find.text('Vazgeç'), findsOneWidget);
    });

    testWidgets('renders without overflow at 914x411 landscape', (
      tester,
    ) async {
      await pumpDialog(tester, const Size(914, 411));

      expect(tester.takeException(), isNull);
      expect(find.text('Vazgeç'), findsOneWidget);
    });

    testWidgets('renders without overflow when player cannot afford Mesk', (
      tester,
    ) async {
      await pumpDialog(tester, const Size(800, 360), akce: 0);

      expect(tester.takeException(), isNull);
      // Vazgeç must remain visible and tappable even when broke.
      expect(find.text('Vazgeç'), findsOneWidget);
    });
  });
}
