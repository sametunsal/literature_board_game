/// Game constants for the literature board game.
/// Centralizes all magic numbers and game rules.
class GameConstants {
  GameConstants._();

  // Board Configuration (RPG Style: 22 tiles)
  static const int boardSize = 22;
  static const int startPosition = 0;

  // Corner Positions (new layout)
  static const int chancePosition = 5; // Şans
  static const int fatePosition = 10; // Kader
  static const int shopPosition = 15; // Kıraathane

  // Jail/Prison (removed - using skip turns for penalties)
  static const int jailPosition = 5; // Mapped to Şans for legacy code
  static const int jailTurns = 1;

  // Game Rules
  static const int passingStartBonus = 50; // Reduced for shorter board
  static const int maxConsecutiveDoubles = 3;
  static const int defaultPropertyPrice = 100;

  // Dice
  static const int diceMinRoll = 2;
  static const int diceMaxRoll = 12;

  // RPG Progression Rewards
  static const int answersToPromote = 3; // Correct answers needed per level
  static const int easyStarReward = 10; // Stars per correct easy answer
  static const int mediumStarReward = 20; // Stars per correct medium answer
  static const int hardStarReward = 30; // Stars per correct hard answer
  static const int masterBonusReward = 5; // Bonus for already-master correct

  // Legacy promotion constants (kept for reference)
  static const int cirakPromotionStars = 10;
  static const int kalfaPromotionStars = 20;
  static const int ustaPromotionStars = 50;

  // Question Timer (in seconds)
  static const int questionTimerSeconds = 45; // Standard category tiles
  static const int chanceCardTimerSeconds = 60; // Extended for Chance/Fate

  // Win Condition
  static const int ehilInventoryRequirement = 50; // Cards needed for Ehil
  static const int quotesToCollect = 50; // Alias for Collection screen

  // Rent Multipliers (kept for legacy compatibility)
  static const int utilityRentMultiplier = 15;
  static const int maxUpgradeRentMultiplier = 10;

  // Taxes (reduced for shorter game)
  static const int incomeTax = 50;
  static const int writingTax = 30;
  static const double bankruptcyRiskMultiplier = 0.5;

  // Rewards
  static const int questionReward = 25;

  // Upgrade Costs
  static const double upgradeCostMultiplier = 0.5;
  static const double finalUpgradeCostMultiplier = 2.0;

  // Animation Durations (milliseconds)
  static const int hopAnimationDelay = 150;
  static const int cardAnimationDelay = 500;
  static const int diceAnimationDelay = 1500;
  static const int turnChangeDelay = 1200;
  static const int bankruptcyDialogDelay = 2000;
  static const int diceResetDelay = 150;

  // Card Timer (IMPORTANT: User requested 60 seconds for Şans/Kader)
  static const int cardTimerSeconds = 60;

  // Upgrade Levels
  static const int maxUpgradeLevel = 4;
  static const int finalUpgradeLevel = 3;

  // Assets
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
