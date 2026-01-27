/// Game constants for the Literature Quiz RPG game.
/// Centralizes all magic numbers and game rules.
class GameConstants {
  GameConstants._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BOARD CONFIGURATION (RPG Style: 22 tiles)
  // ═══════════════════════════════════════════════════════════════════════════
  static const int boardSize = 22;
  static const int startPosition = 0;

  // Corner Positions (new layout)
  static const int chancePosition = 5; // ŞANS
  static const int fatePosition = 16; // KADER
  static const int shopPosition = 11; // KIRAATHANe

  // ═══════════════════════════════════════════════════════════════════════════
  // PENALTY SYSTEM (Library Watch)
  // ═══════════════════════════════════════════════════════════════════════════
  static const int jailPosition = 5; // Mapped to ŞANS for legacy code
  static const int jailTurns = 1;

  // ═══════════════════════════════════════════════════════════════════════════
  // GAME RULES
  // ═══════════════════════════════════════════════════════════════════════════
  static const int passingStartBonus = 50; // Stars awarded when passing start
  static const int maxConsecutiveDoubles = 3; // Maximum doubles before penalty

  // ═══════════════════════════════════════════════════════════════════════════
  // DICE CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const int diceMinRoll = 2;
  static const int diceMaxRoll = 12;

  // ═══════════════════════════════════════════════════════════════════════════
  // LEVEL UP SYSTEM (Literature Quiz RPG)
  // ═══════════════════════════════════════════════════════════════════════════
  // Level System: 4 levels per category
  // Level 0: Novice (Başlangıç)
  // Level 1: Apprentice (Çırak)
  // Level 2: Journeyman (Kalfa)
  // Level 3: Master (Usta)

  // Star Rewards for correct answers based on tile difficulty
  static const int easyStarReward = 5; // Stars per correct easy answer
  static const int mediumStarReward = 10; // Stars per correct medium answer
  static const int hardStarReward = 15; // Stars per correct hard answer

  // Bonus stars for reaching new levels
  static const int levelUpBonusStars = 20; // Bonus stars when leveling up

  // Level progression: Correct answer = +1 level (max level 3)
  // No requirement for multiple correct answers - instant level up
  static const int maxLevelPerCategory = 3; // Maximum level (Master)

  // ═══════════════════════════════════════════════════════════════════════════
  // WIN CONDITION
  // ═══════════════════════════════════════════════════════════════════════════
  // Player wins when they have collected 50 quotes AND are Master in all 6 categories
  static const int quotesToCollect = 50; // Total quotes needed to win
  static const int totalCategories = 6; // Total number of categories

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMERS (in seconds)
  // ═══════════════════════════════════════════════════════════════════════════
  static const int questionTimerSeconds = 45; // Standard category tiles
  static const int chanceCardTimerSeconds =
      60; // Extended for Chance/Fate cards
  static const int cardTimerSeconds = 60; // Şans/Kader card timer

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS (milliseconds)
  // ═══════════════════════════════════════════════════════════════════════════
  static const int hopAnimationDelay = 150;
  static const int cardAnimationDelay = 500;
  static const int diceAnimationDelay = 1500;
  static const int turnChangeDelay = 1200;
  static const int diceResetDelay = 150;

  // ═══════════════════════════════════════════════════════════════════════════
  // ASSETS
  // ═══════════════════════════════════════════════════════════════════════════
  static const int totalAvatars = 20;
  static String getAvatarPath(int index) =>
      'assets/images/avatar_${(index + 1).toString().padLeft(2, '0')}.png';

  // Modern Avatar Icons (for players without custom avatars)
  static const List<String> modernAvatarIcons = [
    'face_retouching_natural',
    'sentiment_very_satisfied',
    'emoji_emotions',
    'psychology',
    'face',
    'mood',
    'tag_faces',
    'person_outline',
  ];
}
