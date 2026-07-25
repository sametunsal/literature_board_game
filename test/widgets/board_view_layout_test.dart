import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/board/game_controls_overlay.dart';
import 'package:literature_board_game/presentation/widgets/board/player_hud.dart';
import 'package:literature_board_game/presentation/widgets/board/player_hud_manager.dart';
import 'package:literature_board_game/presentation/widgets/board_view.dart';
import 'package:literature_board_game/presentation/widgets/enhanced_tile_widget.dart';
import 'package:literature_board_game/providers/game_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Landscape viewports the gameplay screen must survive, from the smallest
/// supported phone in landscape up to desktop/TV.
const List<Size> _viewports = [
  Size(800, 360),
  Size(914, 411),
  Size(1200, 700),
  Size(1920, 1080),
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('BoardView lays out without overflow at every landscape size', (
    tester,
  ) async {
    for (final size in _viewports) {
      await _pumpBoardView(tester, size);
      expect(
        tester.takeException(),
        isNull,
        reason: 'BoardView overflowed at $size',
      );
      await _tearDownBoardView(tester);
    }
  });

  testWidgets('board area and HUD column never intersect', (tester) async {
    for (final size in _viewports) {
      await _pumpBoardView(tester, size);

      final boardRect = tester.getRect(find.byKey(kBoardAreaKey));
      final hudRect = tester.getRect(find.byKey(kHudColumnKey));

      expect(
        boardRect.overlaps(hudRect),
        isFalse,
        reason: 'Board $boardRect overlaps HUD $hudRect at $size',
      );
      // The HUD column sits to the right of the board area.
      expect(hudRect.left, greaterThanOrEqualTo(boardRect.right - 0.5));

      await _tearDownBoardView(tester);
    }
  });

  testWidgets('every board tile stays inside the viewport', (tester) async {
    for (final size in _viewports) {
      await _pumpBoardView(tester, size);

      final tiles = find.byType(EnhancedTileWidget);
      expect(tiles, findsNWidgets(BoardConfig.boardSize));

      for (var i = 0; i < BoardConfig.boardSize; i++) {
        final rect = tester.getRect(tiles.at(i));
        expect(rect.left, greaterThanOrEqualTo(-0.5), reason: 'tile $i @ $size');
        expect(rect.top, greaterThanOrEqualTo(-0.5), reason: 'tile $i @ $size');
        expect(
          rect.right,
          lessThanOrEqualTo(size.width + 0.5),
          reason: 'tile $i @ $size',
        );
        // Bottom edge is the one the old floating-HUD layout used to clip.
        expect(
          rect.bottom,
          lessThanOrEqualTo(size.height + 0.5),
          reason: 'tile $i @ $size',
        );
      }

      await _tearDownBoardView(tester);
    }
  });

  testWidgets('HUD column shows player panels and menu controls', (
    tester,
  ) async {
    for (final size in _viewports) {
      await _pumpBoardView(tester, size);

      expect(find.byKey(kHudColumnKey), findsOneWidget);
      expect(
        find.byType(PlayerHud),
        findsWidgets,
        reason: 'no player panels at $size',
      );
      expect(find.byType(GameControlsOverlay), findsOneWidget);
      // Pause, portfolio and bot-mode buttons.
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byTooltip('Yayın portföyü'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);

      // The HUD column is really on screen, with a usable width.
      final hudRect = tester.getRect(find.byKey(kHudColumnKey));
      expect(hudRect.width, greaterThan(120));
      expect(hudRect.right, closeTo(size.width, 0.5));

      await _tearDownBoardView(tester);
    }
  });

  testWidgets('board area still dominates the viewport', (tester) async {
    for (final size in _viewports) {
      await _pumpBoardView(tester, size);

      final boardRect = tester.getRect(find.byKey(kBoardAreaKey));
      expect(
        boardRect.width,
        greaterThanOrEqualTo(size.width * 0.65),
        reason: 'board area only ${boardRect.width} wide at $size',
      );
      expect(
        boardRect.height,
        greaterThanOrEqualTo(size.height * 0.80),
        reason: 'board area only ${boardRect.height} tall at $size',
      );

      await _tearDownBoardView(tester);
    }
  });

  testWidgets('six players fit the HUD column on a 800x360 viewport', (
    tester,
  ) async {
    const size = Size(800, 360);
    await _pumpBoardView(tester, size, playerCount: 6);

    expect(tester.takeException(), isNull);
    expect(find.byKey(kHudColumnKey), findsOneWidget);
    expect(find.byType(PlayerHud), findsNWidgets(6));
    expect(find.byIcon(Icons.pause), findsOneWidget);

    final boardRect = tester.getRect(find.byKey(kBoardAreaKey));
    final hudRect = tester.getRect(find.byKey(kHudColumnKey));
    expect(boardRect.overlaps(hudRect), isFalse);

    // The panel list scrolls rather than overflowing.
    expect(
      find.descendant(
        of: find.byKey(kHudColumnKey),
        matching: find.byType(SingleChildScrollView),
      ),
      findsWidgets,
    );

    await _tearDownBoardView(tester);
  });

  testWidgets('PlayerHudManager still pumps standalone in perimeter mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PlayerHudManager(state: _gameState(4))),
      ),
    );
    await tester.pump();

    expect(find.byType(PlayerHud), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}

// ─── Helpers ────────────────────────────────────────────────────────────────

Future<void> _pumpBoardView(
  WidgetTester tester,
  Size size, {
  int playerCount = 3,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameProvider.overrideWith((ref) {
          final notifier = GameNotifier(ref);
          notifier.updateState(_gameState(playerCount));
          return notifier;
        }),
      ],
      child: const MaterialApp(home: BoardView()),
    ),
  );

  // Let the "Masa Hazırlanıyor" opening overlay and the board entrance
  // animation finish so the real layout is measured.
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _tearDownBoardView(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

GameState _gameState(int playerCount) {
  const colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];
  return GameState(
    players: [
      for (var i = 0; i < playerCount; i++)
        Player(
          id: 'p${i + 1}',
          name: 'Oyuncu ${i + 1}',
          color: colors[i % colors.length],
          iconIndex: i,
        ),
    ],
    tiles: BoardConfig.tiles,
    phase: GamePhase.playerTurn,
  );
}
