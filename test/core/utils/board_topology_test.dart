import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/utils/board_layout_config.dart';
import 'package:literature_board_game/core/utils/board_layout_helper.dart';
import 'package:literature_board_game/core/utils/board_topology.dart';
import 'package:literature_board_game/data/board_config.dart';

void main() {
  const topology = BoardTopology.standard;

  group('BoardTopology invariants (standard 5/6 topology)', () {
    test('boardSize is 26', () {
      expect(topology.boardSize, 26);
      expect(BoardConfig.boardSize, 26);
    });

    test('corner indices are 0, 6, 13, 19 in path order', () {
      expect(topology.cornerIndices, [0, 6, 13, 19]);
      expect(topology.bottomRightCorner, 0);
      expect(topology.bottomLeftCorner, 6);
      expect(topology.topLeftCorner, 13);
      expect(topology.topRightCorner, 19);
      expect(BoardConfig.cornerIndices, [0, 6, 13, 19]);
      expect(BoardConfig.startPosition, 0);
      expect(BoardConfig.signingDayPosition, 6);
      expect(BoardConfig.shopPosition, 13);
      expect(BoardConfig.libraryPosition, 19);
    });

    test('every tile maps to exactly one classification', () {
      for (var id = 0; id < topology.boardSize; id++) {
        final isCorner = topology.isCorner(id);
        final side = topology.middleSideOf(id);
        expect(
          isCorner ? side == null : side != null,
          isTrue,
          reason: 'Tile $id must be either a corner or on exactly one side '
              '(isCorner=$isCorner, side=$side)',
        );
      }
    });

    test('side ranges match the legacy hardcoded runs', () {
      expect(topology.middleRangeOf(BoardSide.bottom), (first: 1, last: 5));
      expect(topology.middleRangeOf(BoardSide.left), (first: 7, last: 12));
      expect(topology.middleRangeOf(BoardSide.top), (first: 14, last: 18));
      expect(topology.middleRangeOf(BoardSide.right), (first: 20, last: 25));

      for (var id = 1; id <= 5; id++) {
        expect(topology.middleSideOf(id), BoardSide.bottom);
        expect(topology.middleIndexOf(id), id);
      }
      for (var id = 7; id <= 12; id++) {
        expect(topology.middleSideOf(id), BoardSide.left);
        expect(topology.middleIndexOf(id), id - 6);
      }
      for (var id = 14; id <= 18; id++) {
        expect(topology.middleSideOf(id), BoardSide.top);
        expect(topology.middleIndexOf(id), id - 13);
      }
      for (var id = 20; id <= 25; id++) {
        expect(topology.middleSideOf(id), BoardSide.right);
        expect(topology.middleIndexOf(id), id - 19);
      }
    });

    test('side middle counts are 5/6/5/6', () {
      expect(topology.middleCountOf(BoardSide.bottom), 5);
      expect(topology.middleCountOf(BoardSide.left), 6);
      expect(topology.middleCountOf(BoardSide.top), 5);
      expect(topology.middleCountOf(BoardSide.right), 6);
    });

    test('rotation quarters match the legacy per-side values', () {
      for (final id in topology.cornerIndices) {
        expect(topology.rotationQuarterTurns(id), 0, reason: 'corner $id');
      }
      for (var id = 1; id <= 5; id++) {
        expect(topology.rotationQuarterTurns(id), 0, reason: 'bottom $id');
      }
      for (var id = 7; id <= 12; id++) {
        expect(topology.rotationQuarterTurns(id), 3, reason: 'left $id');
      }
      for (var id = 14; id <= 18; id++) {
        expect(topology.rotationQuarterTurns(id), 2, reason: 'top $id');
      }
      for (var id = 20; id <= 25; id++) {
        expect(topology.rotationQuarterTurns(id), 1, reason: 'right $id');
      }
    });

    test('path wraps: last tile (25) is the right run end, adjacent to 0', () {
      expect(topology.middleRangeOf(BoardSide.right).last, 25);
      expect(topology.boardSize - 1, 25);
      // The tile after 25 in path order is the start corner.
      expect((25 + 1) % topology.boardSize, topology.bottomRightCorner);
      expect(topology.isValidTile(25), isTrue);
      expect(topology.isValidTile(26), isFalse);
      expect(topology.isValidTile(-1), isFalse);
    });

    test('geometry units match the legacy constants', () {
      expect(topology.sideRatio, 1.5);
      expect(topology.widthUnits, 8.0); // 2*1.5 + 5
      expect(topology.heightUnits, 9.0); // 2*1.5 + 6
      expect(topology.aspectRatio, closeTo(8 / 9, 1e-12));
    });
  });

  group('Layout equivalence with pre-topology geometry', () {
    const screenSizes = [
      Size(800, 360),
      Size(914, 411),
      Size(1280, 720),
      Size(1920, 1080),
    ];

    test('board dimensions follow 8x9 kShort units', () {
      for (final size in screenSizes) {
        final layout = BoardLayoutConfig.fromScreen(size);
        expect(layout.kLongSide, closeTo(layout.kShortSide * 1.5, 1e-9));
        expect(
          layout.actualWidth,
          closeTo(8 * layout.kShortSide, 1e-9),
          reason: 'width at $size',
        );
        expect(
          layout.actualHeight,
          closeTo(9 * layout.kShortSide, 1e-9),
          reason: 'height at $size',
        );
        expect(layout.aspectRatio, closeTo(8 / 9, 1e-9));
      }
    });

    test('every tile center and size matches the legacy hardcoded math', () {
      for (final size in screenSizes) {
        final layout = BoardLayoutConfig.fromScreen(size);
        for (var id = 0; id < topology.boardSize; id++) {
          final center = BoardLayoutHelper.getTileCenter(id, layout);
          final expected = _legacyTileCenter(id, layout);
          expect(
            center.dx,
            closeTo(expected.dx, 1e-9),
            reason: 'tile $id center.dx at $size',
          );
          expect(
            center.dy,
            closeTo(expected.dy, 1e-9),
            reason: 'tile $id center.dy at $size',
          );

          final tileSize = BoardLayoutHelper.getTileSize(id, layout);
          final expectedSize = _legacyTileSize(id, layout);
          expect(
            tileSize.width,
            closeTo(expectedSize.width, 1e-9),
            reason: 'tile $id width at $size',
          );
          expect(
            tileSize.height,
            closeTo(expectedSize.height, 1e-9),
            reason: 'tile $id height at $size',
          );
        }
      }
    });
  });
}

