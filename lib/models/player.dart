import 'package:flutter/material.dart';
import 'game_enums.dart';

class Player {
  final String id;
  final String name;
  final int position;
  final bool inJail;
  final Color color;
  final int iconIndex;
  final int turnsToSkip; // Library watch penalty turns remaining

  // RPG Progression Fields
  final int stars; // Currency for shop
  final List<String> collectedQuotes; // Owned quote IDs/texts
  final Map<String, int> categoryLevels; // Level index per category (0-3)
  final String mainTitle; // Current title (Çaylak → Ehil)
  final Map<String, int> correctAnswers; // Correct answers per category

  const Player({
    required this.id,
    required this.name,
    required this.color,
    required this.iconIndex,
    this.position = 0,
    this.inJail = false,
    this.turnsToSkip = 0,
    // RPG defaults
    this.stars = 0,
    this.collectedQuotes = const [],
    this.categoryLevels = const {},
    this.mainTitle = 'Çaylak',
    this.correctAnswers = const {},
  });

  /// Get rank level for a specific category (0=none, 1=cirak, 2=kalfa, 3=usta)
  int getLevelForCategory(QuestionCategory category) {
    return categoryLevels[category.name] ?? 0;
  }

  /// Check if player is master (Level 3) in all categories
  bool get isUstaInAllCategories {
    for (final category in QuestionCategory.values) {
      if (getLevelForCategory(category) < 3) {
        return false;
      }
    }
    return true;
  }

  /// Check if player qualifies for Ehil title
  bool get isEhil => isUstaInAllCategories && collectedQuotes.length >= 50;

  Player copyWith({
    String? name,
    Color? color,
    int? iconIndex,
    int? position,
    bool? inJail,
    int? turnsToSkip,
    int? stars,
    List<String>? collectedQuotes,
    Map<String, int>? categoryLevels,
    String? mainTitle,
    Map<String, int>? correctAnswers,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      iconIndex: iconIndex ?? this.iconIndex,
      position: position ?? this.position,
      inJail: inJail ?? this.inJail,
      turnsToSkip: turnsToSkip ?? this.turnsToSkip,
      stars: stars ?? this.stars,
      collectedQuotes: collectedQuotes ?? this.collectedQuotes,
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
}
