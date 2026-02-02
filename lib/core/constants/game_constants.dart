import 'package:flutter/material.dart';

/// Game constants for Literature Quiz RPG game.
/// Centralizes all magic numbers and game rules.
class GameConstants {
  GameConstants._();

  // ═══════════════════════════════════════════════════════════════
  // BOARD CONFIGURATION (RPG Style: 26 tiles - 7-6-7-6 SPLIT)
  // ═══════════════════════════════════════════════════════════════
  static const int boardSize = 26;
  static const int startPosition = 0;

  // Corner Positions (7-6-7-6 split: indices 0, 7, 13, 20)
  static const int signingDayPosition =
      7; // İMZA GÜNÜ (Bottom-Left corner) - CORNER 1
  static const int shopPosition = 13; // KIRAATHANE (Top-Left corner) - CORNER 2
  static const int libraryPosition =
      20; // KÜTÜPHANE (Top-Right corner) - CORNER 3

  // Special Tile Positions (Şans and Kader)
  static const int chancePosition1 = 3; // ŞANS (Bottom edge)
  static const int chancePosition2 = 16; // ŞANS (Top edge)
  static const int fatePosition1 = 10; // KADER (Left edge)
  static const int fatePosition2 = 22; // KADER (Right edge)

  // ═══════════════════════════════════════════════════════════════
  // PENALTY SYSTEM (Library Watch)
  // ═══════════════════════════════════════════════════════════════
  static const int jailPosition = 20; // KÜTÜPHANE (Library)
  static const int jailTurns = 2; // 2 turns suspension penalty

  // ═══════════════════════════════════════════════════════════════════
  // MIKRO EKONOMİ (Start-from-Zero Balance)
  // ═══════════════════════════════════════════════════════════════════

  // Starting Balance
  static const int initialStars = 0; // Players start with nothing

  // Question Rewards (based on difficulty)
  static const int rewardEasy = 3; // REWARD_EASY - Motivasyon için en az 3
  static const int rewardMedium = 5; // REWARD_MEDIUM
  static const int rewardHard = 8; // REWARD_HARD
  static const int rewardTesvik = 10; // REWARD_TESVIK - Bonus sorular değerli olmalı

  // Penalties & Costs
  static const int hintCost = 1; // HINT_COST - Ucuz olsun ki kullanılsın
  static const int wrongAnswerPenalty = 0; // WRONG_ANSWER_PENALTY - 0 puandayken eksiye düşürme
  static const int jailFee = 5; // JAIL_FEE - Hapisten çıkma bedeli

  // ═══════════════════════════════════════════════════════════════════
  // GAME RULES
  // ═══════════════════════════════════════════════════════════════════
  static const int passingStartBonus = 5; // Stars awarded when passing start (reduced from 50)
  static const int maxConsecutiveDoubles = 3; // Maximum doubles before penalty

  // ═════════════════════════════════════════════════════════════════════
  // DICE CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════
  static const int diceMinRoll = 2;
  static const int diceMaxRoll = 12;

  // ═══════════════════════════════════════════════════════════════════════
  // MASTERY SYSTEM (Literature Quiz RPG)
  // ═══════════════════════════════════════════════════════════════════════
  // Mastery System: 4 levels per category
  // Level 0: Novice (Hiçbir Şey Bilmiyor)
  // Level 1: Çırak (Apprentice) - Requires 3 Easy correct answers
  // Level 2: Kalfa (Journeyman) - Requires 3 Medium correct answers (must be Çırak)
  // Level 3: Usta (Master) - Requires 3 Hard correct answers (must be Kalfa)

  // Correct answers required for each promotion
  static const int answersRequiredForPromotion = 3;

  // Star Rewards for correct answers based on tile difficulty
  static const int easyStarReward = 5; // Stars per correct easy answer
  static const int mediumStarReward = 10; // Stars per correct medium answer
  static const int hardStarReward = 15; // Stars per correct hard answer

  // Promotion rewards (multiplier based on new rank)
  // Çırak = 1x, Kalfa = 2x, Usta = 3x
  static const int promotionBaseReward = 10; // Base stars for promotion

  // Maximum level per category
  static const int maxLevelPerCategory = 3; // Maximum level (Usta)

  // ═══════════════════════════════════════════════════════════════════
  // WIN CONDITION (Sprint Mode - ~15 min games)
  // ═════════════════════════════════════════════════════════════════════
  // Player wins when they have collected X quotes AND are Master in Y categories
  static const int quotesToCollect = 20; // Total quotes needed to win (reduced from 50)
  static const int requiredMasteries = 3; // Number of categories to master (reduced from 6)
  static const int totalCategories = 6; // Total number of categories

  // ═══════════════════════════════════════════════════════════════════
  // CATCH-UP MECHANIC (Underdog Bonus)
  // ═══════════════════════════════════════════════════════════════════
  static const double underdogThreshold = 0.5; // Player gets bonus if stars < leader * threshold
  static const int underdogBonusStars = 3; // Fixed bonus for underdog
  static const double underdogMultiplier = 1.5; // Reward multiplier for underdog

  // ═══════════════════════════════════════════════════════════════════
  // QUOTE DROP RATE (Progression Bonus)
  // ═══════════════════════════════════════════════════════════════════
  static const double hardQuestionQuoteDropRate = 0.3; // 30% chance to get quote on Hard correct

  // ═══════════════════════════════════════════════════════════════════
  // TIMERS (in seconds)
  // ═══════════════════════════════════════════════════════════════════════════
  static const int questionTimerSeconds = 45; // Standard category tiles
  static const int chanceCardTimerSeconds =
      60; // Extended for Chance/Fate cards
  static const int cardTimerSeconds = 60; // Şans/Kader card timer

  // ═══════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS (milliseconds)
  // ═══════════════════════════════════════════════════════════════════════════════════
  static const int hopAnimationDelay = 150;
  static const int cardAnimationDelay = 500;
  static const int diceAnimationDelay = 1500;
  static const int turnChangeDelay = 1200;
  static const int diceResetDelay = 150;

  // ═════════════════════════════════════════════════════════════════════════════════
  // ASSETS
  // ═════════════════════════════════════════════════════════════════════════════════════════════
  static const int totalAvatars = 20;

  /// Available icons for player selection (Replaces legacy assets)
  static const List<IconData> iconPalette = [
    Icons.person,
    Icons.face,
    Icons.pets,
    Icons.emoji_people,
    Icons.accessibility_new,
    Icons.child_care,
    Icons.person_pin,
    Icons.directions_run,
    Icons.school, // Added for variety
    Icons.sports_esports, // Added for variety
  ];

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