/// Verbatim copy of the pre-topology BoardLayoutHelper.getTileCenter math
/// (hardcoded 26-tile ranges) used as the equivalence oracle.
Offset _legacyTileCenter(int tileId, BoardLayoutConfig layout) {
  final kL = layout.kLongSide;
  final kS = layout.kShortSide;
  final w = layout.actualWidth;
  final h = layout.actualHeight;

  if (tileId == 0) return Offset(w - kL / 2, h - kL / 2);
  if (tileId == 6) return Offset(kL / 2, h - kL / 2);
  if (tileId == 13) return Offset(kL / 2, kL / 2);
  if (tileId == 19) return Offset(w - kL / 2, kL / 2);

  if (tileId >= 1 && tileId <= 5) {
    return Offset(w - kL - (tileId - 0.5) * kS, h - kL / 2);
  }
  if (tileId >= 7 && tileId <= 12) {
    return Offset(kL / 2, h - kL - (tileId - 6 - 0.5) * kS);
  }
  if (tileId >= 14 && tileId <= 18) {
    return Offset(kL + (tileId - 13 - 0.5) * kS, kL / 2);
  }
  return Offset(w - kL / 2, kL + (tileId - 19 - 0.5) * kS);
}

/// Verbatim copy of the pre-topology getTileWidth/getTileHeight ranges.
Size _legacyTileSize(int tileId, BoardLayoutConfig layout) {
  final kL = layout.kLongSide;
  final kS = layout.kShortSide;
  if (const [0, 6, 13, 19].contains(tileId)) return Size(kL, kL);
  // Bottom/Top middle: vertical (kShort × kLong)
  if ((tileId >= 1 && tileId <= 5) || (tileId >= 14 && tileId <= 18)) {
    return Size(kS, kL);
  }
  // Left/Right middle: horizontal (kLong × kShort)
  return Size(kL, kS);
}
