import 'package:flutter/material.dart';

/// Configuration class for HYBRID MONOPOLY-STYLE board layout
///
/// **MIXED TILE ORIENTATIONS:**
/// - Corner tiles (0, 6, 13, 19): SQUARE (kLong × kLong)
/// - Bottom/Top middle tiles: VERTICAL (kShort width × kLong height)
/// - Left/Right middle tiles: HORIZONTAL (kLong width × kShort height)
///
/// **Tile Distribution (26 tiles):**
/// - Bottom (0-6): Corner 0 (BR), Middle 1-5, Corner 6 (BL) = 7 tiles
/// - Left (7-13): Middle 7-12, Corner 13 (TL) = 7 tiles
/// - Top (14-19): Middle 14-18, Corner 19 (TR) = 6 tiles
/// - Right (20-25): Middle 20-25 = 6 tiles (connects to Corner 0)
class BoardLayoutConfig {
  final double screenWidth;
  final double screenHeight;

  /// Short side of category tiles
  late final double kShortSide;

  /// Long side of category tiles (1.5x short side)
  late final double kLongSide;

  /// Ratio of long side to short side
  static const double sideRatio = 1.5;

  /// Board size ratio relative to screen
  static const double boardToScreenRatio = 0.94;

  /// Number of middle tiles on Bottom/Top rows (between corners)
  static const int middleTilesHorizontal = 5;

  /// Number of middle tiles on Left/Right columns (between corners)
  static const int middleTilesVertical = 6;

  /// Corner indices
  static const List<int> cornerIndices = [0, 6, 13, 19];

  BoardLayoutConfig({required this.screenWidth, required this.screenHeight}) {
    // Board dimensions formula:
    // actualWidth = 2*kLong + 5*kShort (2 corners + 5 vertical middle tiles)
    // actualHeight = 2*kLong + 6*kShort (2 corners + 6 horizontal middle tiles)
    //
    // With kLong = kShort * 1.5:
    // actualWidth = 2*(1.5*kShort) + 5*kShort = 3*kShort + 5*kShort = 8*kShort
    // actualHeight = 2*(1.5*kShort) + 6*kShort = 3*kShort + 6*kShort = 9*kShort
    //
    // Aspect ratio = 8/9 ≈ 0.889

    final availableWidth = screenWidth * boardToScreenRatio;
    final availableHeight = screenHeight * boardToScreenRatio;

    // Calculate kShort based on which dimension is constraining
    final widthUnits = 2 * sideRatio + middleTilesHorizontal; // 3 + 5 = 8
    final heightUnits = 2 * sideRatio + middleTilesVertical; // 3 + 6 = 9

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
    if (cornerIndices.contains(tileId)) return kLongSide;
    // Bottom/Top middle tiles: VERTICAL (narrow width)
    if (tileId >= 1 && tileId <= 5) return kShortSide; // Bottom middle
    if (tileId >= 14 && tileId <= 18) return kShortSide; // Top middle
    // Left/Right middle tiles: HORIZONTAL (wide)
    return kLongSide;
  }

  /// Tile height for a specific tile
  double getTileHeight(int tileId) {
    if (cornerIndices.contains(tileId)) return kLongSide;
    // Bottom/Top middle tiles: VERTICAL (tall)
    if (tileId >= 1 && tileId <= 5) return kLongSide; // Bottom middle
    if (tileId >= 14 && tileId <= 18) return kLongSide; // Top middle
    // Left/Right middle tiles: HORIZONTAL (short height)
    return kShortSide;
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
}
