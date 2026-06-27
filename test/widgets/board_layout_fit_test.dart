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

void main() {
  testWidgets(
    'BoardLayout keeps every projected tile inside landscape viewport',
    (tester) async {
      await _expectBoardFits(tester, const Size(640, 360));
      await _expectBoardFits(tester, const Size(720, 360));
      await _expectBoardFits(tester, const Size(1920, 1080));
      await _expectBoardFits(tester, const Size(2400, 1080));
    },
  );
}

Future<void> _expectBoardFits(WidgetTester tester, Size size) async {
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
  await tester.pump(const Duration(seconds: 2));

  final tileFinder = find.byType(EnhancedTileWidget);
  expect(tileFinder, findsNWidgets(BoardConfig.boardSize));

  Rect? unionRect;
  for (var i = 0; i < BoardConfig.boardSize; i++) {
    final rect = tester.getRect(tileFinder.at(i));
    expect(rect.left, greaterThanOrEqualTo(-0.5));
    expect(rect.top, greaterThanOrEqualTo(-0.5));
    expect(rect.right, lessThanOrEqualTo(size.width + 0.5));
    expect(rect.bottom, lessThanOrEqualTo(size.height + 0.5));
    unionRect = unionRect == null ? rect : unionRect.expandToInclude(rect);
  }

  // Lower bound: the board must remain visually dominant. The union of all tile
  // rects should span at least 82% of the viewport height so the fit policy
  // cannot silently shrink the board back to a tiny size.
  expect(unionRect, isNotNull);
  expect(
    unionRect!.height,
    greaterThanOrEqualTo(size.height * 0.82),
    reason: 'Board too small: tile union height ${unionRect.height} '
        '< 0.82 * ${size.height}',
  );

  await tester.pumpWidget(const SizedBox.shrink());
}
