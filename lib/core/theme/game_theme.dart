import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Comprehensive theme for the Literature Board Game
/// Provides consistent styling across all game components
class GameTheme {
  GameTheme._(); // Private constructor to prevent instantiation

  // ════════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE - MODERN DARK ACADEMIA (V2.5)
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary background / Canvas - Hayalet Siyahı (Phantom Black)
  static const Color tableBackgroundColor = Color(0xFF202621);

  /// Slightly lighter shade for gradient spotlight effect
  static const Color tableHighlightColor = Color(0xFF2A3029);

  /// Panel/Surface color - Eskitilmiş Deri (Worn Leather)
  static const Color parchmentColor = Color(0xFF734838);

  /// Success/Gold accent for highlights and borders - Altın (Gold)
  static const Color goldAccent = Color(0xFFFFD700);

  /// Primary CTA/Accent - Parlatılmış Bakır (Burnished Copper)
  static const Color copperAccent = Color(0xFFA66F5B);

  /// Primary text color - Antik Dantel (Antique Lace)
  static const Color textDark = Color(0xFFD9B596);

  /// Error color - Derin Bordo (Deep Burgundy)
  static const Color errorColor = Color(0xFF401B1B);

  /// Dialog overlay color (darker for dark theme)
  static const Color dialogOverlayColor = Color(0xCC000000);

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
  // TYPOGRAPHY - BASE FONTS
  // ════════════════════════════════════════════════════════════════════════════

  /// Header font - Playfair Display for elegant titles
  static TextStyle get headerFont => GoogleFonts.playfairDisplay();

  /// Body font - Poppins for readable UI text
  static TextStyle get bodyFont => GoogleFonts.poppins();

  // ════════════════════════════════════════════════════════════════════════════
  // TEXT STYLES
  // ════════════════════════════════════════════════════════════════════════════

  /// HUD title style (EDEBİNA) - Large, bold, Gold, Playfair
  static TextStyle get hudTitleStyle => GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: goldAccent,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.7),
        blurRadius: 10,
        offset: const Offset(2, 3),
      ),
    ],
  );

  /// HUD subtitle/action text style - Antique Lace for readability
  static TextStyle get hudSubtitleStyle =>
      GoogleFonts.poppins(color: textDark.withValues(alpha: 0.8), fontSize: 10);

  /// Tile title style - Small, bold, Antique Lace, Poppins
  static TextStyle get tileTitleStyle => GoogleFonts.poppins(
    fontSize: 8,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  /// Tile price style - Very small, lighter Antique Lace, Poppins
  static TextStyle get tilePriceStyle => GoogleFonts.poppins(
    fontSize: 7,
    fontWeight: FontWeight.w500,
    color: textDark.withValues(alpha: 0.7),
  );

  /// Corner tile label style - Antique Lace for dark backgrounds
  static TextStyle get cornerLabelStyle => GoogleFonts.poppins(
    fontSize: 8,
    fontWeight: FontWeight.w900,
    color: textDark,
  );

  /// Price badge text style - Antique Lace
  static const TextStyle priceBadgeStyle = TextStyle(
    fontSize: 7,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // DECORATIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// Main table background with radial gradient spotlight effect
  static BoxDecoration get tableDecoration => BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        tableHighlightColor, // Lighter green at center
        tableBackgroundColor, // Deep green at edges
      ],
      stops: const [0.0, 1.0],
    ),
  );

  /// Alias for backward compatibility
  static BoxDecoration get backgroundTable => tableDecoration;

  /// Board container with 3D shadow effect
  static BoxDecoration get boardDecoration => BoxDecoration(
    color: parchmentColor,
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
    color: parchmentColor,
    borderRadius: BorderRadius.circular(12),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [parchmentColor, parchmentColor.withValues(alpha: 0.9)],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(2, 2),
      ),
    ],
  );

  /// Card decoration for tiles/panels with 3D floating effect - Worn Leather surface
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: parchmentColor,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: copperAccent.withValues(alpha: 0.3), width: 1),
    boxShadow: [
      // Ambient shadow (soft, spread)
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 12,
        spreadRadius: 1,
      ),
      // Direct shadow (sharper, offset for 3D effect)
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 8,
        offset: const Offset(2, 4),
      ),
    ],
  );

  /// Glass decoration for overlays/panels
  /// White with 10% opacity for glassmorphism effect
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 20,
        spreadRadius: -5,
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
  // BUTTON STYLES
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary elevated button style - Burnished Copper CTA
  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: copperAccent,
    foregroundColor: textDark,
    shadowColor: Colors.black.withValues(alpha: 0.5),
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    textStyle: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: textDark,
    ),
  );

  /// Secondary/Gold button style for special actions
  static ButtonStyle get goldButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: goldAccent,
    foregroundColor: tableBackgroundColor,
    shadowColor: goldAccent.withValues(alpha: 0.4),
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

  // ════════════════════════════════════════════════════════════════════════════
  // LEGACY ALIASES (For backward compatibility)
  // ════════════════════════════════════════════════════════════════════════════

  static const Color parchment = parchmentColor;
  static const Color textPrimary = textDark;
  static const Color primaryText = textDark;
  static const Color accentRed = errorColor;
  static const Color accentGold = goldAccent;
  static const Color accentCopper = copperAccent;
  static const Color tileBorder = Color(0xFF5D4037);

  /// Legacy text styles
  static const TextStyle tileTitle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: textDark,
    letterSpacing: -0.2,
  );

  static const TextStyle tilePrice = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

  /// Alias for propertyTitleStyle (backward compatibility)
  static TextStyle get propertyTitleStyle => tileTitleStyle;
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
