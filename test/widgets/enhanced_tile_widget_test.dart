import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/services/question_flow_service.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/tile_type.dart';
import 'package:literature_board_game/presentation/widgets/enhanced_tile_widget.dart';

void main() {
  testWidgets('book tile renders book title and category subtitle', (
    tester,
  ) async {
    final book = BookConfig.books.first;
    final tile = BoardConfig.tiles.singleWhere(
      (tile) => tile.position == book.tilePosition,
    );
    final categorySubtitle = QuestionFlowService.getCategoryDisplayName(
      tile.category!,
    );

    await tester.pumpWidget(_tileApp(tile));

    expect(find.text(_formatTileLabel(book.title)), findsOneWidget);
    expect(find.text(_formatTileLabel(categorySubtitle)), findsOneWidget);
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

    expect(find.text(_formatTileLabel(tile.name)), findsOneWidget);
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

String _formatTileLabel(String name) {
  if (!name.contains(' ') && !name.contains('-')) {
    return name;
  }

  final words = name
      .split(RegExp(r'[\s\-]+'))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) return name;
  if (words.length == 1) return words.first;
  if (words.length <= 3) return words.join('\n');

  return '${words[0]}\n${words.sublist(1, words.length - 1).join(' ')}\n${words.last}';
}
