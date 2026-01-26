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
  kiraathane, // Shop corner tile
}

enum QuestionCategory {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkimlari,
  edebiSanatlar,
  eserKarakter,
  bonusBilgiler,
}

enum CardType { sans, kader }

enum GamePhase { setup, rollingForOrder, playing, gameOver }

/// Player rank progression: None → Çırak → Kalfa → Usta
enum PlayerRank { none, cirak, kalfa, usta }

/// Question difficulty levels
enum Difficulty { easy, medium, hard }
