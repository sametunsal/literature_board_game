import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/game_enums.dart';
import 'package:literature_board_game/models/tile_type.dart';
import 'package:literature_board_game/presentation/widgets/enhanced_tile_widget.dart';

void main() {
  testWidgets('book tile renders book title without category subtitle', (
    tester,
  ) async {
    final book = BookConfig.books.first;
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );
    final categoryDisplayName =
        book.category.displayName;

    await tester.pumpWidget(_tileApp(tile));

    expect(find.text(book.title), findsOneWidget);
    expect(find.text(categoryDisplayName), findsNothing);
  });

  testWidgets('special tile label remains unchanged', (tester) async {
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.type == TileType.shop,
    );

    await tester.pumpWidget(_tileApp(tile));

    expect(find.text('KIRAATHANE'), findsOneWidget);
  });

  testWidgets('category tile without book falls back to tile name', (
    tester,
  ) async {
    const tile = BoardTile(
      id: 'fallback',
      name: 'Fallback Category',
      position: 99,
      type: TileType.category,
      category: 'benKimim',
      difficulty: Difficulty.easy,
    );

    await tester.pumpWidget(_tileApp(tile));

    expect(find.text('Fallback Category'), findsOneWidget);
  });

  testWidgets('same-category tiles share the same color strip', (
    tester,
  ) async {
    final sameCategoryTiles = BoardConfig.tiles
        .where(
          (t) =>
              t.type == TileType.category &&
              t.category == QuestionCategory.turkEdebiyatindaIlkler.name,
        )
        .toList();

    expect(sameCategoryTiles.length, greaterThanOrEqualTo(2));

    final colors = <Color>[];
    for (final tile in sameCategoryTiles) {
      await tester.pumpWidget(_tileApp(tile));

      final containers = find.byType(Container);
      final stripContainers = <Container>[];
      for (final element in containers.evaluate()) {
        final container = element.widget as Container;
        if (container.decoration == null && container.color != null) {
          stripContainers.add(container);
        }
      }

      expect(stripContainers, isNotEmpty);
      colors.add(stripContainers.first.color!);
    }

    for (final color in colors) {
      expect(color, equals(colors.first));
    }
  });

  testWidgets('book title uses fixed style with ellipsis overflow', (
    tester,
  ) async {
    final book = BookConfig.books.first;
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );

    await tester.pumpWidget(_tileApp(tile));

    final textWidget = tester.widget<Text>(find.text(book.title));
    expect(textWidget.maxLines, 2);
    expect(textWidget.overflow, TextOverflow.ellipsis);
  });
}

Widget _tileApp(BoardTile tile) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: EnhancedTileWidget(tile: tile, width: 100, height: 60),
      ),
    ),
  );
}
