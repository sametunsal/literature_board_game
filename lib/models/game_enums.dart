/// Game enums for the Literature Quiz RPG
/// This file contains all enum definitions used throughout the game

/// Question categories for the Literature Quiz RPG
enum QuestionCategory {
  benKimim,
  turkEdebiyatindaIlkler,
  edebiyatAkimlari,
  edebiSanatlar,
  eserKarakter,
  tesvik,
}

/// Extension to get display name for QuestionCategory
extension QuestionCategoryExtension on QuestionCategory {
  String get displayName {
    switch (this) {
      case QuestionCategory.benKimim:
        return 'Ben Kimim?';
      case QuestionCategory.turkEdebiyatindaIlkler:
        return 'Türk Edebiyatında İlkler';
      case QuestionCategory.edebiyatAkimlari:
        return 'Edebiyat Akımları';
      case QuestionCategory.edebiSanatlar:
        return 'Edebi Sanatlar';
      case QuestionCategory.eserKarakter:
        return 'Eser-Karakter';
      case QuestionCategory.tesvik:
        return 'Teşvik';
    }
  }
}

/// Game phases for state management
enum GamePhase {
  setup,
  rollingForOrder,
  playerTurn,
  questionPhase,
  cardPhase,
  movementPhase,
  gameOver,
}

/// Card types for Şans (Chance) and Kader (Fate) cards
enum CardType {
  sans, // Chance
  kader, // Fate
}

/// Extension to get display name for CardType
extension CardTypeExtension on CardType {
  String get displayName {
    switch (this) {
      case CardType.sans:
        return 'Şans';
      case CardType.kader:
        return 'Kader';
    }
  }
}
