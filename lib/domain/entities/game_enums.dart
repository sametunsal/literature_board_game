/// Domain enums for the literature board game.
/// Pure Dart - no Flutter dependencies.

enum TileType {
  start,
  property,
  publisher,
  chance,
  fate,
  libraryWatch,
  autographDay,
  bankruptcyRisk,
  writingSchool,
  educationFoundation,
  incomeTax,
  writingTax,
}

enum QuestionCategory {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkimlari,
  edebiyatSanatlari,
  eserKarakter,
}

enum CardType { sans, kader }

enum GamePhase { setup, rollingForOrder, playing, gameOver }

/// Color group identifiers for Monopoly-style property grouping
enum PropertyColorGroup {
  brown, // Group 1: Near Start
  lightBlue, // Group 2
  pink, // Group 3
  orange, // Group 4
  red, // Group 5
  yellow, // Group 6
  green, // Group 7
  blue, // Group 8: Most expensive
  utility, // Publishers, Schools, Foundations
  special, // Corners, Tax, Cards
}
