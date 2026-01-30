import 'package:flutter/material.dart';
import '../../../core/utils/board_layout_config.dart';
import 'tile_widget.dart';

/// Grid widget containing all 22 tiles of the board
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
    final tiles = _buildAllTiles();
    return Stack(children: tiles);
  }

  /// Generate all 22 tiles for 6x7 grid
  List<Widget> _buildAllTiles() {
    final T = layout.tileSize;
    final W = layout.actualWidth;
    final H = layout.actualHeight;

    return [
      // ═════════════════════════════════════════════════════════════════════
      // BOTTOM ROW (IDs 0-5): Right to Left, from Start to Şans
      // ═════════════════════════════════════════════════════════════════════
      // 0: Start (Bottom-Right Corner)
      _buildTile(
        id: 0,
        left: W - T,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      // 1-4: Bottom edge tiles (going left)
      _buildTile(
        id: 1,
        left: W - T * 2,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      _buildTile(
        id: 2,
        left: W - T * 3,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      _buildTile(
        id: 3,
        left: W - T * 4,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      _buildTile(
        id: 4,
        left: W - T * 5,
        top: H - T,
        width: T,
        height: T,
        rotation: 0,
      ),
      // 5: Şans (Bottom-Left Corner)
      _buildTile(id: 5, left: 0, top: H - T, width: T, height: T, rotation: 0),

      // ═════════════════════════════════════════════════════════════════════
      // LEFT COLUMN (IDs 6-10): Bottom to Top
      // ═════════════════════════════════════════════════════════════════════
      _buildTile(
        id: 6,
        left: 0,
        top: H - T * 2,
        width: T,
        height: T,
        rotation: 3,
      ),
      _buildTile(
        id: 7,
        left: 0,
        top: H - T * 3,
        width: T,
        height: T,
        rotation: 3,
      ),
      _buildTile(
        id: 8,
        left: 0,
        top: H - T * 4,
        width: T,
        height: T,
        rotation: 3,
      ),
      _buildTile(
        id: 9,
        left: 0,
        top: H - T * 5,
        width: T,
        height: T,
        rotation: 3,
      ),
      _buildTile(
        id: 10,
        left: 0,
        top: H - T * 6,
        width: T,
        height: T,
        rotation: 3,
      ),

      // ═════════════════════════════════════════════════════════════════════
      // TOP ROW (IDs 11-16): Left to Right, from Shop to Kader
      // ═════════════════════════════════════════════════════════════════════
      // 11: Shop/Kıraathane (Top-Left Corner)
      _buildTile(id: 11, left: 0, top: 0, width: T, height: T, rotation: 2),
      // 12-15: Top edge tiles (going right)
      _buildTile(id: 12, left: T, top: 0, width: T, height: T, rotation: 2),
      _buildTile(id: 13, left: T * 2, top: 0, width: T, height: T, rotation: 2),
      _buildTile(id: 14, left: T * 3, top: 0, width: T, height: T, rotation: 2),
      _buildTile(id: 15, left: T * 4, top: 0, width: T, height: T, rotation: 2),
      // 16: Kader (Top-Right Corner)
      _buildTile(id: 16, left: W - T, top: 0, width: T, height: T, rotation: 2),

      // ═════════════════════════════════════════════════════════════════════
      // RIGHT COLUMN (IDs 17-21): Top to Bottom
      // ═════════════════════════════════════════════════════════════════════
      _buildTile(id: 17, left: W - T, top: T, width: T, height: T, rotation: 1),
      _buildTile(
        id: 18,
        left: W - T,
        top: T * 2,
        width: T,
        height: T,
        rotation: 1,
      ),
      _buildTile(
        id: 19,
        left: W - T,
        top: T * 3,
        width: T,
        height: T,
        rotation: 1,
      ),
      _buildTile(
        id: 20,
        left: W - T,
        top: T * 4,
        width: T,
        height: T,
        rotation: 1,
      ),
      _buildTile(
        id: 21,
        left: W - T,
        top: T * 5,
        width: T,
        height: T,
        rotation: 1,
      ),
    ];
  }

  /// Build a single positioned tile using TileWidget
  Widget _buildTile({
    required int id,
    required double left,
    required double top,
    required double width,
    required double height,
    required int rotation,
  }) {
    return TileWidget(
      id: id,
      left: left,
      top: top,
      width: width,
      height: height,
      rotation: rotation,
      isSelected: id == currentPlayerPosition,
      isPulsing: pulsingTileId == id,
      isHovered: hoveredTileId == id,
      onHoverEnter: onHoverEnter != null ? () => onHoverEnter!(id) : null,
      onHoverExit: onHoverExit != null ? () => onHoverExit!(id) : null,
      onPulseComplete: onPulseComplete,
    );
  }
}
