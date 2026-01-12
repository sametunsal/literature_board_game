import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../../core/theme/game_theme.dart';

/// Enhanced tile widget with classic Monopoly-style appearance
///
/// STRICT LAYOUT RULES BY EDGE (quarterTurns) - All strips face INWARD:
/// - Bottom (0): Column [Strip(top), Text] - Text 0° (no rotation)
/// - Right (1): Row [Text, Strip(right)] - RotatedBox(quarterTurns: 3) = bottom→top reading
/// - Top (2): Column [Text, Strip(bottom)] - Text 180° (Transform.rotate)
/// - Left (3): Row [Strip(left), Text] - RotatedBox(quarterTurns: 1) = top→bottom reading
///
/// No parent RotatedBox wrapper - widget handles all orientation internally
class EnhancedTileWidget extends StatelessWidget {
  final BoardTile tile;
  final double width;
  final double height;

  /// Quarter turns: 0=Bottom, 1=Right, 2=Top, 3=Left
  final int quarterTurns;
  final Player? owner;
  final int? calculatedRent;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    required this.width,
    required this.height,
    this.quarterTurns = 0,
    this.owner,
    this.calculatedRent,
  });

  bool get _isCorner => tile.id % 10 == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: GameTheme.parchmentColor,
        border: Border.all(color: const Color(0xFF2C2C2C), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: _isCorner ? _buildCornerContent() : _buildPropertyContent(),
    );
  }

  /// Build property tile with edge-specific layout
  Widget _buildPropertyContent() {
    final groupColor = tile.groupColor;
    final isOwned = owner != null;

    // Color strip widget
    Widget colorStrip = Container(
      decoration: BoxDecoration(
        color: groupColor,
        border: Border.all(color: const Color(0xFF2C2C2C), width: 0.5),
      ),
      child: _buildUpgradeIcons(),
    );

    // Text content widget (title + price)
    Widget textContent = _buildTextContent(isOwned);

    // STRICT SWITCH BY EDGE POSITION
    switch (quarterTurns) {
      case 0:
        // BOTTOM EDGE: Strip TOP, Text 0° (upright)
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Strip at TOP
            SizedBox(height: 10, child: colorStrip),
            // Text CENTER (no rotation)
            Expanded(child: _wrapWithRotation(textContent, 0)),
          ],
        );

      case 1:
        // RIGHT EDGE (physical right side of board): Strip on LEFT faces center
        // Layout: [Color Strip | Text (RotatedBox quarterTurns: 3)]
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Strip on LEFT side of tile = faces LEFT toward board center
            SizedBox(width: 10, child: colorStrip),
            // Text rotated -90° (bottom-to-top reading)
            Expanded(child: RotatedBox(quarterTurns: 3, child: textContent)),
          ],
        );

      case 2:
        // TOP EDGE: Strip BOTTOM, Text readable (0°)
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text CENTER (no rotation - readable from player side)
            Expanded(child: textContent),
            // Strip at BOTTOM
            SizedBox(height: 10, child: colorStrip),
          ],
        );

      case 3:
        // LEFT EDGE (physical left side of board): Strip on RIGHT faces center
        // Layout: [Text (RotatedBox quarterTurns: 1) | Color Strip]
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text rotated +90° (top-to-bottom reading)
            Expanded(child: RotatedBox(quarterTurns: 1, child: textContent)),
            // Strip on RIGHT side of tile = faces RIGHT toward board center
            SizedBox(width: 10, child: colorStrip),
          ],
        );

      default:
        return Column(
          children: [
            SizedBox(height: 10, child: colorStrip),
            Expanded(child: textContent),
          ],
        );
    }
  }

  /// Wrap content with rotation transform
  Widget _wrapWithRotation(Widget child, double degrees) {
    if (degrees == 0) return child;

    return Transform.rotate(angle: degrees * (math.pi / 180), child: child);
  }

  /// Build the text content (title + price/rent + owner indicator)
  Widget _buildTextContent(bool isOwned) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TITLE
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tile.title,
                      textAlign: TextAlign.center,
                      style: GameTheme.tileTitleStyle.copyWith(
                        fontSize: 8,
                        height: 1.1,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // PRICE or RENT
              if (tile.price != null && !tile.isUtility)
                _buildPriceRentBadge(isOwned),
            ],
          ),
          // Owner icon
          if (isOwned)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: owner!.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build upgrade icons (houses/hotel)
  Widget _buildUpgradeIcons() {
    if (tile.upgradeLevel == 0) return const SizedBox.shrink();

    if (tile.upgradeLevel == 4) {
      return const Center(child: Icon(Icons.home, size: 7, color: Colors.red));
    }

    // Vertical for left/right edges, horizontal for top/bottom
    bool isVertical = quarterTurns == 1 || quarterTurns == 3;

    if (isVertical) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            tile.upgradeLevel,
            (i) => const Icon(Icons.home, size: 5, color: Colors.green),
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          tile.upgradeLevel,
          (i) => const Icon(Icons.home, size: 5, color: Colors.green),
        ),
      ),
    );
  }

  /// Build price/rent badge
  Widget _buildPriceRentBadge(bool isOwned) {
    final displayValue = isOwned
        ? (calculatedRent ?? tile.price!)
        : tile.price!;
    final label = isOwned ? 'K' : '₺';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: isOwned
            ? Colors.orange.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.08),
      ),
      child: Text(
        '$label$displayValue',
        style: GameTheme.tilePriceStyle.copyWith(
          fontSize: 7,
          fontWeight: FontWeight.bold,
          color: isOwned ? Colors.deepOrange : GameTheme.textDark,
        ),
      ),
    );
  }

  /// Build corner tile content
  Widget _buildCornerContent() {
    final config = _getCornerConfig();
    final minDimension = width < height ? width : height;
    final iconSize = minDimension * 0.28;

    // Corner text rotation based on position
    // Top corners (quarterTurns 1 and 2) should be readable (0°)
    double rotation = switch (quarterTurns) {
      0 => 0, // Bottom-left: normal
      1 => 0, // Top-left: readable (was -90°)
      2 => 0, // Top-right: readable (was 180°)
      3 => 90 * (math.pi / 180), // Bottom-right: rotated
      _ => 0,
    };

    return Container(
      color: config.backgroundColor,
      child: Center(
        child: Transform.rotate(
          angle: rotation,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(config.icon, size: iconSize, color: Colors.black87),
                const SizedBox(height: 1),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: minDimension * 0.85),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      config.label,
                      textAlign: TextAlign.center,
                      style: GameTheme.cornerLabelStyle.copyWith(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CornerTileConfig _getCornerConfig() {
    final predefined = GameTheme.cornerConfigs[tile.id];
    if (predefined != null) return predefined;

    return switch (tile.type) {
      TileType.start => const CornerTileConfig(
        icon: Icons.arrow_forward,
        label: 'BAŞLANGIÇ',
        backgroundColor: Color(0xFFE8F5E9),
      ),
      TileType.libraryWatch => const CornerTileConfig(
        icon: Icons.local_library,
        label: 'KÜTÜPHANE\nNÖBETİ',
        backgroundColor: Color(0xFFFFF3E0),
      ),
      TileType.autographDay => const CornerTileConfig(
        icon: Icons.edit,
        label: 'İMZA GÜNÜ',
        backgroundColor: Color(0xFFF3E5F5),
      ),
      TileType.bankruptcyRisk => const CornerTileConfig(
        icon: Icons.warning,
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
