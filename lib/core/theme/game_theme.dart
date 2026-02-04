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
  // COLOR PALETTE - MODERN MINIMALIST (V3.0)
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary background / Canvas - Deep Teal (Dark Mode)
  static const Color tableBackgroundColor = Color(0xFF0F2E25);

  /// Slightly lighter shade for gradient spotlight effect
  static const Color tableHighlightColor = Color(0xFF1A3D32);

  /// Panel/Surface color - Pure White
  static const Color parchmentColor = Color(0xFFFFFFFF);

  /// Success/Primary accent for highlights and borders - Modern Blue
  static const Color goldAccent = Color(0xFFFFB300);

  /// Primary CTA/Accent - Modern Blue
  static const Color copperAccent = Color(0xFF2196F3);

  /// Primary text color - Black
  static const Color textDark = Color(0xFF1A1A1A);

  /// Error color - Bright Red
  static const Color errorColor = Color(0xFFF44336);

  /// Dialog overlay color (darker for dark theme)
  static const Color dialogOverlayColor = Color(0x99000000);

  // ════════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE - MODERN MINIMALIST LIGHT (V3.0)
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary background / Canvas - Neutral Grey
  static const Color lightBackgroundColor = Color(0xFFF0F2F5);

  /// Slightly darker shade for gradient spotlight effect
  static const Color lightHighlightColor = Color(0xFFE8EBF0);

  /// Panel/Surface color - Pure White
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);

  /// Accent color - Modern Blue (for highlights)
  static const Color lightAccentRed = Color(0xFF2196F3);

  /// Primary text color - Black (for contrast)
  static const Color lightTextColor = Color(0xFF1A1A1A);

  /// Error color - Bright Red
  static const Color lightErrorColor = Color(0xFFF44336);

  /// Dialog overlay color (lighter for light theme)
  static const Color lightDialogOverlay = Color(0x66000000);

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
    1: Color(0xFF9C27B0), // Purple - tiles 1-4 (vibrant)
    2: Color(0xFF2196F3), // Blue - tiles 6-9 (vibrant)
    3: Color(0xFFE91E63), // Pink - tiles 11-14 (vibrant)
    4: Color(0xFFFF9800), // Orange - tiles 16-19 (vibrant)
    5: Color(0xFFF44336), // Red - tiles 21-24 (vibrant)
    6: Color(0xFFFFEB3B), // Yellow - tiles 26-29 (vibrant)
    7: Color(0xFF4CAF50), // Green - tiles 31-34 (vibrant)
    8: Color(0xFF00BCD4), // Cyan - tiles 36-39 (vibrant)
  };

  /// Get the group color for a tile based on its ID (26-tile board)
  static Color getGroupColor(int tileId) {
    // Bottom row (excluding start and special tiles): 1-4
    if (tileId >= 1 && tileId <= 4) return _groupColors[1]!;
    // Left column category tiles: 7-10
    if (tileId >= 7 && tileId <= 10) return _groupColors[2]!;
    // Top row category tiles: 13-16
    if (tileId >= 13 && tileId <= 16) return _groupColors[3]!;
    // Right column category tiles (first part): 19-22
    if (tileId >= 19 && tileId <= 22) return _groupColors[4]!;
    // Right column category tiles (back to start): 24-25
    if (tileId >= 24 && tileId <= 25) return _groupColors[5]!;
    return Colors.grey.shade400;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CORNER TILE CONFIGURATIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// Corner tile visual configuration data
  static const Map<int, CornerTileConfig> cornerConfigs = {
    0: CornerTileConfig(
      icon: Icons.play_arrow,
      label: 'BAŞLA',
      backgroundColor: Color(0xFFE8F5E9),
    ),
    10: CornerTileConfig(
      icon: Icons.local_library,
      label: 'NÖBET',
      backgroundColor: Color(0xFFFFF3E0),
    ),
    20: CornerTileConfig(
      icon: Icons.campaign,
      label: 'İMZA',
      backgroundColor: Color(0xFFF3E5F5),
    ),
    30: CornerTileConfig(
      icon: Icons.warning,
      label: 'RİSK',
      backgroundColor: Color(0xFFFFEBEE),
    ),
  };

  // ════════════════════════════════════════════════════════════════════════════
  // OTTOMAN SCHOLAR COLORS (For non-gameplay screens)
  // ════════════════════════════════════════════════════════════════════════════

  /// Ottoman Scholar: Aged Ottoman Paper background
  static const Color ottomanBackground = Color(0xFFF5F1E8);

  /// Ottoman Scholar: Paper edge/gradient shadow
  static const Color ottomanBackgroundAlt = Color(0xFFEDE8DC);

  /// Ottoman Scholar: Deep Ink/Teal (Ottoman inkwell)
  static const Color ottomanAccent = Color(0xFF1A4D42);

  /// Ottoman Scholar: Sepia Brown (aged paper edges)
  static const Color ottomanSepia = Color(0xFF8B4513);

  /// Ottoman Scholar: Antique Gold (brushed metal feel)
  static const Color ottomanGold = Color(0xFFC9A227);

  /// Ottoman Scholar: Polished Gold (hover state)
  static const Color ottomanGoldLight = Color(0xFFD4AF37);

  /// Ottoman Scholar: Aged Gold shadow
  static const Color ottomanGoldShadow = Color(0xFF8B6914);

  /// Ottoman Scholar: Dried Sepia (primary text)
  static const Color ottomanText = Color(0xFF3D3B35);

  /// Ottoman Scholar: Muted Sepia (secondary text)
  static const Color ottomanTextSecondary = Color(0xFF8B7355);

  /// Ottoman Scholar: Signature line (input underline)
  static const Color ottomanSignatureLine = Color(0xFF8B7355);

  /// Ottoman Scholar: Aged Edge border
  static const Color ottomanBorder = Color(0xFFD4C4A8);

  /// Ottoman Scholar: Cinnabar Red (traditional Ottoman)
  static const Color ottomanCinnabar = Color(0xFFA83F39);

  // ════════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY - BASE FONTS (ALL SANS-SERIF)
  // ════════════════════════════════════════════════════════════════════════════

  /// Header font - Poppins (Sans-Serif) for modern titles
  static TextStyle get headerFont => GoogleFonts.poppins();

  /// Body font - Poppins for readable UI text
  static TextStyle get bodyFont => GoogleFonts.poppins();

  // ════════════════════════════════════════════════════════════════════════════
  // OTTOMAN SCHOLAR TYPOGRAPHY (For non-gameplay screens)
  // ════════════════════════════════════════════════════════════════════════════

  /// Ottoman Scholar: Main Title (EDEBİNA) - Cinzel Decorative, 60sp
  static TextStyle get ottomanTitle => GoogleFonts.cinzelDecorative(
        fontSize: 60,
        fontWeight: FontWeight.w900,
        color: ottomanAccent,
        letterSpacing: 4,
        height: 1.0,
      );

  /// Ottoman Scholar: Subtitle (ANA MENÜ) - Cormorant Garamond, 24sp
  static TextStyle get ottomanSubtitle => GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ottomanAccent.withValues(alpha: 0.7),
        letterSpacing: 6,
        height: 1.0,
      );

  /// Ottoman Scholar: Header Labels - Crimson Text, Bold
  static TextStyle get ottomanHeader => GoogleFonts.crimsonText(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: ottomanAccent,
        letterSpacing: 2,
        height: 1.2,
      );

  /// Ottoman Scholar: Button Text - Crimson Text, SemiBold
  static TextStyle get ottomanButtonText => GoogleFonts.crimsonText(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 1.5,
        height: 1.0,
      );

  /// Ottoman Scholar: Body Text - Crimson Text, Medium
  static TextStyle get ottomanBody => GoogleFonts.crimsonText(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ottomanText,
        height: 1.4,
      );

  /// Ottoman Scholar: Handwriting/Signature Style - Amiri
  static TextStyle get ottomanSignature => GoogleFonts.amiri(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: ottomanText,
        height: 1.0,
      );

  /// Ottoman Scholar: Player Label - Cinzel Decorative, Small
  static TextStyle get ottomanPlayerLabel => GoogleFonts.cinzelDecorative(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ottomanTextSecondary,
        letterSpacing: 2.0,
        height: 1.0,
      );

  // ════════════════════════════════════════════════════════════════════════════
  // HUD TYPOGRAPHY HIERARCHY
  // Scale: 24 → 18 → 14 → 12 → 10 → 8 (1.25 ratio)
  // ════════════════════════════════════════════════════════════════════════════

  /// HUD Title Large (24px) - Major game titles, winner announcements
  static TextStyle get hudTitleLarge => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: goldAccent,
    letterSpacing: 0.5,
  );

  /// HUD Title Medium (18px) - Section headers, panel titles
  static TextStyle get hudTitleMedium => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
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
    fontWeight: FontWeight.w700,
    color: goldAccent,
    letterSpacing: 0.5,
  );

  /// Player name in score row
  static TextStyle get hudPlayerName => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textDark.withValues(alpha: 0.9),
  );

  /// Balance/money display
  static TextStyle get hudBalance => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  /// Log entry text
  static TextStyle get hudLogEntry => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textDark.withValues(alpha: 0.75),
    height: 1.3,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // LEGACY TEXT STYLES (Backward compatibility)
  // ════════════════════════════════════════════════════════════════════════════

  /// HUD title style (EDEBINA) - Large, bold, Amber, Poppins
  /// @deprecated Use hudTitleLarge instead
  static TextStyle get hudTitleStyle => hudTitleLarge.copyWith(fontSize: 28);

  /// HUD subtitle/action text style - Black for readability
  /// @deprecated Use hudCaption instead
  static TextStyle get hudSubtitleStyle => hudCaption;

  /// Tile title style - Small, bold, Black, Poppins
  static TextStyle get tileTitleStyle => GoogleFonts.poppins(
    fontSize: 8,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  /// Tile price style - Very small, lighter Black, Poppins
  static TextStyle get tilePriceStyle => GoogleFonts.poppins(
    fontSize: 7,
    fontWeight: FontWeight.w500,
    color: textDark.withValues(alpha: 0.7),
  );

  /// Corner tile label style - Black for backgrounds
  static TextStyle get cornerLabelStyle => GoogleFonts.poppins(
    fontSize: 8,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  /// Price badge text style - Black
  static const TextStyle priceBadgeStyle = TextStyle(
    fontSize: 7,
    fontWeight: FontWeight.w700,
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

  /// Board container with flat shadow effect
  /// @deprecated Use boardDecorationFor(isDarkMode) for theme-aware decoration
  @Deprecated('Use boardDecorationFor(isDarkMode) for proper theme support')
  static BoxDecoration get boardDecoration => boardDecorationFor(true);

  /// Theme-aware board decoration (flat, modern)
  static BoxDecoration boardDecorationFor(bool isDarkMode) {
    final tokens = getTokens(isDarkMode);
    return BoxDecoration(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: tokens.shadow.withValues(alpha: isDarkMode ? 0.3 : 0.15),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 4),
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

  /// Theme-aware center area decoration (flat, modern)
  static BoxDecoration centerAreaDecorationFor(bool isDarkMode) {
    final tokens = getTokens(isDarkMode);
    return BoxDecoration(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: tokens.shadow.withValues(alpha: isDarkMode ? 0.15 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Card decoration for tiles/panels with flat effect
  /// @deprecated Use cardDecorationFor(isDarkMode) for theme-aware decoration
  @Deprecated('Use cardDecorationFor(isDarkMode) for proper theme support')
  static BoxDecoration get cardDecoration => cardDecorationFor(true);

  /// Theme-aware card decoration (flat, modern)
  static BoxDecoration cardDecorationFor(bool isDarkMode) {
    final tokens = getTokens(isDarkMode);
    return BoxDecoration(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: tokens.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: tokens.shadow.withValues(alpha: isDarkMode ? 0.15 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
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
  static BoxDecoration groupColorStrip(int tileId) =>
      BoxDecoration(color: getGroupColor(tileId));

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
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                ),
              ],
      );

  // ════════════════════════════════════════════════════════════════════════════
  // BUTTON STYLES
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary elevated button style - Modern Blue CTA
  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: copperAccent,
    foregroundColor: Colors.white,
    shadowColor: Colors.black.withValues(alpha: 0.2),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
  );

  /// Secondary/Amber button style for special actions
  static ButtonStyle get goldButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: goldAccent,
    foregroundColor: Colors.black,
    shadowColor: goldAccent.withValues(alpha: 0.3),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
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
  static const Color tileBorder = Color(0xFFE0E0E0);

  /// Legacy text styles
  static const TextStyle tileTitle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
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
        titleLarge: GoogleFonts.poppins(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.poppins(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.poppins(color: tokens.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.textOnAccent,
          shadowColor: tokens.shadow,
          elevation: isDarkMode ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
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
