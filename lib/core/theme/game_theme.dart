import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Comprehensive theme for the Literature Board Game
/// Provides consistent styling across all game components
class GameTheme {
  GameTheme._(); // Private constructor to prevent instantiation

  // ════════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary table background - deep rich green
  static const Color _tableColor = Color(0xFF2E4A3C);

  /// Board surface - warm parchment beige
  static const Color _boardColor = Color(0xFFF5E6D3);

  /// Compatibility aliases for existing code
  static const Color parchment = _boardColor;
  static const Color textPrimary = Color(0xFF263238);
  static const Color primaryText = textPrimary;
  static const Color accentRed = Color(0xFFE57373);
  static const Color accentGold = Color(0xFFFFD54F);
  static const Color tileBorder = Color(0xFF5D4037);

  /// Dialog overlay color
  static const Color dialogOverlayColor = Color(0x8A000000); // Colors.black54

  // ════════════════════════════════════════════════════════════════════════════
  // GROUP COLORS (Property color strips by tile ID range)
  // ════════════════════════════════════════════════════════════════════════════

  static const Map<int, Color> _groupColors = {
    1: Color(0xFF7B1FA2), // Purple - tiles 1-4
    2: Color(0xFF1976D2), // Blue - tiles 6-9
    3: Color(0xFFC2185B), // Pink - tiles 11-14
    4: Color(0xFFF57C00), // Orange - tiles 16-19
    5: Color(0xFFD32F2F), // Red - tiles 21-24
    6: Color(0xFFFBC02D), // Yellow - tiles 26-29
    7: Color(0xFF388E3C), // Green - tiles 31-34
    8: Color(0xFF0288D1), // Light Blue - tiles 36-39
  };

  /// Get the group color for a tile based on its ID
  static Color getGroupColor(int tileId) {
    if (tileId >= 1 && tileId <= 4) return _groupColors[1]!;
    if (tileId >= 6 && tileId <= 9) return _groupColors[2]!;
    if (tileId >= 11 && tileId <= 14) return _groupColors[3]!;
    if (tileId >= 16 && tileId <= 19) return _groupColors[4]!;
    if (tileId >= 21 && tileId <= 24) return _groupColors[5]!;
    if (tileId >= 26 && tileId <= 29) return _groupColors[6]!;
    if (tileId >= 31 && tileId <= 34) return _groupColors[7]!;
    if (tileId >= 36 && tileId <= 39) return _groupColors[8]!;
    return Colors.grey.shade400;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CORNER TILE CONFIGURATIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// Corner tile visual configuration data
  static const Map<int, CornerTileConfig> cornerConfigs = {
    0: CornerTileConfig(
      icon: Icons.start,
      label: 'BAŞLANGIÇ',
      backgroundColor: Color(0xFFE8F5E9),
    ),
    10: CornerTileConfig(
      icon: Icons.local_library,
      label: 'NÖBET',
      backgroundColor: Color(0xFFFFF3E0),
    ),
    20: CornerTileConfig(
      icon: Icons.campaign,
      label: 'İMZA GÜNÜ',
      backgroundColor: Color(0xFFF3E5F5),
    ),
    30: CornerTileConfig(
      icon: Icons.gavel,
      label: 'İFLAS RİSKİ',
      backgroundColor: Color(0xFFFFEBEE),
    ),
  };

  // ════════════════════════════════════════════════════════════════════════════
  // BACKGROUND & CONTAINER DECORATIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// Main table background with radial gradient
  static BoxDecoration get backgroundTable => const BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(-0.3, -0.3),
      radius: 1.2,
      colors: [
        Color(0xFF3D5A4D), // Lighter green
        _tableColor,
      ],
    ),
  );

  /// Board container with 3D shadow effect
  static BoxDecoration get boardDecoration => BoxDecoration(
    color: _boardColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      // Outer dark shadow for depth
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 20,
        spreadRadius: 5,
        offset: const Offset(10, 10),
      ),
      // Inner light shadow for embossed effect
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.2),
        blurRadius: 15,
        spreadRadius: -5,
        offset: const Offset(-5, -5),
      ),
    ],
  );

  /// Center area with subtle gradient
  static BoxDecoration get centerAreaDecoration => BoxDecoration(
    color: _boardColor,
    borderRadius: BorderRadius.circular(12),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _boardColor,
        Color(0xFFE8D5C4), // Slightly darker beige
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(2, 2),
      ),
    ],
  );

  /// Tile card decoration with subtle shadow
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 6,
        offset: const Offset(2, 4),
      ),
    ],
  );

  /// Color strip decoration for property tiles
  static BoxDecoration groupColorStrip(int tileId) => BoxDecoration(
    color: getGroupColor(tileId),
    border: const Border(bottom: BorderSide(color: Colors.black87, width: 0.5)),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // PAWN DECORATIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// Pawn decoration with optional active glow effect
  static BoxDecoration pawnDecoration(Color color, {bool isActive = false}) =>
      BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: isActive
            ? const [BoxShadow(color: Colors.white, blurRadius: 10)]
            : const [BoxShadow(color: Colors.black54, blurRadius: 4)],
      );

  // ════════════════════════════════════════════════════════════════════════════
  // TEXT STYLES
  // ════════════════════════════════════════════════════════════════════════════

  /// Tile title text style
  static const TextStyle tileTitle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  /// Tile price text style
  static const TextStyle tilePrice = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

  /// HUD title style (EDEBİYAT)
  static TextStyle get hudTitleStyle => GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 8,
        offset: const Offset(2, 2),
      ),
      Shadow(
        color: Colors.white.withValues(alpha: 0.3),
        blurRadius: 4,
        offset: const Offset(-1, -1),
      ),
    ],
  );

  /// HUD subtitle/action text style
  static TextStyle get hudSubtitleStyle =>
      GoogleFonts.poppins(color: Colors.white70, fontSize: 10);

  /// Property tile title style
  static TextStyle get propertyTitleStyle => GoogleFonts.poppins(
    fontSize: 8,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  /// Corner tile label style
  static TextStyle get cornerLabelStyle => GoogleFonts.poppins(
    fontSize: 8,
    fontWeight: FontWeight.w900,
    color: Colors.black87,
  );

  /// Price badge text style
  static const TextStyle priceBadgeStyle = TextStyle(
    fontSize: 7,
    fontWeight: FontWeight.bold,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // BUTTON STYLES
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary elevated button style
  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFD4A574), // Golden
    foregroundColor: const Color(0xFF3A2F26), // Dark brown text
    shadowColor: Colors.black.withValues(alpha: 0.4),
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    textStyle: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS (Constants for consistency)
  // ════════════════════════════════════════════════════════════════════════════

  static const Duration boardEntryDuration = Duration(milliseconds: 800);
  static const Duration boardFadeDuration = Duration(milliseconds: 600);
  static const Duration pawnMoveDuration = Duration(milliseconds: 600);
  static const Duration dialogEntryDuration = Duration(milliseconds: 300);
  static const Duration diceRollDuration = Duration(milliseconds: 500);
}

/// Configuration data for corner tiles
class CornerTileConfig {
  final IconData icon;
  final String label;
  final Color backgroundColor;

  const CornerTileConfig({
    required this.icon,
    required this.label,
    required this.backgroundColor,
  });
}
