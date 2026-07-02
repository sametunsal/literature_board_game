import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/data/board_config.dart';
import 'package:literature_board_game/models/tile_type.dart';

/// Guards against stale/duplicated board position constants: every named
/// position must point at a tile of the matching type in the generated tile
/// list, and the tile list must agree with the topology. If Phase 2 changes
/// the topology or renumbers tiles, these tests fail until data and
/// constants are remapped together.
void main() {
  group('BoardConfig position constants match tile data', () {
    test('tile list length matches topology boardSize', () {
      expect(BoardConfig.tiles.length, BoardConfig.boardSize);
      expect(BoardConfig.boardSize, BoardConfig.topology.boardSize);
    });

    test('tile positions are sequential and unique', () {
      final tiles = BoardConfig.tiles;
      for (var i = 0; i < tiles.length; i++) {
        expect(tiles[i].position, i, reason: 'tile at index $i');
      }
    });

    test('named corner positions point at the right tile types', () {
      expect(
        BoardConfig.getTile(BoardConfig.startPosition).type,
        TileType.start,
      );
      expect(
        BoardConfig.getTile(BoardConfig.signingDayPosition).type,
        TileType.signingDay,
      );
      expect(BoardConfig.getTile(BoardConfig.shopPosition).type, TileType.shop);
      expect(
        BoardConfig.getTile(BoardConfig.libraryPosition).type,
        TileType.library,
      );
    });

    test('corner positions are exactly the topology corners', () {
      expect(BoardConfig.cornerIndices, [
        BoardConfig.startPosition,
        BoardConfig.signingDayPosition,
        BoardConfig.shopPosition,
        BoardConfig.libraryPosition,
      ]);
    });

    test('chance/fate positions point at chance/fate tiles', () {
      expect(
        BoardConfig.getTile(BoardConfig.chancePosition1).type,
        TileType.chance,
      );
      expect(
        BoardConfig.getTile(BoardConfig.chancePosition2).type,
        TileType.chance,
      );
      expect(BoardConfig.getTile(BoardConfig.fatePosition1).type, TileType.fate);
      expect(BoardConfig.getTile(BoardConfig.fatePosition2).type, TileType.fate);
    });

    test('chance/fate tiles exist nowhere else on the board', () {
      final chancePositions = BoardConfig.tiles
          .where((tile) => tile.type == TileType.chance)
          .map((tile) => tile.position)
          .toList();
      final fatePositions = BoardConfig.tiles
          .where((tile) => tile.type == TileType.fate)
          .map((tile) => tile.position)
          .toList();
      expect(chancePositions, [
        BoardConfig.chancePosition1,
        BoardConfig.chancePosition2,
      ]);
      expect(fatePositions, [
        BoardConfig.fatePosition1,
        BoardConfig.fatePosition2,
      ]);
    });

    test('special corner tile types exist nowhere else on the board', () {
      for (final entry in {
        TileType.start: BoardConfig.startPosition,
        TileType.signingDay: BoardConfig.signingDayPosition,
        TileType.shop: BoardConfig.shopPosition,
        TileType.library: BoardConfig.libraryPosition,
      }.entries) {
        final positions = BoardConfig.tiles
            .where((tile) => tile.type == entry.key)
            .map((tile) => tile.position)
            .toList();
        expect(
          positions,
          [entry.value],
          reason: '${entry.key} must exist exactly once at ${entry.value}',
        );
      }
    });
  });
}
