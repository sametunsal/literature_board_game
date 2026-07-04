import 'package:flutter/material.dart';
import 'board_topology.dart';

/// Configuration class for HYBRID MONOPOLY-STYLE board layout
///
/// **MIXED TILE ORIENTATIONS:**
/// - Corner tiles: SQUARE (kLong × kLong)
/// - Bottom/Top middle tiles: VERTICAL (kShort width × kLong height)
/// - Left/Right middle tiles: HORIZONTAL (kLong width × kShort height)
///
/// Tile distribution, corner indices, and side ranges all come from
/// [BoardTopology] — see [topology].
class BoardLayoutConfig {
  final double screenWidth;
  final double screenHeight;

  /// Short side of category tiles
  late final double kShortSide;

  /// Long side of category tiles ([sideRatio]x short side)
  late final double kLongSide;

  /// Perimeter topology driving all tile counts, indices, and unit math.
  static const BoardTopology topology = BoardTopology.standard;

  /// Ratio of long side to short side
  static const double sideRatio = BoardTopology.defaultSideRatio;

  /// Board size ratio relative to screen (will be adjusted dynamically)
  static const double boardToScreenRatio = 0.94;

  /// Minimum board size ratio for tiny screens
  static const double minBoardToScreenRatio = 0.85;

  /// Maximum board size ratio for large screens
  static const double maxBoardToScreenRatio = 0.94;

  /// Number of middle tiles on Bottom/Top rows (between corners)
  static int get middleTilesHorizontal => topology.horizontalMiddleCount;

  /// Number of middle tiles on Left/Right columns (between corners)
  static int get middleTilesVertical => topology.verticalMiddleCount;

  /// Corner indices
  static List<int> get cornerIndices => topology.cornerIndices;

  BoardLayoutConfig({required this.screenWidth, required this.screenHeight}) {
    // Board dimensions formula (counts from topology):
    // actualWidth = 2*kLong + horizontalMiddleCount*kShort
    // actualHeight = 2*kLong + verticalMiddleCount*kShort
    //
    // With the standard 7/4 topology and kLong = kShort * 1.5:
    // actualWidth = 3*kShort + 7*kShort = 10*kShort
    // actualHeight = 3*kShort + 4*kShort = 7*kShort
    //
    // Aspect ratio = 10/7 ≈ 1.43 (landscape)

    // Dynamic board-to-screen ratio based on screen size
    final shortestSide = screenWidth < screenHeight
        ? screenWidth
        : screenHeight;
    final dynamicRatio = _calculateDynamicRatio(shortestSide);

    final availableWidth = screenWidth * dynamicRatio;
    final availableHeight = screenHeight * dynamicRatio;

    // Calculate kShort based on which dimension is constraining
    final widthUnits = topology.widthUnits; // 2*1.5 + 7 = 10
    final heightUnits = topology.heightUnits; // 2*1.5 + 4 = 7

    final kShortByWidth = availableWidth / widthUnits;
    final kShortByHeight = availableHeight / heightUnits;

    // Use the smaller value to fit within screen
    kShortSide = kShortByWidth < kShortByHeight
        ? kShortByWidth
        : kShortByHeight;
    kLongSide = kShortSide * sideRatio;
  }

  /// Legacy getter for backward compatibility (average for pawn sizing)
  double get tileSize => (kShortSide + kLongSide) / 2;

  /// Corner tile size
  double get cornerSize => kLongSide;

  /// Normal tile size (legacy)
  double get normalSize => kShortSide;

  /// Tile width for a specific tile
  double getTileWidth(int tileId) {
    final side = topology.middleSideOf(tileId);
    // Bottom/Top middle tiles: VERTICAL (narrow width)
    if (side == BoardSide.bottom || side == BoardSide.top) return kShortSide;
    // Corners and Left/Right middle tiles: wide (kLong)
    return kLongSide;
  }

  /// Tile height for a specific tile
  double getTileHeight(int tileId) {
    final side = topology.middleSideOf(tileId);
    // Left/Right middle tiles: HORIZONTAL (short height)
    if (side == BoardSide.left || side == BoardSide.right) return kShortSide;
    // Corners and Bottom/Top middle tiles: tall (kLong)
    return kLongSide;
  }

  /// Actual board dimensions
  double get actualWidth => 2 * kLongSide + middleTilesHorizontal * kShortSide;
  double get actualHeight => 2 * kLongSide + middleTilesVertical * kShortSide;

  /// Aspect ratio (width / height)
  double get aspectRatio => actualWidth / actualHeight;

  /// For backward compatibility
  double get tileWidth => kShortSide;
  double get tileHeight => kLongSide;

  /// Factory to create from screen size
  factory BoardLayoutConfig.fromScreen(Size screenSize) {
    return BoardLayoutConfig(
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
    );
  }

  /// Calculate dynamic board-to-screen ratio based on screen size
  /// Smaller screens get more aggressive compression to prevent overflow
  double _calculateDynamicRatio(double shortestSide) {
    if (shortestSide < 360) {
      // Very small screens (tiny phones)
      return minBoardToScreenRatio;
    } else if (shortestSide < 600) {
      // Small screens (mobile portrait)
      return minBoardToScreenRatio + 0.03;
    } else if (shortestSide < 900) {
      // Medium screens (mobile landscape, small tablets)
      return minBoardToScreenRatio + 0.06;
    } else {
      // Large screens (tablets, desktops)
      return maxBoardToScreenRatio;
    }
  }
}
