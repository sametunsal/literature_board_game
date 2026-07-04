/// Which side of the board perimeter a tile sits on.
///
/// Corner tiles belong to no side; they are classified via
/// [BoardTopology.isCorner].
enum BoardSide { bottom, left, top, right }

/// Single source of truth for the board's perimeter topology.
///
/// The tile path walks counter-clockwise from the bottom-right corner:
///
/// ```
/// [TL]  [top middles →]        [TR]
/// [↑]                           [↓]
/// [left middles]      [right middles]
/// [↑]                           [↓]
/// [BL]  [← bottom middles]     [BR = 0]
/// ```
///
/// All indices — corners, per-side middle runs, board size — are derived
/// from two counts, so changing the tile distribution is a matter of
/// constructing a different [BoardTopology] instead of editing hardcoded
/// ranges across layout, rendering, and data files.
class BoardTopology {
  /// Middle tiles between corners on each horizontal side (bottom and top).
  final int horizontalMiddleCount;

  /// Middle tiles between corners on each vertical side (left and right).
  final int verticalMiddleCount;

  /// Ratio of a tile's long side to its short side (kLong / kShort).
  final double sideRatio;

  /// Default long/short tile side ratio shared by every topology.
  static const double defaultSideRatio = 1.5;

  const BoardTopology({
    required this.horizontalMiddleCount,
    required this.verticalMiddleCount,
    this.sideRatio = defaultSideRatio,
  });

  /// The topology currently shipped: 7 middles on bottom/top, 4 on
  /// left/right → 26 tiles, landscape board aspect 10:7 ≈ 1.43.
  ///
  /// The pre-redesign portrait topology was (5, 6) → aspect 8:9 ≈ 0.89,
  /// which wasted ~half the width of landscape-locked phone screens.
  static const BoardTopology standard = BoardTopology(
    horizontalMiddleCount: 7,
    verticalMiddleCount: 4,
  );

  /// Total tiles on the perimeter path.
  int get boardSize =>
      2 * horizontalMiddleCount + 2 * verticalMiddleCount + 4;

  // ═══════════════════════════════════════════════════════════════════════
  // CORNERS (path order: BR → BL → TL → TR)
  // ═══════════════════════════════════════════════════════════════════════

  /// Bottom-right corner — the path start.
  int get bottomRightCorner => 0;

  /// Bottom-left corner.
  int get bottomLeftCorner => horizontalMiddleCount + 1;

  /// Top-left corner.
  int get topLeftCorner => horizontalMiddleCount + verticalMiddleCount + 2;

  /// Top-right corner.
  int get topRightCorner =>
      2 * horizontalMiddleCount + verticalMiddleCount + 3;

  /// Corner tile ids in path order.
  List<int> get cornerIndices => [
    bottomRightCorner,
    bottomLeftCorner,
    topLeftCorner,
    topRightCorner,
  ];

  bool isCorner(int tileId) =>
      tileId == bottomRightCorner ||
      tileId == bottomLeftCorner ||
      tileId == topLeftCorner ||
      tileId == topRightCorner;

  bool isValidTile(int tileId) => tileId >= 0 && tileId < boardSize;

  // ═══════════════════════════════════════════════════════════════════════
  // MIDDLE RUNS
  // ═══════════════════════════════════════════════════════════════════════

  /// First and last middle tile id (inclusive) of [side]'s run.
  ({int first, int last}) middleRangeOf(BoardSide side) {
    switch (side) {
      case BoardSide.bottom:
        return (first: bottomRightCorner + 1, last: bottomLeftCorner - 1);
      case BoardSide.left:
        return (first: bottomLeftCorner + 1, last: topLeftCorner - 1);
      case BoardSide.top:
        return (first: topLeftCorner + 1, last: topRightCorner - 1);
      case BoardSide.right:
        return (first: topRightCorner + 1, last: boardSize - 1);
    }
  }

  /// Number of middle tiles on [side].
  int middleCountOf(BoardSide side) =>
      side == BoardSide.bottom || side == BoardSide.top
      ? horizontalMiddleCount
      : verticalMiddleCount;

  /// The side of a middle tile, or null for corners and invalid ids.
  BoardSide? middleSideOf(int tileId) {
    if (!isValidTile(tileId) || isCorner(tileId)) return null;
    if (tileId < bottomLeftCorner) return BoardSide.bottom;
    if (tileId < topLeftCorner) return BoardSide.left;
    if (tileId < topRightCorner) return BoardSide.top;
    return BoardSide.right;
  }

  /// 1-based position of a middle tile within its side's run, walking in
  /// path order (bottom: right→left, left: bottom→top, top: left→right,
  /// right: top→bottom). Returns 0 for corners and invalid ids.
  int middleIndexOf(int tileId) {
    final side = middleSideOf(tileId);
    if (side == null) return 0;
    return tileId - middleRangeOf(side).first + 1;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RENDERING HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  /// Quarter turns applied to a tile's content so it faces the board center:
  /// 0 = bottom row and corners, 1 = right column (90° CW), 2 = top row
  /// (180°), 3 = left column (270°).
  int rotationQuarterTurns(int tileId) {
    switch (middleSideOf(tileId)) {
      case null:
        return 0; // Corners (and invalid ids) render unrotated.
      case BoardSide.bottom:
        return 0;
      case BoardSide.right:
        return 1;
      case BoardSide.top:
        return 2;
      case BoardSide.left:
        return 3;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // GEOMETRY UNITS
  // ═══════════════════════════════════════════════════════════════════════

  /// Board width in kShort units: two corners (sideRatio each) plus the
  /// horizontal middle run.
  double get widthUnits => 2 * sideRatio + horizontalMiddleCount;

  /// Board height in kShort units: two corners plus the vertical middle run.
  double get heightUnits => 2 * sideRatio + verticalMiddleCount;

  /// Intrinsic board aspect ratio (width / height).
  double get aspectRatio => widthUnits / heightUnits;
}
