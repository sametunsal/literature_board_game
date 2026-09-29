import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/dialogs/pause_dialog.dart';
import 'package:literature_board_game/presentation/dialogs/settings_dialog.dart';
import 'package:literature_board_game/presentation/widgets/board/game_controls_overlay.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

/// Regression tests for the pause-menu <-> settings-dialog layering.
///
/// In [embedded] mode the pause surface is a root-overlay [OverlayEntry],
/// which sits above navigator routes; a plain [showDialog] would therefore
/// open behind it. The settings flow must hide the pause surface, keep the
/// game paused, and restore the pause surface when the dialog closes.
void main() {
  group('embedded GameControlsOverlay', () {
    testWidgets(
      'settings opens above pause menu, pause returns after close, game stays paused',
      (tester) async {
        final container = await _pumpApp(tester, embedded: true);

        await tester.pumpAndSettle();
        expect(container.read(gameProvider).isGamePaused, isFalse);

        // Open the pause menu (root-overlay entry).
        await tester.tap(find.byIcon(Icons.pause));
        await tester.pumpAndSettle();
        expect(find.byType(PauseDialog), findsOneWidget);
        expect(container.read(gameProvider).isGamePaused, isTrue);

        // Open settings: the dialog must be reachable and the pause surface
        // must not stay on top of it.
        await tester.tap(find.text('AYARLAR'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsDialog), findsOneWidget);
        expect(find.byType(PauseDialog), findsNothing);
        expect(container.read(gameProvider).isGamePaused, isTrue);

        // Close settings: the pause menu comes back exactly once and the
        // game is still paused.
        await tester.tap(find.text('TAMAM'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsDialog), findsNothing);
        expect(find.byType(PauseDialog), findsOneWidget);
        expect(container.read(gameProvider).isGamePaused, isTrue);

        // Resume from the restored pause menu.
        await tester.tap(find.text('OYUNA DÖN'));
        await tester.pumpAndSettle();
        expect(find.byType(PauseDialog), findsNothing);
        expect(container.read(gameProvider).isGamePaused, isFalse);
      },
    );
  });

  group('non-embedded GameControlsOverlay', () {
    testWidgets(
      'settings opens above pause menu, pause returns after close, game stays paused',
      (tester) async {
        final container = await _pumpApp(tester, embedded: false);

        await tester.pumpAndSettle();
        expect(container.read(gameProvider).isGamePaused, isFalse);

        await tester.tap(find.byIcon(Icons.pause));
        await tester.pumpAndSettle();
        expect(find.byType(PauseDialog), findsOneWidget);
        expect(container.read(gameProvider).isGamePaused, isTrue);

        await tester.tap(find.text('AYARLAR'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsDialog), findsOneWidget);
        expect(find.byType(PauseDialog), findsNothing);
        expect(container.read(gameProvider).isGamePaused, isTrue);

        await tester.tap(find.text('TAMAM'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsDialog), findsNothing);
        expect(find.byType(PauseDialog), findsOneWidget);
        expect(container.read(gameProvider).isGamePaused, isTrue);

        await tester.tap(find.text('OYUNA DÖN'));
        await tester.pumpAndSettle();
        expect(find.byType(PauseDialog), findsNothing);
        expect(container.read(gameProvider).isGamePaused, isFalse);
      },
    );
  });
}

Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  required bool embedded,
}) async {
  final container = ProviderContainer(
    overrides: [
      gameProvider.overrideWith((ref) {
        final notifier = GameNotifier(ref);
        notifier.updateState(
          GameState(
            players: const [
              Player(
                id: 'p1',
                name: 'Player 1',
                color: Colors.red,
                iconIndex: 0,
                stars: 12,
              ),
            ],
            tiles: BoardConfig.tiles,
            phase: GamePhase.playerTurn,
            bookOwnerships: const {},
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
      child: MaterialApp(
        home: Scaffold(body: GameControlsOverlay(embedded: embedded)),
      ),
    ),
  );
  return container;
}
