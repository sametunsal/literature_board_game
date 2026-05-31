import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/services/board_book_lookup_service.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/data/book_config.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/tile_type.dart';

void main() {
  group('BoardBookLookupService', () {
    test('tile without bookId returns null', () {
      const tile = BoardTile(
        id: 'empty',
        name: 'Empty',
        position: 99,
        type: TileType.category,
        category: 'benKimim',
        difficulty: Difficulty.easy,
      );

      expect(BoardBookLookupService.bookForTile(tile), isNull);
      expect(BoardBookLookupService.isBookTile(tile), isFalse);
    });

    test('tile with valid bookId returns matching Book', () {
      final book = BookConfig.books.first;
      final tile = BoardConfig.tiles.singleWhere(
        (tile) => tile.position == book.tilePosition,
      );

      final resolvedBook = BoardBookLookupService.bookForTile(tile);

      expect(resolvedBook, isNotNull);
      expect(resolvedBook!.id, book.id);
      expect(resolvedBook.tilePosition, tile.position);
      expect(BoardBookLookupService.isBookTile(tile), isTrue);
    });

    test('board position lookup returns matching Book', () {
      final book = BookConfig.books.first;

      final resolvedBook = BoardBookLookupService.bookAtPosition(
        book.tilePosition,
      );

      expect(resolvedBook, isNotNull);
      expect(resolvedBook!.id, book.id);
    });

    test('special tiles are not book tiles', () {
      final specialTiles = BoardConfig.tiles
          .where((tile) => tile.type != TileType.category)
          .toList();

      expect(specialTiles, isNotEmpty);
      for (final tile in specialTiles) {
        expect(BoardBookLookupService.bookForTile(tile), isNull);
        expect(BoardBookLookupService.isBookTile(tile), isFalse);
      }
    });

    test('all book tiles are category tiles', () {
      final bookTiles = BoardBookLookupService.bookTiles();

      expect(bookTiles, hasLength(BookConfig.expectedBookCount));
      for (final tile in bookTiles) {
        expect(tile.type, TileType.category);
      }
    });

    test('all mapped books have tile.position == book.tilePosition', () {
      final bookTiles = BoardBookLookupService.bookTiles();

      for (final tile in bookTiles) {
        final book = BoardBookLookupService.bookForTile(tile);

        expect(book, isNotNull);
        expect(tile.position, book!.tilePosition);
      }
    });

    test('invalid bookId returns null and false', () {
      const tile = BoardTile(
        id: 'invalid',
        name: 'Invalid',
        position: 99,
        type: TileType.category,
        category: 'benKimim',
        bookId: 'missing_book',
        difficulty: Difficulty.easy,
      );

      expect(BoardBookLookupService.bookForTile(tile), isNull);
      expect(BoardBookLookupService.isBookTile(tile), isFalse);
    });

    test('lookup does not mutate input tile or config data', () {
      final originalTiles = BoardConfig.tiles;
      final originalTile = originalTiles.firstWhere(
        (tile) => tile.bookId != null,
      );
      final originalJson = originalTile.toJson();
      final originalBookIds = BookConfig.books.map((book) => book.id).toList();

      final book = BoardBookLookupService.bookForTile(originalTile);
      final bookTiles = BoardBookLookupService.bookTiles(tiles: originalTiles);

      expect(book, isNotNull);
      expect(bookTiles, isNot(same(originalTiles)));
      expect(originalTile.toJson(), originalJson);
      expect(BookConfig.books.map((book) => book.id).toList(), originalBookIds);
    });
  });
}
