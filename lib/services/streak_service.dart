import 'package:shared_preferences/shared_preferences.dart';

/// Streak Service - Tracks user's daily login streak for gamification
/// Uses SharedPreferences for persistent storage
class StreakService {
  // Singleton pattern
  static StreakService? _instance;
  static StreakService get instance => _instance ??= StreakService._();

  StreakService._();

  // Storage keys
  static const String _keyLastLoginDate = 'streak_last_login_date';
  static const String _keyStreakDays = 'streak_days';

  SharedPreferences? _prefs;

  /// Initialize the service (call once at app start)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check and update streak on app open
  /// Returns the current streak count
  Future<int> checkAndUpdateStreak() async {
    await init();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get last login date
    final lastLoginStr = _prefs!.getString(_keyLastLoginDate);
    final currentStreak = _prefs!.getInt(_keyStreakDays) ?? 0;

    if (lastLoginStr == null) {
      // First time user - start streak at 1
      await _saveStreak(today, 1);
      return 1;
    }

    final lastLogin = DateTime.parse(lastLoginStr);
    final lastLoginDay = DateTime(
      lastLogin.year,
      lastLogin.month,
      lastLogin.day,
    );

    // Calculate difference in days
    final difference = today.difference(lastLoginDay).inDays;

    if (difference == 0) {
      // Same day - return existing streak (no change)
      return currentStreak;
    } else if (difference == 1) {
      // Consecutive day - increment streak
      final newStreak = currentStreak + 1;
      await _saveStreak(today, newStreak);
      return newStreak;
    } else {
      // Streak broken (more than 1 day gap) - reset to 1
      await _saveStreak(today, 1);
      return 1;
    }
  }

  /// Get current streak without updating
  Future<int> getCurrentStreak() async {
    await init();
    return _prefs!.getInt(_keyStreakDays) ?? 0;
  }

  /// Check if user logged in today
  Future<bool> hasLoggedInToday() async {
    await init();

    final lastLoginStr = _prefs!.getString(_keyLastLoginDate);
    if (lastLoginStr == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime.parse(lastLoginStr);
    final lastLoginDay = DateTime(
      lastLogin.year,
      lastLogin.month,
      lastLogin.day,
    );

    return today.isAtSameMomentAs(lastLoginDay);
  }

  /// Reset streak (for testing or user request)
  Future<void> resetStreak() async {
    await init();
    await _prefs!.remove(_keyLastLoginDate);
    await _prefs!.remove(_keyStreakDays);
  }

  /// Save streak data
  Future<void> _saveStreak(DateTime date, int streakDays) async {
    await _prefs!.setString(_keyLastLoginDate, date.toIso8601String());
    await _prefs!.setInt(_keyStreakDays, streakDays);
  }

  /// Get last login date (for debugging/display)
  Future<DateTime?> getLastLoginDate() async {
    await init();
    final lastLoginStr = _prefs!.getString(_keyLastLoginDate);
    if (lastLoginStr == null) return null;
    return DateTime.parse(lastLoginStr);
  }
}
