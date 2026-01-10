import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../../core/theme/game_theme.dart';

/// Enhanced tile widget with card-like appearance
/// Handles both property tiles and corner tiles with appropriate styling
/// Text is counter-rotated to remain readable regardless of tile orientation
class EnhancedTileWidget extends StatelessWidget {
  final BoardTile tile;
  final double width;
  final double height;

  /// Quarter turns the tile is rotated (0-3)
  /// 0 = Bottom edge, 1 = Left edge, 2 = Top edge, 3 = Right edge
  final int quarterTurns;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    required this.width,
    required this.height,
    this.quarterTurns = 0,
  });

  /// Check if this tile is a corner tile (id divisible by 10)
  bool get _isCorner => tile.id % 10 == 0;

  /// Calculate the counter-rotation angle to keep text upright
  /// Returns radians to rotate text back to readable orientation
  double get _counterRotationAngle {
    // Quarter turns: 0=0°, 1=90°, 2=180°, 3=270°
    // Counter-rotation: negative of the rotation
    return -quarterTurns * math.pi / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: GameTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: _isCorner
          ? _CornerContent(
              tile: tile,
              width: width,
              height: height,
              counterRotation: _counterRotationAngle,
            )
          : _PropertyContent(
              tile: tile,
              width: width,
              height: height,
              counterRotation: _counterRotationAngle,
            ),
    );
  }
}

/// Property tile content with color strip, title, and price
/// Text is counter-rotated to remain readable
class _PropertyContent extends StatelessWidget {
  final BoardTile tile;
  final double width;
  final double height;
  final double counterRotation;

  const _PropertyContent({
    required this.tile,
    required this.width,
    required this.height,
    required this.counterRotation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // COLOR STRIP (Top - 10px height for property group identification)
        Container(
          height: 10,
          width: double.infinity,
          decoration: GameTheme.groupColorStrip(tile.id),
          child: _UpgradeIcons(upgradeLevel: tile.upgradeLevel),
        ),

        // CONTENT AREA
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TITLE (counter-rotated)
                    Expanded(
                      child: Center(
                        child: Transform.rotate(
                          angle: counterRotation,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: _getMaxTextWidth(constraints),
                              ),
                              child: Text(
                                tile.title,
                                textAlign: TextAlign.center,
                                style: GameTheme.tileTitleStyle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // PRICE (counter-rotated, only if applicable)
                    if (tile.price != null && !tile.isUtility)
                      Transform.rotate(
                        angle: counterRotation,
                        child: _PriceBadge(price: tile.price!),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Calculate max text width based on rotation
  double _getMaxTextWidth(BoxConstraints constraints) {
    // For rotated tiles (90° or 270°), use height as width constraint
    final isRotated =
        counterRotation.abs() == math.pi / 2 ||
        counterRotation.abs() == 3 * math.pi / 2;
    if (isRotated) {
      return constraints.maxHeight * 0.9;
    }
    return constraints.maxWidth * 0.95;
  }
}

/// Corner tile content with icon and label
/// Content is counter-rotated to remain readable
class _CornerContent extends StatelessWidget {
  final BoardTile tile;
  final double width;
  final double height;
  final double counterRotation;

  const _CornerContent({
    required this.tile,
    required this.width,
    required this.height,
    required this.counterRotation,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getCornerConfig();
    final minDimension = width < height ? width : height;
    final iconSize = minDimension * 0.35;

    return Container(
      color: config.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // BACKGROUND ICON (large and faded) - also counter-rotated
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Transform.rotate(
                    angle: counterRotation,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(config.icon, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),

              // FOREGROUND CONTENT (counter-rotated)
              Transform.rotate(
                angle: counterRotation,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ICON
                      Icon(config.icon, size: iconSize, color: Colors.black87),
                      const SizedBox(height: 4),

                      // LABEL
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: minDimension * 0.85,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            config.label,
                            textAlign: TextAlign.center,
                            style: GameTheme.cornerLabelStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Get corner configuration from theme or derive from tile type
  CornerTileConfig _getCornerConfig() {
    // First try to get from predefined configs
    final predefined = GameTheme.cornerConfigs[tile.id];
    if (predefined != null) return predefined;

    // Fallback: derive from tile type
    return switch (tile.type) {
      TileType.start => const CornerTileConfig(
        icon: Icons.start,
        label: 'BAŞLANGIÇ',
        backgroundColor: Color(0xFFE8F5E9),
      ),
      TileType.libraryWatch => const CornerTileConfig(
        icon: Icons.local_library,
        label: 'NÖBET',
        backgroundColor: Color(0xFFFFF3E0),
      ),
      TileType.autographDay => const CornerTileConfig(
        icon: Icons.campaign,
        label: 'İMZA GÜNÜ',
        backgroundColor: Color(0xFFF3E5F5),
      ),
      TileType.bankruptcyRisk => const CornerTileConfig(
        icon: Icons.gavel,
        label: 'İFLAS RİSKİ',
        backgroundColor: Color(0xFFFFEBEE),
      ),
      _ => const CornerTileConfig(
        icon: Icons.help,
        label: '',
        backgroundColor: Colors.white,
      ),
    };
  }
}

/// Upgrade level indicator with star icons
class _UpgradeIcons extends StatelessWidget {
  final int upgradeLevel;

  const _UpgradeIcons({required this.upgradeLevel});

  @override
  Widget build(BuildContext context) {
    if (upgradeLevel == 0) return const SizedBox.shrink();

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          upgradeLevel,
          (i) => const Icon(Icons.star, size: 6, color: Colors.white),
        ),
      ),
    );
  }
}

/// Price badge widget with subtle background
class _PriceBadge extends StatelessWidget {
  final int price;

  const _PriceBadge({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.black.withValues(alpha: 0.05),
      ),
      child: Text('$price₺', style: GameTheme.tilePriceStyle),
    );
  }
}
