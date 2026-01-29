/// Data source for theme settings.
/// Uses SharedPreferences for persistence.
/// Pure Dart - no Flutter dependencies (except SharedPreferences).
library;

import 'package:shared_preferences/shared_preferences.dart';

class ThemeDataSource {
  ThemeDataSource._();

  static final ThemeDataSource _instance = ThemeDataSource._();
  static ThemeDataSource get instance => _instance;

  static const String _themeKey = 'theme_mode';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';

  /// Get the saved theme mode
  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  /// Save the theme mode
  Future<bool> setThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_themeKey, themeMode);
  }

  /// Get sound enabled setting
  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Save sound enabled setting
  Future<bool> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_soundEnabledKey, enabled);
  }

  /// Get music enabled setting
  Future<bool> getMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? true;
  }

  /// Save music enabled setting
  Future<bool> setMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_musicEnabledKey, enabled);
  }

  /// Clear all theme settings
  Future<void> clearThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_soundEnabledKey);
    await prefs.remove(_musicEnabledKey);
  }
}
