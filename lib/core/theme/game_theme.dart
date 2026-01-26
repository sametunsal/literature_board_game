import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_tokens.dart';

// Re-export for convenience
export 'theme_tokens.dart';

/// Comprehensive theme for the Literature Board Game
/// Provides consistent styling across all game components
class GameTheme {
  GameTheme._(); // Private constructor to prevent instantiation

  // ════════════════════════════════════════════════════════════════════════════
  // THEME TOKENS ACCESS
  // ════════════════════════════════════════════════════════════════════════════

  /// Get the appropriate theme tokens based on mode
  static ThemeTokens getTokens(bool isDarkMode) =>
      ThemeTokens.forMode(isDarkMode);

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
  // COLOR PALETTE - CLASSIC LIBRARY (V2.6 - LIGHT MODE)
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary background / Canvas - Parchment/Cream
  static const Color lightBackgroundColor = Color(0xFFF5F5DC);

  /// Slightly darker shade for gradient spotlight effect
  static const Color lightHighlightColor = Color(0xFFEBE8D0);

  /// Panel/Surface color - Paper White
  static const Color lightSurfaceColor = Color(0xFFE8E0D6);

  /// Accent color - Deep Red (for highlights)
  static const Color lightAccentRed = Color(0xFFC41E3A);

  /// Primary text color - Dark Brown (for contrast)
  static const Color lightTextColor = Color(0xFF2C241B);

  /// Error color - Muted Red
  static const Color lightErrorColor = Color(0xFFB71C1C);

  /// Dialog overlay color (lighter for light theme)
  static const Color lightDialogOverlay = Color(0x99000000);

  // ════════════════════════════════════════════════════════════════════════════
  // DYNAMIC COLOR GETTERS (token-based for theme mode)
  // ════════════════════════════════════════════════════════════════════════════

  static Color backgroundColor(bool isDarkMode) =>
      getTokens(isDarkMode).background;

  static Color highlightColor(bool isDarkMode) =>
      getTokens(isDarkMode).backgroundHighlight;

  static Color surfaceColor(bool isDarkMode) => getTokens(isDarkMode).surface;

  static Color primaryTextColor(bool isDarkMode) =>
      getTokens(isDarkMode).textPrimary;

  static Color accentColor(bool isDarkMode) => getTokens(isDarkMode).accent;

  static Color primaryAccent(bool isDarkMode) => getTokens(isDarkMode).primary;

  static Color errorAccent(bool isDarkMode) => getTokens(isDarkMode).danger;

  static Color overlayColor(bool isDarkMode) =>
      getTokens(isDarkMode).dialogOverlay;

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
  // HUD TYPOGRAPHY HIERARCHY
  // Scale: 24 → 18 → 14 → 12 → 10 → 8 (1.25 ratio)
  // ════════════════════════════════════════════════════════════════════════════

