import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/motion/motion_constants.dart';
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
class EnhancedTileWidget extends StatefulWidget {
  final BoardTile tile;
  final double width;
  final double height;

  /// Quarter turns: 0=Bottom, 1=Right, 2=Top, 3=Left
  final int quarterTurns;
  final Player? owner;
  final int? calculatedRent;
  final bool isSelected;
  final bool isHovered;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    required this.width,
    required this.height,
    this.quarterTurns = 0,
    this.owner,
    this.calculatedRent,
    this.isSelected = false,
    this.isHovered = false,
  });

  @override
  State<EnhancedTileWidget> createState() => _EnhancedTileWidgetState();
}

class _EnhancedTileWidgetState extends State<EnhancedTileWidget> {
  bool _isPressed = false;

  bool get _isCorner => widget.tile.id % 10 == 0;

  @override
  Widget build(BuildContext context) {
    // Get theme tokens based on current brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tokens = GameTheme.getTokens(isDarkMode);

    // Calculate scale based on press, hover, and selection state
    // Press takes priority, then selection, then hover
    final scale = _isPressed
        ? 0.96
        : (widget.isHovered ? 1.05 : (widget.isSelected ? 1.08 : 1.0));

    // DEBUG: Log shadow values to diagnose negative blur radius issue
    // DEBUG: Log shadow values removed for production
    // DEBUG: Log shadow values removed for production

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: MotionDurations.fast.safe,
        curve: MotionCurves.emphasized,
        child: AnimatedContainer(
          duration: MotionDurations.fast.safe,
          curve: MotionCurves.standard,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isCorner
                ? (widget.isSelected
                      ? tokens.primary.withValues(alpha: 0.15)
                      : (widget.isHovered
                            ? tokens.primary.withValues(alpha: 0.08)
                            : tokens.tileBase))
                : tokens.tileBase,
            border: Border.all(
              color: _isPressed
                  ? tokens.primary
                  : (widget.isSelected
                        ? tokens.primary
                        : (widget.isHovered
                              ? tokens.primary.withValues(alpha: 0.5)
                              : tokens.border.withValues(alpha: 0.5))),
              width: _isPressed
                  ? 2.0
                  : (widget.isSelected ? 2.0 : (widget.isHovered ? 1.5 : 0.5)),
            ),
            boxShadow: [
              // Press glow effect - always present but hidden when not pressed
              BoxShadow(
                color: _isPressed
                    ? tokens.primary.withValues(alpha: 0.15)
                    : Colors.transparent, // Transparent instead of removing
                blurRadius: _isPressed ? 8 : 0,
                spreadRadius: _isPressed ? 2 : 0,
              ),
              // Existing selection/hover shadows
              BoxShadow(
                color: widget.isSelected
                    ? tokens.primary.withValues(alpha: 0.3)
                    : (widget.isHovered
                          ? tokens.shadow.withValues(alpha: 0.25)
                          : tokens.shadow.withValues(alpha: 0.15)),
                blurRadius:
                    (widget.isSelected ? 6.0 : (widget.isHovered ? 4.0 : 2.0))
                        .clamp(0.0, double.infinity),
                spreadRadius: widget.isSelected ? 1 : 0,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _isCorner
              ? _buildCornerContent(tokens, isDarkMode)
              : _buildPropertyContent(tokens, isDarkMode),
        ),
      ),
    );
  }

  /// Build property tile with edge-specific layout
  Widget _buildPropertyContent(ThemeTokens tokens, bool isDarkMode) {
    // Check for special tiles that use custom images
    if (_isLibraryTile()) {
      return _buildSpecialTileContent(
        imagePath: 'assets/images/library.png',
        backgroundColor: isDarkMode
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFFFFBF0), // Lighter for light theme
        tokens: tokens,
      );
    }

    if (_isChanceOrFateTile()) {
      return _buildSpecialTileContent(
        imagePath: 'assets/images/old_shop.png',
        backgroundColor: isDarkMode
            ? const Color(0xFFF3E5F5)
            : const Color(0xFFFAF5FC), // Lighter for light theme
        tokens: tokens,
      );
    }

    final groupColor = widget.tile.groupColor;
    final isOwned = widget.owner != null;

