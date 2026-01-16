import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/game_theme.dart';

/// Theme preset options for the game
enum ThemePreset {
  /// Warm Library Light - cream/parchment with teal accents (DEFAULT)
  warmLibraryLight,

  /// Dark Academia - moody dark with gold accents
  darkAcademia,
}

/// Extension to get display names for presets
extension ThemePresetX on ThemePreset {
  String get displayName {
    switch (this) {
      case ThemePreset.warmLibraryLight:
        return 'Sıcak Kitaplık';
      case ThemePreset.darkAcademia:
        return 'Karanlık Akademi';
    }
  }

  String get key {
    switch (this) {
      case ThemePreset.warmLibraryLight:
        return 'warmLibraryLight';
      case ThemePreset.darkAcademia:
        return 'darkAcademia';
    }
  }

  static ThemePreset fromKey(String? key) {
    switch (key) {
      case 'darkAcademia':
        return ThemePreset.darkAcademia;
      case 'warmLibraryLight':
      default:
        return ThemePreset.warmLibraryLight; // Default to light
    }
  }
}

/// Theme state - tracks the current theme preset
class ThemeState {
  final ThemePreset preset;

  const ThemeState({this.preset = ThemePreset.warmLibraryLight});

  /// Convenience getter for dark mode check
  bool get isDarkMode => preset == ThemePreset.darkAcademia;

  /// Get the current theme tokens
  ThemeTokens get tokens => GameTheme.getTokens(isDarkMode);

  ThemeState copyWith({ThemePreset? preset}) {
    return ThemeState(preset: preset ?? this.preset);
  }
}

/// Theme notifier for managing app theme with persistence
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _presetKey = 'themePreset';
  static const String _legacyDarkKey = 'isDarkTheme'; // Legacy migration

  ThemeNotifier() : super(const ThemeState()) {
    _loadTheme();
  }

  /// Load saved theme preference from SharedPreferences
  /// Handles migration from legacy boolean key
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Check for new preset key first
    final presetKey = prefs.getString(_presetKey);
    if (presetKey != null) {
      state = state.copyWith(preset: ThemePresetX.fromKey(presetKey));
      return;
    }

    // Migrate from legacy boolean key if present
    if (prefs.containsKey(_legacyDarkKey)) {
      final wasDark = prefs.getBool(_legacyDarkKey) ?? false;
      final preset = wasDark
          ? ThemePreset.darkAcademia
          : ThemePreset.warmLibraryLight;
      state = state.copyWith(preset: preset);

      // Save in new format and remove legacy key
      await prefs.setString(_presetKey, preset.key);
      await prefs.remove(_legacyDarkKey);
      return;
    }

    // No saved preference - default to warm library light (already set in ThemeState)
  }

  /// Toggle between themes
  Future<void> toggleTheme() async {
    final newPreset = state.isDarkMode
        ? ThemePreset.warmLibraryLight
        : ThemePreset.darkAcademia;
    await setPreset(newPreset);
  }

  /// Set theme preset directly
  Future<void> setPreset(ThemePreset preset) async {
    state = state.copyWith(preset: preset);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_presetKey, preset.key);
  }

  /// Legacy method for backward compatibility
  Future<void> setTheme(bool isDarkMode) async {
    await setPreset(
      isDarkMode ? ThemePreset.darkAcademia : ThemePreset.warmLibraryLight,
    );
  }
}

/// Global theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
