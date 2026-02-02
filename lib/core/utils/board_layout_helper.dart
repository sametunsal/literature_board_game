import 'package:flutter/material.dart';
import 'board_layout_config.dart';

/// Helper class for HYBRID MONOPOLY-STYLE board layout calculations
///
/// **TILE LAYOUT (26 tiles on perimeter):**
/// - Corners (0, 6, 13, 19): Square tiles (kLong × kLong)
/// - Bottom/Top middle: Vertical rectangles (kShort × kLong)
/// - Left/Right middle: Horizontal rectangles (kLong × kShort)
///
/// **Board Structure:**
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
  /// Get the center position of a tile
  static Offset getTileCenter(int tileId, BoardLayoutConfig layout) {
    final kL = layout.kLongSide;
    final kS = layout.kShortSide;
    final W = layout.actualWidth;
    final H = layout.actualHeight;

    // Clamp invalid tile IDs
    if (tileId < 0 || tileId >= 26) {
      return Offset(W - kL / 2, H - kL / 2); // Default to BR corner
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CORNER TILES (Square: kLong × kLong)
    // ═══════════════════════════════════════════════════════════════════════
    if (tileId == 0) {
      // Bottom-Right Corner (Start)
      return Offset(W - kL / 2, H - kL / 2);
    }
    if (tileId == 6) {
      // Bottom-Left Corner
      return Offset(kL / 2, H - kL / 2);
    }
    if (tileId == 13) {
      // Top-Left Corner
      return Offset(kL / 2, kL / 2);
    }
    if (tileId == 19) {
      // Top-Right Corner
      return Offset(W - kL / 2, kL / 2);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BOTTOM ROW MIDDLE (Indices 1-5): Vertical tiles (kShort × kLong)
    // Between Corner 0 (right) and Corner 6 (left)
    // X decreases from right to left
    // ═══════════════════════════════════════════════════════════════════════
    if (tileId >= 1 && tileId <= 5) {
      // Start after Corner 0, distribute 5 tiles
      final index = tileId; // 1, 2, 3, 4, 5
      // X position: from right edge, skip corner, then place tiles
      final x = W - kL - (index - 0.5) * kS;
      final y = H - kL / 2;
      return Offset(x, y);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // LEFT COLUMN MIDDLE (Indices 7-12): Horizontal tiles (kLong × kShort)
    // Between Corner 6 (bottom) and Corner 13 (top)
    // Y decreases (going up)
    // ═══════════════════════════════════════════════════════════════════════
    if (tileId >= 7 && tileId <= 12) {
      // 6 tiles between corners
      final index = tileId - 6; // 1, 2, 3, 4, 5, 6
      final x = kL / 2;
      // Y position: from bottom, skip corner, then place tiles going up
      final y = H - kL - (index - 0.5) * kS;
      return Offset(x, y);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // TOP ROW MIDDLE (Indices 14-18): Vertical tiles (kShort × kLong)
    // Between Corner 13 (left) and Corner 19 (right)
    // X increases from left to right
    // ═══════════════════════════════════════════════════════════════════════
    if (tileId >= 14 && tileId <= 18) {
      // 5 tiles between corners
      final index = tileId - 13; // 1, 2, 3, 4, 5
      // X position: from left edge, skip corner, then place tiles
      final x = kL + (index - 0.5) * kS;
      final y = kL / 2;
      return Offset(x, y);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // RIGHT COLUMN MIDDLE (Indices 20-25): Horizontal tiles (kLong × kShort)
    // Between Corner 19 (top) and Corner 0 (bottom)
    // Y increases (going down)
    // ═══════════════════════════════════════════════════════════════════════
    if (tileId >= 20 && tileId <= 25) {
      // 6 tiles between corners
      final index = tileId - 19; // 1, 2, 3, 4, 5, 6
      final x = W - kL / 2;
      // Y position: from top, skip corner, then place tiles going down
      final y = kL + (index - 0.5) * kS;
      return Offset(x, y);
    }

    // Fallback (should never reach)
    return Offset(W / 2, H / 2);
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

  /// Get tile rotation based on board side
  static double getTileRotation(int tileId) {
    // Corners: no rotation
    if ([0, 6, 13, 19].contains(tileId)) return 0;
    // Bottom row: no rotation
    if (tileId >= 1 && tileId <= 5) return 0;
    // Left column: -90° (CCW)
    if (tileId >= 7 && tileId <= 12) return -3.14159 / 2;
    // Top row: 180°
    if (tileId >= 14 && tileId <= 18) return 3.14159;
    // Right column: 90° (CW)
    return 3.14159 / 2;
  }
}
