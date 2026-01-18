/// Game constants for the literature board game.
/// Centralizes all magic numbers and game rules.
class GameConstants {
  GameConstants._();

  // Board Configuration
  static const int boardSize = 40;
  static const int startPosition = 0;

  // Jail/Prison
  static const int jailPosition = 10;
  static const int jailTurns = 2;

  // Game Rules
  static const int passingStartBonus = 200;
  static const int maxConsecutiveDoubles = 3;
  static const int defaultPropertyPrice = 100;

  // Dice
  static const int diceMinRoll = 2;
  static const int diceMaxRoll = 12;

  // Rent Multipliers
  static const int utilityRentMultiplier = 15;
  static const int maxUpgradeRentMultiplier = 10; // Cilt/Hotel gives 10x rent

  // Taxes
  static const int incomeTax = 200;
  static const int writingTax = 150;
  static const double bankruptcyRiskMultiplier = 0.5; // Half balance lost

  // Rewards
  static const int questionReward = 50;

  // Upgrade Costs
  static const double upgradeCostMultiplier = 0.5; // Half of property price
  static const double finalUpgradeCostMultiplier =
      2.0; // 2x of property price for Cilt

  // Animation Durations (milliseconds)
  static const int hopAnimationDelay = 150;
  static const int cardAnimationDelay = 500;
  static const int diceAnimationDelay = 1500;
  static const int turnChangeDelay = 1200;
  static const int bankruptcyDialogDelay = 2000;
  static const int diceResetDelay =
      150; // Additional delay after dice animation

  // Upgrade Levels
  static const int maxUpgradeLevel = 4; // 0: none, 1-3: upgrades, 4: Cilt
  static const int finalUpgradeLevel = 3; // Level before Cilt
  // Assets
  static const int totalAvatars = 20;
  static String getAvatarPath(int index) =>
      'assets/images/avatar_${(index + 1).toString().padLeft(2, '0')}.png';
}
