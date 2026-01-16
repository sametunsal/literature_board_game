import 'package:flutter/material.dart';

/// Immutable theme tokens class containing semantic color definitions.
/// This provides a centralized, type-safe way to manage theme colors.
@immutable
class ThemeTokens {
  // ════════════════════════════════════════════════════════════════════════════
  // BACKGROUND & SURFACE COLORS
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary background color (canvas/scaffold)
  final Color background;

  /// Slightly different shade for gradient highlights
  final Color backgroundHighlight;

  /// Surface color for cards, panels, elevated elements
  final Color surface;

  /// Alternative surface for secondary panels
  final Color surfaceAlt;

  // ════════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary text color - highest contrast
  final Color textPrimary;

  /// Secondary text color - muted, for subtitles/hints
  final Color textSecondary;

  /// Text color on accent/primary buttons
  final Color textOnAccent;

  // ════════════════════════════════════════════════════════════════════════════
  // ACCENT & ACTION COLORS
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary action color (CTAs, primary buttons)
  final Color primary;

  /// Secondary accent (supporting highlights)
  final Color secondary;

  /// Main accent for emphasis (gold in dark, teal in light)
  final Color accent;

  // ════════════════════════════════════════════════════════════════════════════
  // SEMANTIC STATE COLORS
  // ════════════════════════════════════════════════════════════════════════════

  /// Success state color
  final Color success;

  /// Warning state color
  final Color warning;

  /// Danger/error state color
  final Color danger;

  // ════════════════════════════════════════════════════════════════════════════
  // UI ELEMENT COLORS
  // ════════════════════════════════════════════════════════════════════════════

  /// Border color for cards, tiles, inputs
  final Color border;

  /// Shadow color (typically semi-transparent black)
  final Color shadow;

  // ════════════════════════════════════════════════════════════════════════════
  // TILE-SPECIFIC COLORS
  // ════════════════════════════════════════════════════════════════════════════

  /// Base tile background
  final Color tileBase;

  /// Highlighted/hovered tile
  final Color tileHighlight;

  /// Owned/purchased tile indicator
  final Color tileOwned;

  /// Correct answer tile
  final Color tileCorrect;

  /// Wrong answer tile
  final Color tileWrong;

  // ════════════════════════════════════════════════════════════════════════════
  // DIALOG COLORS
  // ════════════════════════════════════════════════════════════════════════════

  /// Dialog/modal background
  final Color dialogBackground;

  /// Overlay behind dialogs
  final Color dialogOverlay;

  // ════════════════════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ════════════════════════════════════════════════════════════════════════════

  const ThemeTokens({
    required this.background,
    required this.backgroundHighlight,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnAccent,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.border,
    required this.shadow,
    required this.tileBase,
    required this.tileHighlight,
    required this.tileOwned,
    required this.tileCorrect,
    required this.tileWrong,
    required this.dialogBackground,
    required this.dialogOverlay,
  });

  // ════════════════════════════════════════════════════════════════════════════
  // PRESETS
  // ════════════════════════════════════════════════════════════════════════════

  /// Dark Academia preset - existing dark theme colors
  /// Moody, rich, and atmospheric with gold accents
  static const darkAcademia = ThemeTokens(
    // Background
    background: Color(0xFF202621), // Phantom Black (tableBackgroundColor)
    backgroundHighlight: Color(0xFF2A3029), // Slightly lighter for gradient
    // Surfaces
    surface: Color(0xFF734838), // Worn Leather (parchmentColor)
    surfaceAlt: Color(0xFF5D4037), // Darker leather variant
    // Text - IMPROVED CONTRAST
    textPrimary: Color(0xFFE2C4A8), // Brighter Antique Lace for better contrast
    textSecondary: Color(0xCCD9B596), // Antique Lace @ 80% (was 70%)
    textOnAccent: Color(0xFF202621), // Dark text on gold buttons
    // Accents
    primary: Color(0xFFA66F5B), // Burnished Copper (copperAccent)
    secondary: Color(0xFF8B7355), // Muted bronze
    accent: Color(0xFFFFD700), // Gold (goldAccent)
    // Semantic - IMPROVED DANGER VISIBILITY
    success: Color(0xFF4CAF50), // Brighter green for visibility
    warning: Color(0xFFFFA726), // Brighter amber
    danger: Color(0xFFB23A48), // Deep burgundy-red (dark academia vibe)
    // UI Elements
    border: Color(0x4DA66F5B), // Copper @ 30%
    shadow: Color(0x80000000), // Black @ 50%
    // Tiles
    tileBase: Color(0xFF734838), // Worn leather
    tileHighlight: Color(0xFF8B5A4A), // Lighter leather
    tileOwned: Color(0xFF4A3728), // Darker owned
    tileCorrect: Color(0xFF2E4A2E), // Dark green
    tileWrong: Color(0xFF4A2E2E), // Dark red
    // Dialogs
    dialogBackground: Color(0xFF734838), // Worn leather
    dialogOverlay: Color(0xCC000000), // Black @ 80%
  );

  /// Warm Library Light preset - new light theme
  /// Warm, inviting, classic library aesthetic with cream/parchment tones
  /// DUAL-ACCENT SYSTEM:
  /// - primary = teal (selection, CTA buttons)
  /// - accent = amber (rewards, trophy, money highlights)
  /// - secondary = warm olive (supporting, less emphasis)
  static const warmLibraryLight = ThemeTokens(
    // Background - warm cream/parchment
    background: Color(0xFFFAF7F2), // Warm cream
    backgroundHighlight: Color(0xFFF5F0E8), // Slightly darker for gradient
    // Surfaces - ivory/off-white
    surface: Color(0xFFFFFDF8), // Ivory white
    surfaceAlt: Color(0xFFEDE8DF), // Slightly darker parchment
    // Text - deep ink colors for excellent contrast
    textPrimary: Color(0xFF1A1F2E), // Deep ink (navy-black)
    textSecondary: Color(0xFF3D4555), // Darker muted ink (was #4A5568)
    textOnAccent: Color(0xFFFFFDF8), // Light text on teal/primary buttons
    // Accents - DUAL SYSTEM
    primary: Color(0xFF2D6A6A), // Muted teal (selection, CTA)
    secondary: Color(0xFF6B705C), // Warm olive (calm supporting tone)
    accent: Color(0xFFD4A017), // Rich amber/gold (rewards/trophy/money)
    // Semantic - softer, more muted for light theme
    success: Color(0xFF2E7D32), // Soft green
    warning: Color(0xFFE65100), // Deep orange
    danger: Color(0xFFC62828), // Soft red
    // UI Elements - IMPROVED SHADOW
    border: Color(0xFFD4C9B8), // Warm beige border
    shadow: Color(0x26000000), // Subtle shadow 15% (was 10%)
    // Tiles - light surfaces with gentle tints
    tileBase: Color(0xFFFFFDF8), // Ivory base
    tileHighlight: Color(0xFFE0F2F1), // Gentle teal tint
    tileOwned: Color(0xFFFFF8E1), // Subtle amber tint
    tileCorrect: Color(0xFFE8F5E9), // Soft green tint
    tileWrong: Color(0xFFFFEBEE), // Soft red tint
    // Dialogs - subtle overlay for light theme
    dialogBackground: Color(0xFFFFFDF8), // Ivory
    dialogOverlay: Color(0x66000000), // Black @ 40% (subtle)
  );

  // ════════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// Get tokens for the given mode
  static ThemeTokens forMode(bool isDarkMode) {
    return isDarkMode ? darkAcademia : warmLibraryLight;
  }

  /// Check if this is a dark theme
  bool get isDark => this == darkAcademia;
}
