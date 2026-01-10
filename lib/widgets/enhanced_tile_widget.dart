import 'package:flutter/material.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../core/theme/game_theme.dart';

/// Enhanced tile widget with card-like appearance
/// Handles both property tiles and corner tiles with appropriate styling
class EnhancedTileWidget extends StatelessWidget {
  final BoardTile tile;
  final double width;
  final double height;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    required this.width,
    required this.height,
  });

  /// Check if this tile is a corner tile (id divisible by 10)
  bool get _isCorner => tile.id % 10 == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: GameTheme.cardDecoration,
      child: _isCorner
          ? _CornerContent(tile: tile, width: width)
          : _PropertyContent(tile: tile, height: height),
    );
  }
}

/// Property tile content with color strip and title
class _PropertyContent extends StatelessWidget {
  final BoardTile tile;
  final double height;

  const _PropertyContent({required this.tile, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // COLOR STRIP (Top 25%)
        Container(
          height: height * 0.25,
          width: double.infinity,
          decoration: GameTheme.groupColorStrip(tile.id),
          child: _UpgradeIcons(upgradeLevel: tile.upgradeLevel),
        ),
        // CONTENT
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  style: GameTheme.propertyTitleStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tile.price != null && !tile.isUtility)
                  _PriceBadge(price: tile.price!),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Corner tile content with icon and label
class _CornerContent extends StatelessWidget {
  final BoardTile tile;
  final double width;

  const _CornerContent({required this.tile, required this.width});

  @override
  Widget build(BuildContext context) {
    // Get config from theme, with fallback for unknown types
    final config = _getCornerConfig();

    return Container(
      color: config.backgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background icon (large and faded)
          Opacity(opacity: 0.1, child: Icon(config.icon, size: width * 0.8)),
          // Foreground content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(config.icon, size: width * 0.4, color: Colors.black87),
              const SizedBox(height: 4),
              Text(
                config.label,
                textAlign: TextAlign.center,
                style: GameTheme.cornerLabelStyle,
              ),
            ],
          ),
        ],
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
          (i) => const Icon(Icons.star, size: 8, color: Colors.white),
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
      child: Text('$price₺', style: GameTheme.priceBadgeStyle),
    );
  }
}
