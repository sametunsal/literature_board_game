import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/player.dart';
import 'package:literature_board_game/presentation/widgets/board/board_visual_constants.dart';
import 'package:literature_board_game/presentation/widgets/board/player_hud.dart';
import 'package:literature_board_game/presentation/widgets/board/player_hud_manager.dart';
import 'package:literature_board_game/providers/game_notifier.dart';

void main() {
  Player player(int i) => Player(
    id: 'p$i',
    name: 'Oyuncu $i',
    color: Colors.primaries[i % Colors.primaries.length],
    iconIndex: i,
  );

  Future<void> setViewport(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('current, next, and idle HUD panels all share the same size', (
    tester,
  ) async {
    await setViewport(tester, const Size(800, 360));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              PlayerHud(player: player(0), isCurrentPlayer: true),
              PlayerHud(player: player(1), isNextPlayer: true),
              PlayerHud(player: player(2)),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final sizes = tester
        .widgetList(find.byType(PlayerHud))
        .map((w) => tester.getSize(find.byWidget(w)))
        .toList();
    expect(sizes, hasLength(3));
    for (final size in sizes) {
      expect(size, const Size(kPlayerHudCompactWidth, kPlayerHudHeight));
    }
    expect(tester.takeException(), isNull);
  });

  for (final (playerCount, viewport) in const [
    (2, Size(800, 360)),
    (4, Size(800, 360)),
    (6, Size(914, 411)),
  ]) {
    testWidgets(
      '$playerCount-player HUD layout renders without overflow at '
      '${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        await setViewport(tester, viewport);

        final state = GameState(
          players: List.generate(playerCount, player),
          tiles: BoardConfig.tiles,
          currentPlayerIndex: 0,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PlayerHudManager(state: state)),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(PlayerHud), findsNWidgets(playerCount));

        final sizes = tester
            .widgetList(find.byType(PlayerHud))
            .map((w) => tester.getSize(find.byWidget(w)))
            .toSet();
        expect(
          sizes,
          hasLength(1),
          reason: 'all HUD panels must share identical dimensions',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
