import 'package:flutter/material.dart';
import 'game_enums.dart';

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

  /// Category levels - tracks level (0-3) for each of the 6 categories
  /// 0 = Novice, 1 = Apprentice, 2 = Journeyman, 3 = Master
  final Map<String, int> categoryLevels;

  /// Current title (Çaylak → Ehil)
  final String mainTitle;

  /// Correct answers per category for promotion tracking
  final Map<String, int> correctAnswers;

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
    this.mainTitle = 'Çaylak',
    this.correctAnswers = const {},
  });

  /// Add stars to the player's balance
  Player addStars(int amount) {
    return copyWith(stars: stars + amount);
  }

  /// Check if player has enough stars to make a purchase
  bool hasEnoughStars(int amount) {
    return stars >= amount;
  }

  /// Increase the level for a specific category
  Player increaseCategoryLevel(String category) {
    final currentLevel = categoryLevels[category] ?? 0;
    if (currentLevel >= 3) {
      return this; // Already at max level
    }
    final newLevels = Map<String, int>.from(categoryLevels);
    newLevels[category] = currentLevel + 1;
    return copyWith(categoryLevels: newLevels);
  }

  /// Get the rank name for a specific category
  /// Returns: "Novice", "Apprentice", "Journeyman", "Master"
  String getCategoryLevel(String category) {
    final level = categoryLevels[category] ?? 0;
    switch (level) {
      case 0:
        return 'Novice';
      case 1:
        return 'Apprentice';
      case 2:
        return 'Journeyman';
      case 3:
        return 'Master';
      default:
        return 'Novice';
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

  /// Check if player is "Master" in all 6 categories
  bool isMasterInAllCategories() {
    for (final category in QuestionCategory.values) {
      if ((categoryLevels[category.name] ?? 0) < 3) {
        return false;
      }
    }
    return true;
  }

  /// Check if player has won the game
  /// Win condition: 50 quotes collected AND Master in all 6 categories
  bool hasWon() {
    return getTotalCollectedQuotes() >= 50 && isMasterInAllCategories();
  }

  /// Get rank level for a specific category (0=none, 1=cirak, 2=kalfa, 3=usta)
  /// @deprecated Use getCategoryLevel() instead for English names
  int getLevelForCategory(QuestionCategory category) {
    return categoryLevels[category.name] ?? 0;
  }

  /// Check if player is master (Level 3) in all categories
  /// @deprecated Use isMasterInAllCategories() instead
  bool get isUstaInAllCategories {
    return isMasterInAllCategories();
  }

  /// Check if player qualifies for Ehil title
  /// @deprecated Use hasWon() instead
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
    String? mainTitle,
    Map<String, int>? correctAnswers,
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
      mainTitle: mainTitle ?? this.mainTitle,
      correctAnswers: correctAnswers ?? this.correctAnswers,
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
      mainTitle: json['mainTitle'] as String? ?? 'Çaylak',
      correctAnswers:
          (json['correctAnswers'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
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
      'mainTitle': mainTitle,
      'correctAnswers': correctAnswers,
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
    return 'Player(id: $id, name: $name, stars: $stars, position: $position, '
        'collectedQuotesCount: ${collectedQuotes.length}, inJail: $inJail, turnsToSkip: $turnsToSkip, '
        'categoryLevels: $categoryLevels, mainTitle: $mainTitle)';
  }
}
