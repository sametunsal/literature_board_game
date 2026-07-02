import 'package:flutter/material.dart';
import 'board_layout_config.dart';
import 'board_topology.dart';

/// Helper class for HYBRID MONOPOLY-STYLE board layout calculations
///
/// **TILE LAYOUT (perimeter path):**
/// - Corners: Square tiles (kLong × kLong)
/// - Bottom/Top middle: Vertical rectangles (kShort × kLong)
/// - Left/Right middle: Horizontal rectangles (kLong × kShort)
///
/// Tile counts, corner indices, and side runs come from
/// [BoardLayoutConfig.topology]. With the standard 5/6 topology:
/// ```
/// [13-TL]  [14] [15] [16] [17] [18]  [19-TR]
/// [12]                                [20]
/// [11]                                [21]
/// [10]          CENTER AREA           [22]
/// [9]                                 [23]
/// [8]                                 [24]
/// [7]                                 [25]
/// [6-BL]   [5]  [4]  [3]  [2]  [1]   [0-BR]
/// ```
class BoardLayoutHelper {
  static BoardTopology get _topology => BoardLayoutConfig.topology;

  /// Get the center position of a tile
  static Offset getTileCenter(int tileId, BoardLayoutConfig layout) {
    final kL = layout.kLongSide;
    final kS = layout.kShortSide;
    final W = layout.actualWidth;
    final H = layout.actualHeight;
    final topo = _topology;

    // Clamp invalid tile IDs to the BR corner (path start).
    if (!topo.isValidTile(tileId)) {
      return Offset(W - kL / 2, H - kL / 2);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CORNER TILES (Square: kLong × kLong)
    // ═══════════════════════════════════════════════════════════════════════
    if (tileId == topo.bottomRightCorner) {
      return Offset(W - kL / 2, H - kL / 2);
    }
    if (tileId == topo.bottomLeftCorner) {
      return Offset(kL / 2, H - kL / 2);
    }
    if (tileId == topo.topLeftCorner) {
      return Offset(kL / 2, kL / 2);
    }
    if (tileId == topo.topRightCorner) {
      return Offset(W - kL / 2, kL / 2);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MIDDLE TILES — placed along their side's run in path order, skipping
    // the corner (kLong), each occupying one kShort step.
    // ═══════════════════════════════════════════════════════════════════════
    final index = topo.middleIndexOf(tileId); // 1-based within the run
    switch (topo.middleSideOf(tileId)!) {
      case BoardSide.bottom:
        // Between BR and BL corners; X decreases from right to left.
        return Offset(W - kL - (index - 0.5) * kS, H - kL / 2);
      case BoardSide.left:
        // Between BL and TL corners; Y decreases going up.
        return Offset(kL / 2, H - kL - (index - 0.5) * kS);
      case BoardSide.top:
        // Between TL and TR corners; X increases from left to right.
        return Offset(kL + (index - 0.5) * kS, kL / 2);
      case BoardSide.right:
        // Between TR and BR corners; Y increases going down.
        return Offset(W - kL / 2, kL + (index - 0.5) * kS);
    }
  }

  /// Get tile dimensions (width, height) for a specific tile
  static Size getTileSize(int tileId, BoardLayoutConfig layout) {
    return Size(layout.getTileWidth(tileId), layout.getTileHeight(tileId));
  }

  /// Get tile rect with proper dimensions
  static Rect getTileRect(int tileId, BoardLayoutConfig layout) {
    final center = getTileCenter(tileId, layout);
    final size = getTileSize(tileId, layout);
    return Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
  }

  /// Calculate offset for multiple players on the same tile
  static Offset calculatePlayerOffset(
    int indexInGroup,
    int totalPlayers,
    double tileSize,
  ) {
    if (totalPlayers <= 1) return Offset.zero;
    final offsetAmount = tileSize * 0.15;
    double dx = 0, dy = 0;

    if (totalPlayers == 2) {
      dx = (indexInGroup == 0 ? -1 : 1) * offsetAmount * 0.7;
      dy = (indexInGroup == 0 ? -1 : 1) * offsetAmount * 0.7;
    } else if (totalPlayers == 3) {
      if (indexInGroup == 0) {
        dy = -offsetAmount;
      } else if (indexInGroup == 1) {
        dx = -offsetAmount;
        dy = offsetAmount * 0.5;
      } else {
        dx = offsetAmount;
        dy = offsetAmount * 0.5;
      }
    } else {
      dx = ((indexInGroup % 2) == 0 ? -1 : 1) * offsetAmount * 0.7;
      dy = (indexInGroup < 2 ? -1 : 1) * offsetAmount * 0.7;
    }
    return Offset(dx, dy);
  }

  /// Get tile rotation in radians based on board side
  static double getTileRotation(int tileId) {
    switch (_topology.rotationQuarterTurns(tileId)) {
      case 1: // Right column: 90° (CW)
        return 3.14159 / 2;
      case 2: // Top row: 180°
        return 3.14159;
      case 3: // Left column: -90° (CCW)
        return -3.14159 / 2;
      default: // Corners & bottom row: no rotation
        return 0;
    }
  }
}
