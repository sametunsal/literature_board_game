import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/motion/motion_constants.dart';
import '../../models/board_tile.dart';
import '../../models/difficulty.dart';
import '../../models/tile_type.dart';

/// Enhanced tile widget with modern flat design
/// Uses Icons instead of vintage images for cleaner look
class EnhancedTileWidget extends StatefulWidget {
  final BoardTile tile;
  final double width;
  final double height;
  final int quarterTurns;
  final bool isSelected;
  final bool isHovered;

  const EnhancedTileWidget({
    super.key,
    required this.tile,
    required this.width,
    required this.height,
    this.quarterTurns = 0,
    this.isSelected = false,
    this.isHovered = false,
  });

  @override
  State<EnhancedTileWidget> createState() => _EnhancedTileWidgetState();
}

class _EnhancedTileWidgetState extends State<EnhancedTileWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Calculate scale based on press, hover, and selection state
    // Press takes priority, then selection, then hover
    final scale = _isPressed
        ? 0.96
        : (widget.isHovered ? 1.05 : (widget.isSelected ? 1.08 : 1.0));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.grey.shade300,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              // Press glow effect
              BoxShadow(
                color: widget.isSelected
                    ? Colors.blue.withValues(alpha: 0.3)
                    : Colors.transparent,
                blurRadius: _isPressed ? 8 : 0,
                spreadRadius: _isPressed ? 2 : 0,
              ),
              // Selection/hover shadows
              BoxShadow(
                color: widget.isSelected
                    ? Colors.blue.withValues(alpha: 0.2)
                    : (widget.isHovered
                          ? Colors.blue.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1)),
                blurRadius: widget.isSelected
                    ? 8.0
                    : (widget.isHovered ? 6.0 : 3.0),
                spreadRadius: widget.isSelected ? 0 : 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Check tile type for custom corner icons
    switch (widget.tile.type) {
      case TileType.start:
        return _buildCornerTileContent(
          icon: Icons.play_arrow,
          iconColor: Colors.green.shade700,
          label: 'BAŞLANGIÇ',
        );
      case TileType.shop:
        return _buildCornerTileContent(
          icon: Icons.local_cafe,
          iconColor: Colors.brown.shade700,
          label: 'KIRAATHANE',
        );
      case TileType.library:
        return _buildCornerTileContent(
          icon: Icons.local_library,
          iconColor: Colors.teal.shade700,
          label: 'KÜTÜPHANE',
        );
      case TileType.signingDay:
        return _buildCornerTileContent(
          icon: Icons.edit_note,
          iconColor: Colors.purple.shade700,
          label: 'İMZA GÜNÜ',
        );
      case TileType.corner:
        return _buildCornerTileContent(
          icon: Icons.star,
          iconColor: Colors.orange.shade700,
          label: widget.tile.name,
        );
      default:
        break;
    }

    // Standard tiles with color strip and text
    final groupColor = _getGroupColor();

    // Color strip widget with vibrant colors
    Widget colorStrip = Container(decoration: BoxDecoration(color: groupColor));

    // Text content widget (title + price/info)
    Widget textContent = _buildStandardTileContent();

    // STRICT SWITCH BY EDGE POSITION
    switch (widget.quarterTurns) {
      case 0:
        // BOTTOM EDGE: Strip TOP, Text 0° (upright)
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10, child: colorStrip),
            SizedBox(height: 4), // Spacing between strip and text
            Expanded(child: _wrapWithRotation(textContent, 0)),
          ],
        );

      case 1:
        // Right EDGE (physical right side of board): Strip on LEFT faces center
        // Layout: [Color Strip | Text (RotatedBox quarterTurns: 3)]
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 10, child: colorStrip),
            SizedBox(width: 4), // Spacing between strip and text
            Expanded(child: RotatedBox(quarterTurns: 3, child: textContent)),
          ],
        );

      case 2:
        // TOP EDGE: Strip BOTTOM, Text readable (0°)
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: textContent),
            SizedBox(height: 4), // Spacing between text and strip
            SizedBox(height: 10, child: colorStrip),
          ],
        );

      case 3:
        // LEFT EDGE (physical left side of board): Strip on RIGHT faces center
        // Layout: [Text (RotatedBox quarterTurns: 1) | Color Strip]
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: RotatedBox(quarterTurns: 1, child: textContent)),
            SizedBox(width: 4), // Spacing between text and strip
            SizedBox(width: 10, child: colorStrip),
          ],
        );

      default:
        return Column(
          children: [
            SizedBox(height: 10, child: colorStrip),
            SizedBox(height: 4), // Spacing between strip and text
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

  /// Build standard tile content with title and difficulty
  Widget _buildStandardTileContent() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title - Centered, wraps naturally
          Text(
            widget.tile.name,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          // Difficulty - if category tile
          if (widget.tile.category != null) ...[
            Text(
              widget.tile.difficulty.displayName,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build corner tile with icon and label (Column layout)
  /// Icons have a subtle "breathing" idle animation with random delay
  Widget _buildCornerTileContent({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    // Generate a random delay (0-1000ms) based on tile id for uniqueness
    final randomDelay = (widget.tile.id.hashCode % 1000).abs();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon - Prominent size with breathing animation
                Animate(
                  onPlay: (controller) => controller.repeat(),
                  delay: Duration(milliseconds: randomDelay),
                  effects: [
                    ScaleEffect(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.05, 1.05),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                    ),
                    ScaleEffect(
                      begin: const Offset(1.05, 1.05),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                    ),
                  ],
                  child: Icon(icon, size: 32, color: iconColor),
                ),
                const SizedBox(height: 4),
                // Label text - Dark for contrast
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get group color from tile ID (simplified for modern theme)
  Color _getGroupColor() {
    final id = int.tryParse(widget.tile.id) ?? 0;

    // Modern vibrant colors
    switch (id) {
      case 0:
        return Colors.green.shade500;
      case 1:
        return Colors.blue.shade500;
      case 2:
        return Colors.purple.shade400;
      case 3:
        return Colors.orange.shade400;
      case 4:
        return Colors.red.shade400;
      case 5:
        return Colors.teal.shade400;
      case 6:
        return Colors.pink.shade400;
      case 7:
        return Colors.indigo.shade400;
      case 8:
        return Colors.brown.shade400;
      case 9:
        return Colors.grey.shade400;
      case 10:
        return Colors.blue.shade300;
      case 11:
        return Colors.purple.shade300;
      case 12:
        return Colors.orange.shade300;
      case 13:
        return Colors.red.shade300;
      case 14:
        return Colors.teal.shade300;
      case 15:
        return Colors.amber.shade300;
      case 16:
        return Colors.brown.shade300;
      // RIGHT COLUMN TILES (17-21) - Vibrant colors for 3rd category occurrences
      case 17:
        return Colors.deepPurple.shade400; // edebiSanatlar (3rd)
      case 18:
        return Colors.cyan.shade400; // eserKarakter (3rd)
      case 19:
        return Colors.lime.shade400; // edebiyatAkimlari (3rd)
      case 20:
        return Colors.lightBlue.shade400; // benKimim (3rd)
      case 21:
        return Colors.pink.shade500; // tesvik (3rd) - Distinct vibrant pink
      default:
        return Colors.grey.shade200;
    }
  }
}
