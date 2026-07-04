import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/utils/board_layout_config.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/board/board_layout.dart';
import 'package:literature_board_game/presentation/widgets/enhanced_tile_widget.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

/// Phase 2 usability measurements: the landscape 10:7 board must not merely
/// fit the viewport — it must *use* it. The legacy 8:9 portrait board only
/// covered 38–48% of the screen width; these tests pin the improvement.
void main() {
  const screenSizes = [
    Size(800, 360),
    Size(914, 411),
    Size(1280, 720),
    Size(1920, 1080),
  ];

  testWidgets('board fills landscape viewports usefully', (tester) async {
    for (final size in screenSizes) {
      await _measureBoard(tester, size);
    }
  });
}

Future<void> _measureBoard(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final confettiController = ConfettiController();
  addTearDown(confettiController.dispose);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: BoardLayout(
            state: GameState(
              players: const [
                Player(
                  id: 'p1',
                  name: 'Oyuncu 1',
                  color: Colors.blue,
                  iconIndex: 0,
                ),
              ],
              tiles: BoardConfig.tiles,
            ),
            layout: BoardLayoutConfig.fromScreen(size),
            isDarkMode: false,
            confettiController: confettiController,
            onQuestionConfirm: () {},
            onQuestionCancel: () {},
          ),
        ),
      ),
    ),
  );
  // Two pumps: the first frame starts the board's entrance animation (scale
  // begins at 0.92), the second advances past it so we measure settled
  // geometry, not the animation's first frame.
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));

  final tileFinder = find.byType(EnhancedTileWidget);
  expect(tileFinder, findsNWidgets(BoardConfig.boardSize));

  // 1. Viewport fit: every tile fully on screen.
  Rect? unionRect;
  for (var i = 0; i < BoardConfig.boardSize; i++) {
    final rect = tester.getRect(tileFinder.at(i));
    expect(rect.left, greaterThanOrEqualTo(-0.5), reason: 'tile $i at $size');
    expect(rect.top, greaterThanOrEqualTo(-0.5), reason: 'tile $i at $size');
    expect(
      rect.right,
      lessThanOrEqualTo(size.width + 0.5),
      reason: 'tile $i at $size',
    );
    expect(
      rect.bottom,
      lessThanOrEqualTo(size.height + 0.5),
      reason: 'tile $i at $size',
    );
    unionRect = unionRect == null ? rect : unionRect.expandToInclude(rect);
  }
  unionRect!;

  // 2. Vertical dominance (as before): board must stay visually large.
  final heightUsage = unionRect.height / size.height;
  expect(
    heightUsage,
    greaterThanOrEqualTo(0.82),
    reason: 'Board too small vertically at $size: '
        '${unionRect.height} < 0.82 * ${size.height}',
  );

  // 3. Landscape width usage: the legacy portrait board peaked at ~48% and
  // sat at ~38% on phones. The 10:7 board must clearly beat that.
  final widthUsage = unionRect.width / size.width;
  expect(
    widthUsage,
    greaterThanOrEqualTo(0.55),
    reason: 'Board wastes landscape width at $size: '
        'union ${unionRect.width} is ${(widthUsage * 100).toStringAsFixed(1)}% '
        'of ${size.width}',
  );

  // 4. Side-label long-axis space: a rotated side book label lays out along
  // its tile's width. After the 12px colour strip and 4px padding it must
  // keep enough length for a whole short title at a readable font size.
  final sideTileRect = tester.getRect(
    find
        .ancestor(
          of: find.textContaining('Çalıkuşu', findRichText: true),
          matching: find.byType(EnhancedTileWidget),
        )
        .first,
  );
  final sideLabelAxis = sideTileRect.width - 12 - 4;
  expect(
    sideLabelAxis,
    greaterThanOrEqualTo(50),
    reason: 'Side label long axis too short at $size: $sideLabelAxis',
  );

  debugPrint(
    'BOARD GEOMETRY ${size.width.toInt()}x${size.height.toInt()}: '
    'union=${unionRect.width.toStringAsFixed(1)}x'
    '${unionRect.height.toStringAsFixed(1)} '
    'widthUsage=${(widthUsage * 100).toStringAsFixed(1)}% '
    'heightUsage=${(heightUsage * 100).toStringAsFixed(1)}% '
    'sideLabelAxis=${sideLabelAxis.toStringAsFixed(1)}px',
  );

  await tester.pumpWidget(const SizedBox.shrink());
}
