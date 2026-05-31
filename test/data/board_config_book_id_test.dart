import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/tile_type.dart';

void main() {
  group('BoardConfig book IDs', () {
    test('all BookConfig books appear on exactly one board tile', () {
      for (final book in BookConfig.books) {
        final matchingTiles = BoardConfig.tiles
            .where((tile) => tile.bookId == book.id)
            .toList();

        expect(
          matchingTiles,
          hasLength(1),
          reason: 'Book ${book.id} should map to exactly one tile.',
        );
        expect(matchingTiles.single.position, book.tilePosition);
      }
    });

    test('all book tiles are category tiles', () {
      final bookTiles = BoardConfig.tiles
          .where((tile) => tile.bookId != null)
          .toList();

      expect(bookTiles, hasLength(BookConfig.expectedBookCount));
      for (final tile in bookTiles) {
        expect(tile.type, TileType.category);
      }
    });

    test('no special tiles have bookId', () {
      final specialTiles = BoardConfig.tiles
          .where((tile) => tile.type != TileType.category)
          .toList();

      for (final tile in specialTiles) {
        expect(
          tile.bookId,
          isNull,
          reason: 'Special tile ${tile.position} should not have bookId.',
        );
      }
    });
  });
}
