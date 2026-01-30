import 'package:flutter/material.dart';

/// Configuration class for board layout calculations
///
/// This class encapsulates all board dimension calculations and provides
/// a centralized way to compute tile sizes, positions, and board dimensions.
class BoardLayoutConfig {
  final double boardWidth;
  final double boardHeight;

  /// Number of columns (width in tiles)
  static const int gridCols = 6;

  /// Number of rows (height in tiles)
  static const int gridRows = 7;

  /// Total perimeter tiles
  static const int totalTiles = 22;

  /// Size of each tile (uniform)
  late final double tileSize;

  /// Icon size ratio for center decoration
  static const double centerIconRatio = 0.25;

  /// Board size ratio relative to screen
  static const double boardToScreenRatio = 0.92;

  BoardLayoutConfig({required this.boardWidth, required this.boardHeight}) {
    // Tile size is determined by the shorter dimension / its tile count
    final tileByWidth = boardWidth / gridCols;
    final tileByHeight = boardHeight / gridRows;
    tileSize = (tileByWidth < tileByHeight) ? tileByWidth : tileByHeight;
  }

  /// Corner tile size (same as normal for uniform grid)
  double get cornerSize => tileSize;

  /// Normal tile size (same as corner)
  double get normalSize => tileSize;

  /// Actual board dimensions based on tile size
  double get actualWidth => tileSize * gridCols;
  double get actualHeight => tileSize * gridRows;

  /// Factory to create from screen size (optimized for landscape)
  factory BoardLayoutConfig.fromScreen(Size screenSize) {
    // Use most of screen height (limiting factor in landscape)
    final availableHeight = screenSize.height * boardToScreenRatio;
    // Calculate width maintaining 6:7 aspect ratio
    final aspectRatio = gridCols / gridRows; // 6/7 ≈ 0.857
    final availableWidth = availableHeight * aspectRatio;

    return BoardLayoutConfig(
      boardWidth: availableWidth,
      boardHeight: availableHeight,
    );
  }
}
