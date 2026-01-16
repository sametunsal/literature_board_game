import 'package:flutter/material.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../core/theme/game_theme.dart';

class GameTileWidget extends StatelessWidget {
  final BoardTile tile;
  final double size;

  const GameTileWidget({super.key, required this.tile, required this.size});

  @override
  Widget build(BuildContext context) {
    // Get theme tokens based on current brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tokens = GameTheme.getTokens(isDarkMode);

    bool isCorner = tile.id % 10 == 0;

    return Container(
      width: isCorner ? size * 1.5 : size,
      height: isCorner ? size * 1.5 : size,
      decoration: BoxDecoration(
        color: tokens.surface, // Theme-aware surface
        border: Border.all(color: tokens.border, width: 0.8),
        boxShadow: isCorner
            ? []
            : [
                BoxShadow(
                  color: tokens.shadow.withValues(alpha: 0.12),
                  offset: Offset(1, 1),
                ),
              ],
      ),
      child: isCorner ? _buildCorner(tokens) : _buildStandard(tokens),
    );
  }

  Widget _buildStandard(ThemeTokens tokens) {
    return Column(
      children: [
        // Renk Şeridi (Üst %20)
        Container(
          height: size * 0.25,
          color: _getGroupColor(tile.id),
          child: _buildUpgradeIcons(),
        ),
        // İçerik
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  style: GameTheme.tileTitle.copyWith(
                    fontSize: size * 0.13,
                    color: tokens.textPrimary, // Theme-aware text
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
                if (tile.price != null)
                  Text(
                    "${tile.price} Y",
                    style: GameTheme.tilePrice.copyWith(
                      color: tokens.textSecondary, // Theme-aware secondary text
                    ),
                  ),
                SizedBox(height: 2),
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
        icon = Icons.start;
        bg = Color(0xFFC8E6C9);
        label = "BAŞLANGIÇ";
        break;
      case TileType.libraryWatch:
        icon = Icons.menu_book;
        bg = Color(0xFFFFCCBC);
        label = "NÖBET";
        break;
      case TileType.autographDay:
        icon = Icons.edit;
        bg = Color(0xFFE1BEE7);
        label = "İMZA";
        break;
      case TileType.bankruptcyRisk:
        icon = Icons.warning;
        bg = Color(0xFFFFCDD2);
        label = "RİSK";
        break;
      default:
        icon = Icons.help;
        bg = tokens.surface; // Theme-aware fallback
    }

    return Container(
      color: bg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: size * 0.6, color: Colors.black45),
          Positioned(
            bottom: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Always dark on colored corners
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeIcons() {
    if (tile.upgradeLevel == 0) return SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        tile.upgradeLevel,
        (i) => Icon(Icons.star, size: 8, color: Colors.white),
      ),
    );
  }

  Color _getGroupColor(int id) {
    if (id > 0 && id < 5) return Color(0xFF8E24AA); // Mor
    if (id > 5 && id < 10) return Color(0xFF039BE5); // Mavi
    if (id > 10 && id < 15) return Color(0xFFD81B60); // Pembe
    if (id > 15 && id < 20) return Color(0xFFFB8C00); // Turuncu
    if (id > 20 && id < 25) return Color(0xFFE53935); // Kırmızı
    if (id > 25 && id < 30) return Color(0xFFFDD835); // Sarı
    if (id > 30 && id < 35) return Color(0xFF43A047); // Yeşil
    if (id > 35 && id < 40) return Color(0xFF1E88E5); // Koyu Mavi
    return Colors.grey;
  }
}
