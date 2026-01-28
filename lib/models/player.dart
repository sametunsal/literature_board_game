import 'package:flutter/material.dart';
import 'difficulty.dart';
import 'game_enums.dart';

/// Mastery levels for categories
enum MasteryLevel { novice, cirak, kalfa, usta }

/// Extension to get display name for mastery level
extension MasteryLevelExtension on MasteryLevel {
  String get displayName {
    switch (this) {
      case MasteryLevel.novice:
        return 'Hiçbir Şey Bilmiyor';
      case MasteryLevel.cirak:
        return 'Çırak';
      case MasteryLevel.kalfa:
        return 'Kalfa';
      case MasteryLevel.usta:
        return 'Usta';
    }
  }

  int get value {
    switch (this) {
      case MasteryLevel.novice:
        return 0;
      case MasteryLevel.cirak:
        return 1;
      case MasteryLevel.kalfa:
        return 2;
      case MasteryLevel.usta:
        return 3;
    }
  }
}

/// Model representing a player in the Literature Quiz RPG game
class Player {
  /// Unique identifier for the player
  final String id;

  /// Player's display name
  final String name;

  /// Player's color on the board
  final Color color;

  /// Avatar icon index (1-20)
  final int iconIndex;

  /// Current position on the board (0-21)
  final int position;

  /// Whether player is in jail (library watch)
  final bool inJail;

  /// Number of turns to skip (library watch penalty turns remaining)
  final int turnsToSkip;

  /// Stars earned (currency for shop) - replaces Monopoly's "money"
  final int stars;

  /// List of quote IDs/texts collected by the player
  final List<String> collectedQuotes;

  /// Mastery levels for each category (0=Novice, 1=Çırak, 2=Kalfa, 3=Usta)
  final Map<String, int> categoryLevels;

  /// Progress tracking: correct answers per category per difficulty
  /// Structure: {categoryName: {difficultyName: count}}
  final Map<String, Map<String, int>> categoryProgress;

  /// Current title (Çaylak → Ehil)
  final String mainTitle;

  const Player({
    required this.id,
    required this.name,
    required this.color,
    required this.iconIndex,
    this.position = 0,
    this.inJail = false,
    this.turnsToSkip = 0,
    this.stars = 0,
    this.collectedQuotes = const [],
    this.categoryLevels = const {},
    this.categoryProgress = const {},
    this.mainTitle = 'Çaylak',
  });

  /// Add stars to the player's balance
  Player addStars(int amount) {
    return copyWith(stars: stars + amount);
  }

  /// Check if player has enough stars to make a purchase
  bool hasEnoughStars(int amount) {
    return stars >= amount;
  }

  /// Get the mastery level for a specific category
  MasteryLevel getMasteryLevel(String category) {
    final level = categoryLevels[category] ?? 0;
    return MasteryLevel.values[level.clamp(0, 3)];
  }

  /// Get the number of correct answers for a specific category and difficulty
  int getCorrectAnswerCount(String category, Difficulty difficulty) {
    return categoryProgress[category]?[difficulty.name] ?? 0;
  }

  /// Record a correct answer for a category and difficulty
  /// Returns the new count
  int recordCorrectAnswer(String category, Difficulty difficulty) {
    final newProgress = Map<String, Map<String, int>>.from(categoryProgress);
    if (!newProgress.containsKey(category)) {
      newProgress[category] = {};
    }
    final categoryMap = Map<String, int>.from(newProgress[category]!);
    categoryMap[difficulty.name] = (categoryMap[difficulty.name] ?? 0) + 1;
    newProgress[category] = categoryMap;
    return newProgress[category]![difficulty.name]!;
  }

  /// Check if player can promote to Çırak (3 Easy answers, currently Novice)
  bool canPromoteToCirak(String category) {
    final currentLevel = getMasteryLevel(category);
    if (currentLevel != MasteryLevel.novice) return false;
    final easyCount = getCorrectAnswerCount(category, Difficulty.easy);
    return easyCount >= 3;
  }

  /// Check if player can promote to Kalfa (3 Medium answers, currently Çırak)
  bool canPromoteToKalfa(String category) {
    final currentLevel = getMasteryLevel(category);
    if (currentLevel != MasteryLevel.cirak) return false;
    final mediumCount = getCorrectAnswerCount(category, Difficulty.medium);
    return mediumCount >= 3;
  }

