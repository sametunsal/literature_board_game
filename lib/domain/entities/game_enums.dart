/// Domain enums for the literature board game.
/// Pure Dart - no Flutter dependencies.

enum TileType {
  start,
  property,
  chance,
  fate,
  kiraathane, // Shop corner tile
}

/// Question categories in specified order (each appears 3x on board)
enum QuestionCategory {
  turkEdebiyatindaIlkler, // 1st - "Türk Edebiyatında İlkler"
  edebiSanatlar, // 2nd - "Edebi Sanatlar"
  eserKarakter, // 3rd - "Eser-Karakter"
  edebiyatAkimlari, // 4th - "Edebiyat Akımları"
  benKimim, // 5th - "Ben Kimim?"
  tesvik, // 6th - "Teşvik"
}

enum CardType { sans, kader }

enum GamePhase { setup, rollingForOrder, playing, gameOver }

/// Player rank progression: None → Çırak → Kalfa → Usta
enum PlayerRank { none, cirak, kalfa, usta }

/// Question difficulty levels
enum Difficulty { easy, medium, hard }
