import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/models/board_tile.dart';
import 'package:literature_board_game/models/difficulty.dart';
import 'package:literature_board_game/models/tile_type.dart';

void main() {
  group('BoardTile bookId', () {
    test('defaults to null', () {
      const tile = BoardTile(
        id: '1',
        name: 'Category',
        position: 1,
        type: TileType.category,
        category: 'edebiSanatlar',
      );

      expect(tile.bookId, isNull);
    });

    test('copyWith preserves bookId by default', () {
      const tile = BoardTile(
        id: '1',
        name: 'Category',
        position: 1,
        type: TileType.category,
        category: 'edebiSanatlar',
        bookId: 'intibah',
      );

      final updated = tile.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
      expect(updated.bookId, 'intibah');
    });

    test('copyWith replaces bookId', () {
      const tile = BoardTile(
        id: '1',
        name: 'Category',
        position: 1,
        type: TileType.category,
        category: 'edebiSanatlar',
        bookId: 'intibah',
      );

      final updated = tile.copyWith(bookId: 'calikusu');

      expect(updated.bookId, 'calikusu');
    });

    test('JSON round trip preserves bookId', () {
      const tile = BoardTile(
        id: '1',
        name: 'Category',
        position: 1,
        type: TileType.category,
        category: 'edebiSanatlar',
        bookId: 'intibah',
        difficulty: Difficulty.hard,
      );

      final decoded = BoardTile.fromJson(tile.toJson());

      expect(decoded.id, tile.id);
      expect(decoded.name, tile.name);
      expect(decoded.position, tile.position);
      expect(decoded.type, tile.type);
      expect(decoded.category, tile.category);
      expect(decoded.bookId, tile.bookId);
      expect(decoded.difficulty, tile.difficulty);
    });
  });
}
