import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme state - tracks whether dark mode is enabled
class ThemeState {
  final bool isDarkMode;

  const ThemeState({this.isDarkMode = true});

  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }
}

/// Theme notifier for managing app theme with persistence
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'isDarkTheme';

  ThemeNotifier() : super(const ThemeState()) {
    _loadTheme();
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true; // Default to dark
    state = state.copyWith(isDarkMode: isDark);
  }

  /// Toggle between dark and light themes
  Future<void> toggleTheme() async {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);

    // Persist the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newValue);
  }

  /// Set theme directly (useful for initialization)
  Future<void> setTheme(bool isDarkMode) async {
    state = state.copyWith(isDarkMode: isDarkMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }
}

/// Global theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
