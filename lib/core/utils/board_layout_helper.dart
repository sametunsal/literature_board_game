import 'package:flutter/material.dart';
import 'board_layout_config.dart';

/// Helper class for board layout calculations
///
/// This class provides static methods for calculating tile centers,
/// player offsets, and other geometric calculations needed for the board.
/// All methods are pure functions that take layout config and return positions.
class BoardLayoutHelper {
  /// Calculates the center position of a tile given its ID
  ///
  /// [tileId] The ID of the tile (0-25)
  /// [layout] The board layout configuration
  ///
  /// Returns the center [Offset] of the tile in board coordinates.
  static Offset getTileCenter(int tileId, BoardLayoutConfig layout) {
    final T = layout.tileSize;
    final W = layout.actualWidth;
    final H = layout.actualHeight;
    final halfT = T / 2;

    // Invalid tile ID - default to start
    if (tileId < 0 || tileId >= 26) return Offset(W - halfT, H - halfT);

    // ═════════════════════════════════════════════════════════════════════
    // BOTTOM ROW (IDs 0-6): Right to Left - 7 tiles
    // ═════════════════════════════════════════════════════════════════════
    if (tileId <= 6) {
      // X: Start from right edge, move left by tile index
      // 0 -> W - T/2, 1 -> W - 1.5T, 2 -> W - 2.5T, etc.
      final x = W - halfT - (tileId * T);
      final y = H - halfT;
      return Offset(x, y);
    }

    // ═════════════════════════════════════════════════════════════════════
    // LEFT COLUMN (IDs 7-12): Bottom to Top - 6 tiles
    // ═════════════════════════════════════════════════════════════════════
    if (tileId <= 12) {
      final x = halfT;
      // 7 -> H - 1.5T, 8 -> H - 2.5T, etc.
      final y = H - halfT - ((tileId - 6) * T);
      return Offset(x, y);
    }

    // ═════════════════════════════════════════════════════════════════════
    // TOP ROW (IDs 13-18): Left to Right - 6 tiles
    // ═════════════════════════════════════════════════════════════════════
    if (tileId <= 18) {
      // 13 -> T/2, 14 -> 1.5T, 15 -> 2.5T, etc.
      final x = halfT + ((tileId - 12) * T);
      final y = halfT;
      return Offset(x, y);
    }

    // ═════════════════════════════════════════════════════════════════════
    // RIGHT COLUMN (IDs 19-25): Top to Bottom - 7 tiles
    // ═════════════════════════════════════════════════════════════════════
    final x = W - halfT;
    // 19 -> 1.5T, 20 -> 2.5T, etc.
    final y = halfT + ((tileId - 18) * T);
    return Offset(x, y);
  }

  /// Calculates the offset for a player pawn when multiple players are on the same tile
  ///
  /// [indexInGroup] The index of this player within the group on the same tile (0-based)
  /// [totalPlayers] Total number of players on this tile (1-4+)
  /// [tileSize] The size of the tile
  ///
  /// Returns the [Offset] to apply to the tile center to position this player.
  static Offset calculatePlayerOffset(
    int indexInGroup,
    int totalPlayers,
    double tileSize,
  ) {
    if (totalPlayers <= 1) {
      return Offset.zero;
    }

    final offsetAmount = tileSize * 0.15;
    double dx = 0;
    double dy = 0;

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
      // 4+ players: 2x2 grid approx
      dx = ((indexInGroup % 2) == 0 ? -1 : 1) * offsetAmount * 0.7;
      dy = (indexInGroup < 2 ? -1 : 1) * offsetAmount * 0.7;
    }

    return Offset(dx, dy);
  }

  /// Calculates the position (left, top) for a tile on the board
  ///
  /// [tileId] The ID of the tile (0-25)
  /// [layout] The board layout configuration
  ///
  /// Returns a [Rect] containing the tile's position and size.
  static Rect getTileRect(int tileId, BoardLayoutConfig layout) {
    final center = getTileCenter(tileId, layout);

    return Rect.fromCenter(
      center: center,
      width: layout.tileSize,
      height: layout.tileSize,
    );
  }

  /// Gets the rotation angle for a tile based on its position on the board
  ///
  /// [tileId] The ID of the tile (0-25)
  ///
  /// Returns the rotation in radians.
  static double getTileRotation(int tileId) {
    // Bottom row: no rotation
    if (tileId <= 6) return 0;
    // Left column: rotate 90° counter-clockwise
    if (tileId <= 12) return -3.14159 / 2;
    // Top row: rotate 180°
    if (tileId <= 18) return 3.14159;
    // Right column: rotate 90° clockwise
    return 3.14159 / 2;
  }
}
