/// Domain entity representing a player in the game.
/// Pure Dart - no Flutter dependencies.

import 'game_enums.dart';

class Player {
  final String id;
  final String name;
  final int stars;
  final int position;
  final List<String> collectedQuotes;
  final bool inJail;
  final int iconIndex;
  final int turnsToSkip; // Library watch penalty turns remaining

  // RPG Progression Fields
  final Map<String, int>
  categoryLevels; // 0=Novice, 1=Apprentice, 2=Journeyman, 3=Master
  final String mainTitle; // Current title (Çaylak → Ehil)
  final Map<String, int>
  correctAnswers; // Correct answers per category for promotion

  const Player({
    required this.id,
    required this.name,
    required this.iconIndex,
    this.stars = 0,
    this.position = 0,
    this.collectedQuotes = const [],
    this.inJail = false,
    this.turnsToSkip = 0,
    this.categoryLevels = const {},
    this.mainTitle = 'Çaylak',
    this.correctAnswers = const {},
  });

  /// Get rank for a specific category
  int getLevelForCategory(QuestionCategory category) {
    return categoryLevels[category.name] ?? 0;
  }

  /// Check if player is master (Master = 3) in all categories
  bool get isMasterInAllCategories {
    for (final category in QuestionCategory.values) {
      if (getLevelForCategory(category) < 3) {
        return false;
      }
    }
    return true;
  }

  /// Check if player qualifies for Ehil title
  /// Check if player qualifies for Ehil title
  bool get isEhil => isMasterInAllCategories && collectedQuotes.length >= 50;

  Player copyWith({
    String? name,
    int? iconIndex,
    int? stars,
    int? position,
    List<String>? collectedQuotes,
    bool? inJail,
    int? turnsToSkip,
    Map<String, int>? categoryLevels,
    String? mainTitle,
    Map<String, int>? correctAnswers,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      iconIndex: iconIndex ?? this.iconIndex,
      stars: stars ?? this.stars,
      position: position ?? this.position,
      collectedQuotes: collectedQuotes ?? this.collectedQuotes,
      inJail: inJail ?? this.inJail,
      turnsToSkip: turnsToSkip ?? this.turnsToSkip,
      categoryLevels: categoryLevels ?? this.categoryLevels,
      mainTitle: mainTitle ?? this.mainTitle,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Player(id: $id, name: $name, stars: $stars, position: $position, '
        'collectedQuotesCount: ${collectedQuotes.length}, inJail: $inJail, turnsToSkip: $turnsToSkip, '
        'categoryLevels: $categoryLevels, mainTitle: $mainTitle)';
  }
}