  /// Check if player can promote to Usta (3 Hard answers, currently Kalfa)
  bool canPromoteToUsta(String category) {
    final currentLevel = getMasteryLevel(category);
    if (currentLevel != MasteryLevel.kalfa) return false;
    final hardCount = getCorrectAnswerCount(category, Difficulty.hard);
    return hardCount >= 3;
  }

  /// Promote player to next level in a category
  /// Returns the new mastery level
  MasteryLevel promoteInCategory(String category) {
    final currentLevel = getMasteryLevel(category);
    if (currentLevel == MasteryLevel.usta) return currentLevel;

    final newLevelValue = currentLevel.value + 1;
    final newLevels = Map<String, int>.from(categoryLevels);
    newLevels[category] = newLevelValue;

    return MasteryLevel.values[newLevelValue];
  }

  /// Get the reward multiplier based on the new mastery level
  /// Çırak = 1x, Kalfa = 2x, Usta = 3x
  int getRewardMultiplier(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.novice:
        return 0;
      case MasteryLevel.cirak:
        return 1;
      case MasteryLevel.kalfa:
        return 2;
      case MasteryLevel.usta:
        return 3;
    }
  }

  /// Collect a quote by adding it to the collected quotes list
  Player collectQuote(String quote) {
    if (hasCollectedQuote(quote)) {
      return this; // Already collected
    }
    final newQuotes = List<String>.from(collectedQuotes)..add(quote);
    return copyWith(collectedQuotes: newQuotes);
  }

  /// Check if player has collected a specific quote
  bool hasCollectedQuote(String quote) {
    return collectedQuotes.contains(quote);
  }

  /// Get the total number of quotes collected
  int getTotalCollectedQuotes() {
    return collectedQuotes.length;
  }

  /// Check if player is "Usta" in all 6 categories
  bool isUstaInAllCategories() {
    for (final category in QuestionCategory.values) {
      if (getMasteryLevel(category.name) != MasteryLevel.usta) {
        return false;
      }
    }
    return true;
  }

  /// Check if player has won the game
  /// Win condition: 50 quotes collected AND Usta in all 6 categories
  bool hasWon() {
    return getTotalCollectedQuotes() >= 50 && isUstaInAllCategories();
  }

  /// Check if player qualifies for Ehil title
  bool get isEhil => hasWon();

  /// Creates a copy of this player with optional new values
  Player copyWith({
    String? id,
    String? name,
    Color? color,
    int? iconIndex,
    int? position,
    bool? inJail,
    int? turnsToSkip,
    int? stars,
    List<String>? collectedQuotes,
    Map<String, int>? categoryLevels,
    Map<String, Map<String, int>>? categoryProgress,
    String? mainTitle,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      iconIndex: iconIndex ?? this.iconIndex,
      position: position ?? this.position,
      inJail: inJail ?? this.inJail,
      turnsToSkip: turnsToSkip ?? this.turnsToSkip,
      stars: stars ?? this.stars,
      collectedQuotes: collectedQuotes ?? this.collectedQuotes,
      categoryLevels: categoryLevels ?? this.categoryLevels,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      mainTitle: mainTitle ?? this.mainTitle,
    );
  }

  /// Creates a Player from JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(int.parse(json['color'] as String)),
      iconIndex: json['iconIndex'] as int,
      position: json['position'] as int? ?? 0,
      inJail: json['inJail'] as bool? ?? false,
      turnsToSkip: json['turnsToSkip'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
      collectedQuotes:
          (json['collectedQuotes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categoryLevels:
          (json['categoryLevels'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      categoryProgress:
          (json['categoryProgress'] as Map<String, dynamic>?)?.map(
            (catKey, catValue) => MapEntry(
              catKey,
              (catValue as Map<String, dynamic>).map(
                (diffKey, count) => MapEntry(diffKey, count as int),
              ),
            ),
          ) ??
          {},
      mainTitle: json['mainTitle'] as String? ?? 'Çaylak',
    );
  }

  /// Converts this Player to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value.toString(),
      'iconIndex': iconIndex,
      'position': position,
      'inJail': inJail,
      'turnsToSkip': turnsToSkip,
      'stars': stars,
      'collectedQuotes': collectedQuotes,
      'categoryLevels': categoryLevels,
      'categoryProgress': categoryProgress,
      'mainTitle': mainTitle,
    };
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
    return 'Player(id: $id, name: $name, position: $position, stars: $stars, quotes: ${collectedQuotes.length})';
  }
}
