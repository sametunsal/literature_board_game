/// Data Transfer Object for Player entity.
/// Used for JSON serialization and persistence.
/// Pure Dart - no Flutter dependencies.

class PlayerModel {
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

  PlayerModel({
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

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      stars: json['stars'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      collectedQuotes:
          (json['collectedQuotes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      inJail: json['inJail'] as bool? ?? false,
      iconIndex: json['iconIndex'] as int,
      turnsToSkip: json['turnsToSkip'] as int? ?? 0,
      categoryLevels:
          (json['categoryLevels'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
      mainTitle: json['mainTitle'] as String? ?? 'Çaylak',
      correctAnswers:
          (json['correctAnswers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stars': stars,
      'position': position,
      'collectedQuotes': collectedQuotes,
      'inJail': inJail,
      'iconIndex': iconIndex,
      'turnsToSkip': turnsToSkip,
      'categoryLevels': categoryLevels,
      'mainTitle': mainTitle,
      'correctAnswers': correctAnswers,
    };
  }

  PlayerModel copyWith({
    String? id,
    String? name,
    int? stars,
    int? position,
    List<String>? collectedQuotes,
    bool? inJail,
    int? iconIndex,
    int? turnsToSkip,
    Map<String, int>? categoryLevels,
    String? mainTitle,
    Map<String, int>? correctAnswers,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      stars: stars ?? this.stars,
      position: position ?? this.position,
      collectedQuotes: collectedQuotes ?? this.collectedQuotes,
      inJail: inJail ?? this.inJail,
      iconIndex: iconIndex ?? this.iconIndex,
      turnsToSkip: turnsToSkip ?? this.turnsToSkip,
      categoryLevels: categoryLevels ?? this.categoryLevels,
      mainTitle: mainTitle ?? this.mainTitle,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PlayerModel(id: $id, name: $name, stars: $stars, position: $position, '
        'collectedQuotesCount: ${collectedQuotes.length}, inJail: $inJail, iconIndex: $iconIndex, turnsToSkip: $turnsToSkip, '
        'categoryLevels: $categoryLevels, mainTitle: $mainTitle)';
  }
}
