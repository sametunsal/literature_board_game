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

  /// Main accent for emphasis
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

  /// Modern Minimalist Dark preset - clean, flat dark theme
  /// Deep teal/green background with white surfaces and blue accents
  static const modernMinimalistDark = ThemeTokens(
    // Background - Deep Teal/Green
    background: Color(0xFF0F2E25), // Deep teal
    backgroundHighlight: Color(0xFF1A3D32), // Slightly lighter teal
    // Surfaces - Pure white and light grey
    surface: Color(0xFFFFFFFF), // Pure white
    surfaceAlt: Color(0xFFF5F5F5), // Light grey
    // Text - High contrast
    textPrimary: Color(0xFF1A1A1A), // Black
    textSecondary: Color(0xFF666666), // Dark grey
    textOnAccent: Color(0xFFFFFFFF), // White on buttons
    // Accents - Modern Blue/Amber
    primary: Color(0xFF2196F3), // Modern blue
    secondary: Color(0xFF607D8B), // Cool grey
    accent: Color(0xFFFFB300), // Amber
    // Semantic - Bright, clear colors
    success: Color(0xFF4CAF50), // Bright green
    warning: Color(0xFFFF9800), // Bright orange
    danger: Color(0xFFF44336), // Bright red
    // UI Elements - Subtle
    border: Color(0xFFE0E0E0), // Light grey border
    shadow: Color(0x1A000000), // Subtle shadow
    // Tiles - White with subtle variations
    tileBase: Color(0xFFFFFFFF), // Pure white
    tileHighlight: Color(0xFFF5F5F5), // Light grey
    tileOwned: Color(0xFFE3F2FD), // Light blue tint
    tileCorrect: Color(0xFFE8F5E9), // Light green tint
    tileWrong: Color(0xFFFFEBEE), // Light red tint
    // Dialogs
    dialogBackground: Color(0xFFFFFFFF), // White
    dialogOverlay: Color(0x99000000), // Black @ 60%
  );

  /// Modern Minimalist Light preset - clean, flat light theme
  /// Neutral grey background with white surfaces and blue accents
  static const modernMinimalistLight = ThemeTokens(
    // Background - Neutral grey
    background: Color(0xFFF0F2F5), // Light neutral grey
    backgroundHighlight: Color(0xFFE8EBF0), // Slightly darker
    // Surfaces - Pure white
    surface: Color(0xFFFFFFFF), // Pure white
    surfaceAlt: Color(0xFFF8F9FA), // Very light grey
    // Text - High contrast
    textPrimary: Color(0xFF1A1A1A), // Black
    textSecondary: Color(0xFF666666), // Dark grey
    textOnAccent: Color(0xFFFFFFFF), // White on buttons
    // Accents - Modern Blue/Amber
    primary: Color(0xFF2196F3), // Modern blue
    secondary: Color(0xFF607D8B), // Cool grey
    accent: Color(0xFFFFB300), // Amber
    // Semantic - Bright, clear colors
    success: Color(0xFF4CAF50), // Bright green
    warning: Color(0xFFFF9800), // Bright orange
    danger: Color(0xFFF44336), // Bright red
    // UI Elements - Subtle
    border: Color(0xFFE0E0E0), // Light grey border
    shadow: Color(0x1A000000), // Subtle shadow
    // Tiles - White with subtle variations
    tileBase: Color(0xFFFFFFFF), // Pure white
    tileHighlight: Color(0xFFF5F5F5), // Light grey
    tileOwned: Color(0xFFE3F2FD), // Light blue tint
    tileCorrect: Color(0xFFE8F5E9), // Light green tint
    tileWrong: Color(0xFFFFEBEE), // Light red tint
    // Dialogs
    dialogBackground: Color(0xFFFFFFFF), // White
    dialogOverlay: Color(0x66000000), // Black @ 40%
  );

  // ════════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// Get tokens for the given mode
  static ThemeTokens forMode(bool isDarkMode) {
    return isDarkMode ? modernMinimalistDark : modernMinimalistLight;
  }

  /// Check if this is a dark theme
  bool get isDark => this == modernMinimalistDark;
}