    // Color strip widget with improved border
    Widget colorStrip = Container(
      decoration: BoxDecoration(
        color: groupColor,
        border: Border.all(
          color: tokens.shadow.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: 0.2),
            blurRadius: 1.0.clamp(0.0, double.infinity),
          ),
        ],
      ),
      child: _buildUpgradeIcons(),
    );

    // Text content widget (title + price)
    Widget textContent = _buildTextContent(isOwned, tokens, isDarkMode);

    // STRICT SWITCH BY EDGE POSITION
    switch (widget.quarterTurns) {
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
        // Right EDGE (physical right side of board): Strip on LEFT faces center
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

  /// Check if this is a Library/Question tile
  bool _isLibraryTile() {
    final titleLower = widget.tile.title.toLowerCase();
    return titleLower.contains('kütüphane') ||
        widget.tile.type == TileType.libraryWatch ||
        widget.tile.type == TileType.writingSchool ||
        widget.tile.type == TileType.educationFoundation;
  }

  /// Check if this is a Chance or Fate tile
  bool _isChanceOrFateTile() {
    final titleLower = widget.tile.title.toLowerCase();
    return titleLower.contains('şans') ||
        titleLower.contains('kader') ||
        widget.tile.type == TileType.chance ||
        widget.tile.type == TileType.fate;
  }

  /// Build special tile with custom image (Pop-Up Book style)
  Widget _buildSpecialTileContent({
    required String imagePath,
    required Color backgroundColor,
    required ThemeTokens tokens,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, backgroundColor.withValues(alpha: 0.8)],
        ),
      ),
      child: Stack(
        children: [
          // Centered image with shadow
          Center(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: tokens.shadow.withValues(alpha: 0.25),
                      blurRadius: 4.0.clamp(0.0, double.infinity),
                      spreadRadius: 0.5,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
          // Title label at bottom
          Positioned(
            left: 2,
            right: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                color: tokens.shadow.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                widget.tile.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GameTheme.tileTitleStyle.copyWith(
                  fontSize: 6,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Wrap content with rotation transform
  Widget _wrapWithRotation(Widget child, double degrees) {
    if (degrees == 0) return child;

    return Transform.rotate(angle: degrees * (math.pi / 180), child: child);
  }

  /// Build the text content (title + price/rent + owner indicator)
  Widget _buildTextContent(bool isOwned, ThemeTokens tokens, bool isDarkMode) {
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
                      widget.tile.title,
                      textAlign: TextAlign.center,
                      style: GameTheme.tileTitleStyle.copyWith(
                        fontSize: 8,
                        height: 1.1,
                        color: tokens.textPrimary, // Theme-aware text
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // PRICE or RENT
              if (widget.tile.price != null && !widget.tile.isUtility)
                _buildPriceRentBadge(isOwned, tokens),
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
                  color: widget.owner!.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.white : Colors.white,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tokens.shadow.withValues(alpha: 0.3),
                      blurRadius: 2.0.clamp(0.0, double.infinity),
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
    if (widget.tile.upgradeLevel == 0) return const SizedBox.shrink();

    if (widget.tile.upgradeLevel == 4) {
      return const Center(child: Icon(Icons.home, size: 7, color: Colors.red));
    }

    // Vertical for left/right edges, horizontal for top/bottom
    bool isVertical = widget.quarterTurns == 1 || widget.quarterTurns == 3;

    if (isVertical) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.tile.upgradeLevel,
            (i) => const Icon(Icons.home, size: 5, color: Colors.green),
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.tile.upgradeLevel,
          (i) => const Icon(Icons.home, size: 5, color: Colors.green),
        ),
      ),
    );
  }

  /// Build price/rent badge
  Widget _buildPriceRentBadge(bool isOwned, ThemeTokens tokens) {
    final displayValue = isOwned
        ? (widget.calculatedRent ?? widget.tile.price!)
        : widget.tile.price!;
    final label = isOwned ? 'K' : '₺';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: isOwned
            ? Colors.orange.withValues(alpha: 0.2)
            : tokens.shadow.withValues(alpha: 0.08),
      ),
      child: Text(
        '$label$displayValue',
        style: GameTheme.tilePriceStyle.copyWith(
          fontSize: 7,
          fontWeight: FontWeight.bold,
          color: isOwned ? Colors.deepOrange : tokens.textPrimary,
        ),
      ),
    );
  }

  /// Build corner tile content
  Widget _buildCornerContent(ThemeTokens tokens, bool isDarkMode) {
    // Check if this is the Start Tile - use custom image
    if (widget.tile.id == 0 || widget.tile.type == TileType.start) {
      return _buildStartTileContent(tokens);
    }

    final config = _getCornerConfig();
    final minDimension = widget.width < widget.height
        ? widget.width
        : widget.height;
    final iconSize = minDimension * 0.28;

    // Corner text rotation based on position
    // Top corners (quarterTurns 1 and 2) should be readable (0°)
    double rotation = switch (widget.quarterTurns) {
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
                        color: Colors.black87, // Always dark on colored corners
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

  /// Build Start Tile with custom gate.png image
  Widget _buildStartTileContent(ThemeTokens tokens) {
    final minDimension = widget.width < widget.height
        ? widget.width
        : widget.height;

    return Container(
      decoration: BoxDecoration(
        // Warm gradient background for Start tile
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8F5E9), // Light green
            const Color(0xFFC8E6C9), // Slightly darker green
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gate Image with shadow effect
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadow.withValues(alpha: 0.25),
                        blurRadius: 6.0.clamp(0.0, double.infinity),
                        spreadRadius: 1,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/gate.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Label text
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: minDimension * 0.85),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'BAŞLANGIÇ',
                    textAlign: TextAlign.center,
                    style: GameTheme.cornerLabelStyle.copyWith(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32), // Dark green for contrast
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CornerTileConfig _getCornerConfig() {
    final predefined = GameTheme.cornerConfigs[widget.tile.id];
    if (predefined != null) return predefined;

    return switch (widget.tile.type) {
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
