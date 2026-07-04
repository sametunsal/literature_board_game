import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literature_board_game/core/utils/board_layout_config.dart';
import 'package:literature_board_game/core/utils/board_layout_helper.dart';
import 'package:literature_board_game/core/utils/board_topology.dart';
import 'package:literature_board_game/data/board_config.dart';

void main() {
  const topology = BoardTopology.standard;

  group('BoardTopology invariants (standard 7/4 landscape topology)', () {
    test('boardSize is 26', () {
      expect(topology.boardSize, 26);
      expect(BoardConfig.boardSize, 26);
    });

    test('corner indices are 0, 8, 13, 21 in path order', () {
      expect(topology.cornerIndices, [0, 8, 13, 21]);
      expect(topology.bottomRightCorner, 0);
      expect(topology.bottomLeftCorner, 8);
      expect(topology.topLeftCorner, 13);
      expect(topology.topRightCorner, 21);
      expect(BoardConfig.cornerIndices, [0, 8, 13, 21]);
      expect(BoardConfig.startPosition, 0);
      expect(BoardConfig.signingDayPosition, 8);
      expect(BoardConfig.shopPosition, 13);
      expect(BoardConfig.libraryPosition, 21);
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

    test('side ranges are bottom 1-7, left 9-12, top 14-20, right 22-25', () {
      expect(topology.middleRangeOf(BoardSide.bottom), (first: 1, last: 7));
      expect(topology.middleRangeOf(BoardSide.left), (first: 9, last: 12));
      expect(topology.middleRangeOf(BoardSide.top), (first: 14, last: 20));
      expect(topology.middleRangeOf(BoardSide.right), (first: 22, last: 25));

      for (var id = 1; id <= 7; id++) {
        expect(topology.middleSideOf(id), BoardSide.bottom);
        expect(topology.middleIndexOf(id), id);
      }
      for (var id = 9; id <= 12; id++) {
        expect(topology.middleSideOf(id), BoardSide.left);
        expect(topology.middleIndexOf(id), id - 8);
      }
      for (var id = 14; id <= 20; id++) {
        expect(topology.middleSideOf(id), BoardSide.top);
        expect(topology.middleIndexOf(id), id - 13);
      }
      for (var id = 22; id <= 25; id++) {
        expect(topology.middleSideOf(id), BoardSide.right);
        expect(topology.middleIndexOf(id), id - 21);
      }
    });

    test('side middle counts are 7/4/7/4', () {
      expect(topology.middleCountOf(BoardSide.bottom), 7);
      expect(topology.middleCountOf(BoardSide.left), 4);
      expect(topology.middleCountOf(BoardSide.top), 7);
      expect(topology.middleCountOf(BoardSide.right), 4);
    });

    test('rotation quarters follow board sides', () {
      for (final id in topology.cornerIndices) {
        expect(topology.rotationQuarterTurns(id), 0, reason: 'corner $id');
      }
      for (var id = 1; id <= 7; id++) {
        expect(topology.rotationQuarterTurns(id), 0, reason: 'bottom $id');
      }
      for (var id = 9; id <= 12; id++) {
        expect(topology.rotationQuarterTurns(id), 3, reason: 'left $id');
      }
      for (var id = 14; id <= 20; id++) {
        expect(topology.rotationQuarterTurns(id), 2, reason: 'top $id');
      }
      for (var id = 22; id <= 25; id++) {
        expect(topology.rotationQuarterTurns(id), 1, reason: 'right $id');
      }
    });

    test('path wraps: last tile (25) is the right run end, adjacent to 0', () {
      expect(topology.middleRangeOf(BoardSide.right).last, 25);
      expect(topology.boardSize - 1, 25);
      expect((25 + 1) % topology.boardSize, topology.bottomRightCorner);
      expect(topology.isValidTile(25), isTrue);
      expect(topology.isValidTile(26), isFalse);
      expect(topology.isValidTile(-1), isFalse);
    });

    test('geometry units give a 10:7 landscape board', () {
      expect(topology.sideRatio, 1.5);
      expect(topology.widthUnits, 10.0); // 2*1.5 + 7
      expect(topology.heightUnits, 7.0); // 2*1.5 + 4
      expect(topology.aspectRatio, closeTo(10 / 7, 1e-12));
    });
  });

  group('BoardTopology derivation holds for the legacy 5/6 portrait shape',
      () {
    // The pre-redesign topology, kept as an explicit instance to prove the
    // derivation math generalizes beyond the shipped constants.
    const legacy = BoardTopology(
      horizontalMiddleCount: 5,
      verticalMiddleCount: 6,
    );

    test('legacy invariants', () {
      expect(legacy.boardSize, 26);
      expect(legacy.cornerIndices, [0, 6, 13, 19]);
      expect(legacy.middleRangeOf(BoardSide.bottom), (first: 1, last: 5));
      expect(legacy.middleRangeOf(BoardSide.left), (first: 7, last: 12));
      expect(legacy.middleRangeOf(BoardSide.top), (first: 14, last: 18));
      expect(legacy.middleRangeOf(BoardSide.right), (first: 20, last: 25));
      expect(legacy.widthUnits, 8.0);
      expect(legacy.heightUnits, 9.0);
      expect(legacy.aspectRatio, closeTo(8 / 9, 1e-12));
    });
  });

  group('Board geometry (standard topology through the layout pipeline)', () {
    const screenSizes = [
      Size(800, 360),
      Size(914, 411),
      Size(1280, 720),
      Size(1920, 1080),
    ];

    test('board dimensions follow 10x7 kShort units', () {
      for (final size in screenSizes) {
        final layout = BoardLayoutConfig.fromScreen(size);
        expect(layout.kLongSide, closeTo(layout.kShortSide * 1.5, 1e-9));
        expect(
          layout.actualWidth,
          closeTo(10 * layout.kShortSide, 1e-9),
          reason: 'width at $size',
        );
        expect(
          layout.actualHeight,
          closeTo(7 * layout.kShortSide, 1e-9),
          reason: 'height at $size',
        );
        expect(layout.aspectRatio, closeTo(10 / 7, 1e-9));
      }
    });

    test('all 26 tile centers are unique and inside the board', () {
      for (final size in screenSizes) {
        final layout = BoardLayoutConfig.fromScreen(size);
        final centers = <Offset>[];
        for (var id = 0; id < topology.boardSize; id++) {
          final center = BoardLayoutHelper.getTileCenter(id, layout);
          expect(center.dx, inInclusiveRange(0, layout.actualWidth));
          expect(center.dy, inInclusiveRange(0, layout.actualHeight));
          for (final other in centers) {
            expect(
              (center - other).distance,
              greaterThan(layout.kShortSide * 0.5),
              reason: 'tile $id center too close to another at $size',
            );
          }
          centers.add(center);

          final rect = BoardLayoutHelper.getTileRect(id, layout);
          expect(rect.left, greaterThanOrEqualTo(-1e-9));
          expect(rect.top, greaterThanOrEqualTo(-1e-9));
          expect(rect.right, lessThanOrEqualTo(layout.actualWidth + 1e-9));
          expect(rect.bottom, lessThanOrEqualTo(layout.actualHeight + 1e-9));
        }
      }
    });

    test('consecutive tiles are spatially adjacent, including the 25→0 wrap',
        () {
      // Max legal step along the path: middle↔corner transition, whose
      // center distance is kLong/2 + kShort/2 = 1.25 * kShort.
      for (final size in screenSizes) {
        final layout = BoardLayoutConfig.fromScreen(size);
        final maxStep = 1.25 * layout.kShortSide + 1e-6;
        for (var id = 0; id < topology.boardSize; id++) {
          final next = (id + 1) % topology.boardSize;
          final a = BoardLayoutHelper.getTileCenter(id, layout);
          final b = BoardLayoutHelper.getTileCenter(next, layout);
          final distance = (a - b).distance;
          expect(
            distance,
            lessThanOrEqualTo(maxStep),
            reason: 'tiles $id→$next too far apart at $size',
          );
          expect(
            distance,
            greaterThan(layout.kShortSide * 0.9),
            reason: 'tiles $id→$next overlap at $size',
          );
        }
      }
    });

    test('center area is landscape and 40% of the board', () {
      final layout = BoardLayoutConfig.fromScreen(const Size(914, 411));
      final centerWidth = layout.actualWidth - 2 * layout.kLongSide;
      final centerHeight = layout.actualHeight - 2 * layout.kLongSide;
      final centerFraction = (centerWidth * centerHeight) /
          (layout.actualWidth * layout.actualHeight);
      expect(centerWidth / centerHeight, closeTo(7 / 4, 1e-9));
      expect(centerFraction, closeTo(0.40, 0.01));
      // Perimeter must dominate: center stays well under half the board.
      expect(centerFraction, lessThan(0.45));
      expect(centerFraction, greaterThan(0.30));
    });

    test('every tile center lies inside its own tile rect', () {
      final layout = BoardLayoutConfig.fromScreen(const Size(914, 411));
      for (var id = 0; id < topology.boardSize; id++) {
        final rect = BoardLayoutHelper.getTileRect(id, layout);
        final center = BoardLayoutHelper.getTileCenter(id, layout);
        expect(rect.contains(center), isTrue, reason: 'tile $id');
      }
    });
  });
}
