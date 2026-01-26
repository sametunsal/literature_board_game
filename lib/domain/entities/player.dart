/// Domain entity representing a player in the game.
/// Pure Dart - no Flutter dependencies.

import 'game_enums.dart';

class Player {
  final String id;
  final String name;
  final int balance;
  final int position;
  final List<int> ownedTiles;
  final bool inJail;
  final int iconIndex;
  final int turnsToSkip; // Library watch penalty turns remaining

  // RPG Progression Fields
  final int stars; // Currency for shop
  final List<String> inventory; // Owned quote IDs
  final Map<String, PlayerRank> categoryProgress; // Rank per category
  final String mainTitle; // Current title (Çaylak → Ehil)
  final Map<String, int>
  correctAnswers; // Correct answers per category for promotion

  const Player({
    required this.id,
    required this.name,
    required this.iconIndex,
    this.balance = 2500,
    this.position = 0,
    this.ownedTiles = const [],
    this.inJail = false,
    this.turnsToSkip = 0,
    // RPG defaults
    this.stars = 0,
    this.inventory = const [],
    this.categoryProgress = const {},
    this.mainTitle = 'Çaylak',
    this.correctAnswers = const {},
  });

  /// Get rank for a specific category (defaults to none)
  PlayerRank getRankForCategory(QuestionCategory category) {
    return categoryProgress[category.name] ?? PlayerRank.none;
  }

  /// Check if player is master (Usta) in all categories
  bool get isUstaInAllCategories {
    for (final category in QuestionCategory.values) {
      if (getRankForCategory(category) != PlayerRank.usta) {
        return false;
      }
    }
    return true;
  }

  /// Check if player qualifies for Ehil title
  bool get isEhil => isUstaInAllCategories && inventory.length >= 50;

  Player copyWith({
    String? name,
    int? iconIndex,
    int? balance,
    int? position,
    List<int>? ownedTiles,
    bool? inJail,
    int? turnsToSkip,
    int? stars,
    List<String>? inventory,
    Map<String, PlayerRank>? categoryProgress,
    String? mainTitle,
    Map<String, int>? correctAnswers,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      iconIndex: iconIndex ?? this.iconIndex,
      balance: balance ?? this.balance,
      position: position ?? this.position,
      ownedTiles: ownedTiles ?? this.ownedTiles,
      inJail: inJail ?? this.inJail,
      turnsToSkip: turnsToSkip ?? this.turnsToSkip,
      stars: stars ?? this.stars,
      inventory: inventory ?? this.inventory,
      categoryProgress: categoryProgress ?? this.categoryProgress,
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
    return 'Player(id: $id, name: $name, balance: $balance, position: $position, '
        'ownedTiles: $ownedTiles, inJail: $inJail, turnsToSkip: $turnsToSkip, '
        'stars: $stars, mainTitle: $mainTitle)';
  }
}
