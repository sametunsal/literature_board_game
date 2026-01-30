import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/board_tile.dart';
import '../../models/tile_type.dart';
import '../../models/difficulty.dart';
import '../../core/theme/game_theme.dart';

class GameTileWidget extends StatelessWidget {
  final BoardTile tile;
  final double size;

  const GameTileWidget({super.key, required this.tile, required this.size});

  @override
  Widget build(BuildContext context) {
    // Get theme tokens based on current brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tokens = GameTheme.getTokens(isDarkMode);

    bool isCorner = tile.type == TileType.corner;

    return Container(
      width: isCorner ? size * 1.5 : size,
      height: isCorner ? size * 1.5 : size,
      decoration: BoxDecoration(
        color: Colors.white, // Pure white for modern flat design
        borderRadius: BorderRadius.circular(8), // Rounded corners
        border: Border.all(
          color: tokens.border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isCorner ? _buildCorner(tokens) : _buildStandard(tokens),
    );
  }

  Widget _buildStandard(ThemeTokens tokens) {
    return Column(
      children: [
        // Color Strip (Top 25%) - Vibrant, pastel colors
        Container(
          height: size * 0.25,
          decoration: BoxDecoration(
            color: _getGroupColor(tile.position),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: _buildUpgradeIcons(),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Text(
                  tile.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87, // Dark grey/black for readability
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Difficulty level indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(
                      tile.difficulty,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tile.difficulty.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: _getDifficultyColor(tile.difficulty),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(ThemeTokens tokens) {
    IconData icon;
    Color bg;
    String label = "";

    switch (tile.type) {
      case TileType.start:
        icon = Icons.play_arrow_rounded;
        bg = const Color(0xFFE8F5E9); // Light green
        label = "BAŞLA";
        break;
      case TileType.shop:
        icon = Icons.store_rounded;
        bg = const Color(0xFFFFF8E1); // Light amber
        label = "KIRAATHANE";
        break;
      case TileType.collection:
        icon = Icons.collections_bookmark_rounded;
        bg = const Color(0xFFF3E5F5); // Light purple
        label = "KOLEKSİYON";
        break;
      default:
        icon = Icons.help_outline_rounded;
        bg = const Color(0xFFF5F5F5); // Light grey
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: size * 0.5, color: Colors.black54),
          Positioned(
            bottom: 6,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeIcons() {
    return const SizedBox();
  }

  Color _getDifficultyColor(Difficulty diff) {
    return switch (diff) {
      Difficulty.easy => const Color(0xFF4CAF50), // Vibrant green
      Difficulty.medium => const Color(0xFFFF9800), // Vibrant orange
      Difficulty.hard => const Color(0xFFF44336), // Vibrant red
    };
  }

  Color _getGroupColor(int id) {
    // Vibrant, pastel colors for modern look
    if (id > 0 && id < 5) return const Color(0xFF9C27B0); // Vibrant purple
    if (id > 5 && id < 10) return const Color(0xFF2196F3); // Vibrant blue
    if (id > 10 && id < 15) return const Color(0xFFE91E63); // Vibrant pink
    if (id > 15 && id < 20) return const Color(0xFFFF9800); // Vibrant orange
    if (id > 20 && id < 25) return const Color(0xFFF44336); // Vibrant red
    if (id > 25 && id < 30) return const Color(0xFFFFEB3B); // Vibrant yellow
    if (id > 30 && id < 35) return const Color(0xFF4CAF50); // Vibrant green
    if (id > 35 && id < 40) return const Color(0xFF00BCD4); // Vibrant cyan
    return Colors.grey.shade400;
  }
}
