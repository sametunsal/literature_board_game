import 'package:flutter/material.dart';

/// Game constants for Literature Board Game
///
/// This file contains all of magic numbers and configuration values
/// used throughout the application to improve maintainability.

class GameConstants {
  // Board configuration
  static const int boardSize = 40;
  static const int passStartReward = 50;
  static const int initialStars = 150;
  static const int libraryWatchTurns = 2;
  static const int maxDoubleDice = 3;
  static const int bankruptcyThreshold = 0;

  // Tile dimensions
  static const double tileWidth = 100.0;
  static const double tileHeight = 120.0;
  static const double tileSpacing = 8.0;
  static const double tileRunSpacing = 8.0;

  // Player token dimensions
  static const double tokenSize = 32.0;
  static const double tokenBorderWidth = 2.0;
  static const double tokenShadowBlur = 4.0;
  static const double tokenShadowOffset = 2.0;

  // Token stacking offset
  static const double tokenStackOffset = 12.0;
  static const double tokenStackTopOffset = -8.0;
  static const double tokenStackRightOffset = -8.0;

  // Animation configuration
  static const Duration animationDuration = Duration(milliseconds: 600);
  static const Curve animationCurve = Curves.easeInOut;

  // Tile colors
  static const double tileBorderWidthNormal = 1.0;
  static const double tileBorderWidthActive = 3.0;
  static const double tileBorderRadius = 8.0;
  static const double tileElevationNormal = 1.0;
  static const double tileElevationActive = 4.0;
  static const double tilePadding = 8.0;

  // Shadow configuration
  static const double activeTileShadowBlur = 8.0;
  static const double activeTileShadowSpread = 2.0;
  static const double activeTileShadowOpacity = 0.4;

  // Text configuration
  static const double tileNumberFontSize = 14.0;
  static const double tileNameFontSize = 9.0;
  static const double diceRollFontSize = 10.0;
  static const double tokenTextFontSize = 10.0;

  // Spacing
  static const double smallSpacing = 4.0;
  static const double mediumSpacing = 8.0;

  // Log configuration
  static const int maxLogMessages = 50;

  // Tax configuration
  static const int incomeTaxRate = 10;
  static const int incomeTaxMin = 20;
  static const int authorTaxRate = 15;
  static const int authorTaxMin = 30;

  // Bankruptcy loss percentage
  static const double bankruptcyLossPercentage = 0.5;

  // START tile passing threshold
  static const int startPassThresholdOld = 35;
  static const int startPassThresholdNew = 5;

  // Question answering configuration
  static const int questionTimerDuration = 30; // seconds to answer
  static const int wrongAnswerPenalty = 10; // stars penalty for wrong answer
}

/// Tile type colors
class TileColors {
  static const Color corner = Color(0xFFFFCC80); // orange.shade100
  static const Color book = Color(0xFF82B1FF); // blueAccent.shade100
  static const Color publisher = Color(0xFF90EE90); // green.shade100
  static const Color chance = Color(0xFFE1BEE7); // purple.shade100
  static const Color fate = Color(0xFFFF8A80); // redAccent.shade100
  static const Color tax = Color(0xFFE0E0E0); // grey.shade200
  static const Color special = Color(0xFFB2DFDB); // teal.shade100
  static const Color activeHighlight = Color(0xFFFFF9C4); // yellow.shade200
  static const Color activeBorder = Color(0xFFFBC02D); // yellow.shade700
  static const Color normalBorder = Color(0xFF8D6E63); // brown.shade400
  static const Color boardBackground = Color(0xFFDFE4E4); // brown.shade50
  static const Color boardBorder = Color(0xFFA1887F); // brown.shade300
}

/// Text styles
class TextStyles {
  static const FontWeight bold = FontWeight.bold;
  static const FontWeight medium = FontWeight.w500;
  static const Color tileNumberColor = Color(0xFF3E2723); // brown.shade900
  static const Color tileNameColor = Color(0xFF5D4037); // brown.shade800
  static const Color diceRollColor = Color(0xFF7B1FA2); // purple.shade800
  static const Color tokenTextColor = Colors.white;
}
