import 'package:flutter/material.dart';
import '../../../core/utils/board_layout_config.dart';
import '../../../core/utils/board_layout_helper.dart';
import 'tile_widget.dart';

/// Grid widget containing all 26 tiles of the board (Monopoly-style layout)
///
/// **HYBRID GEOMETRY:**
/// - Corner tiles (0, 6, 13, 19): Square (kLong × kLong)
/// - Bottom/Top middle: Vertical rectangles (kShort × kLong)
/// - Left/Right middle: Horizontal rectangles (kLong × kShort)
class TileGrid extends StatelessWidget {
  final BoardLayoutConfig layout;
  final int currentPlayerPosition;
  final int? pulsingTileId;
  final int? hoveredTileId;
  final ValueChanged<int>? onHoverEnter;
  final ValueChanged<int>? onHoverExit;
  final VoidCallback? onPulseComplete;

  const TileGrid({
    super.key,
    required this.layout,
    required this.currentPlayerPosition,
    this.pulsingTileId,
    this.hoveredTileId,
    this.onHoverEnter,
    this.onHoverExit,
    this.onPulseComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: _buildAllTiles());
  }

  /// Generate all 26 tiles with dynamic sizing
  List<Widget> _buildAllTiles() {
    final List<Widget> tiles = [];

    for (int id = 0; id < 26; id++) {
      // Get center position and size from layout helper
      final center = BoardLayoutHelper.getTileCenter(id, layout);
      final size = BoardLayoutHelper.getTileSize(id, layout);

      // Convert center to top-left for Positioned widget
      final left = center.dx - size.width / 2;
      final top = center.dy - size.height / 2;

      // Get rotation based on which side the tile is on
      final rotation = _getRotationQuarter(id);

      tiles.add(
        TileWidget(
          id: id,
          left: left,
          top: top,
          width: size.width,
          height: size.height,
          rotation: rotation,
          isSelected: id == currentPlayerPosition,
          isPulsing: pulsingTileId == id,
          isHovered: hoveredTileId == id,
          onHoverEnter: onHoverEnter != null ? () => onHoverEnter!(id) : null,
          onHoverExit: onHoverExit != null ? () => onHoverExit!(id) : null,
          onPulseComplete: onPulseComplete,
        ),
      );
    }

    return tiles;
  }

  /// Returns rotation quarter based on tile position:
  /// - 0: Bottom row & corners (no rotation)
  /// - 1: Right column (90° clockwise)
  /// - 2: Top row (180°)
  /// - 3: Left column (270° / -90°)
  int _getRotationQuarter(int id) {
    // Corners: no rotation
    if ([0, 6, 13, 19].contains(id)) return 0;
    // Bottom middle
    if (id >= 1 && id <= 5) return 0;
    // Left middle
    if (id >= 7 && id <= 12) return 3;
    // Top middle
    if (id >= 14 && id <= 18) return 2;
    // Right middle
    return 1;
  }
}