  /// HUD Title Large (24px) - Major game titles, winner announcements
  static TextStyle get hudTitleLarge => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: goldAccent,
    letterSpacing: 0.5,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.6),
        blurRadius: 8,
        offset: const Offset(2, 2),
      ),
    ],
  );

  /// HUD Title Medium (18px) - Section headers, panel titles
  static TextStyle get hudTitleMedium => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: goldAccent,
    letterSpacing: 0.3,
  );

  /// HUD Subtitle (14px) - Secondary headers, player names emphasis
  static TextStyle get hudSubtitle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textDark,
    letterSpacing: 0.2,
  );

  /// HUD Body (12px) - Main content text, descriptions
  static TextStyle get hudBody => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textDark.withValues(alpha: 0.9),
    height: 1.4,
  );

  /// HUD Caption (10px) - Small labels, timestamps, hints
  /// IMPROVED: Increased alpha from 0.7 to 0.8 for small text readability
  static TextStyle get hudCaption => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textDark.withValues(alpha: 0.8),
    letterSpacing: 0.15,
  );

  /// HUD Micro (8px) - Tiny UI elements, badges, tile text
  static TextStyle get hudMicro => GoogleFonts.poppins(
    fontSize: 8,
    fontWeight: FontWeight.w600,
    color: textDark.withValues(alpha: 0.85),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // HUD LABEL STYLES (Semantic naming for specific uses)
  // ════════════════════════════════════════════════════════════════════════════

  /// Score panel header label (uppercase)
  static TextStyle get hudSectionLabel => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: goldAccent,
    letterSpacing: 0.5,
  );

  /// Player name in score row
  /// IMPROVED: Increased alpha from 0.85 to 0.9 for better readability
  static TextStyle get hudPlayerName => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textDark.withValues(alpha: 0.9),
  );

  /// Balance/money display
  static TextStyle get hudBalance => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  /// Log entry text
  /// IMPROVED: Increased alpha from 0.7 to 0.75 for readability
  static TextStyle get hudLogEntry => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: textDark.withValues(alpha: 0.75),
    height: 1.3,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // LEGACY TEXT STYLES (Backward compatibility)
  // ════════════════════════════════════════════════════════════════════════════

  /// HUD title style (EDEBINA) - Large, bold, Gold, Playfair
  /// @deprecated Use hudTitleLarge instead
  static TextStyle get hudTitleStyle => hudTitleLarge.copyWith(
    fontSize: 28,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.7),
        blurRadius: 10,
        offset: const Offset(2, 3),
      ),
    ],
  );

  /// HUD subtitle/action text style - Antique Lace for readability
  /// @deprecated Use hudCaption instead
  static TextStyle get hudSubtitleStyle => hudCaption;

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
  /// @deprecated Use tableDecorationFor(isDarkMode) for theme-aware decoration
  @Deprecated(
    'Use tableDecorationFor(isDarkMode) instead for proper theme support',
  )
  static BoxDecoration get tableDecoration => tableDecorationFor(true);

  /// Theme-aware table decoration
  static BoxDecoration tableDecorationFor(bool isDarkMode) {
    final tokens = getTokens(isDarkMode);
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [tokens.backgroundHighlight, tokens.background],
        stops: const [0.0, 1.0],
      ),
    );
  }

  /// Alias for backward compatibility
  static BoxDecoration get backgroundTable => tableDecorationFor(true);

  /// Board container with 3D shadow effect
  /// @deprecated Use boardDecorationFor(isDarkMode) for theme-aware decoration
  @Deprecated('Use boardDecorationFor(isDarkMode) for proper theme support')
  static BoxDecoration get boardDecoration => boardDecorationFor(true);

  /// Theme-aware board decoration
  static BoxDecoration boardDecorationFor(bool isDarkMode) {
    final tokens = getTokens(isDarkMode);
    return BoxDecoration(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        // Outer shadow for depth
        BoxShadow(
          color: tokens.shadow.withValues(alpha: isDarkMode ? 0.5 : 0.2),
          blurRadius: 20,
          spreadRadius: isDarkMode ? 5 : 2,
          offset: const Offset(10, 10),
        ),
        // Inner highlight for embossed effect
        BoxShadow(
          color: (isDarkMode ? Colors.white : tokens.background).withValues(
            alpha: isDarkMode ? 0.2 : 0.5,
          ),
          blurRadius: 15,
          spreadRadius: -5,
          offset: const Offset(-5, -5),
        ),
      ],
    );
  }

  /// Center area with subtle gradient
  /// @deprecated Use centerAreaDecorationFor(isDarkMode) for theme-aware decoration
  @Deprecated(
    'Use centerAreaDecorationFor(isDarkMode) for proper theme support',
  )
  static BoxDecoration get centerAreaDecoration =>
      centerAreaDecorationFor(true);

  /// Theme-aware center area decoration
  static BoxDecoration centerAreaDecorationFor(bool isDarkMode) {
    final tokens = getTokens(isDarkMode);
    return BoxDecoration(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [tokens.surface, tokens.surfaceAlt],
      ),
      boxShadow: [
        BoxShadow(
          color: tokens.shadow.withValues(alpha: isDarkMode ? 0.2 : 0.1),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
    );
  }

  /// Card decoration for tiles/panels with 3D floating effect
  /// @deprecated Use cardDecorationFor(isDarkMode) for theme-aware decoration
  @Deprecated('Use cardDecorationFor(isDarkMode) for proper theme support')
  static BoxDecoration get cardDecoration => cardDecorationFor(true);

  /// Theme-aware card decoration
  static BoxDecoration cardDecorationFor(bool isDarkMode) {
    final tokens = getTokens(isDarkMode);
    return BoxDecoration(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: tokens.border, width: 1),
      boxShadow: [
        // Ambient shadow (soft, spread)
        BoxShadow(
          color: tokens.shadow.withValues(alpha: isDarkMode ? 0.3 : 0.15),
          blurRadius: 12,
          spreadRadius: 1,
        ),
        // Direct shadow (sharper, offset for 3D effect)
        BoxShadow(
          color: tokens.shadow.withValues(alpha: isDarkMode ? 0.4 : 0.1),
          blurRadius: 8,
          offset: const Offset(2, 4),
        ),
      ],
    );
  }

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

  // ════════════════════════════════════════════════════════════════════════════
  // THEME DATA BUILDER
  // ════════════════════════════════════════════════════════════════════════════

  /// Build complete ThemeData based on current mode using tokens
  static ThemeData buildThemeData(bool isDarkMode) {
    final tokens = getTokens(isDarkMode);

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: tokens.background,
      colorScheme: isDarkMode
          ? ColorScheme.dark(
              surface: tokens.surface,
              primary: tokens.primary,
              secondary: tokens.accent,
              error: tokens.danger,
              onSurface: tokens.textPrimary,
              onPrimary: tokens.textOnAccent,
            )
          : ColorScheme.light(
              surface: tokens.surface,
              primary: tokens.primary,
              secondary: tokens.accent,
              error: tokens.danger,
              onSurface: tokens.textPrimary,
              onPrimary: tokens.textOnAccent,
            ),
      cardColor: tokens.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.poppins(color: tokens.textPrimary),
        bodyMedium: GoogleFonts.poppins(color: tokens.textPrimary),
        bodySmall: GoogleFonts.poppins(color: tokens.textSecondary),
        titleLarge: GoogleFonts.playfairDisplay(color: tokens.textPrimary),
        titleMedium: GoogleFonts.playfairDisplay(color: tokens.textPrimary),
        titleSmall: GoogleFonts.poppins(color: tokens.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.textOnAccent,
          shadowColor: tokens.shadow,
          elevation: isDarkMode ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
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
